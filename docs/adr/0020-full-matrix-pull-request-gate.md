# 0020 — The pull-request gate builds and tests every combination on every published platform

- Status: Accepted
- Date: 2026-08-04
- Deciders: @bgauduch

## Context and problem statement

`build-test` built every supported combination twice on a pull request: once on
`amd64` to run the structure tests, then once for the whole published platform
set. Nothing ever *ran* the image on `arm64` — not on a pull request, not at
release, where the publishing workflows build and push without testing at all.

That blind spot is not theoretical. `arm/v7` and `386` images shipped a
non-executable `aws` for years (#161) behind green multi-arch builds, and the
defect was found by a human running `scripts/validate.sh --full` on Apple
Silicon. **A successful build proves the image assembles, not that it works.**

The harness study (#152) opened this item as a cost problem — "the pull-request
gate is not sized for iteration" — and proposed a representative subset plus one
multi-arch canary. The cost that framing was written against disappeared before
the decision was taken: ADR-0015 cut the version lines 16 → 3 and ADR-0019 cut
the platforms 4 → 2. Measured on this repository, the proposed trim saved 14.2 →
8.6 runner-minutes at an unchanged wall clock, and GitHub-hosted runner minutes
are free on a public repository. The question therefore flipped, from *how
little can the gate build* to *what does the gate actually prove*.

## Decision drivers

- Runner minutes are free here; the currencies that are not free are wall clock
  and reviewer confidence.
- A defect that only manifests on `arm64` currently reaches users, not merely
  release, because no workflow executes an `arm64` image (#161).
- The matrix is already bounded by upstream policy on both axes (ADR-0015,
  ADR-0019), so full coverage is affordable at today's size.
- The gate must not need re-arguing every time a version line moves.

## Considered options

- **Representative subset plus a multi-arch canary** (the study's proposal):
  cuts the gate to 5 platform builds, spends coverage to buy runner minutes that
  cost nothing, and leaves the `arm64` runtime blind spot untouched.
- **That subset, plus an `arm64` structure-test run on the newest combination
  only**: closes most of the blind spot, but keeps older Terraform lines
  unexecuted on `arm64` to save roughly two runner-minutes.
- **Full coverage — every combination, every published platform, built *and*
  tested** (chosen).

## Decision outcome

Chosen option: **the pull-request gate covers the supported matrix in full, on
both axes, and asserts behaviour rather than assembly**.

- The gate's matrix is **combinations × published platforms**: one job per pair,
  each performing a single-platform build loaded into the runner's daemon
  followed by one container-structure-test run. At the current matrix that is
  six jobs, all parallel.
- **`arm64` jobs run under emulation**: `setup-qemu-action` installs binfmt, the
  build targets `linux/arm64`, and container-structure-test — an `amd64` tool
  driving the Docker daemon — executes its assertions inside the emulated image.
  The same test template serves both architectures: every assertion it makes is
  architecture-independent.
- **The separate multi-arch build step disappears.** Both architectures are now
  built individually, so what remained was the assembly of a manifest from cache.
  The manifest that matters is the published one, and the publishing workflows
  own it (ADR-0018).
- The platform set is **inherited from ADR-0019**, not declared here.
- **This decision is bounded by the matrix that makes it affordable.** A second
  AWS CLI line would take the gate to twelve jobs and roughly forty
  runner-minutes. That is the trigger to revisit this ADR — deliberately, not by
  letting the gate drift into a trim nobody decided.

### Consequences

- Good: `arm64` is executed on every pull request for the first time. The class
  of defect #161 belongs to becomes detectable before merge instead of after
  publication.
- Good: one build per job instead of two, and the job name states the exact pair
  it verified.
- Cost: roughly 20 runner-minutes per gate run against 14.2 before, at a
  comparable wall clock since the jobs are parallel. Free on a public repository.
- Constraint: the `arm64` assertions depend on QEMU emulation being sound on the
  runner. If emulation proves unreliable, the fallback is to keep the `arm64`
  build everywhere and run the `arm64` structure tests on the newest combination
  only — a narrowing that would itself need this ADR revisited.
- The gate now matches the release matrix in coverage without replacing it:
  release still publishes, and `verify_release` still asserts the tags exist.

## More information

Study and tier ladder: #152, where this is tier 2. Version axis:
[ADR-0015](0015-version-support-follows-upstream-eol.md); platform set:
[ADR-0019](0019-platform-support-follows-upstream.md); publication:
[ADR-0018](0018-single-owner-publication-matrix.md). The defect that motivates
testing rather than building: #161, delivered as
[ADR-0017](0017-arch-native-aws-cli-bundle.md) and ADR-0019.

The same change moves the rendering of the container-structure-test config into
`scripts/validate.sh --render-tests`, called by the workflow. That is shared
logic the two callers were writing twice, and moving it implements
[ADR-0016](0016-single-verification-oracle.md) rather than deciding anything new.
