# `.claude/` — Claude Code adapter layer

This directory is the **tool-specific adapter** for Claude Code (ADR-0009). The
tool-agnostic instructions and rules live in [`AGENTS.md`](../AGENTS.md) and the
docs it points to; this directory only holds what Claude Code reads by name.

| Path | Purpose |
|---|---|
| `settings.json` | Committed Claude Code settings: the **SessionStart hook** wiring (→ `scripts/agent-session-start.sh`), the **role→model mapping** (ADR-0006, tier aliases so model swaps are one edit and drift-free), and a small verify-workflow permission allow-list. |
| `settings.local.json` | Personal, machine-specific overrides. **Git-ignored** — never committed. |

Related, outside this directory:

- [`scripts/agent-session-start.sh`](../scripts/agent-session-start.sh) — the
  agnostic bootstrap the hook runs (Docker daemon behind the egress proxy +
  resume pointer). Kept out of `.claude/` so another agent's adapter can reuse it.
- [`docs/agent-framework.md`](../docs/agent-framework.md) — how the framework and
  the local verify harness fit together.
- [`AGENTS.md`](../AGENTS.md) · [`docs/agent-conventions.md`](../docs/agent-conventions.md)
  · [`docs/roadmap.md`](../docs/roadmap.md) · [`docs/adr/`](../docs/adr/) — the
  agnostic sources of truth.

> Roles are referenced by name everywhere; the concrete model per role lives
> **only** in `settings.json` (ADR-0006). Swapping a model is a one-line change
> here, not a doc-wide edit.
