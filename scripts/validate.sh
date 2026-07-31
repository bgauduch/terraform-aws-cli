#!/usr/bin/env bash
#
# Single verification oracle (see the ADR "single verification oracle"): the
# same checks for the maintainer, the agent mid-loop, and CI (validate.yml).
# T0 (--fast) needs no Docker and runs in seconds.
#
# Principle (ADR-0016): the oracle checks only invariants no purpose-built
# tool covers, and calls tools rather than re-implementing them. Pass 1a
# scope (#152):
#   1. supported_versions.json <-> security/ signature material (both
#      directions; nothing else checks the orphan direction at all)
#   2. ADR files <-> ADR index (docs/adr/README.md)
# plus hadolint when the binary is available locally (in CI that gate is
# owned by lint-dockerfile.yml). Pin/template drift is deliberately NOT
# checked here: container-structure-test owns its detection (T1/T2) and
# the atomic write scripts (#152 PR 4) remove the drift class itself.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
pass() { printf 'PASS %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*" >&2; FAIL=1; }
skip() { printf 'SKIP %s\n' "$*"; }

usage() {
  printf 'usage: %s --fast\n' "${0##*/}" >&2
  printf '  --fast   structural checks only, no Docker required (T0)\n' >&2
  exit 2
}
[ "${1:-}" = "--fast" ] || usage

# ---------------------------------------------------------------------------
# 1. supported_versions.json <-> security/
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
# 2. ADR files <-> index (docs/adr/README.md)
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
# 3. hadolint, when available (CI gate: lint-dockerfile.yml)
# ---------------------------------------------------------------------------
check_hadolint() {
  if command -v hadolint >/dev/null 2>&1; then
    if hadolint --config hadolint.yaml Dockerfile; then
      pass "hadolint"
    else
      fail "hadolint reported issues"
    fi
  else
    skip "hadolint not installed (CI gate: lint-dockerfile.yml)"
  fi
}

check_versions_security
check_adr_index
check_hadolint

if [ "$FAIL" != 0 ]; then
  printf 'validate: FAILED\n' >&2
  exit 1
fi
printf 'validate: OK\n'
