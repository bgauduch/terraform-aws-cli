# 0008 — Conventional branch naming

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

> **Amended 2026-07-21** — the `type/phase-N-topic` variant is dropped. **All**
> branches use `type/<topic>`; phase membership is roadmap/issue domain, not the
> branch name. The `type/topic` core decision below is unchanged.

## Context and problem statement

The original framework convention named branches `claude/phase-N-<topic>`. That
embeds a tool name ("claude") into shared Git history and does not align with the
Conventional Commits vocabulary we already enforce on commits and PR titles
(ADR-0002). We want branch names that are tool-agnostic and consistent with that
vocabulary.

## Decision drivers

- Tool-agnostic naming (no "claude" / agent names in shared refs).
- Consistency with Conventional Commits (already enforced elsewhere).
- Traceability to roadmap phases without rigidity.

## Considered options

- `type/topic` using the Conventional Commits type set.
- `type/NN-topic` always embedding an issue/phase number.
- GitFlow fixed prefixes (`feature/`, `fix/`, `release/`, `chore/`).

## Decision outcome

Chosen option: **`type/topic`** — no phase numbers, no tool names.

- `type` is one of the Conventional Commits types: `feat`, `fix`, `docs`,
  `chore`, `ci`, `refactor`, `build`, `test`, `perf`.
- `topic` is a short kebab-case slug.
- Examples: `docs/framework-foundation`, `ci/pr-triggers`,
  `chore/bump-terraform`, `docs/oss-governance`.

This replaces the earlier `claude/phase-N-<topic>` branch-naming rule in
[`docs/roadmap.md`](../roadmap.md).

### Consequences

- Good: tool-agnostic, consistent with commit/PR conventions, simple (no phase infix to maintain).
- Cost: none material; one rule updated.
- Follow-ups: the roadmap's branch-naming hard rule is updated; the Decisions
  table records this ADR.

## More information

Aligns with ADR-0002 (Conventional Commits). No automated branch-name linting is
added for now; the convention is documented and reviewed.
