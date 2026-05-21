# Claude Code framework — roadmap

> **Source of truth for the Claude Code framework adoption in this repository.**
> Last updated: 2026-05-21
> Status: Phase 0 in progress

## Why this document exists

This file freezes the plan agreed in the planning session of 2026-05-21. It
survives context loss and onboards future contributors (human or AI) to the
agentic tooling adopted in this repository. Decisions are summarised here and
detailed in their respective ADRs (`docs/adr/`).

## Repository profile

Minimalist Docker image bundling Terraform CLI + AWS CLI on Debian. Low-traffic
OSS project. Recurring tasks: bumping Terraform / AWS CLI versions, bumping the
Debian base image, bumping GitHub Actions, cutting releases, reviewing the
Dockerfile.

Reference repository: `bgauduch/terraform-aws-cli` (the `zenika-open-source`
upstream is no longer maintained).

## Decisions

| Topic | Decision | ADR |
|---|---|---|
| Image versioning | Repo semver `vX.Y.Z`; image tags derived | ADR-0003 |
| Tag strategy (P0 subset) | `latest`, `edge`, `vX.Y.Z`, `vX.Y`, fully-pinned immutable | ADR-0003 |
| Commit convention | Conventional Commits, **strict** from day one | ADR-0002 |
| Release automation | release-please (Google), Release PR workflow | ADR-0002 |
| Local commit-msg hook | Standalone `.githooks/commit-msg` running commitlint in Docker, opt-in | ADR-0002 |
| Dependency bot | Renovate only (Dependabot retired) | ADR-0002 |
| ADR format | MADR (Nygard considered, rejected for simplicity) | ADR-0005 |
| Terraform deprecation | Drop versions < 1.0 from `supported_versions.json` | ADR-0004 |
| Rollback policy | No mutation of immutable full tags; consumers re-pin an older tag | `docs/rollback.md` |
| Multi-agent plan validation | Simplified to a single `tech-architect` agent (no 4-agent panel) | — |
| End-user persona agents | Two distinct agents: `end-user-sre-ci`, `end-user-dev-local` | — |
| Supply chain | Trivy scan, SBOM (SPDX), SLSA provenance, cosign signing | — |
| PostToolUse ADR nudge hook | Deferred (rely on skill description + CLAUDE.md rule + PR checkbox) | — |
| `audit-claude-framework` skill | Replaced by a monthly CI health-check workflow | — |
| MCP custom servers | Out of scope | — |

## Phases

Each phase is delivered as **one pull request** to enable focused review.

### Phase 0 — Cleanup (P0, prerequisite)
Pure hygiene, no new tooling.
- This roadmap document
- Fix `push-latest.yml` (`supported_platforms.json` inexistent reference, wrong `hashicorp.asc` path)
- Fix `build-test.yml` (wrong `hashicorp.asc` path)
- Fix `dockerhub-description-update.yml` (wrong watched path filter)
- Refresh `docs/dependencies-upgrades.md` (bullseye → bookworm, accurate package list and paths)

### Phase 1 — OSS conventions, commits, release (P0)
- `CONTRIBUTING.md`, `SECURITY.md`, `CODEOWNERS`
- `.github/PULL_REQUEST_TEMPLATE.md` (ADR checkbox)
- `.github/ISSUE_TEMPLATE/` : `bug.yml`, `bump-version.yml`, `feature.yml`
- `.commitlintrc.json` + `.github/workflows/commitlint.yml` (**strict**)
- release-please config + workflow; migrate `release.yml` to trigger on Release PR merge
- New tag strategy applied (P0 subset)
- Retire `.github/dependabot.yml`, extend `renovate.json`
- Clean `supported_versions.json` (drop TF < 1.0)
- ADR-0001 to ADR-0005
- `docs/rollback.md`
- `docs/branch-protection.md` (documentary; apply via GitHub UI)

### Phase 2 — Claude foundations (P0)
- `CLAUDE.md` at repo root (sources of truth, ADR rule, no hard-coded values)
- `.claude/README.md` (framework map)
- `docs/claude-framework.md` (architecture, walkthrough, token cost notes)
- `.claude/settings.json` (permissions allowlist; no PostToolUse hook yet)
- `.gitignore` : `.claude/settings.local.json`
- `scripts/claude-session-start.sh` (SessionStart hook)

### Phase 3 — Skills (P1)
- `bump-terraform-version`
- `bump-awscli-version`
- `bump-debian-base`
- `propose-adr` (triggers in `SKILL.md` description; auto-discovery)
- `validate-supported-versions` (matrix check `supported_versions.json` ↔ `security/`)
- `.githooks/commit-msg` local hook (Docker-based, opt-in; documented in `CONTRIBUTING.md`) — deferred from Phase 1

### Phase 4 — Subagents and slash commands (P1)
Downstream `/preflight`:
- `dockerfile-reviewer`
- `security-reviewer` (hadolint + Trivy + GPG chain)
- `ci-doctor` (workflow paths ↔ files coherence)
- `commit-message-validator`

Upstream `/plan`:
- Single `tech-architect` agent (poses structural questions, flags `adr_required`)
- `end-user-sre-ci` and `end-user-dev-local` as on-demand consultative agents

### Phase 5 — Security CI (P1)
- Trivy scan in `build-test.yml` (fail on critical, non-patchable)
- SBOM SPDX (`--sbom=true`) in `push-latest.yml` and `release.yml`
- SLSA provenance attestation (`--attest=type=provenance,mode=max`)
- cosign signing (keypair in GitHub Secrets)
- `validate-supported-versions.yml` workflow

### Phase 6 — Durability and bonuses (P2)
- Monthly `health-check-claude-framework.yml`
- `actions/stale` for PR/issues
- "Last reviewed" section in `CLAUDE.md`
- Multi-arch container-structure-tests (at least `linux/arm64`)
- Image size regression guard
- Integration test (`terraform init` smoke test)
- Additional tag aliases if demand emerges (`terraform-A.B.C`, `terraform-A.B`)
- Re-evaluate the multi-agent panel idea after 3 months of usage

## Explicitly out of scope

- Custom MCP servers
- `audit-claude-framework` as a Claude skill (replaced by CI)
- Generic pre-commit framework (Python dependency)
- Pre-push git hooks (covered by `/preflight` + CI)
- PostToolUse hook for ADR nudge (unless we observe Claude forgetting in practice)
- Retroactive backfill of ADRs
- Image variants (alpine, slim)

## Conventions for evolution

- This roadmap is updated when a decision is added or changed; older entries
  are not deleted but marked superseded with a pointer to the new ADR.
- Every structural change requires an ADR. See `.claude/skills/propose-adr`
  (Phase 3+).
- Every phase delivery is a single PR; the PR description references the
  phase block above.
- `CLAUDE.md` and skill files reference sources of truth (JSON files, ADRs)
  rather than embedding values that drift.
