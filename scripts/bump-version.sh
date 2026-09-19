#!/usr/bin/env bash
#
# Materialise a Terraform or AWS CLI version bump (ADR-0021): download and
# GPG-verify the signature material, then write supported_versions.json and
# security/ as one unit. Version policy is ADR-0015: one patch per Terraform
# minor line, the latest three lines kept, a new line retiring the oldest; a
# single AWS CLI version.
#
# Nothing in the repository is touched until every download has verified.
# Run scripts/validate.sh --full before pushing the result.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

VERSIONS_FILE="supported_versions.json"
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+$'
TF_RELEASES="https://releases.hashicorp.com/terraform"
AWS_RELEASES="https://awscli.amazonaws.com"
TF_KEPT_MINORS=3

die() { printf 'bump-version: %s\n' "$*" >&2; exit 1; }

usage() {
  cat >&2 <<'USAGE'
usage: bump-version.sh terraform X.Y.Z
       bump-version.sh awscli X.Y.Z

Downloads and GPG-verifies the signature material for the given version, then
updates supported_versions.json and security/ together. The manual fallback is
docs/binaries-verifications.md.
USAGE
  exit 2
}

fetch() {
  # plain --retry does not cover connection resets (curl exit 35), --retry-all-errors does
  curl --silent --show-error --fail --retry 5 --retry-delay 2 --retry-all-errors \
    --output "$2" "$1"
}

gpg_verify() {
  local key="$1" sig="$2" file="$3"
  gpg --quiet --import "$key"
  gpg --verify "$sig" "$file" 2>/dev/null \
    || die "GPG verification failed for ${file} against ${key}"
}

bump_terraform() {
  local version="$1" tmp="$2" sums sig
  sums="terraform_${version}_SHA256SUMS"
  sig="${sums}.sig"

  printf 'Fetching and verifying Terraform %s signature material...\n' "$version"
  fetch "${TF_RELEASES}/${version}/${sums}" "${tmp}/${sums}"
  fetch "${TF_RELEASES}/${version}/${sig}" "${tmp}/${sig}"
  gpg_verify security/hashicorp.asc "${tmp}/${sig}" "${tmp}/${sums}"

  # same minor line: the new patch supersedes the listed one; new line: the
  # oldest listed line retires with it (ADR-0015)
  local before after removed v
  before="$(jq -r '.tf_versions[]' "$VERSIONS_FILE")"
  jq --arg v "$version" --argjson keep "$TF_KEPT_MINORS" '
    .tf_versions |= (
      (map(select((split(".")[0:2]) != ($v | split(".")[0:2]))) + [$v]
        | sort_by(split(".") | map(tonumber)))
      | if length > $keep then .[length - $keep:] else . end
    )' "$VERSIONS_FILE" > "${tmp}/versions.json"
  after="$(jq -r '.tf_versions[]' "${tmp}/versions.json")"

  mv "${tmp}/${sums}" "${tmp}/${sig}" security/
  mv "${tmp}/versions.json" "$VERSIONS_FILE"
  removed="$(comm -23 <(sort <<<"$before") <(sort <<<"$after"))"
  for v in $removed; do
    rm -f "security/terraform_${v}_SHA256SUMS" "security/terraform_${v}_SHA256SUMS.sig"
    printf 'Retired Terraform %s and its signature material\n' "$v"
  done
}

bump_awscli() {
  local version="$1" tmp="$2" arch zip sig
  for arch in x86_64 aarch64; do
    zip="awscli-exe-linux-${arch}-${version}.zip"
    sig="${zip}.sig"
    printf 'Fetching and verifying AWS CLI %s (%s)...\n' "$version" "$arch"
    fetch "${AWS_RELEASES}/${zip}" "${tmp}/${zip}"
    fetch "${AWS_RELEASES}/${sig}" "${tmp}/${sig}"
    gpg_verify security/awscliv2.asc "${tmp}/${sig}" "${tmp}/${zip}"
    rm -f "${tmp}/${zip}"
  done

  local before v
  before="$(jq -r '.awscli_versions[]' "$VERSIONS_FILE")"
  jq --arg v "$version" '.awscli_versions = [$v]' "$VERSIONS_FILE" > "${tmp}/versions.json"

  for arch in x86_64 aarch64; do
    mv "${tmp}/awscli-exe-linux-${arch}-${version}.zip.sig" security/
  done
  mv "${tmp}/versions.json" "$VERSIONS_FILE"
  for v in $before; do
    [ "$v" = "$version" ] && continue
    rm -f security/awscli-exe-linux-x86_64-"${v}".zip.sig \
          security/awscli-exe-linux-aarch64-"${v}".zip.sig
    printf 'Retired AWS CLI %s signature material\n' "$v"
  done
}

main() {
  [ "$#" -eq 2 ] || usage
  local axis="$1" version="$2"
  [[ "$version" =~ $SEMVER_RE ]] || die "version '${version}' is not a semver (X.Y.Z)"
  command -v jq >/dev/null 2>&1 || die "jq is required"
  command -v gpg >/dev/null 2>&1 || die "gpg is required"

  TMP="$(mktemp -d)"
  local tmp="$TMP"
  trap 'rm -rf "$TMP"' EXIT
  export GNUPGHOME="${tmp}/gnupg"
  mkdir -m 700 "$GNUPGHOME"

  case "$axis" in
    terraform) bump_terraform "$version" "$tmp" ;;
    awscli)    bump_awscli "$version" "$tmp" ;;
    *)         usage ;;
  esac

  printf 'bump-version: wrote %s and security/\n' "$VERSIONS_FILE"
  git --no-pager diff --stat -- "$VERSIONS_FILE" || true

  ./scripts/validate.sh --fast
}

main "$@"
