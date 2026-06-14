# 0001 — Adopt a single reconciled roadmap and the agent development framework as SSOT

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

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

## More information

Supersedes the standalone `docs/claude-framework-roadmap.md` from #116 and the
plan in issue #106.
