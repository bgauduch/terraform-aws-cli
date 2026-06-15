# 0010 — APT package pinning strategy

- Status: Accepted
- Date: 2026-06-15
- Deciders: @bgauduch

## Context and problem statement

The Dockerfile pins every OS package to an exact version
(`ca-certificates=20230311+deb12u1`, `curl=7.88.1-10+deb12u14`, …). Debian
removes superseded point-release versions from the `bookworm` mirror, so a stale
pin eventually disappears and the build fails with `apt-get … exit code 100`.
This broke `build-test` (the pin `ca-certificates=20230311` had been superseded
by `…+deb12u1`). The question is whether to keep pinning, drop pins, or freeze
the mirror.

## Decision drivers

- Reproducibility and supply-chain integrity of the image.
- Predictable, reviewable dependency changes.
- Acceptable maintenance for a low-traffic project.

## Considered options

- **Keep exact version pins** and refresh them when Debian supersedes a version
  (or on base-image bumps).
- **Unpin** the OS utility packages (rely on the stable suite). *Rejected — loses
  reproducibility and makes dependency changes invisible.*
- **`snapshot.debian.org`** as a frozen apt source so exact pins never disappear.

## Decision outcome

Chosen option: **keep exact version pins** for all OS packages
(`ca-certificates`, `curl`, `gnupg`, `unzip`, `git`, `jq`, `openssh-client`),
with `--no-install-recommends`. Pins are **refreshed** when a build breaks on a
superseded version or when the base image is bumped — the procedure is documented
in [`docs/dependencies-upgrades.md`](../dependencies-upgrades.md).

Unpinning was explicitly rejected: the bundled tools (Terraform, AWS CLI) are
already pinned + GPG/checksum-verified, and keeping the OS packages pinned too
keeps the whole image reproducible and every change explicit in the diff.

**`snapshot.debian.org`** is recorded as the path to make pins *never* break
(fully reproducible builds); it is deferred to a future ADR/PR rather than
adopted now, to keep this change minimal.

### Consequences

- Good: reproducible, explicit dependencies; supply-chain integrity preserved.
- Cost: pins must be refreshed periodically (when Debian supersedes a version) —
  a manual step today, a candidate for a Renovate custom manager later (#20).
- Lint: hadolint `DL3008` stays **enforced** (pinning required).

## More information

Pin values are read with:

```bash
docker run --rm debian:bookworm-slim bash -c \
  'apt-get update -qq && for p in ca-certificates curl gnupg unzip git jq openssh-client; do \
     printf "%s=%s\n" "$p" "$(apt-cache policy "$p" | awk "/Candidate:/{print \$2}")"; done'
```

The bundled-binary verification chain is unchanged
([`docs/binaries-verifications.md`](../binaries-verifications.md)).
