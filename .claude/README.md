# `.claude/` — Claude Code adapter layer

Tool-specific adapter for Claude Code (ADR-0009). Instructions and rules live in
[`AGENTS.md`](../AGENTS.md) and the docs it points to; this directory holds only
what Claude Code reads by name.

| Path | Purpose |
|---|---|
| `settings.json` | SessionStart hook wiring (→ `scripts/agent-session-start.sh`), the role→model mapping (ADR-0006), and a verify-workflow permission allow-list. |
| `settings.local.json` | Personal overrides. **Git-ignored** — never committed. |

The bootstrap the hook runs lives in
[`scripts/agent-session-start.sh`](../scripts/agent-session-start.sh) (kept out of
`.claude/` so other adapters can reuse it); the framework overview is in
[`docs/agent-framework.md`](../docs/agent-framework.md).
