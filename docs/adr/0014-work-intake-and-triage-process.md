# 0014 — Work intake and triage process (features, fixes, contributions)

- Status: Accepted
- Date: 2026-07-24
- Deciders: @bgauduch

## Context and problem statement

Work enters the repository from several doors — a maintainer idea, a bug, an
external contribution — with no shared lifecycle between "an idea appears" and
"a branch is delivered". The Renovate custom-manager work is the worked example
of what goes wrong: it was qualified in epic #102, folded into the roadmap, then
**epic #102 was closed as *completed* while its custom-manager sub-task was never
delivered**. The scope survived only because it was re-homed by hand to #20 and
#106 after the fact. Without an explicit intake pipeline, scope leaks silently,
duplicates get re-studied, and out-of-scope work slips in.

## Decision drivers

- No silent scope leaks: nothing is closed as done while part of it is undelivered.
- Deduplicate before creating: the same idea should not be studied twice.
- Keep the product scope tight: an explicit go/nogo gate, not implicit accretion.
- One home per fact (conventions L2): each item has a durable home for its
  qualified spec, its priority, and its plan.
- Repeatable by humans and agents alike, and cheap enough that a typo fix is not
  forced through five phases.

## Considered options

- **Ad-hoc (status quo)** — ideas become issues/PRs whenever, closed by feel.
  *Rejected — this is exactly what leaked the #102 sub-task.*
- **Heavyweight external board / project-management tool.** *Rejected — overkill
  for a low-traffic single-maintainer OSS repo; another surface to keep in sync.*
- **A lightweight five-phase intake pipeline, homed in a reference doc and
  governed by this ADR.** Chosen.

## Decision outcome

Chosen option: **a five-phase intake pipeline** that every non-trivial unit of
work flows through. The phases are the decision; the operational checklist is
[`docs/work-intake-and-triage.md`](../work-intake-and-triage.md).

1. **Deduplication** — search existing issues, PRs, ADRs and the roadmap before
   anything else; link and defer to the existing home if found.
2. **Study & framing** — analyse, qualify, ideate; a **go/nogo gate** answers *is
   it useful?* and *does it stay in product scope?*. A `go` creates the issue
   (the qualified spec); a `nogo` is recorded and closed `not planned`.
3. **Prioritisation** — rank against other work, identify dependencies, and add
   it to `docs/roadmap.md` (phase + Decisions table when a decision is made).
4. **Planning** — validate the plan; surface edge cases and cross-cutting impact
   on behaviour, docs and process; record the plan in the **issue body** (the
   issue is the single home for its own spec + plan).
5. **Realisation** — deliver as one focused PR (delivery conventions D1–D5);
   may be deferred or delegated over time.

**Closing integrity (the rule that fixes the #102 defect):** an issue or epic is
`completed` only when its declared scope is delivered. Undelivered scope is
**re-homed explicitly** (to another tracked issue, with the pointer in place
*before* closing) or the item stays open. Never closed `completed` with an
unchecked box and no re-home.

**Scales down:** a typo, a pure version bump, or an obvious one-line fix skips
straight to realisation — the pipeline binds *net-new features, structural
changes, and external contributions*, not trivial hygiene.

### Consequences

- Good: scope stops leaking (closing integrity); duplicates are caught before
  restudy; the go/nogo gate keeps the product minimal; every item has one home
  for spec, priority and plan.
- Bad / cost: upfront ceremony per item; mitigated by the scale-down clause and
  by keeping the reference doc a short checklist, not a process manual.
- Follow-ups: the operational checklist lives in
  [`docs/work-intake-and-triage.md`](../work-intake-and-triage.md); a binary
  *closing-integrity* rule may graduate into `docs/conventions.md` (Delivery) via
  the learning pipeline if the ADR statement proves too soft in practice; the
  Renovate custom-manager work (#20) is the first item re-run through this
  pipeline.

## More information

- Motivating leak: epic #102 (closed `completed`) → re-homed to #20 / #106.
- Related: `docs/roadmap.md` (prioritisation home), `docs/conventions.md`
  (Delivery D1–D5, Docs/language L2), ADR-0001 (roadmap + framework as SSOT).
- The ADR requirement itself: [`docs/adr/README.md`](README.md).
