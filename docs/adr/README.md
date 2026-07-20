# Architecture Decision Records (ADRs)

This directory holds the **Architecture Decision Records** for
`terraform-aws-cli`. An ADR captures a single significant decision — its
context, the options considered, the choice, and its consequences — so the
*why* behind the repository survives context loss (for humans and AI agents
alike).

## When an ADR is required

Any **structural change** must be accompanied by an ADR. As a rule of thumb, a
change is structural if it touches one of these and alters behaviour or policy:

- `Dockerfile` (stages, base image policy, build approach)
- `.github/workflows/**` (CI/CD topology, release flow, security gates)
- `supported_versions.json` (version-support policy)
- release / commit / dependency-bot configuration
- the agent framework (`.claude/**` adapter, orchestration strategy, skills/agents)

A pure version bump, a typo fix, or a docs tweak does **not** need an ADR.

## How it is enforced

1. **PR template checkbox** — every PR declares "ADR added" or "not structural".
2. **CI gate** — `.github/workflows/adr-check.yml` fails a PR that touches
   structural paths (or carries the `needs-adr` label) without adding a new
   `docs/adr/NNNN-*.md`. Apply the `adr-not-needed` label to bypass with a
   reviewer's blessing.
3. **CODEOWNERS** — changes under `docs/adr/` and structural paths require
   review.

This is strong enforcement, not a mathematical guarantee: "structural" can't be
perfectly auto-detected, so the path heuristic + checkbox + human review is the
realistic ceiling.

## Format

ADRs use the [MADR](https://adr.github.io/madr/) format — see
[`0005-use-madr-format-for-adrs.md`](0005-use-madr-format-for-adrs.md) and the
[`0000-template.md`](0000-template.md).

## Creating one

Copy the template, take the next free number, fill it in, and reference it from
the [roadmap](../roadmap.md) Decisions table. A planned `propose-adr` skill will
scaffold this automatically.

## Amending vs superseding

The **decision** an ADR records is immutable. To change the repository's history
of decisions:

- **Amend in place** when the decision still holds and you are only *clarifying*,
  adding a detail/consequence/link, or recording an implementation specific that
  follows from it. Add a dated `> **Amended YYYY-MM-DD** — …` note so the change
  is traceable. No new ADR.
- **Supersede** when the decision itself *changes or reverses*. Write a new ADR,
  set the old one's status to `Superseded by ADR-XXXX` with a forward pointer,
  and never delete it — the old rationale stays on record.

Rule of thumb: *clarification → amend; reversal → supersede.*

## Index

| ADR | Title | Status |
|---|---|---|
| [0001](0001-adopt-unified-roadmap-and-agent-framework.md) | Adopt a single reconciled roadmap and the agent development framework as SSOT | Accepted |
| [0002](0002-contribution-and-release-workflow.md) | Contribution & release workflow (Conventional Commits, squash, release-please, Renovate) | Accepted |
| [0003](0003-image-versioning-and-tag-strategy.md) | Image versioning and Docker tag strategy | Accepted |
| [0004](0004-deprecate-terraform-below-1.0.md) | Deprecate Terraform versions below 1.0 | Accepted |
| [0005](0005-use-madr-format-for-adrs.md) | Use the MADR format for ADRs | Accepted |
| [0006](0006-agent-orchestration-strategy.md) | Generic, config-driven agent orchestration strategy | Accepted |
| [0007](0007-adopt-entire-checkpoints.md) | Adopt Entire / Checkpoints for agent-session capture | Proposed |
| [0008](0008-conventional-branch-naming.md) | Conventional branch naming | Accepted |
| [0009](0009-agent-agnostic-framework.md) | Agent-agnostic framework with a tool-specific adapter layer | Accepted |
| [0010](0010-apt-package-pinning-strategy.md) | APT package pinning strategy | Accepted |
