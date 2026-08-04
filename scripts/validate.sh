#!/usr/bin/env bash
#
# Single verification oracle (ADR-0016): one entry point for the maintainer,
# the agent mid-loop and CI. Tiers and arguments: see usage() below.
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
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+$'

FAIL=0
pass() { printf 'PASS %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*" >&2; FAIL=1; }
skip() { printf 'SKIP %s\n' "$*"; }
die()  { printf 'validate: %s\n' "$*" >&2; exit 2; }

usage() {
  cat >&2 <<'USAGE'
usage: validate.sh --fast
       validate.sh --full [AWS_CLI_VERSION] [TERRAFORM_VERSION] [IMAGE_TAG]
       validate.sh --render-tests [AWS_CLI_VERSION] [TERRAFORM_VERSION]

  --fast          structural checks only, no Docker required (tier 0)
  --full          the fast checks, then hadolint, single-platform image build
                  and container-structure-test (tier 1). Versions default to
                  the latest in supported_versions.json; the tag defaults to
                  "dev".
  --render-tests  render tests/container-structure-tests.yml from its template
                  and exit; called by --full and by build-test.yml.
USAGE
  exit 2
}

# Latest version of an axis in supported_versions.json, semver-sorted.
latest_version() {
  jq -r --arg axis "$1" \
    '.[$axis] | sort_by(split(".") | map(tonumber)) | .[-1]' supported_versions.json
}

# ---------------------------------------------------------------------------
# Tier 0: supported_versions.json <-> security/
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
# Tier 0: ADR files <-> index (docs/adr/README.md)
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
# Tier 0: hadolint via local binary when present (CI gate: lint-dockerfile.yml;
# --full runs the pinned container instead)
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

run_fast() {
  check_versions_security
  check_adr_index
  check_hadolint_local
}

# ---------------------------------------------------------------------------
# Shared logic, called by --full and by build-test.yml: the test config is
# rendered here so the two callers cannot render it differently (ADR-0016).
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

# ---------------------------------------------------------------------------
# Tier 1 (--full): hadolint + single-platform build + container-structure-test.
# Tool images stay pinned.
# ---------------------------------------------------------------------------
host_platform() {
  case "$(uname -m)" in
    x86_64)          printf 'linux/amd64' ;;
    aarch64 | arm64) printf 'linux/arm64' ;;
    *) die "unsupported host architecture: $(uname -m)" ;;
  esac
}

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
  # container-structure-test ships amd64-only; request it explicitly so
  # arm64 hosts emulate silently
  docker container run --rm \
    --platform linux/amd64 \
    --volume "${PWD}"/tests/container-structure-tests.yml:/tests.yml:ro \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    "$CST_IMAGE" test \
    --image "${IMAGE_NAME}:${image_tag}" \
    --config /tests.yml
  pass "container-structure-test"
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
  --render-tests)
    shift
    [ "$#" -le 2 ] || usage
    render_tests "$@"
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
