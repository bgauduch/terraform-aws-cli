# Agent & contribution conventions

> **Authoritative home for the hard rules** that bind any agent session,
> sub-agent, or human contributor to this repository. These were previously
> inlined in [`docs/roadmap.md`](roadmap.md) and are **extracted here** as their
> single source of truth (the roadmap now points to this file). They apply
> **now**. `AGENTS.md` (repo root) is the entry point that references this file;
> `CLAUDE.md` is the thin Claude Code adapter (ADR-0009).

## Authorization (irreversible / shared-state actions)

1. **NEVER merge a pull request without explicit human approval.** Even with
   green CI and positive reviews, only the human triggers a merge.
2. **NEVER push to `master` directly.** All changes flow through a branch and a
   pull request.
3. **The agent MAY open a pull request and drive its CI to green** without a
   per-PR request (**ADR-0012**, supersedes the former "never open a PR without
   an explicit request"). The agent opens the PR, subscribes to its activity, and
   fixes CI failures autonomously. It **reports and waits** when a fix is
   ambiguous, architecturally significant, or would exceed the PR's declared
   scope. The **human still owns the merge** (rule 1).
4. **NEVER force-push, amend pushed commits, or rewrite shared history.** Always
   add a new commit on top.
5. **NEVER bypass hooks** (no `--no-verify`, no `--no-gpg-sign`). A failing hook
   is a signal — fix the cause.
6. **NEVER delete a branch, tag, or remote ref without explicit approval.**

## Branching & delivery

7. One branch per phase, named `type/phase-N-<topic>` (Conventional-Commits type,
   kebab-case topic), off `master`. Non-phase work uses `type/<topic>`. No tool
   or agent names in branch names. See ADR-0008.
8. One pull request per phase. A phase may be split into a small number of
   sequential PRs **only** if a single PR would be too large to review — they
   stay strictly within the phase scope.

## Commits

9. Conventional Commits (`type(scope): subject`) for **both** commit messages
   **and** PR titles (enforced by `commitlint`). The PR title matters because the
   squash-merge subject feeds the release-please changelog.
10. One commit per logical change for reviewability. Avoid mega-commits.
11. Every commit body ends with the session trailer when produced in an agent
    session.

## Roles and delegation (orchestration)

12. **The `orchestrator` role** owns planning, briefs, diff review before push,
    structural decisions, ADR drafting.
13. **The `executor` role** runs scoped briefs: implementation, refactors, docs.
14. Every `executor` delegation **must** be reviewed by the `orchestrator`
    (`git diff master..HEAD`) before push.
15. Phase briefs are ephemeral (conversation only). They are reconstructable from
    the roadmap + the relevant ADRs, so they are not committed.

> Roles map to concrete models in one place (`.claude/settings.json` for Claude
> Code) per ADR-0006 — never hard-coded in prose. See ADR-0009 for the
> agent-agnostic / tool-adapter split.

## Scope discipline

16. A phase touches only files within its declared scope. Drift discovered
    mid-phase is captured as a follow-up (TODO in the PR description or a new ADR)
    — not silently included.
17. Out-of-scope items are not added back without a decision update (a new entry
    in the roadmap Decisions table and, if structural, an ADR).

## Content & language

18. **English only** for all repo-facing content — code, docs, commit and
    PR/issue text, review comments. This is a public showcase repository.
19. **SSOT — one home per fact.** Community/prose docs cross-link, never copy;
    ADRs may repeat content as frozen records. Public docs never embed internal
    phase numbers (they point to the roadmap; delivering a phase flips
    *planned → present tense*).
20. **Never mirror mutable infra/UI settings in prose** — reference the GitHub
    config (branch protection, merge settings, repo options). Decisions about
    them live in ADRs; live values live in GitHub.

## How to resume a session

Read, in order: the tracking issue **#106** (live status), this file (rules),
[`docs/roadmap.md`](roadmap.md) (plan) and [`docs/adr/`](adr/) (decisions). Live
PR/issue state comes from the GitHub API; reconcile it with #106 and edit that
issue's body in place if it drifted.
