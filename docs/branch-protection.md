# Branch protection & merge policy

> Documentary reference for the settings applied via the GitHub UI on the
> default branch (`master`; a later rename to `main` is planned — see [`roadmap.md`](roadmap.md)). Decision: ADR-0002.

## Merge settings (Settings → General → Pull Requests)

- ✅ **Allow squash merging** only — merge commits and rebase merging **disabled**
  (one PR = one commit on the default branch).
- **Default commit message:** *Pull request title and description* — the PR title
  is the Conventional-Commit subject release-please reads; the description body
  carries footers like `BREAKING CHANGE:`.
- ✅ **Automatically delete head branches** after merge.

## Branch protection (Settings → Branches / Rulesets)

For the default branch:

- ✅ **Require a pull request before merging** (no direct pushes).
- ✅ **Require status checks to pass** before merging.
- **Required approving reviews: `0`.**

### Why zero required approvals

This is a **solo-maintained** repository. GitHub forbids approving your own PR,
so a `≥1` requirement is unsatisfiable for a single maintainer and deadlocks
every merge. With `0`, the maintainer remains the gate by reviewing the diff and
clicking **Squash and merge** — that click *is* the human approval required by
the framework (roadmap hard-rule #1). If a second maintainer with write access
joins, raise this to `1`.

`CODEOWNERS` is kept for **ownership and notification**, not as a hard
required-review gate (same self-review limitation).

## Do not rewrite the default branch

Per hard-rule #4, never force-push or rewrite the shared default branch — not
even to "fix" a merge-mode slip (e.g. a rebase-merge that should have been a
squash). Accept the history and correct the *setting* instead. The squash-only
configuration above prevents recurrence.
