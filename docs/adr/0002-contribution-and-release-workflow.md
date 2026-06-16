# 0002 — Contribution & release workflow

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

Releases were manual, commit history had no enforced convention, and two
dependency bots (Dependabot + Renovate) produced overlapping PRs. We want an
automated, predictable contribution-to-release flow.

## Decision drivers

- Automated, changelog-driven releases with minimal manual steps.
- A commit convention machines can parse (for versioning and changelogs).
- A single dependency bot to avoid duplicate/conflicting PRs.
- Low friction for a low-traffic OSS project.

## Considered options

- Release tool: **release-please** vs **Semantic Release**.
- Merge strategy: squash vs merge-commit vs rebase.
- Dependency bot: Renovate only vs Dependabot only vs both.

## Decision outcome

Adopted as one interlocking workflow:

- **Conventional Commits**, strict from day one, enforced by `commitlint` on
  **both** each commit and the **PR title**.
- **Squash-merge** is the chosen strategy (one PR = one commit on `master`); the
  PR title becomes the squash subject and feeds the changelog. Recommended repo
  setting: enable squash with *Default commit message = **Pull request title and
  description*** so footers such as `BREAKING CHANGE:` flow into the commit body
  for release-please. Changes land via PR with a required review; the exact
  GitHub branch-protection/merge settings are maintainer-managed (the live config
  is their source of truth — not mirrored in prose).
- **release-please** drives versioning, changelog and GitHub releases via a
  Release PR; `release.yml` triggers on Release-PR merge. The manual release
  flow is removed.
- Optional opt-in local `.githooks/commit-msg` running commitlint in Docker.
- **Renovate only**; `.github/dependabot.yml` is retired.

release-please was chosen over Semantic Release because its Release-PR model
pairs naturally with squash-merge (the PR title is the unit of change) and keeps
release state reviewable in a PR.

### Consequences

- Good: hands-off releases; consistent history; one bot.
- Cost: contributors must learn Conventional Commits; the in-flight
  Semantic Release work (PR #107) is reworked to release-please.
- Follow-ups: roadmap Phase 1; Renovate extension tracked with #102/#20;
  Dependabot PRs #93–#97 close once Renovate covers their scope.

## More information

Tag strategy is decided separately in ADR-0003.

> **Amended 2026-06-15/16** — recorded the squash *Default commit message*
> recommendation (*Pull request title and description*). Editorial clarification
> of the existing squash decision, not a reversal — see the amend-vs-supersede
> rule in [`README.md`](README.md). Branch-protection / merge settings are
> maintainer-managed in GitHub; the live config is their source of truth — we do
> not mirror mutable infra settings in prose.
