# 0015 — Version support follows upstream EOL (sunset policy)

- Status: Accepted
- Date: 2026-07-31
- Deciders: @bgauduch

## Context and problem statement

`supported_versions.json` only ever grows: 16 Terraform minor lines (1.0 →
1.15) at decision time, plus roughly three new minors per year, with no
retirement rule. ADR-0004 set a fixed floor (drop `< 1.0`) but nothing rolls
that floor forward. Consequences:

- **CI economics**: ~80 platform builds per Dockerfile-touching PR (16 combos ×
  5 builds) — the root cause behind the build-matrix and cache pressure studied
  in #150 and #152.
- **CVE surface**: old bundled Terraform binaries accrue vulnerabilities that
  upstream will never patch.
- **False promise**: listing a version as "supported" implies maintenance;
  HashiCorp had stopped patching 14 of the 16 listed lines.

Upstream facts (verified 2026-07-31): HashiCorp ships code-fixes and hot-fixes
as patch releases on the **latest two "major release" lines only** — an X.Y
bump (1.14 → 1.15) counts as a major release — with GA support capped at two
years ([Support Period and EOL Policy](https://support.hashicorp.com/hc/en-us/articles/360021185113-Support-Period-and-End-of-Life-EOL-Policy)).
The AWS CLI has a single actively maintained v2 line; the matrix already
carries exactly one AWS CLI version.

## Decision drivers

- "Supported" should mean *maintained*, matching upstream reality.
- Durably bound the build matrix, the `security/` material and the CVE surface.
- Never strand users: published images must stay pullable (ADR-0003).
- A rule that needs no re-arguing as versions ship.

## Considered options

- Fixed floor only (status quo, ADR-0004).
- Upstream patched window, strict (latest two minor lines).
- **Upstream patched window plus a one-release grace (latest three minor lines).**
- Upstream two-year GA window (~6 lines; window drifts with release cadence).
- Fixed N latest minors (N arbitrary).

## Decision outcome

Chosen option: **support follows upstream EOL, with a one-release grace**.

- Supported Terraform versions are the **latest three minor lines**: the two
  lines HashiCorp still patches, plus the most recently retired line kept for
  one more minor cycle (grace). One patch per minor line (unchanged from
  ADR-0004's practice).
- When a new minor ships, `supported_versions.json` gains it and drops the
  oldest listed line, in the same change.
- At decision time the matrix becomes `1.13.x`, `1.14.x`, `1.15.x` (16 → 3
  lines); the `security/` signature material of retired lines is removed with
  it.
- **Retirement stops new builds only.** Every previously published fully-pinned
  immutable tag (`vX.Y.Z_tf-A.B.C_aws-D.E.F`) remains pullable forever and is
  never rebuilt or deleted (ADR-0003, `docs/rollback.md`). The README states
  this as part of the user-facing contract.

### Consequences

- Good: matrix 16 → 3 (~80 → ~15 platform builds per PR before any CI-side
  subsetting); `security/` shrinks accordingly; the support promise is honest
  and self-maintaining.
- Bad: users tracking a retired line get no new combinations for it — they
  re-pin an older immutable tag or upgrade Terraform. This narrows the
  user-facing contract, hence the breaking-change marker on the delivering
  commit.
- Supersedes ADR-0004: the fixed `>= 1.0` floor is subsumed by the rolling
  window (which can never re-admit pre-1.0). ADR-0004's "drop below the latest
  two minor lines" option, rejected then, is effectively adopted here in its
  graced form — upstream's policy became the arbiter.
- Follow-ups: the version-bump automation gains a retire-on-EOL step alongside
  add-on-release (#152, #20); a fast-check asserting "no out-of-policy version
  in the matrix" joins the validation oracle when it lands (#152); the
  representative CI subset (#152) is computed against the sunset matrix.

## More information

Study and decision trail: #157 (maintainer `go` 2026-07-31, option A plus
grace). Upstream references:
[HashiCorp Support Period and EOL Policy](https://support.hashicorp.com/hc/en-us/articles/360021185113-Support-Period-and-End-of-Life-EOL-Policy),
[endoflife.date/terraform](https://endoflife.date/terraform).
