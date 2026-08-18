# 0019 — Published platforms follow upstream AWS CLI availability

- Status: Accepted
- Date: 2026-08-03
- Deciders: @bgauduch

## Context and problem statement

The image is published for `linux/amd64`, `linux/arm64`, `linux/arm/v7` and
`linux/386`, a set never recorded by a decision — it predates the ADRs. AWS
distributes a Linux AWS CLI v2 bundle for **`x86_64` and `aarch64` only**:
every other architecture returns 404 on the download endpoint (verified
2026-08-01, #161).

Two of the four published platforms therefore cannot carry a working `aws`.
Before ADR-0017 the Dockerfile installed the `x86_64` bundle unconditionally,
so `arm/v7` and `386` images shipped a binary their rootfs cannot execute
(`qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2'`). ADR-0017 made
the install arch-native, which fixed `arm64` and left the other two with no
bundle to install at all. No user report was ever filed for either platform.

## Decision drivers

- A published platform is a promise the image works there; two of them cannot
  be kept.
- Every combination is built for every platform, so the matrix multiplies CI
  cost — the same pressure ADR-0015 addressed on the version axis.
- The rule must not need re-arguing when upstream adds or drops an
  architecture.

## Considered options

- **Keep the four platforms** and let `arm/v7` and `386` ship a broken `aws`:
  the status quo, and the defect #161 opened on.
- **Build AWS CLI v2 from source** for the two unsupported architectures:
  restores coverage, but loses the GPG-signed upstream bundle and adds a Python
  runtime plus qemu-compiled native dependencies to every build, for platforms
  upstream does not support and nobody asked for.
- **Publish only what upstream supports** (chosen): the platform set is derived
  from AWS CLI availability rather than declared independently of it.

## Decision outcome

Chosen option: **published platforms follow upstream AWS CLI availability**.

- Images are published for **`linux/amd64` and `linux/arm64`**, the two
  platforms AWS ships a Linux CLI v2 bundle for.
- The set is derived, not fixed: if AWS publishes a bundle for another
  architecture, that platform becomes publishable under this ADR without a new
  decision; if one disappears upstream, it leaves the same way.
- **Dropping a platform stops new builds only.** Tags already published keep
  the manifests they were pushed with — the immutability guarantee (ADR-0018,
  `docs/rollback.md`) covers the platform dimension as it does the version one.
- This is the platform counterpart of ADR-0015: support follows upstream on
  both axes, so "supported" keeps meaning *works and is maintained*.

### Consequences

- Good: every published platform runs both bundled tools. The `arm/v7` and
  `386` manifests, which could not, stop being produced.
- Good: four platform builds per combination become two, on every
  image-touching PR and on every release.
- Bad: consumers on 32-bit ARM or x86 get no new images. They never had a
  working `aws` on those platforms, so the promise being withdrawn was never
  kept — but the withdrawal is user-visible, hence the breaking-change marker
  on the delivering commit.
- The pull-request build matrix (#152) and any future multi-arch structure tests
  inherit this set rather than defining their own.

  > **Amended 2026-08-18** — this consequence read "the representative CI matrix",
  > the shape #152 proposed at the time. That proposal was rejected in review:
  > [ADR-0020](0020-full-matrix-pull-request-gate.md) has the gate build **and**
  > structure-test every combination on every platform of this set, so the
  > multi-arch structure tests named here now exist. The set itself, and the way
  > it is inherited rather than redeclared, is unchanged.

## More information

Study and decision trail: #161 (maintainer `go` 2026-08-01), delivered in two
parts — [ADR-0017](0017-arch-native-aws-cli-bundle.md) made the AWS CLI install
arch-native, this ADR trims what is published. Version counterpart:
[ADR-0015](0015-version-support-follows-upstream-eol.md). Upstream reference:
[Install or update the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
