# 0016 — A single verification oracle shared by human, agent and CI

- Status: Accepted
- Date: 2026-07-31
- Deciders: @bgauduch

## Context and problem statement

An **oracle**, here, is whatever decides pass or fail for the repository.
Some invariants span two files and are cheap to decide, yet nothing decided
them: every version in `supported_versions.json` needs its signature
material under `security/`, and every ADR file needs its row in the ADR
index. Drift surfaced only through an expensive CI build, or through a human
noticing. The agent-harness study (#152) asks for a verification entry point
that an agent or a human can run in seconds before pushing, without Docker.

The design risk is duplication: a local script *and* a separate CI
implementation of "the checks" inevitably diverge, and a divergent oracle is
worse than none — green locally must predict green in CI.

## Decision drivers

- Green locally must predict green in CI: ADR-0012 has the agent verify
  before it pushes, which is worthless if the two verdicts differ.
- One home per fact (conventions L2) applies to checks as much as to prose.
- The fast mode must run in seconds without Docker, so it fits inside an
  agent's edit-and-check loop instead of costing a CI round-trip.

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
  contributor (README, CONTRIBUTING), the agent (AGENTS.md) and CI alike.
  `--fast` runs the structural checks only: no Docker, seconds;
  `validate.yml` runs exactly this on every pull request and adds no logic
  of its own. `--full` runs those same checks, then hadolint, a
  single-platform image build and the container-structure-test run.
- **Each direction of a file pair is judged separately**, since the two
  rarely cost the same. For `supported_versions.json` ↔ `security/**`,
  signature material left behind for an unsupported version is reported by
  nothing at all, while a supported version missing its signature file does
  fail on its own, minutes into a build, at the GPG step. `--fast` checks
  both: the first direction is the only detection that exists, the second
  one buys back the wait.
- **Deliberately excluded — Dockerfile pins ↔ test-template assertions**:
  container-structure-test already detects that drift authoritatively, on
  the built image. A static re-parse would re-derive its verdict from the
  source files with a necessarily fuzzy comparison, since a pin and the
  string a tool prints are not the same value (a `10.0p1` package
  legitimately prints `OpenSSH_10.0p2`). Rejected in review (2026-07-31) as
  wheel-reinvention — the principle above generalises that review.
- hadolint is **not** duplicated into `validate.yml`: `lint-dockerfile.yml`
  already owns that CI gate; locally the script runs it when the binary is
  present.
- **Orchestration is a thin per-environment adapter** (the ADR-0009
  core/adapter pattern applied to verification): CI workflows keep their
  native machinery (matrix fan-out, GHA build cache, QEMU, hadolint-action's
  pull-request annotations) and the script keeps the local pipeline — both
  invoke the same tools against the same single-home config
  (`hadolint.yaml`, the test template, `supported_versions.json`, the
  `Dockerfile`). Shared *logic*, such as rendering the test config from its
  template, belongs in the script and is called by CI. Where the two
  adapters can still drift, for instance a tool version pinned on both
  sides, the answer is a `--fast` check comparing them, never routing one
  caller through the other's machinery.
- `scripts/` joins the adr-check structural paths: a change to what verifies
  the repository is structural by nature.

### Consequences

- Good: an agent gets a verdict in seconds instead of paying a CI
  round-trip, and a red `validate` check on a pull request means a
  structural inconsistency in that change, reviewable in one glance.
- Constraint: a red `--fast` on `master` is an oracle bug and is fixed
  before any other work. An oracle that cries wolf gets ignored, and an
  ignored oracle is worse than none.
- Cost: `--fast` needs bash, jq and grep, which CI and contributors already
  have; `--full` needs Docker, as the local build always did.
- Follow-ups: the check inventory, the tier plan and the acceptance criteria
  live in #152; a new check is specified there before it lands here.

## More information

Study and sequencing: #152, which orders every verification this repository
has by cost and authority, from these two local modes up to the release
build that is authoritative. It calls them tier 0 (`--fast`), tier 1
(`--full`), tier 2 (`build-test` on a pull request) and tier 3 (the release
matrix), and abbreviates them `T0` to `T3` — that shorthand belongs to #152
and is not needed to read this decision.
