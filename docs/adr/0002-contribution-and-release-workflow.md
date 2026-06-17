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
- **Squash-merge** (one PR = one commit on `master`); the PR title is the squash
  subject and feeds the changelog. Squash default message = *Pull request title
  and description* (carries `BREAKING CHANGE:` footers for release-please).
- **release-please** drives versioning, changelog and GitHub releases via a
  Release PR. Merging that Release PR is the release trigger; the image
  build/push runs in the **same `release-please.yml` workflow**, gated on the
  `release_created` output (no separate `release.yml`, no Personal Access
  Token — the default `GITHUB_TOKEN` suffices). The manual release flow is
  removed.
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

> **Amended 2026-06-15/16** — recorded the squash default commit message
> (*Pull request title and description*). Clarification, not a reversal.
>
> **Amended 2026-06-17** — the build/push runs inside the single
> `release-please.yml` workflow gated on `release_created`, rather than a
> separate tag-triggered `release.yml`. This avoids a Personal Access Token
> (tags pushed by `GITHUB_TOKEN` do not trigger other workflows) and fits the
> low-friction driver. Mechanism clarification; the decision (release-please,
> Release-PR trigger) is unchanged.
