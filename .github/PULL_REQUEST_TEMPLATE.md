<!--
PR title MUST follow Conventional Commits (type(scope): subject) — it becomes
the squash-merge subject and feeds the release-please changelog. See docs/roadmap.md.
-->

## Summary

<!-- What does this PR change and why? Reference the roadmap phase / issue. -->

Roadmap phase / closes: <!-- e.g. Phase 1 — closes #105 -->

## Breaking change

<!-- Leave empty unless the PR title carries `!`. If it does, end this
description with a footer line reading `BREAKING CHANGE:` followed by what a
consumer must change. release-please copies that footer verbatim into the
release notes and CHANGELOG.md; without it they only repeat the subject
(conventions C4, enforced by the commitlint job). -->

## Architecture Decision Record

<!-- A structural change (Dockerfile, workflows, supported_versions.json, release/
commit/dependency config, or the agent framework `.claude/`) requires an ADR. See docs/adr/. -->

- [ ] This PR adds/updates an ADR under `docs/adr/` (link: ____)
- [ ] This PR is **not** a structural change — no ADR needed

## Checklist

- [ ] PR title follows Conventional Commits
- [ ] Commits are scoped and reviewable
- [ ] Docs / roadmap updated if behaviour or policy changed
- [ ] Docs point to their single home (no restated facts); intros/sections earn their space
- [ ] Touches only files within the declared phase scope
