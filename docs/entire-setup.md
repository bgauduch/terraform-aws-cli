# Entire / Checkpoints — setup

[Entire](https://entire.io) captures AI-agent sessions (prompts, reasoning, file
changes) alongside Git history. It complements our ADRs: Checkpoints records
*how* a change was produced, ADRs record *why*. Decision: see
[ADR-0007](adr/0007-adopt-entire-checkpoints.md).

## Why this is a local, maintainer-run step

`entire login` is an **interactive device-auth flow** (Anthropic auth) and the
CLI is a binary that must be installed — neither can be done from a headless
CI/agent environment. The repository ships the surrounding scaffold; activation
is one local pass.

## Activation (run locally, once)

```bash
# 1. Install the CLI
brew install --cask entire
# or: curl -fsSL https://entire.io/install.sh | bash

# 2. Authenticate (interactive)
entire login

# 3. Enable for Claude Code (bootstraps config on an unconfigured repo)
entire enable --agent claude-code
```

This generates:

- `.entire/settings.json` — project config (**commit this**)
- `.claude/settings.json` — Claude Code hooks (**commit this**; reconcile with
  the Phase 2 `.claude/settings.json` per ADR-0006)
- `.entire/settings.local.json`, `.claude/settings.local.json` — personal
  overrides (**git-ignored**, already in `.gitignore`)

Session transcripts are stored on a separate `entire/checkpoints/v1` branch, not
on `master`. Push it to the same remote (or a dedicated checkpoints repo) with:

```bash
entire configure --checkpoint-remote github:bgauduch/terraform-aws-cli
```

## After activation

Commit the generated `.entire/settings.json` and `.claude/settings.json`, then
flip [ADR-0007](adr/0007-adopt-entire-checkpoints.md) status from **Proposed** to
**Accepted**.
