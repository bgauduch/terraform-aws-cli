# 0016 — A single verification oracle shared by human, agent and CI

- Status: Accepted
- Date: 2026-07-31
- Deciders: @bgauduch

## Context and problem statement

The repository's cheap structural invariants (supported versions ↔ signature
material, Dockerfile pins ↔ test assertions, ADR files ↔ index) were checked
by nothing: drift was only caught — sometimes — by an expensive CI build, or
by a human noticing. The harness study (#152, staged `go 1–2` on 2026-07-31)
calls for a fast pre-push oracle (T0) that an agent or a human can iterate
against in seconds, without Docker.

The design risk is duplication: a local script *and* a separate CI
implementation of "the checks" inevitably diverge, and a divergent oracle is
worse than none — green locally must predict green in CI.

## Decision drivers

- "Green locally predicts green in CI" (the verify-before-push discipline,
  ADR-0012 autonomy floor).
- One home per fact (conventions L2) applies to checks as much as to prose.
- T0 must run in seconds with no Docker, so it fits an agent's inner loop.

## Considered options

- A CI-only job implementing the checks (agents keep pushing to find out).
- A local script plus a separately implemented CI job (diverges).
- **One script, three callers**: the same `scripts/validate.sh` invoked by
  the maintainer, by the agent mid-loop, and by a thin `validate.yml` CI job.

## Decision outcome

Chosen option: **one script, three callers**, bounded by one principle:

**The oracle checks only invariants that no purpose-built tool covers, and
it calls tools rather than re-implementing them.** hadolint owns Dockerfile
linting, container-structure-test owns what the built image prints,
commitlint owns messages — the oracle never re-derives their verdicts. Its
territory is the cross-file repository invariants nothing else looks at.

- `scripts/validate.sh` is the **only verification entry point** — for the
  contributor (CONTRIBUTING), the agent (AGENTS.md) and CI alike. `--fast`
  is the T0 oracle: structural checks only, no Docker, seconds;
  `validate.yml` runs exactly this on every pull request and adds no logic
  of its own. `--full` is the T1 tier: the T0 checks, then hadolint, a
  single-platform image build and the container-structure-test run. The
  previous build script is **removed** in the same change: two local entry
  points would themselves violate the single-oracle invariant. `--full`
  therefore also delivers the #104 fixes that script never got — a correct
  platform string, `set -u`, validated version arguments, no needless
  `--interactive`.
- The oracle is built **in passes** (#152 PR 1): pass 1a ships
  `supported_versions.json` ↔ `security/**` (both directions — the orphan
  direction is checked by nothing else at all, and the missing-file
  direction otherwise fails minutes into a build at the GPG step) and ADR
  files ↔ index, hadolint when the binary is available, and the `--full`
  tier. Later passes add the remaining #152 P2 checks (version policy per
  ADR-0015, workflow path filters, GPG key expiry, the L5 dash gate).
- **Deliberately excluded — Dockerfile pins ↔ test-template assertions**: a
  static re-parse would duplicate container-structure-test's authoritative
  detection (T1 via `--full`, T2 in CI) with a necessarily fuzzy version
  comparison (a `10.0p1` package legitimately prints `OpenSSH_10.0p2`), and
  the drift class itself is eliminated at the source by the atomic
  Dockerfile+template writes of the automation scripts (#152 PR 4).
  Rejected in review (2026-07-31) as wheel-reinvention — the principle
  above generalises that review.
- hadolint is **not** duplicated into `validate.yml`: `lint-dockerfile.yml`
  already owns that CI gate; locally the script runs it opportunistically.
- **Orchestration is a thin per-environment adapter** (the ADR-0009
  core/adapter pattern applied to verification): CI workflows keep their
  native machinery (matrix fan-out, GHA build cache, QEMU, hadolint-action's
  PR annotations) and the script keeps the local pipeline — both invoke the
  same tools against the same single-home config (`hadolint.yaml`, the test
  template, `supported_versions.json`, the `Dockerfile`). Shared *logic*
  (e.g. rendering the test config from the template) belongs in the script
  and is called by CI; residual cross-adapter drift (tool versions pinned on
  both sides) is closed by a T0 coherence check rather than by forcing one
  caller through the other's machinery.
- `scripts/` joins the adr-check structural paths in the same change: the
  oracle and the coming capability layer live there, and a change to the
  verifier is structural by nature.

### Consequences

- Good: agents self-verify in seconds instead of paying a CI round-trip;
  the sunset-material drift class is caught at T0; the acceptance criteria
  in #152 become measurable. (The pin/template class stays with its owners:
  container-structure-test detects, the PR 4 scripts prevent.)
- Good: a red `validate` check on a PR means a structural inconsistency in
  the *change*, reviewable in one glance.
- Constraint: a red T0 on `master` is treated as an oracle bug and fixed
  before any other work (#152 acceptance criteria) — the oracle must never
  cry wolf.
- Cost: the checks are bash + jq + grep; contributors need nothing new.

## More information

Study and sequencing: #152 (target architecture, tiers T0–T3, pass plan).
