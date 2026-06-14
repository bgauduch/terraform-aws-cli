# 0003 — Image versioning and Docker tag strategy

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

The image bundles two independently-versioned tools (Terraform, AWS CLI) on a
Debian base. Consumers need both **reproducible pins** and **convenient floating
aliases**, and the project needs its own version line decoupled from the bundled
tools.

## Decision drivers

- Reproducibility: a tag that never changes meaning.
- Convenience: floating tags so users can track a minor line.
- A project version independent of Terraform/AWS CLI versions.
- Alignment with release-please semver (ADR-0002).

## Considered options

- Fully-pinned tags only (`vX.Y.Z_tf-A.B.C_aws-D.E.F`) + `latest`.
- Floating aliases only (`latest`, `vX.Y`).
- Both: floating aliases **and** immutable fully-pinned tags.

## Decision outcome

Chosen option: **both**. The image carries:

- `latest` — latest supported versions, from `master`.
- `edge` — bleeding edge / pre-release builds.
- `vX.Y.Z` and `vX.Y` — project semver (floating minor), resolving to the latest
  bundled tool versions for that line.
- `vX.Y.Z_tf-A.B.C_aws-D.E.F` — **immutable, fully-pinned** combination.

Repo versioning is project semver `vX.Y.Z`; image tags are derived from it.

### Consequences

- Good: reproducible pins for CI; floating tags for humans.
- Cost: more tags to publish and document.
- Policy: immutable full tags are **never** mutated; rollback = consumers
  re-pin an older tag (see `docs/rollback.md`, roadmap Phase 1).
- Follows: replaces the old `release-S.T_terraform-…_awscli-…` scheme; supersedes
  the pinned-only proposal in epic #100.

## More information

Roadmap Phase 1 (P0 subset) and Phase 3 (full strategy + GHCR).
