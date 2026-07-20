# 0011 — Migrate the base image to Debian 13 (trixie)

- Status: Accepted
- Date: 2026-07-20
- Deciders: @bgauduch

## Context and problem statement

The image was built on `debian:bookworm-20231120-slim`, a base frozen at the end
of 2023. Debian 13 (`trixie`) is now the current stable release, so the old base
accumulates unpatched CVEs and its pinned `deb12u*` OS-package versions are
progressively removed from the `bookworm` mirror (the failure mode ADR-0010
describes). Staying on the frozen base is the single highest-risk item of the
version-refresh work. The question is which base to move to and how to pin it.

## Decision drivers

- Reduce CVE exposure — ship on a current, maintained Debian release.
- Reproducibility and supply-chain integrity (consistent with ADR-0010).
- Predictable, reviewable base-image changes.
- Low maintenance for a low-traffic project.

## Considered options

- **Move to Debian 13 (`trixie`), pinned by digest** — `trixie-slim` referenced by
  its immutable `sha256` manifest digest.
- **Move to `trixie`, pinned by a dated tag** (e.g. `trixie-YYYYMMDD-slim`), as
  the previous `bookworm-20231120-slim` pin did.
- **Stay on `bookworm`** and only refresh the OS-package pins. *Rejected — leaves
  the base a full release behind and does not address the CVE exposure.*

## Decision outcome

Chosen option: **migrate to Debian 13 (`trixie`), pinned by digest**, because the
digest is immutable and unambiguous (it survives mirror re-tagging), which gives
stronger reproducibility than a dated tag while requiring no extra tooling. The
base is set once via the `DEBIAN_VERSION` build arg and consumed by every build
stage.

The seven pinned OS packages (`ca-certificates`, `curl`, `gnupg`, `unzip`, `git`,
`jq`, `openssh-client`) are refreshed to their `trixie`/`deb13` candidates per the
ADR-0010 procedure, and the `container-structure-test` version assertions
(`git`, `jq`, `ssh`) are updated to match the tools shipped by `trixie`.

This change is intentionally scoped to the **base-image move only**. Refreshing
the bundled Terraform / AWS CLI version matrix and the image distribution / tag
work stay separate, so this migration is reviewable on its own.

### Consequences

- Good: current, maintained base → materially reduced CVE surface; digest pin →
  reproducible, explicit builds.
- Cost: the OS-package pins and the test assertions must be refreshed together
  with the base (same ADR-0010 maintenance step); the digest must be bumped when
  a newer `trixie-slim` is adopted.
- Behaviour change: trixie hardens the default `HOME_MODE` to `0700`
  (`/etc/login.defs`), so the non-root user's home is created `drwx------` instead
  of bookworm's `drwxr-xr-x`. This is kept as-is (stricter is better; the home is
  owned by the `nonroot` user) and the container-structure-test assertion is
  updated to match rather than re-loosening the mode.
- Follow-ups: the bundled-tool version refresh and the distribution / tag strategy
  are tracked separately in the roadmap; a `snapshot.debian.org` source (ADR-0010)
  remains the future path to pins that never break.

## More information

- Supersedes the `bookworm` base recorded implicitly in the Dockerfile; the
  pinning policy of [`ADR-0010`](0010-apt-package-pinning-strategy.md) is unchanged
  (amended only to target `trixie`).
- Pin values and the base digest are read with the procedure in
  [`docs/dependencies-upgrades.md`](../dependencies-upgrades.md).
- The bundled-binary verification chain (GPG + checksums) is unchanged
  ([`docs/binaries-verifications.md`](../binaries-verifications.md)).
