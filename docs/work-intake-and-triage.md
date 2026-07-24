# Work intake & triage

Operational checklist for the five-phase intake pipeline decided in
[ADR-0014](adr/0014-work-intake-and-triage-process.md). The *why* and the phase
definitions live there; this file is the *how*. It binds net-new features,
structural changes, and external contributions — trivial hygiene (typos, pure
version bumps, one-line fixes) skips to phase 5.

## The pipeline

### 1. Deduplication
- [ ] Search open **and** closed issues/PRs, `docs/adr/`, and `docs/roadmap.md`
  for the same idea.
- [ ] If it already has a home: link to it, add context there, and stop. No new
  issue.

### 2. Study & framing (go/nogo)
- [ ] Analyse and qualify: problem, users affected, rough approach, alternatives.
- [ ] **Go/nogo gate** — answer both:
  - Is it **useful** (real problem, worth the maintenance)?
  - Does it **stay in product scope** (minimalist Terraform + AWS CLI image)?
- [ ] `nogo` → record the reasoning, close `not planned` (or decline the PR).
- [ ] `go` → create the issue: it is the **qualified spec** and its single home.

### 3. Prioritisation
- [ ] Rank against current work (phase/priority in `docs/roadmap.md`).
- [ ] Identify dependencies and blockers; link them.
- [ ] Add to the roadmap (phase line; Decisions table when a decision is taken).

### 4. Planning
- [ ] Validate the plan (orchestrator review — ADR-0006 roles).
- [ ] Surface **edge cases** and **cross-cutting impact**: behaviour, docs,
  process, CI, security.
- [ ] Record the plan in the **issue body** (edited in place, not scattered in
  comments).
- [ ] Structural change? Draft the ADR now (the [ADR requirement](adr/README.md)).

### 5. Realisation
- [ ] Deliver as one focused PR — delivery conventions D1–D5.
- [ ] May be deferred or delegated; the issue body carries the plan across sessions.

## Closing integrity

An issue or epic is `completed` **only** when its declared scope is delivered.
Undelivered scope is **re-homed to a tracked issue with the pointer in place
before closing**, or the item stays open. Never close `completed` over an
unchecked box (the failure that stranded the Renovate custom manager in #20).

## Pointers

Prioritisation home: [`docs/roadmap.md`](roadmap.md) · Delivery & language rules:
[`docs/conventions.md`](conventions.md) · Decisions: [`docs/adr/`](adr/) · Live
status: tracking issue #106.
