# Roadmap — terraform-aws-cli

> **Single source of truth** for the modernization and the agent development framework
> of this repository. This document reconciles and supersedes the two former
> plans:
>
> - Track A — *"Plan de modernisation"* (issue #106 + epics #98–#105)
> - Track B — *"Claude Code framework roadmap"* (PRs #115 / #116)
>
> Last updated: 2026-07-20 · Status: Phases 0–1 complete; Phase 3 Debian-trixie base merged (#133); Phase 2 (agent foundations) in progress
>
> Reconciliation decisions validated 2026-06-14:
> phases backbone (epics folded in as content) · release-please ·
> floating + immutable tags · Renovate only (Dependabot retired).

## Why this document exists

The repository was being modernized along two parallel plans that targeted the
same outcomes but disagreed on structure and tooling. This file merges them into
one authority so that the **roadmap is clear**, the **process is documented and
validated**, and the **framework is single-source-of-truth**.

It freezes the agreed plan, survives context loss, and onboards future
contributors (human or AI). Decisions are summarised in the Decisions table and
detailed in their ADRs (`docs/adr/`).

## Repository profile

Minimalist Docker image bundling Terraform CLI + AWS CLI on Debian. Low-traffic
OSS project. Recurring tasks: bumping Terraform / AWS CLI versions, bumping the
Debian base image, bumping GitHub Actions, cutting releases, reviewing the
Dockerfile.

Reference repository: `bgauduch/terraform-aws-cli` (the `zenika-open-source`
upstream is no longer maintained).

---

## Orchestration & development conventions (hard rules)

The binding conventions live in their single authoritative homes, split by
audience: **[`docs/conventions.md`](conventions.md)** (shared working
conventions — branching, commits, delivery, ADRs, docs/language) and
**`AGENTS.md`** (agent-session rules: authorization boundaries, roles;
Claude Code adapter `CLAUDE.md`, ADR-0009). Durable records reference rules by
concept; PR autonomy is governed by ADR-0012 (the agent opens PRs and drives CI
to green; the human owns the merge).

---

## Decisions

| Topic | Decision | ADR |
|---|---|---|
| Roadmap structure | Phases backbone; the former epics #98–#105 are folded in as phase content | this doc |
| Image versioning | Repo semver `vX.Y.Z`; image tags derived | ADR-0003 |
| Tag strategy | Floating `latest`, `edge`, `vX.Y.Z`, `vX.Y` **+** fully-pinned immutable `vX.Y.Z_tf-A.B.C_aws-D.E.F` | ADR-0003 |
| Commit convention | Conventional Commits, **strict** from day one (commit history **and** PR titles) | ADR-0002 |
| Merge strategy | **Squash-merge** (one PR = one commit on `master`); PR title becomes the squash subject and feeds the changelog | ADR-0002 |
| Release automation | **release-please** (Google), Release-PR workflow | ADR-0002 |
| Local commit-msg hook | Standalone `.githooks/commit-msg` running commitlint in Docker, opt-in | ADR-0002 |
| Dependency bot | **Renovate only** (Dependabot retired) | ADR-0002 |
| ADR format | MADR (Nygard considered, rejected for simplicity) | ADR-0005 |
| Terraform deprecation | Drop versions `< 1.0` from `supported_versions.json` | ADR-0004 |
| APT package pinning | OS utility packages **pinned** to exact versions (refreshed when Debian supersedes a pin); bundled binaries stay pinned + GPG/checksum verified | ADR-0010 |
| Base image | Debian 13 (`trixie`), pinned by immutable `sha256` digest | ADR-0011 |
| Rollback policy | No mutation of immutable full tags; consumers re-pin an older tag | `docs/rollback.md` |
| ADR enforcement | PR-template checkbox + `adr-check.yml` CI gate + CODEOWNERS (no soft-rule-only) | this doc |
| Branch naming | `type/topic` (Conventional types); no tool names | ADR-0008 |
| Agent-agnostic framework | Generic core (agnostic docs + naming, role/tier orchestration); `.claude/` + `CLAUDE.md` are the Claude Code **adapter** layer | ADR-0009 |
| Agent orchestration | Role/tier abstraction (`orchestrator`/`executor`/`reviewer`), model mapping in `.claude/settings.json` (generic, drift-free) | ADR-0006 |
| PR autonomy | Agent opens PRs & drives CI to green; the human owns the merge | ADR-0012 |
| Docs SSOT & concision | Docs point to one home, never restate; prose earns its space | `docs/conventions.md` |
| Agent session capture | Adopt Entire / Checkpoints — scaffold now, activate locally | ADR-0007 |
| Multi-agent plan validation | Single `tech-architect` agent (no 4-agent panel) | — |
| End-user persona agents | Two on-demand agents: `end-user-sre-ci`, `end-user-dev-local` | — |
| Supply chain | Trivy scan, SBOM (SPDX), SLSA provenance, cosign signing | — |
| PostToolUse ADR nudge hook | Deferred (rely on skill description + agent-instructions rule + PR checkbox) | — |
| `audit-agent-framework` skill | Replaced by a monthly CI health-check workflow | — |
| MCP custom servers | Out of scope | — |

Superseded plans: issue #106 and PRs #115 (close) / #116 (its Phase 0 work is
retained, its roadmap doc is replaced by this file).

> **Brought forward (delivered ahead of Phase 1):** the ADR system now exists at
> `docs/adr/` (ADR-0001…0007) capturing every decision above, together with its
> enforcement (`.github/PULL_REQUEST_TEMPLATE.md`, `.github/workflows/adr-check.yml`,
> `.github/CODEOWNERS`). The Entire scaffold (`docs/entire-setup.md`, `.gitignore`)
> is also in place; activation is a local maintainer step (ADR-0007).

---

## Phases

Each phase is delivered as **one pull request** (split only when a single PR
would be too large to review — see the delivery conventions)
to enable focused review. The "Folds in" column traces each former epic to its
new home.

### Phase 0 — Cleanup *(P0, in progress — PR #116)*
Pure hygiene, no new tooling.
- This roadmap document (replaces the former `claude-framework-roadmap.md`)
- Fix `push-latest.yml` (`supported_platforms.json` inexistent ref, wrong `hashicorp.asc` path → `security/**`)
- Fix `build-test.yml` (wrong `hashicorp.asc` path → `security/**`)
- Fix `dockerhub-description-update.yml` (wrong watched path filter)
- Refresh `docs/dependencies-upgrades.md` (bullseye → bookworm, accurate package list and paths)

### Phase 1 — Commits, release & OSS governance *(P0)* — folds in #101, #102, #105, part of #98
The contribution + release machinery. May split into 1a (governance docs) and
1b (commits/release/bots) if too large.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODEOWNERS` *(#105)*
- `.github/PULL_REQUEST_TEMPLATE.md` (ADR checkbox) + `.github/ISSUE_TEMPLATE/` (`bug.yml`, `bump-version.yml`, `feature.yml`) *(#105)*
- `.commitlintrc.json` + `.github/workflows/commitlint.yml` validating each PR commit **and** the PR title; **strict** failure mode *(#101)*
- **release-please** config + a single `release-please.yml` workflow (versioning/changelog/GitHub release, with the image build/push gated on the Release-PR merge via the `release_created` output); remove the manual release flow *(#101)*
- Branch protection applied via the GitHub UI (squash-merge, required review)
- Tag strategy applied — P0 subset (`latest`, `vX.Y.Z`, fully-pinned)
- **Retire `.github/dependabot.yml`; extend `renovate.json`** (grouping, automerge patches, `chore(deps):` prefix, custom manager for `supported_versions.json`) *(#102, relates #20)*
- Clean `supported_versions.json` — drop Terraform `< 1.0` *(part of #98)*
- `README.md` governance refresh + badges (CI, latest release, GHCR, cosign) *(#105)*
- ADR-0001 … ADR-0005, `docs/rollback.md`

### Phase 2 — Agent foundations *(P0)* — Track B
Agnostic core + a thin Claude Code adapter (ADR-0009).
- `AGENTS.md` at repo root — agnostic SSOT (sources of truth, ADR rule, no hard-coded values); thin `CLAUDE.md` adapter pointing to it (Claude Code reads `CLAUDE.md`)
- `docs/agent-framework.md` (architecture, walkthrough, token-cost notes) + `docs/conventions.md` (the working conventions, extracted from this file)
- `.claude/README.md` (Claude adapter map)
- `.claude/settings.json` — permissions allowlist **+ the role→model mapping** (`orchestrator`/`executor`/`reviewer`) per ADR-0006; no PostToolUse hook yet
- `.gitignore`: `.claude/settings.local.json` *(done early)*
- `scripts/agent-session-start.sh` (SessionStart hook)
- Reconcile with Entire-generated `.claude/settings.json` if Entire is activated (ADR-0007 / `docs/entire-setup.md`)

### Phase 3 — Versions & distribution *(P0)* — folds in #98, #100
Urgent: current versions are frozen at end-2023 and accrue CVEs.
- Bump Debian base image (`bookworm-20231120-slim` → Debian 13 `trixie`, digest-pinned) — **done, ADR-0011** *(#98)*
- Re-pin APT packages in all stages (`curl`, `gnupg`, `ca-certificates`, `git`, `jq`, `openssh-client`, `unzip`) *(#98)*
- Add recent Terraform (1.7.x → 1.11.x) and AWS CLI (2.15.x → 2.17.x) to `supported_versions.json`; regenerate `security/` files (`.asc`, `SHA256SUMS`, `.sig`) *(#98)*
- Bump GitHub Actions (`checkout`, `setup-qemu`, `setup-buildx`, `build-push`, `dockerhub-description`), `container-structure-test`, `hadolint` *(#98)*
- Rename image `zenika/terraform-aws-cli` → `bgauduch/terraform-aws-cli` everywhere *(#100)*
- Publish to `ghcr.io/bgauduch/terraform-aws-cli` as second registry *(#100)*
- Replace `echo | docker login` with `docker/login-action` (DockerHub + GHCR) *(#100, closes #60)*
- Implement full tag strategy: `latest`, `edge`, `vX.Y.Z`, `vX.Y`, fully-pinned `vX.Y.Z_tf-A.B.C_aws-D.E.F` *(#100)*
- Enable Docker Scout CVE monitoring *(#100)*

### Phase 4 — CI/CD hardening & code quality *(P1)* — folds in #103, #104
- Add `pull_request` trigger to `lint-dockerfile` and `build-test` *(#103, closes #46)*
- Add `concurrency:` to every workflow (cancel stale runs) *(#103)*
- Harmonise buildx `cache-from` / `cache-to` across workflows *(#103)*
- Restrict multi-arch build (`amd64,arm64,arm/v7,386`) to publish workflows only *(#103)*
- `dev.sh`: `getopts` parsing, semver validation, fix `PLATEFORM`→`PLATFORM` typo, `set -euo pipefail` *(#104)*
- Dockerfile: merge separate `apt-get install` RUN layers in the `terraform` and `aws-cli` stages *(#104)*
- Extend `container-structure-tests.yml.template`: negative tests (non-root user), binaries-in-`PATH` checks *(#104)*

### Phase 5 — Supply chain security *(P1)* — folds in #99
- `aquasecurity/trivy-action` in `build-test.yml` — fail on critical, non-patchable *(#99)*
- SBOM SPDX (`anchore/sbom-action` / `--sbom=true`) attached to releases *(#99)*
- SLSA provenance attestation (`--attest=type=provenance,mode=max`) *(#99)*
- cosign keyless signing (OIDC GitHub Actions) of published images *(#99)*
- Explicit least-privilege `permissions:` on every job *(#99)*
- `validate-supported-versions.yml` (matrix check `supported_versions.json` ↔ `security/`)

### Phase 6 — Agent skills & subagents *(P1)* — Track B
Skills (auto-discovered via `SKILL.md` descriptions):
- `bump-terraform-version`, `bump-awscli-version`, `bump-debian-base`
- `propose-adr`, `validate-supported-versions`
- `.githooks/commit-msg` local hook (Docker-based, opt-in; documented in `CONTRIBUTING.md`)

Subagents & slash commands:
- Downstream `/preflight`: `dockerfile-reviewer`, `security-reviewer` (hadolint + Trivy + GPG chain), `ci-doctor` (workflow paths ↔ files coherence), `commit-message-validator`
- Upstream `/plan`: single `tech-architect` agent (poses structural questions, flags `adr_required`); `end-user-sre-ci` and `end-user-dev-local` as on-demand consultative agents

### Phase 7 — Durability & bonuses *(P2)*
- Monthly `health-check-agent-framework.yml`
- `ossf/scorecard-action` (OpenSSF score) *(#105)*
- `actions/stale` for PRs/issues
- "Last reviewed" section in `AGENTS.md`
- Multi-arch container-structure-tests (at least `linux/arm64`)
- Image-size regression guard
- Integration smoke test (`terraform init`)
- `wagoodman/dive` image analysis in CI *(#25)*
- Additional tag aliases if demand emerges (`terraform-A.B.C`, `terraform-A.B`)
- Re-evaluate the multi-agent panel after 3 months of usage

### Phase 8 — Default branch rename `master` → `main` *(P2, not top priority)*
Low-priority hygiene; cross-cutting, so delivered as its own phase.
- Rename the default branch `master` → `main` (GitHub UI)
- Update workflow refs across `.github/workflows/**` (`branches: [master]`, `!master`, base-branch assumptions)
- Re-point branch protection + squash/auto-delete settings to `main`
- Update docs that hard-code `master` (this roadmap's hard rules, README badges/links, ADRs, `dev.sh` if needed)
- Update external links pointing at `master` (Docker Hub description, badges)
- Record the rename in an ADR when executed

---

## Open PR & issue disposition

How the existing work is preserved or retired under the reconciled plan.

| Item | Disposition |
|---|---|
| PR #116 *(Phase 0)* | **Closed** — superseded by #119, which carries the workflow path fixes + deps-doc refresh without the obsolete roadmap doc |
| PR #115 *(roadmap doc only)* | **Close** — duplicate, superseded by this document |
| PR #107 *(semantic-release)* | Rework into Phase 1 with **release-please**; salvage the commitlint parts |
| PR #109 *(renovate)* | Fold into Phase 1; ensure Dependabot retirement |
| PR #113 *(docs/governance)* | Fold into Phase 1 |
| PR #108 *(versions)*, #110 *(distribution)* | Fold into Phase 3 |
| PR #114 *(CI/CD)*, #112 *(code quality)* | Fold into Phase 4 |
| PR #111 *(supply chain)* | Fold into Phase 5 |
| Dependabot PRs #93–#97 | **Close** in favour of Renovate (Phase 1); re-apply needed action bumps in Phase 3 |
| External PR #90 *(TF/AWS bump)* | Superseded by Phase 3 version work — thank & close |
| External PR #88 *(python3)* | Tied to the python3 question (#80, #92); decide separately (see below) |
| Issues #98–#105 *(epics)* | Convert to phase trackers or close once their tasks are absorbed |
| Issue #106 *(tracking)* | Repoint to this document as the single roadmap |
| Issues #46, #60, #20, #25 | Addressed within phases (see "closes" annotations) |
| Issues #13 *(completion)*, #16 *(aws provider)*, #91 *(git-lfs)*, #80/#92 *(python3)*, #81 *(cache-key bug)* | Backlog — not in any phase yet; triage individually |

---

## Explicitly out of scope

- Custom MCP servers
- `audit-agent-framework` as an agent skill (replaced by CI)
- Generic pre-commit framework (Python dependency)
- Pre-push git hooks (covered by `/preflight` + CI)
- PostToolUse hook for ADR nudge (unless the agent is observed forgetting in practice)
- Retroactive backfill of ADRs
- Image variants (alpine, slim)
- Bundling python3 in the image (revisit #80/#88/#92 only if demand is strong; document the workaround instead)

## Conventions for evolution

- This roadmap is updated when a decision is added or changed; older entries are
  not deleted but marked superseded with a pointer to the new ADR.
- Every structural change requires an ADR. See `.claude/skills/propose-adr`
  (Phase 6).
- Every phase delivery is a single PR; the PR description references the phase
  block above.
- Agent instructions (`AGENTS.md`/`CLAUDE.md`) and skill files reference sources
  of truth (JSON files, ADRs) rather than embedding values that drift.
