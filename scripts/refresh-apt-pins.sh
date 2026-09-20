#!/usr/bin/env bash
#
# Refresh every Dockerfile apt pin and the tool assertions in the
# container-structure-test template to what the pinned Debian base serves
# (ADR-0010, ADR-0021). Both files are written together or not at all.
# Requires Docker and network. Run validate.sh --full before pushing.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DOCKERFILE="Dockerfile"
TEMPLATE="tests/container-structure-tests.yml.template"
# every package pinned in the Dockerfile
PACKAGES=(ca-certificates curl gnupg unzip git jq openssh-client)
# packages whose CLI banner the template asserts
TOOL_PACKAGES=(git jq openssh-client)

die() { printf 'refresh-apt-pins: %s\n' "$*" >&2; exit 1; }

base_image() {
  local ref
  ref="$(sed -n 's/^ARG DEBIAN_VERSION=//p' "$DOCKERFILE")"
  [ -n "$ref" ] || die "no ARG DEBIAN_VERSION found in ${DOCKERFILE}"
  printf 'debian:%s' "$ref"
}

# Banners are measured, not derived from the package version: the two can
# differ (Debian's openssh 10.0p1-7 reports OpenSSH_10.0p2).
probe() {
  docker container run --rm "$(base_image)" bash -c '
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq >/dev/null 2>&1
    for p in '"${PACKAGES[*]}"'; do
      printf "PIN %s=%s\n" "$p" "$(apt-cache policy "$p" | awk "/Candidate:/{print \$2}")"
    done
    apt-get install -y --no-install-recommends '"${TOOL_PACKAGES[*]}"' >/dev/null 2>&1
    printf "GIT %s\n" "$(git --version | awk "{print \$3}")"
    printf "JQ %s\n"  "$(jq --version)"
    printf "SSH %s\n" "$(ssh -V 2>&1 | grep -oE "OpenSSH_[^, ]+")"
  '
}

main() {
  [ "$#" -eq 0 ] || die "usage: refresh-apt-pins.sh (no arguments)"
  command -v docker >/dev/null 2>&1 || die "docker is required"

  printf 'Probing %s...\n' "$(base_image)"
  local probe_out
  probe_out="$(probe)"

  local tmp_dockerfile tmp_template
  tmp_dockerfile="$(mktemp)"
  tmp_template="$(mktemp)"
  trap 'rm -f "$tmp_dockerfile" "$tmp_template"' EXIT
  cp "$DOCKERFILE" "$tmp_dockerfile"
  cp "$TEMPLATE" "$tmp_template"

  local pkg candidate
  for pkg in "${PACKAGES[@]}"; do
    candidate="$(printf '%s\n' "$probe_out" | sed -n "s/^PIN ${pkg}=//p")"
    { [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; } \
      || die "no apt candidate for ${pkg}"
    grep -Eq "(^|[[:space:]])${pkg}=" "$tmp_dockerfile" \
      || die "package ${pkg} is not pinned in ${DOCKERFILE}"
    sed -E -i "s#(^|[[:space:]])${pkg}=[^[:space:]]+#\1${pkg}=${candidate}#g" "$tmp_dockerfile"
  done

  local git_version jq_banner ssh_banner
  git_version="$(printf '%s\n' "$probe_out" | sed -n 's/^GIT //p')"
  jq_banner="$(printf '%s\n' "$probe_out" | sed -n 's/^JQ //p')"
  ssh_banner="$(printf '%s\n' "$probe_out" | sed -n 's/^SSH //p')"
  { [ -n "$git_version" ] && [ -n "$jq_banner" ] && [ -n "$ssh_banner" ]; } \
    || die "tool banner probe came back incomplete"
  sed -E -i "s#git version [0-9][^\"]*#git version ${git_version}#" "$tmp_template"
  sed -E -i "s#jq-[0-9][^\"]*#${jq_banner}#" "$tmp_template"
  sed -E -i "s#OpenSSH_[0-9][^\"]*#${ssh_banner}#" "$tmp_template"

  if cmp -s "$tmp_dockerfile" "$DOCKERFILE" && cmp -s "$tmp_template" "$TEMPLATE"; then
    printf 'refresh-apt-pins: already current, nothing to write\n'
    exit 0
  fi

  mv "$tmp_dockerfile" "$DOCKERFILE"
  mv "$tmp_template" "$TEMPLATE"
  trap - EXIT
  printf 'refresh-apt-pins: wrote %s and %s\n' "$DOCKERFILE" "$TEMPLATE"
  git --no-pager diff --stat -- "$DOCKERFILE" "$TEMPLATE" || true

  ./scripts/validate.sh --fast
}

main "$@"
