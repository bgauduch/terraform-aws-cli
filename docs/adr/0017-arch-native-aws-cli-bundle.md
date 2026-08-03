# 0017 — Install the arch-native AWS CLI bundle per target platform

- Status: Accepted
- Date: 2026-08-01
- Deciders: bgauduch

## Context and problem statement

The Dockerfile downloaded the `x86_64` AWS CLI v2 bundle unconditionally, while
the image is built and published for several platforms. On any non-amd64
platform the resulting image ships an `aws` binary that cannot execute
natively — surfaced by the verification oracle (ADR-0016) failing its
`aws --version` structure test on an Apple Silicon (arm64) host. AWS publishes
Linux bundles for `x86_64` and `aarch64` only.

## Decision drivers

- The oracle must pass on amd64 CI runners, any amd64 UNIX host and arm64
  (Apple Silicon) hosts alike, building natively on each.
- Signature verification of the bundle must hold on every arch (same GPG key,
  per-arch detached `.sig`).
- No upstream AWS CLI v2 build exists for `arm/v7` or `386`.

## Considered options

- Select the bundle from buildx `TARGETARCH` (`arm64` → `aarch64`, otherwise
  `x86_64`), shipping the matching `.sig` per arch in `security/`
- Keep `x86_64` everywhere and force amd64 (emulated) local builds
- Install the AWS CLI from pip instead of the official bundle

## Decision outcome

Chosen option: **select the bundle from `TARGETARCH`**, because it makes amd64
and arm64 images natively correct with a two-line Dockerfile change, keeps the
official signed bundles, and keeps local verification native (fast) on both
host types. Arches without an upstream bundle keep the `x86_64` fallback —
their prior behaviour — pending a decision on the published platform list.

### Consequences

- Good: published `arm64` images gain a working, natively-signed AWS CLI;
  the oracle builds and tests natively on amd64 and arm64 hosts.
- Cost: each supported AWS CLI version now requires two `.sig` files in
  `security/` (checked by the oracle's structural tier).
- Follow-ups: decide whether `arm/v7` and `386` stay in the published platform
  matrix — their images still carry the non-native `x86_64` binary.

## More information

> **Amended 2026-08-03** — the follow-up above is answered by
> [ADR-0019](0019-platform-support-follows-upstream.md): `arm/v7` and `386`
> leave the published platform set.

- [AWS CLI v2 for Linux ARM announcement](https://aws.amazon.com/blogs/developer/aws-cli-v2-now-available-for-linux-arm/)
- ADR-0016 (single verification oracle) — the failure that surfaced this.
