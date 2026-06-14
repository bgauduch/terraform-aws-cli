# 0007 — Adopt Entire / Checkpoints for agent-session capture

- Status: Proposed
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

This repository is developed heavily with AI agents. We want a durable,
searchable record of *how* changes were produced (prompts, reasoning, file
changes) linked to Git history, complementing the ADRs that record *why*.
[Entire](https://entire.io) (by Thomas Dohmke, ex-GitHub CEO) ships an OSS CLI,
`entire` / Checkpoints, that captures agent sessions alongside commits and
supports Claude Code.

## Decision drivers

- Capture agent context that today is lost when a session ends.
- First-class Claude Code support.
- Keep the main branch clean (session data stored out-of-band).

## Considered options

- **Adopt Entire / Checkpoints.**
- Rely only on commit trailers + ADRs (status quo).
- A community checkpoint tool (e.g. `ccheckpoints`).

## Decision outcome

Chosen option: **adopt Entire / Checkpoints**, but **scaffold now, activate
locally**. It is complementary to ADRs (Checkpoints = *how*, ADRs = *why*), not a
replacement.

What is committed now (this change):
- `.gitignore` entries for `.entire/settings.local.json` and
  `.claude/settings.local.json`.
- `docs/entire-setup.md` with the activation steps.
- This ADR (status **Proposed** until activation lands).

What the maintainer runs locally (cannot be done from a headless CI/agent
environment because `entire login` is an interactive device-auth flow):

```bash
brew install --cask entire      # or: curl -fsSL https://entire.io/install.sh | bash
entire login                    # interactive device auth
entire enable --agent claude-code
```

Then commit the generated `.entire/settings.json` and `.claude/settings.json`.
Session transcripts live on a separate `entire/checkpoints/v1` branch, not on
`master`.

### Consequences

- Good: durable, searchable agent-session history linked to commits.
- Risk: early-stage product; account/auth dependency; `.claude/settings.json`
  overlaps with roadmap Phase 2 — sequence the two together.
- Bad: cannot be fully automated from CI (interactive login).
- Status flips to **Accepted** once activation is committed.

## More information

- https://entire.io · https://github.com/entireio/cli
- Sequence with roadmap Phase 2 (Agent foundations) so `.claude/settings.json`
  is authored once, consistently with ADR-0006.
