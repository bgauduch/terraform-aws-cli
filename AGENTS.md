# AGENTS.md — instructions for agents working this repository

Entry point for any agent working `terraform-aws-cli`. Claude Code adapter:
`CLAUDE.md` (ADR-0009); another tool adds its own thin adapter.

## Sources of truth (read in order)

1. **Tracking issue [#106](https://github.com/bgauduch/terraform-aws-cli/issues/106)** — live status (open PRs/issues, next actions). Its **body is the status SSOT**, edited in place. Keep it current when state changes.
2. **[`docs/conventions.md`](docs/conventions.md)** — the working conventions binding every contributor (branching, commits, delivery, ADRs, docs/language).
3. **[`docs/roadmap.md`](docs/roadmap.md)** — the plan (phases + Decisions table).
4. **[`docs/adr/`](docs/adr/)** — the decisions and their rationale.

One home per fact: reference these, never copy them.

## Session rules (binding for agents)

- **`NEVER` merge a pull request** — the human owns the merge, always.
- **Open PRs and drive their CI to green autonomously** (ADR-0012). Report and
  wait when a fix is ambiguous, architecturally significant, or beyond the PR's
  declared scope.
- **`NEVER` delete a branch, tag, or remote ref** without explicit approval.
- **Roles (ADR-0006):** `orchestrator` (planning, diff review before push, ADR
  drafting), `executor` (scoped implementation), `reviewer` (diff/lint/security
  passes). Executor output is diff-reviewed by the orchestrator before push.
  The role→model mapping lives only in `.claude/settings.json`. Phase briefs are
  ephemeral (conversation only) — reconstructable from the roadmap + ADRs.
- The [working conventions](docs/conventions.md) bind agents too.

## Verifying before you push

The repo ships a Docker image — verify with the tools, don't guess. `dev.sh`
lints, builds and runs the `container-structure-test` assertions; pin/version
data for base bumps comes from
[`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md). CI is the
authoritative (multi-arch) gate.
