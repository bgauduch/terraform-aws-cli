# 0010 — APT package pinning strategy

- Status: Accepted
- Date: 2026-06-15
- Deciders: @bgauduch

## Context and problem statement

The Dockerfile pinned every OS package to an exact version
(`ca-certificates=20230311`, `curl=7.88.1-10+deb12u4`, …). Debian removes old
point-release versions from the `bookworm` mirror as it publishes new ones, so
those exact pins disappear and the build breaks with `apt-get … exit code 100`.
This is exactly what failed `build-test` on PR #119
(`ca-certificates=20230311` no longer available). It recurs every Debian point
release and there is no good automation to chase apt pins.

## Decision drivers

- Builds must not break on routine Debian point releases.
- Low maintenance (no manual apt-version chasing; Renovate can't manage these).
- Keep reproducibility/supply-chain integrity **where it matters** — the bundled
  tools.

## Considered options

- **Keep exact pins** and chase versions on every break (status quo).
- **Pin against `snapshot.debian.org`** for frozen, reproducible apt versions.
- **Unpin the OS utility packages**, relying on the Debian *stable* suite + the
  pinned base image for adequate reproducibility.

## Decision outcome

Chosen option: **unpin the OS utility packages**
(`ca-certificates`, `curl`, `gnupg`, `unzip`, `git`, `jq`, `openssh-client`),
keeping `--no-install-recommends`. Hadolint **DL3008** is ignored
(`hadolint.yaml`) since unpinning is now intentional.

Crucially, this does **not** weaken supply-chain integrity for what matters:

- **Terraform** and **AWS CLI** remain version-pinned (`supported_versions.json`)
  and verified by **GPG signature + checksum** at build time.
- The **base image** stays tag-pinned (digest pin + bump tracked in Phase 3 /
  #108).

Only the auxiliary OS utilities float, bounded by the `bookworm` stable suite.

### Consequences

- Good: builds stop breaking on Debian point releases; no apt-version chasing.
- Cost: exact OS-package versions are no longer reproducible byte-for-byte
  (acceptable for a tools image; the security-critical binaries are still pinned
  and verified).
- Lint: DL3008 ignored, documented in `hadolint.yaml`.
- Follow-ups: base-image digest pin + bump (#108); adopt `snapshot.debian.org`
  later only if strict OS reproducibility is ever required.

## More information

Superseded approach: the per-package exact pins added in earlier Dockerfile
revisions. The bundled-binary verification chain is unchanged
(`docs/binaries-verifications.md`).
