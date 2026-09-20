#!/usr/bin/env bash
#
# Single verification oracle (ADR-0016): one entry point for the maintainer,
# the agent mid-loop and CI. Modes and arguments: see usage() below.
#
# Only add a check that no purpose-built tool covers: hadolint,
# container-structure-test and commitlint own their verdicts, this script
# calls them (ADR-0016).
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

HADOLINT_IMAGE="hadolint/hadolint:2.12.0-alpine"
CST_IMAGE="gcr.io/gcp-runtimes/container-structure-test:v1.16.0"
IMAGE_NAME="bgauduch/terraform-aws-cli"
# published architectures (ADR-0019); the publishing workflows carry the
# composed literal, asserted against this list by check_platform_lines
PLATFORM_ARCHS=(amd64 arm64)
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+$'
RELEASE_RE='^v[0-9]+\.[0-9]+\.[0-9]+$'
HUB_API="https://hub.docker.com/v2/repositories/${IMAGE_NAME}"

FAIL=0
pass() { printf 'PASS %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*" >&2; FAIL=1; }
skip() { printf 'SKIP %s\n' "$*"; }
die()  { printf 'validate: %s\n' "$*" >&2; exit 2; }

usage() {
  cat >&2 <<'USAGE'
usage: validate.sh --fast
       validate.sh --full [AWS_CLI_VERSION] [TERRAFORM_VERSION] [IMAGE_TAG]
       validate.sh --assert-image IMAGE_REF [AWS_CLI_VERSION] [TERRAFORM_VERSION]
       validate.sh --published RELEASE_VERSION
       validate.sh --render-tests [AWS_CLI_VERSION] [TERRAFORM_VERSION]
       validate.sh --latest AXIS
       validate.sh --matrix [--with-arch]

Checks, by what they verify and what they cost:
  --fast          the working tree, structurally: no Docker, seconds.
  --full          the image: the fast checks, then containerized hadolint, a
                  single-platform build and container-structure-test (Docker,
                  minutes). Versions default to the latest in
                  supported_versions.json; the tag defaults to "dev".
  --assert-image  the shipped artefact: pull IMAGE_REF (a tag or an untagged
                  repo@digest) per published architecture and run the
                  structure tests against it (Docker + QEMU). Run by the
                  publishers before any tag moves (ADR-0022).
  --published     the registry, for a release (vX.Y.Z): network only, no
                  Docker and no credentials. Called by release-please.yml; run
                  it by hand to re-check a release that has just been
                  published.

Machine outputs (ADR-0016):
  --render-tests  render tests/container-structure-tests.yml from its
                  template; called by --full and by build-test.yml.
  --latest        print the newest version of AXIS (tf_versions or
                  awscli_versions), semver-sorted; called by the publishing
                  workflows.
  --matrix        print supported_versions.json as a compact build matrix;
                  --with-arch adds the published architectures. Called by
                  build-test.yml and release-please.yml.
USAGE
  exit 2
}

# ---------------------------------------------------------------------------
# Helpers shared across modes.
# ---------------------------------------------------------------------------

# Latest version of an axis in supported_versions.json, semver-sorted.
latest_version() {
  jq -r --arg axis "$1" \
    '.[$axis] | sort_by(split(".") | map(tonumber)) | .[-1]' supported_versions.json
}

# The version this repository currently declares as released.
current_release() {
  jq -r '.["."]' .release-please-manifest.json
}

host_platform() {
  case "$(uname -m)" in
    x86_64)          printf 'linux/amd64' ;;
    aarch64 | arm64) printf 'linux/arm64' ;;
    *) die "unsupported host architecture: $(uname -m)" ;;
  esac
}

# container-structure-test ships amd64-only; request it explicitly so
# arm64 hosts emulate silently
cst_test() {
  docker container run --rm \
    --platform linux/amd64 \
    --volume "${PWD}"/tests/container-structure-tests.yml:/tests.yml:ro \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    "$CST_IMAGE" test \
    --image "$1" \
    --config /tests.yml
}

# ---------------------------------------------------------------------------
# Structural check: supported_versions.json <-> security/
# Every supported version has its signature material; no orphan material for
# versions that are no longer supported (sunset, ADR-0015).
# ---------------------------------------------------------------------------
check_versions_security() {
  local ok=1 v f
  for v in $(jq -r '.tf_versions[]' supported_versions.json); do
    for f in "security/terraform_${v}_SHA256SUMS" "security/terraform_${v}_SHA256SUMS.sig"; do
      [ -f "$f" ] || { fail "missing ${f} for supported Terraform ${v}"; ok=0; }
    done
  done
  for v in $(jq -r '.awscli_versions[]' supported_versions.json); do
    for a in x86_64 aarch64; do
      f="security/awscli-exe-linux-${a}-${v}.zip.sig"
      [ -f "$f" ] || { fail "missing ${f} for supported AWS CLI ${v}"; ok=0; }
    done
  done
  for f in security/terraform_*_SHA256SUMS; do
    [ -e "$f" ] || continue
    v="${f#security/terraform_}"; v="${v%_SHA256SUMS}"
    jq -e --arg v "$v" '.tf_versions | index($v)' supported_versions.json >/dev/null \
      || { fail "orphan ${f}: Terraform ${v} is not in supported_versions.json"; ok=0; }
  done
  for f in security/awscli-exe-linux-*.zip.sig; do
    [ -e "$f" ] || continue
    v="${f#security/awscli-exe-linux-}"; v="${v#*-}"; v="${v%.zip.sig}"
    jq -e --arg v "$v" '.awscli_versions | index($v)' supported_versions.json >/dev/null \
      || { fail "orphan ${f}: AWS CLI ${v} is not in supported_versions.json"; ok=0; }
  done
  [ "$ok" = 1 ] && pass "supported_versions.json <-> security/ consistent"
}

# ---------------------------------------------------------------------------
# Structural check: ADR files <-> index (docs/adr/README.md)
# ---------------------------------------------------------------------------
check_adr_index() {
  local ok=1 f n
  for f in docs/adr/[0-9]*.md; do
    n="${f#docs/adr/}"
    [ "${n%%-*}" = "0000" ] && continue
    grep -qF "(${n})" docs/adr/README.md \
      || { fail "ADR ${n} missing from the docs/adr/README.md index"; ok=0; }
  done
  while IFS= read -r n; do
    [ -f "docs/adr/${n}" ] || { fail "index references missing docs/adr/${n}"; ok=0; }
  done < <(grep -oE '\]\([0-9]{4}-[^)]+\.md\)' docs/adr/README.md | sed 's/^](//; s/)$//' | sort -u)
  [ "$ok" = 1 ] && pass "ADR files <-> index consistent"
}

# ---------------------------------------------------------------------------
# Structural check: hadolint via local binary when present (CI gate:
# lint-dockerfile.yml; --full runs the pinned container instead)
# ---------------------------------------------------------------------------
check_hadolint_local() {
  if command -v hadolint >/dev/null 2>&1; then
    if hadolint --config hadolint.yaml Dockerfile; then
      pass "hadolint"
    else
      fail "hadolint reported issues"
    fi
  else
    skip "hadolint not installed (CI gate: lint-dockerfile.yml; --full runs it in Docker)"
  fi
}

# ---------------------------------------------------------------------------
# Structural check: the platform declarations agree (ADR-0019).
# Lines carrying an expression (build-test composes linux/<arch> per job)
# are skipped. An assertion, not a shared constant (#174).
# ---------------------------------------------------------------------------
check_platform_lines() {
  local expected line f ok=1 found=0
  expected="$(printf 'linux/%s,' "${PLATFORM_ARCHS[@]}")"
  expected="${expected%,}"
  for f in .github/workflows/*.yml; do
    while IFS= read -r line; do
      case "$line" in *'${{'*) continue ;; esac
      found=$((found + 1))
      [ "$line" = "$expected" ] \
        || { fail "${f} declares platforms '${line}', expected '${expected}'"; ok=0; }
    done < <(grep -E '^[[:space:]]*platforms:' "$f" | sed -E 's/^[[:space:]]*platforms:[[:space:]]*//')
  done
  [ "$found" -gt 0 ] || { fail "no literal platforms: line found under .github/workflows/"; ok=0; }
  [ "$ok" = 1 ] && pass "platform declarations agree (${found} literal lines = ${expected})"
}

# ---------------------------------------------------------------------------
# Structural check: the published image name agrees across its three real
# registry references (build-test's IMAGE_NAME is a runner-local tag and is
# deliberately not one of them).
# ---------------------------------------------------------------------------
check_image_name() {
  local ok=1 org name
  grep -q -- "--tag ${IMAGE_NAME}:edge" .github/workflows/push-edge.yml \
    || { fail "push-edge.yml does not tag ${IMAGE_NAME}:edge"; ok=0; }
  grep -q "repository: ${IMAGE_NAME}$" .github/workflows/dockerhub-description-update.yml \
    || { fail "dockerhub-description-update.yml does not target ${IMAGE_NAME}"; ok=0; }
  org="$(sed -n 's/^[[:space:]]*ORGANIZATION: "\(.*\)"$/\1/p' .github/workflows/release-please.yml)"
  name="$(sed -n 's/^[[:space:]]*IMAGE_NAME: "\(.*\)"$/\1/p' .github/workflows/release-please.yml)"
  [ "${org}/${name}" = "$IMAGE_NAME" ] \
    || { fail "release-please.yml publishes ${org}/${name}, expected ${IMAGE_NAME}"; ok=0; }
  [ "$ok" = 1 ] && pass "published image name agrees across the registry references"
}

run_fast() {
  check_versions_security
  check_adr_index
  check_platform_lines
  check_image_name
  check_hadolint_local
}

# ---------------------------------------------------------------------------
# Image check (--full): the structural checks, then containerized hadolint, a
# single-platform build and container-structure-test. Tool images stay pinned.
# ---------------------------------------------------------------------------

run_full() {
  local aws_version tf_version image_tag platform
  aws_version="${1:-$(latest_version awscli_versions)}"
  tf_version="${2:-$(latest_version tf_versions)}"
  image_tag="${3:-dev}"
  [[ "$aws_version" =~ $SEMVER_RE ]] || die "AWS_CLI_VERSION '${aws_version}' is not a semver (X.Y.Z)"
  [[ "$tf_version" =~ $SEMVER_RE ]] || die "TERRAFORM_VERSION '${tf_version}' is not a semver (X.Y.Z)"
  platform="$(host_platform)"

  run_fast
  [ "$FAIL" = 0 ] || { printf 'validate: structural checks failed, not building\n' >&2; exit 1; }

  printf 'Linting Dockerfile (%s)...\n' "$HADOLINT_IMAGE"
  docker container run --rm \
    --volume "${PWD}":/data:ro \
    --workdir /data \
    "$HADOLINT_IMAGE" /bin/hadolint \
    --config hadolint.yaml Dockerfile
  pass "hadolint (containerized)"

  printf 'Building %s:%s (AWS CLI %s, Terraform %s, %s)...\n' \
    "$IMAGE_NAME" "$image_tag" "$aws_version" "$tf_version" "$platform"
  docker buildx build \
    --progress plain \
    --platform "$platform" \
    --build-arg AWS_CLI_VERSION="$aws_version" \
    --build-arg TERRAFORM_VERSION="$tf_version" \
    --tag "${IMAGE_NAME}:${image_tag}" \
    --load .
  pass "image build"

  printf 'Running container-structure-test (%s)...\n' "$CST_IMAGE"
  render_tests "$aws_version" "$tf_version"
  cst_test "${IMAGE_NAME}:${image_tag}"
  pass "container-structure-test"
}

# ---------------------------------------------------------------------------
# Artefact check (--assert-image): the structure tests against a registry
# image, per published architecture (ADR-0022).
# ---------------------------------------------------------------------------
run_assert_image() {
  local ref="$1" aws_version tf_version arch repo manifest arch_digest
  aws_version="${2:-$(latest_version awscli_versions)}"
  tf_version="${3:-$(latest_version tf_versions)}"
  [[ "$aws_version" =~ $SEMVER_RE ]] || die "AWS_CLI_VERSION '${aws_version}' is not a semver (X.Y.Z)"
  [[ "$tf_version" =~ $SEMVER_RE ]] || die "TERRAFORM_VERSION '${tf_version}' is not a semver (X.Y.Z)"

  # pulling one ref with different platforms does not repoint the local
  # ref, so each architecture is resolved to its own digest
  repo="${ref%%@*}"
  case "${repo##*/}" in *:*) repo="${repo%:*}" ;; esac
  manifest="$(docker buildx imagetools inspect "$ref" --format '{{json .Manifest}}')"

  render_tests "$aws_version" "$tf_version"
  for arch in "${PLATFORM_ARCHS[@]}"; do
    arch_digest="$(printf '%s' "$manifest" | jq -r --arg p "linux/${arch}" \
      '.manifests[]? | select(.platform.os + "/" + .platform.architecture == $p) | .digest')"
    [ -n "$arch_digest" ] \
      || die "the manifest of ${ref} has no linux/${arch} entry (multi-arch reference expected)"
    printf 'Pulling %s (linux/%s)...\n' "${repo}@${arch_digest}" "$arch"
    docker pull --quiet "${repo}@${arch_digest}"
    cst_test "${repo}@${arch_digest}"
    pass "structure tests against ${ref} (linux/${arch}, ${arch_digest})"
  done
}

# ---------------------------------------------------------------------------
# Registry check (--published): what the registry serves for a release.
# Network only: the Docker Hub API is public, so this runs from a laptop, an
# agent session or CI with no Docker and no registry credentials.
# ---------------------------------------------------------------------------
hub_get() {
  curl --silent --fail --retry 5 --retry-delay 2 --retry-all-errors "$1"
}

# Digest a tag resolves to; empty when the tag does not exist.
tag_digest() {
  hub_get "${HUB_API}/tags/$1" | jq -r '.digest // empty' || true
}

tag_is_immutable() {
  local tag="$1" rules="$2" rule
  while IFS= read -r rule; do
    [ -n "$rule" ] || continue
    printf '%s' "$tag" | grep -Eq "$rule" && return 0
  done <<< "$rules"
  return 1
}

# The registry enforces immutability alongside the workflow, so its rules are
# part of ADR-0018: a rule covering a floating form denies the push that moves
# it.
check_registry_immutability() {
  local rules ok=1 entry tag want got
  rules="$(hub_get "${HUB_API}/" | jq -r '.immutable_tags_settings | select(.enabled) | .rules[]')" || true

  # one sample per tag form, with the mutability ADR-0018 declares for it
  local samples=(
    "v0.0.0:immutable"
    "v0.0.0_tf-0.0.0_aws-0.0.0:immutable"
    "v0.0:mutable"
    "latest:mutable"
    "edge:mutable"
  )
  for entry in "${samples[@]}"; do
    tag="${entry%:*}"; want="${entry#*:}"
    if tag_is_immutable "$tag" "$rules"; then got=immutable; else got=mutable; fi
    [ "$got" = "$want" ] \
      || { fail "registry treats ${tag} as ${got}, ADR-0018 declares its form ${want}"; ok=0; }
  done
  [ "$ok" = 1 ] && pass "registry immutability rules match the publication matrix"
}

check_published_tags() {
  local version="$1" ok=1 tf aws tag reference expected actual
  reference="${version}_tf-$(latest_version tf_versions)_aws-$(latest_version awscli_versions)"

  for tf in $(jq -r '.tf_versions[]' supported_versions.json); do
    for aws in $(jq -r '.awscli_versions[]' supported_versions.json); do
      tag="${version}_tf-${tf}_aws-${aws}"
      [ -n "$(tag_digest "$tag")" ] \
        || { fail "pinned tag ${tag} is missing from the registry"; ok=0; }
    done
  done

  expected="$(tag_digest "$reference")"
  if [ -z "$expected" ]; then
    fail "reference tag ${reference} is missing, the floating tags cannot be verified"
    return
  fi

  # `latest` and `vX.Y` belong to the current release (ADR-0018), so they carry
  # no expectation for any other. At release time the checked-out tree is the
  # release commit, so CI always takes the branch below.
  if [ "${version#v}" != "$(current_release)" ]; then
    skip "floating tags: ${version} is not the current release (v$(current_release)), which is what latest and ${version%.*} track"
    [ "$ok" = 1 ] && pass "every ${version} pinned tag is live"
    return
  fi

  # A floating tag can exist and still resolve to the previous release, so
  # presence is not publication.
  for tag in "$version" "${version%.*}" latest; do
    actual="$(tag_digest "$tag")"
    if [ -z "$actual" ]; then
      fail "floating tag ${tag} is missing from the registry"; ok=0
    elif [ "$actual" != "$expected" ]; then
      fail "floating tag ${tag} resolves to ${actual}, expected ${expected} (${reference})"; ok=0
    fi
  done
  [ "$ok" = 1 ] && pass "every ${version} tag resolves to ${expected}"
}

run_published() {
  local version="${1:-}"
  [ -n "$version" ] || usage
  [[ "$version" =~ $RELEASE_RE ]] || die "release version '${version}' is not a vX.Y.Z tag"
  check_registry_immutability
  check_published_tags "$version"
}

# ---------------------------------------------------------------------------
# Machine outputs, not checks: the workflow decides when, this script decides
# what (ADR-0016). The test config is rendered here so its callers (--full and
# build-test.yml) cannot render it differently; --latest and --matrix are read
# by the publishing workflows and print a single value.
# ---------------------------------------------------------------------------
render_tests() {
  local aws_version tf_version
  aws_version="${1:-$(latest_version awscli_versions)}"
  tf_version="${2:-$(latest_version tf_versions)}"
  [[ "$aws_version" =~ $SEMVER_RE ]] || die "AWS_CLI_VERSION '${aws_version}' is not a semver (X.Y.Z)"
  [[ "$tf_version" =~ $SEMVER_RE ]] || die "TERRAFORM_VERSION '${tf_version}' is not a semver (X.Y.Z)"

  # sed, not envsubst: gettext is absent from some contributor and agent
  # environments, and the template has exactly two placeholders
  sed -e "s/\${AWS_VERSION}/${aws_version}/g" \
      -e "s/\${TF_VERSION}/${tf_version}/g" \
      tests/container-structure-tests.yml.template \
      > tests/container-structure-tests.yml
  if grep -q '\${' tests/container-structure-tests.yml; then
    die "unsubstituted placeholder left in tests/container-structure-tests.yml: $(grep -o '\${[^}]*}' tests/container-structure-tests.yml | sort -u | tr '\n' ' ')"
  fi
  pass "rendered tests/container-structure-tests.yml (AWS CLI ${aws_version}, Terraform ${tf_version})"
}

print_latest() {
  case "$1" in
    tf_versions | awscli_versions) latest_version "$1" ;;
    *) die "unknown axis '$1' (tf_versions or awscli_versions)" ;;
  esac
}

print_matrix() {
  local archs
  case "${1:-}" in
    --with-arch)
      archs="$(printf '%s\n' "${PLATFORM_ARCHS[@]}" | jq -R . | jq -sc .)"
      jq -c --argjson archs "$archs" '. + {arch: $archs}' supported_versions.json
      ;;
    '')
      jq -c . supported_versions.json
      ;;
    *)
      usage
      ;;
  esac
}

MODE="${1:-}"
case "$MODE" in
  --fast)
    [ "$#" -le 1 ] || usage
    run_fast
    ;;
  --full)
    shift
    [ "$#" -le 3 ] || usage
    run_full "$@"
    ;;
  --assert-image)
    shift
    { [ "$#" -ge 1 ] && [ "$#" -le 3 ]; } || usage
    run_assert_image "$@"
    ;;
  --published)
    shift
    [ "$#" -eq 1 ] || usage
    run_published "$@"
    ;;
  --render-tests)
    shift
    [ "$#" -le 2 ] || usage
    render_tests "$@"
    ;;
  --latest)
    shift
    [ "$#" -eq 1 ] || usage
    print_latest "$1"
    exit 0
    ;;
  --matrix)
    shift
    [ "$#" -le 1 ] || usage
    print_matrix "$@"
    exit 0
    ;;
  *)
    usage
    ;;
esac

if [ "$FAIL" != 0 ]; then
  printf 'validate: FAILED\n' >&2
  exit 1
fi
printf 'validate: OK\n'
