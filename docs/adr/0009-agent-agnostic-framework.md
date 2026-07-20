# 0009 — Agent-agnostic framework with a tool-specific adapter layer

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

The framework was authored around "Claude" — naming ("Claude Code framework",
"Claude foundations"), planned files (`docs/claude-framework.md`,
`scripts/claude-session-start.sh`), and hard-coded model names (Opus/Sonnet) in
prose. That couples the framework to one agent and contradicts ADR-0006 (generic
role/tier orchestration) and ADR-0008 (no tool names in shared refs). At the same
time, some artifacts are **mandated by the Claude Code tool** and cannot be
renamed without breaking it.

## Decision drivers

- Portability: the framework should not be tied to a single agent.
- Consistency with ADR-0006 (roles, not model names) and ADR-0008.
- Pragmatism: Claude Code is the agent actually in use; its required files must
  keep their names to function.

## Considered options

- Leave everything Claude-named (status quo).
- Rename everything to be agnostic (breaks the Claude Code tool, which requires
  `.claude/` and `CLAUDE.md`).
- **Two layers: an agnostic core + a thin tool-specific adapter.**

## Decision outcome

Chosen option: **two layers**.

**Agnostic core** (no tool names; portable to any agent):
- SSOT instructions: `AGENTS.md` at repo root.
- Docs: `docs/agent-framework.md`, `docs/agent-conventions.md`, `docs/roadmap.md`.
- Orchestration by **role/tier** (`orchestrator`/`executor`/`reviewer`),
  ADR-0006 — never model names in prose.
- Generic skill *logic* and conventions.

**Tool adapter layer** (Claude Code specifics, clearly labelled as adapter):
- `.claude/` (settings, skills, subagents) and a thin `CLAUDE.md` that points to
  `AGENTS.md`. Claude Code reads these by name, so they keep their names.
- The role→model mapping lives in `.claude/settings.json` (the adapter holds the
  concrete models).
- Another agent (e.g. Gemini CLI) would add its own adapter (e.g. `GEMINI.md`)
  without touching the core.

Legitimate tool references (e.g. `entire enable --agent claude-code`, "Claude
Code support" in ADR-0007) remain — they name a real tool, not the framework.

### Consequences

- Good: portable framework; consistent with ADR-0006/0008; one place per tool.
- Cost: a thin `CLAUDE.md` adapter duplicating a pointer to `AGENTS.md`.
- Follow-ups: implemented as the agent-foundations roadmap work; existing
  docs/ADRs reworded in this change.

## More information

`.claude/` cannot be renamed while Claude Code is the active agent — that is the
reason an adapter layer exists rather than full renaming. Historical references
to the former `claude-framework-roadmap.md` (the superseded Track B file) are
kept as-is for traceability.
