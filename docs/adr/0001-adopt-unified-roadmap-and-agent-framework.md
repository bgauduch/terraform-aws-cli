# 0001 — Adopt a single reconciled roadmap and the agent development framework as SSOT

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

> **Amended 2026-07-31** — the SSOT is split by mutation rate: `docs/roadmap.md`
> holds only the durable plan (phase scopes, decisions) and carries no progress
> state; all live status is tracked solely in the issue #106 body (conventions
> D5). Status annotations were removed from the roadmap accordingly. The
> single-roadmap decision below is unchanged.

## Context and problem statement

The repository was being modernized along two parallel, overlapping plans:
Track A, the epic-based *"plan de modernisation"* (issue #106, epics #98–#105),
and Track B, the *"Claude Code framework roadmap"* (PRs #115/#116). They
targeted the same outcomes but disagreed on structure and tooling, and neither
was authoritative — so the roadmap was not clear, the process not validated, and
there was no single source of truth.

## Decision drivers

- One authority, so contributors (human or AI) know where to look.
- Keep the relevant work from both plans; discard neither.
- A delivery model that yields focused, reviewable changes.
- Discipline that survives context loss.

## Considered options

- Keep Track A (epics + sprints) as the spine, graft the framework in as one epic.
- Keep Track B (phases) as the spine, fold the epics in as phase content.
- Write a brand-new roadmap merging both numbering schemes from scratch.

## Decision outcome

Chosen option: **Track B phased backbone, with the epics folded in as phase
content**, captured in [`docs/roadmap.md`](../roadmap.md) as the single source of
truth.

### Consequences

- Good: one roadmap; phased single-PR delivery; ADR-driven decisions; the
  agent orchestration model is part of the framework.
- Good: every epic task is traced to a phase in the roadmap's disposition table.
- Cost: existing epic PRs (#107–#114) must be re-aligned to the phase model.
- Follow-ups: #115 closed as duplicate; #116 retains its Phase 0 work; #106
  repointed to `docs/roadmap.md`.

> **Amended 2026-08-23** — the SSOT split says where the durable plan lives; it
> never said what the tracking issue may hold, and the issue grew a ledger of
> merged pull requests, closed issues and branches that is retyped in full on
> every edit. An untouched line then goes stale silently: the open-PR table
> drifted on 2026-08-18 and three times on 2026-08-22. Two clauses close it:
>
> 1. The tracking issue's body holds only work in progress that **has no home
>    in GitHub itself**. Anything a GitHub or git query returns — open or
>    closed issues, open or merged pull requests, branches, releases, tags,
>    ADRs — is **never** restated there.
> 2. A learning leaves the body when its home exists, not when someone
>    remembers it. Conventions L4 says a learning is captured transiently then
>    promoted; promoting **includes removing**.
>
> Clause 1 removes the cause rather than the symptom: every session is already
> required to reconcile against `list_pull_requests` / `list_issues` /
> `list_branches`, so storing that answer only creates the drift the
> reconciliation then has to repair. A table that does not exist cannot be
> stale. The delivery obligation this changes is [conventions
> D5](../conventions.md#delivery). Clarification of the split, not a reversal
> (#178).

## More information

Supersedes the standalone `docs/claude-framework-roadmap.md` from #116 and the
plan in issue #106.
