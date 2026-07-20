# AGENTS.md — instructions for agents working this repository

**Single, tool-agnostic entry point** for any agent (AI or human) contributing to
`terraform-aws-cli`. It names the sources of truth and the binding rules; it does
**not** duplicate them. Tool-specific adapters point here: `CLAUDE.md` for Claude
Code (ADR-0009). Another agent would add its own thin adapter (e.g. `GEMINI.md`)
without touching this file.

## What this repository is

A minimalist, multi-stage Debian image bundling the **Terraform CLI** + **AWS
CLI**, GPG/checksum-verified, published to Docker Hub. Low-traffic OSS. Recurring
work: bump Terraform / AWS CLI / the Debian base / GitHub Actions, cut releases,
review the Dockerfile.

## Sources of truth (read these, in order)

1. **Tracking issue [#106](https://github.com/bgauduch/terraform-aws-cli/issues/106)** — live status, open PRs/issues, next actions. Its **body is the status SSOT**, edited in place (not rolling comments). Keep it current when state changes.
2. **[`docs/agent-conventions.md`](docs/agent-conventions.md)** — the binding hard rules (authorization, branching, commits, roles, scope, language).
3. **[`docs/roadmap.md`](docs/roadmap.md)** — the plan (phases, decisions table).
4. **[`docs/adr/`](docs/adr/)** — the decisions and their rationale (ADR-0001…).

Reference these; never copy their content elsewhere (one home per fact).

## The rules in one breath

**English only** · Conventional Commits (commits **and** PR titles) · **squash-merge** only · branches `type/topic` / `type/phase-N-topic`, no tool names (ADR-0008) · one PR per phase · a **structural change needs an ADR** (`adr-check` gate; bypass with the `adr-not-needed` label only when implementing an existing ADR).

**The agent opens PRs and drives their CI to green; the human owns the merge**
(ADR-0012). Never merge without a human · never push `master` · never force-push
or rewrite history · never delete a ref without approval · never bypass hooks.
Full text: [`docs/agent-conventions.md`](docs/agent-conventions.md).

## Roles (orchestration)

Work is organised by **role**, never by model name (ADR-0006): `orchestrator`
(planning, diff review before push, ADR drafting), `executor` (scoped
implementation), `reviewer` (diff / security / lint passes). The role→model
mapping is tool-specific and lives in the adapter (`.claude/settings.json` for
Claude Code) — see ADR-0009.

## Verifying a change before you push

This repo ships a Docker image; verify with the tools, don't guess. `dev.sh`
lints (hadolint), builds, and runs the `container-structure-test` assertions.
Version/pin data for Debian bumps is gathered by building against the target base
(see [`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md)). CI is the
authoritative gate (multi-arch); a strong local pass should predict it.
