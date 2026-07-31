#!/usr/bin/env bash
#
# Single verification oracle (see the ADR "single verification oracle"): the
# same checks for the maintainer, the agent mid-loop, and CI (validate.yml).
# T0 (--fast) needs no Docker and runs in seconds.
#
# Pass 1a scope (#152): the three highest-value drift checks
#   1. supported_versions.json <-> security/ signature material
#   2. Dockerfile apt pins <-> container-structure-test version assertions
#   3. ADR files <-> ADR index (docs/adr/README.md)
# plus hadolint when the binary is available locally (in CI that gate is
# owned by lint-dockerfile.yml; the oracle does not duplicate it there).
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
# 2. Dockerfile apt pins <-> test template version assertions
# The template asserts what the tool prints, the Dockerfile pins the Debian
# package: epochs, Debian revisions and pN suffixes differ (a 10.0p1 package
# may print OpenSSH_10.0p2), so the comparison uses the numeric base version
# with dot-boundary prefix matching in either direction.
# ---------------------------------------------------------------------------
pin_upstream() { # tool name -> upstream version from its Dockerfile pin
  local raw
  raw="$(grep -oE "${1}=[^ \\\\]+" Dockerfile | head -1 | cut -d= -f2)"
  raw="${raw#*:}"          # strip epoch
  printf '%s' "${raw%%-*}" # strip Debian revision
}
base_match() { # numeric bases match if one is a dot-prefix of the other
  local a="${1%%p*}" b="${2%%p*}"
  case "$b" in "$a" | "$a".*) return 0 ;; esac
  case "$a" in "$b" | "$b".*) return 0 ;; esac
  return 1
}
check_pins_template() {
  local ok=1 tpl=tests/container-structure-tests.yml.template expected pinned
  expected="$(grep -oE 'git version [0-9.]+' "$tpl" | awk '{print $3}')"
  pinned="$(pin_upstream git)"
  base_match "$expected" "$pinned" || { fail "git: template asserts ${expected}, Dockerfile pins ${pinned}"; ok=0; }
  expected="$(grep -oE 'jq-[0-9.]+' "$tpl" | head -1 | cut -d- -f2)"
  pinned="$(pin_upstream jq)"
  base_match "$expected" "$pinned" || { fail "jq: template asserts ${expected}, Dockerfile pins ${pinned}"; ok=0; }
  expected="$(grep -oE 'OpenSSH_[0-9.]+p?[0-9]*' "$tpl" | head -1 | cut -d_ -f2)"
  pinned="$(pin_upstream openssh-client)"
  base_match "$expected" "$pinned" || { fail "openssh: template asserts ${expected}, Dockerfile pins ${pinned}"; ok=0; }
  [ "$ok" = 1 ] && pass "Dockerfile pins <-> test template assertions consistent"
}

# ---------------------------------------------------------------------------
# 3. ADR files <-> index (docs/adr/README.md)
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
# 4. hadolint, when available (CI gate: lint-dockerfile.yml)
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
check_pins_template
check_adr_index
check_hadolint

if [ "$FAIL" != 0 ]; then
  printf 'validate: FAILED\n' >&2
  exit 1
fi
printf 'validate: OK\n'
