# CLAUDE.md

Thin Claude Code **adapter** (ADR-0009). The instructions live in
[`AGENTS.md`](AGENTS.md) — read it first; it is the tool-agnostic single source of
truth for how to work this repository.

Claude Code reads this file by name, so it stays. It adds only Claude-Code
specifics:

- **Adapter layer:** `.claude/` will hold the Claude Code settings, the role→model
  mapping (ADR-0006), and skills/subagents — added with the agent-foundations
  harness work. `.claude/settings.local.json` is personal and git-ignored.
- **Everything else** — sources of truth, hard rules, roles, verification — is in
  [`AGENTS.md`](AGENTS.md) and the docs it points to
  ([`docs/agent-conventions.md`](docs/agent-conventions.md),
  [`docs/roadmap.md`](docs/roadmap.md), [`docs/adr/`](docs/adr/), tracking issue
  #106). Do not duplicate them here.
