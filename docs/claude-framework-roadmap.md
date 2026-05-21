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

## Development conventions (hard rules)

These rules bind any Claude session, sub-agent, or human contributor working
under this framework. They apply **now**, even before Phase 1 / Phase 2 land.
They will be extracted to `docs/claude-framework-conventions.md` (Phase 1) and
reflected in `CLAUDE.md` (Phase 2), but this section is the source of truth
until then.

### Authorization (irreversible / shared-state actions)
1. **NEVER merge a pull request without explicit human approval.** Even when
   CI is green and reviews are positive, the human user is the only authority
   that triggers a merge. Claude does not call `merge_pull_request` (or any
   equivalent) on its own initiative.
2. **NEVER push to `master` directly.** All changes flow through a
   phase-specific branch and a pull request.
3. **NEVER create a pull request without an explicit request from the user.**
   Claude commits, pushes, then reports — the user decides when to open the PR.
4. **NEVER force-push, amend pushed commits, or rewrite shared history.**
   Always create a new commit on top.
5. **NEVER bypass hooks** (no `--no-verify`, no `--no-gpg-sign`). A failing
   hook is a signal — fix the cause.
6. **NEVER delete a branch, tag, or remote ref without explicit approval.**

### Branching
7. One branch per phase, named `claude/phase-N-<topic>`, off `master`.
8. One pull request per phase. Phases don't pile up on the same branch.

### Commits
9. Conventional Commits format (`type(scope): subject`). Strict from day one
   (enforced by `.github/workflows/commitlint.yml` once Phase 1 lands).
10. One commit per logical change for reviewability. Avoid mega-commits.
11. Every commit message body ends with the session trailer when produced
    in a Claude session.

### Model and delegation
12. Opus is the orchestrator: planning, briefs, diff review before push,
    structural decisions, ADR drafting.
13. Sonnet executes scoped briefs (implementation, refactors, docs).
14. Every Sonnet delegation **must** be reviewed by Opus (`git diff master..HEAD`)
    before push.
15. Phase briefs are ephemeral (conversation only). They are reconstructable
    from this roadmap + the relevant ADRs, so they don't need to be committed.

### Scope discipline
16. A phase touches only files within its declared scope. Drift discovered
    mid-phase is captured as a follow-up (a TODO in the PR description or a
    new ADR) — not silently included.
17. Out-of-scope items listed in this document are not added back without a
    decision update (and a new entry in the Decisions table).

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
