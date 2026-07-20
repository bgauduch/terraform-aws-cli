# AGENTS.md — instructions for agents working this repository

Tool-agnostic entry point for any agent (AI or human) working `terraform-aws-cli`.
It points to the sources of truth; it does not restate them. Tool adapters point
here — `CLAUDE.md` for Claude Code (ADR-0009); another agent adds its own.

## Sources of truth (read in order)

1. **Tracking issue [#106](https://github.com/bgauduch/terraform-aws-cli/issues/106)** — live status (open PRs/issues, next actions). Its **body is the status SSOT**, edited in place. Keep it current when state changes.
2. **[`docs/agent-conventions.md`](docs/agent-conventions.md)** — the binding hard rules (authorization, branching, commits, roles, scope, language). Read them before acting.
3. **[`docs/roadmap.md`](docs/roadmap.md)** — the plan (phases + Decisions table).
4. **[`docs/adr/`](docs/adr/)** — the decisions and their rationale.

One home per fact: reference these, never copy them.

## Roles

Work is organised by **role**, never model name (ADR-0006): `orchestrator`,
`executor`, `reviewer`. The role→model mapping lives only in the adapter
(`.claude/settings.json`).

## Verifying before you push

The repo ships a Docker image — verify with the tools, don't guess. `dev.sh`
lints, builds and runs the `container-structure-test` assertions; pin/version
data for base bumps comes from
[`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md). CI is the
authoritative (multi-arch) gate.
