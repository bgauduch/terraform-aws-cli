# 0020 — The pull-request gate builds a representative subset, not the full matrix

- Status: Accepted
- Date: 2026-08-04
- Deciders: @bgauduch

## Context and problem statement

`build-test` builds every supported combination twice on every image-touching
pull request: once on `amd64` to run the structure tests, then once for the
whole published platform set. At the current matrix that is 3 × (1 + 2) = 9
platform builds, and the `arm64` half runs under QEMU emulation, which
dominates the wall time.

The raw count already fell by an order of magnitude from outside this
decision: ADR-0015 cut the version lines from 16 to 3, ADR-0019 cut the
platforms from 4 to 2. What neither answers is the question a count cannot:
**which combinations the pull-request gate must build for its verdict to mean
anything**, given that the release workflow (the full matrix on every
platform, then `verify_release`) stays authoritative.

## Decision drivers

- The gate is a pre-merge signal paid on every iteration of every image-touching
  PR; the authoritative build is the release one.
- The Dockerfile installs the two axes in **independent stages**: Terraform and
  the AWS CLI are downloaded, GPG-verified and copied separately, and neither
  reads the other's version. Pairing them exhaustively discovers nothing that
  covering each version once does not.
- Per-version, per-architecture signature material is already asserted by the
  oracle (ADR-0016, extended to both arches by ADR-0017), so the risk left to
  the arch axis is what the *build* does with that material.
- The subset must be computed from `supported_versions.json`, so the sunset
  matrix (ADR-0015) remains its only input, and it must inherit the platform set
  from ADR-0019 rather than declare one.

## Considered options

- **Keep the full matrix on both platforms**: maximal coverage, and the cost the
  study opened on. Every version line pays an emulated `arm64` build on every
  push to every PR.
- **Build the newest combination only**: cheapest, but a PR that touches an
  older line's signature material or its version entry then builds nothing that
  exercises it — the gate would be silent on exactly the change that needs it.
- **A representative subset plus one multi-arch canary** (chosen).

## Decision outcome

Chosen option: **the gate covers each axis, not their product, and checks the
multi-arch build once**.

- **Version coverage — every supported version appears in at least one job.**
  Both axes are sorted oldest to newest and paired positionally; the shorter one
  repeats its newest entry until the longer is exhausted. The gate therefore
  runs `max(#tf, #awscli)` jobs instead of `#tf × #awscli`, and the last pair is
  always the newest combination. The cartesian product stays with the release.
- **Platform coverage — one canary.** Subset jobs build `linux/amd64` and run
  container-structure-test, which ships `amd64`-only. A single canary job builds
  the **newest** combination for the full published platform set, inherited from
  ADR-0019 and never redeclared here. The newest combination is what `edge` and
  `latest` carry, so the canary proves the multi-arch build of the artefact
  users actually pull.
- **What this accepts**: a defect reachable only by pairing a non-newest
  Terraform with a non-newest AWS CLI, or only on `arm64` of a non-newest
  combination, reaches `master` and surfaces at release time instead of on the
  PR. The first is bounded by the independence of the Dockerfile stages, the
  second by the oracle already proving both architectures have their signature
  material. Neither class has occurred; #161, the one arch-specific defect this
  repository has had, was in the shared install logic and would be caught by the
  canary.
- The subset is **computed, not listed**: adding or retiring a version line
  changes the gate with no workflow edit.

### Consequences

- Good: 9 platform builds become 5 on the current matrix, and one emulated
  `arm64` build instead of three — the expensive axis is paid once per PR.
- Neutral, worth stating so it is not mistaken for a regression: **the gate does
  not get faster**. The canary is the critical path and takes about as long as
  one of the old jobs, which ran their multi-arch builds in parallel. What falls
  is compute and cache pressure (the concern #150 opened on), not latency.
- Good: the gate no longer grows with the product of the two axes. Adding a
  second AWS CLI line would have doubled it to 6 jobs; it now adds none.
- Bad: a green `build-test` no longer means every published combination builds.
  It means every supported version builds, and the shipped combination builds
  everywhere. The release matrix plus `verify_release` (ADR-0018) remain the
  authoritative gate, and ADR-0013's coverage statement is amended accordingly.
- Constraint: the canary must stay the newest combination. Pointing it at an
  arbitrary combination would decouple it from what `edge` and `latest` publish,
  which is the property that makes one canary enough.

## More information

Study, tier ladder and sequencing: #152 (this is its tier 2). Version axis:
[ADR-0015](0015-version-support-follows-upstream-eol.md); platform set:
[ADR-0019](0019-platform-support-follows-upstream.md); authoritative publication
gate: [ADR-0018](0018-single-owner-publication-matrix.md).

The same change moves the rendering of the container-structure-test config into
`scripts/validate.sh --render-tests`, called by the workflow. That is shared
logic the two callers were writing twice, and moving it implements
[ADR-0016](0016-single-verification-oracle.md) rather than deciding anything new.
