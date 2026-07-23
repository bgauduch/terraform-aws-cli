# Working conventions

Binding conventions for every contributor, human or agent. Each section below
has a stable anchor — other docs **link to a section, never restate it**.
Agent-session rules (authorization boundaries, roles) live in
[`AGENTS.md`](../AGENTS.md).

## How rules are written

- One bold imperative sentence, plus at most two supporting sentences.
- Binary: a reviewer can answer yes/no "was this followed?" on a given change.
  Advisory guidance lives in `docs/` or an ADR, not here.
- No judgement words; `NEVER` / `ALWAYS` / `MAY` mark the binding verbs.
- Evolutions: append to the relevant section — per-section numbers (B1, C2, …)
  never shift; amend with a dated note; new rules arrive via the learning
  pipeline (L4). Durable records (ADRs) reference rules **by concept**, not by
  number.
- If this file outgrows quick scanning (~150 lines), split it into
  `docs/conventions/` (one file per section) — as an explicit, separate change.

## Branching

- **B1 — Branches are named `type/<topic>`**: a Conventional-Commits type + a
  short kebab-case slug, off `master`. `NEVER` tool or agent names (tools
  default to them). See ADR-0008.
- **B2 — Every change flows through a branch and a pull request.** `NEVER` push
  `master` directly.
- **B3 — `NEVER` force-push, amend pushed commits, or rewrite shared history.**
  Add commits on top; integrate `master` by merging it into the branch (the
  squash-merge flattens it at the end).

## Commits

- **C1 — Conventional Commits for commit messages AND PR titles**
  (`type(scope): subject`, enforced by commitlint). The PR title becomes the
  squash-merge subject and feeds the release-please changelog.
- **C2 — One commit per logical change.**
- **C3 — `NEVER` bypass hooks** (no `--no-verify`, no `--no-gpg-sign`) — a
  failing hook is a signal; fix the cause.

## Delivery

- **D1 — Squash-merge only**: one PR becomes one commit on `master`.
- **D2 — One focused PR per unit of work.** A roadmap phase ships as one PR,
  split only when a single PR would be too large to review.
- **D3 — A PR touches only its declared scope.** Drift discovered mid-work is
  captured as a follow-up (PR description, issue, or ADR), `NEVER` silently
  included; out-of-scope items return only with a decision update.
- **D4 — A PR's title and description track its current content.** When new
  commits change what the PR delivers, update both in the same pass (the
  title's downstream role: C1).
- **D5 — A state change ships with its status update.** Opening, merging or
  closing a PR — or completing a tracked task — edits the tracking issue (#106)
  body in the same gesture; epic/phase checklists are ticked when the
  delivering PR merges. *(Added 2026-07-23.)*

## ADRs

- **A1 — A structural change ships with an ADR** (`adr-check` CI gate; the
  `adr-not-needed` label only when implementing an existing ADR). The **ADR
  requirement** — what is structural, and when a dated note suffices instead —
  is defined in [`docs/adr/README.md`](adr/README.md).

## Documentation & language

- **L1 — English only** for all repo-facing content: code, docs, commits,
  PR/issue text, review comments.
- **L2 — One home per fact; docs point, `NEVER` restate.** ADRs may repeat
  content as frozen records. Prose earns its space: intros and sections must
  add information.
- **L3 — `NEVER` mirror mutable infra/UI settings in prose.** Reference the
  GitHub config; decisions about them live in ADRs, live values in GitHub.
- **L4 — Learnings graduate to a durable home.** Captured transiently in the
  tracking issue (#106), then promoted: a rule here (with a dated note) for a
  do/don't, an ADR for a decision meeting the ADR requirement. #106 keeps only
  live status and not-yet-graduated learnings.
