#!/usr/bin/env bash
#
# Single verification oracle (ADR-0016): the same checks for the maintainer,
# the agent mid-loop, and CI. One entry point, two tiers:
#   --fast  T0: structural checks only, no Docker, seconds (validate.yml runs
#           exactly this on every PR)
#   --full  T1: T0 checks, then hadolint, a single-platform image build and
#           the container-structure-test run (absorbs the former dev.sh)
#
# Principle (ADR-0016): the oracle checks only invariants no purpose-built
# tool covers, and calls tools rather than re-implementing them. hadolint,
# buildx and container-structure-test are called; their verdicts are theirs.
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

  --fast   structural checks only, no Docker required (T0)
  --full   T0 checks, then hadolint, single-platform image build and
           container-structure-test (T1). Versions default to the latest
           in supported_versions.json; the tag defaults to "dev".
USAGE
  exit 2
}

# ---------------------------------------------------------------------------
# T0: supported_versions.json <-> security/
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
    f="security/awscli-exe-linux-x86_64-${v}.zip.sig"
    [ -f "$f" ] || { fail "missing ${f} for supported AWS CLI ${v}"; ok=0; }
  done
  for f in security/terraform_*_SHA256SUMS; do
    v="${f#security/terraform_}"; v="${v%_SHA256SUMS}"
    jq -e --arg v "$v" '.tf_versions | index($v)' supported_versions.json >/dev/null \
      || { fail "orphan ${f}: Terraform ${v} is not in supported_versions.json"; ok=0; }
  done
  for f in security/awscli-exe-linux-x86_64-*.zip.sig; do
    v="${f#security/awscli-exe-linux-x86_64-}"; v="${v%.zip.sig}"
    jq -e --arg v "$v" '.awscli_versions | index($v)' supported_versions.json >/dev/null \
      || { fail "orphan ${f}: AWS CLI ${v} is not in supported_versions.json"; ok=0; }
  done
  [ "$ok" = 1 ] && pass "supported_versions.json <-> security/ consistent"
}

# ---------------------------------------------------------------------------
# T0: ADR files <-> index (docs/adr/README.md)
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
# T0: hadolint via local binary when present (CI gate: lint-dockerfile.yml;
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
# T1 (--full): hadolint + single-platform build + container-structure-test,
# the pipeline formerly in dev.sh. Tool images stay pinned.
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
  aws_version="${1:-$(jq -r '.awscli_versions | sort_by(split(".") | map(tonumber)) | .[-1]' supported_versions.json)}"
  tf_version="${2:-$(jq -r '.tf_versions | sort_by(split(".") | map(tonumber)) | .[-1]' supported_versions.json)}"
  image_tag="${3:-dev}"
  [[ "$aws_version" =~ $SEMVER_RE ]] || die "AWS_CLI_VERSION '${aws_version}' is not a semver (X.Y.Z)"
  [[ "$tf_version" =~ $SEMVER_RE ]] || die "TERRAFORM_VERSION '${tf_version}' is not a semver (X.Y.Z)"
  platform="$(host_platform)"

  run_fast
  [ "$FAIL" = 0 ] || { printf 'validate: T0 failed, not building\n' >&2; exit 1; }

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
  AWS_VERSION="$aws_version" TF_VERSION="$tf_version" \
    envsubst '${AWS_VERSION},${TF_VERSION}' \
    < tests/container-structure-tests.yml.template \
    > tests/container-structure-tests.yml
  docker container run --rm \
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
  *)
    usage
    ;;
esac

if [ "$FAIL" != 0 ]; then
  printf 'validate: FAILED\n' >&2
  exit 1
fi
printf 'validate: OK\n'
