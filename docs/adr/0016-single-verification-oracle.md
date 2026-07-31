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

Chosen option: **one script, three callers**.

- `scripts/validate.sh --fast` is the T0 oracle: structural checks only, no
  Docker, seconds. `validate.yml` runs exactly this script on every pull
  request; it adds no logic of its own.
- The oracle is built **in passes** (#152 PR 1): pass 1a ships the three
  highest-value checks — `supported_versions.json` ↔ `security/**`,
  Dockerfile apt pins ↔ `tests/container-structure-tests.yml.template`
  assertions (numeric-base comparison: epochs, Debian revisions and pN
  suffixes differ from what tools print), ADR files ↔ index — plus hadolint
  when the binary is available. Later passes add the remaining #152 P2
  checks (version policy per ADR-0015, workflow path filters, GPG key
  expiry, the L5 dash gate) and `--full` (absorbing `dev.sh`, #152 PR 4).
- hadolint is **not** duplicated into `validate.yml`: `lint-dockerfile.yml`
  already owns that CI gate; locally the script runs it opportunistically.
- `scripts/` joins the adr-check structural paths in the same change: the
  oracle and the coming capability layer live there, and a change to the
  verifier is structural by nature.

### Consequences

- Good: agents self-verify in seconds instead of paying a CI round-trip;
  drift classes (the ADR-0011 pin/template class, the sunset material class)
  are caught at T0; the acceptance criteria in #152 become measurable.
- Good: a red `validate` check on a PR means a structural inconsistency in
  the *change*, reviewable in one glance.
- Constraint: a red T0 on `master` is treated as an oracle bug and fixed
  before any other work (#152 acceptance criteria) — the oracle must never
  cry wolf.
- Cost: the checks are bash + jq + grep; contributors need nothing new.

## More information

Study and sequencing: #152 (target architecture, tiers T0–T3, pass plan).
The one-oracle invariant is stated there as "core invariant: one oracle,
three callers".
