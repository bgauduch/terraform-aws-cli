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
   it useful?* and *does it stay in product scope?*. **The go/nogo call is the
   human maintainer's** — agents study, qualify and recommend, the human decides
   (the same ownership split as the merge, ADR-0012). A `go` creates the issue
   (the qualified spec); a `nogo` is recorded and closed `not planned`.
3. **Prioritisation** — rank against other work, identify dependencies, and add
   it to `docs/roadmap.md` (phase + Decisions table when a decision is made).
4. **Planning** — validate the plan; surface edge cases and cross-cutting impact
   on behaviour, docs and process; record the plan in the **issue body** (the
   issue is the single home for its own spec + plan); resolve the **ADR
   lifecycle** (below).
5. **Realisation** — deliver as one focused PR (delivery conventions D1–D6);
   may be deferred or delegated over time.

**ADR lifecycle is not re-specified here.** Creation, amendment, and
supersession follow the existing ADR process
([`docs/adr/README.md`](README.md), § Amending vs superseding): a conflict with a
recorded decision is flagged as early as dedup/study (phase 1–2, a supersede
candidate) and resolved at planning (phase 4) — new decision → new ADR; reversal
→ supersede; clarification → amend; reversible convention → `conventions.md`. The
pipeline hooks into that process rather than duplicating it (conventions L2).

**Closing integrity (the rule that fixes the #102 defect):** an issue or epic is
`completed` only when its declared scope is delivered. Undelivered scope is
**re-homed explicitly** (to another tracked issue, with the pointer in place
*before* closing) or the item stays open. Never closed `completed` with an
unchecked box and no re-home. The rule is binding as **Delivery D6** in
[`docs/conventions.md`](../conventions.md) — this ADR records the decision
behind it.

**Scales down:** a typo, a pure version bump, or an obvious one-line fix skips
straight to realisation — the pipeline binds *net-new features, structural
changes, and external contributions*, not trivial hygiene.

> **Amended 2026-08-22 — the incident lane.** A fix for a defect already
> affecting users is a structural change, so phases 1, 2, 4 and 5 bind it as
> written. **Phase 3 does not:** ranking against current work has no meaning for
> something being done because production is broken, and the pipeline had no
> lane for it. The trace is deferred, not waived — the delivering pull request
> carries the roadmap entry. Recorded because #171 reached delivery without it
> and nothing was wrong: an exemption that is never written down is
> indistinguishable from an omission, and gets repeated.

> **Amended 2026-08-23 — the fix-forward lane.** The pipeline had one exit for
> a defect noticed while delivering something else: file it. Conventions D3
> makes that binding (*"drift discovered mid-work is captured as a follow-up,
> `NEVER` silently included"*), so a one-line mechanical fault costs a study, an
> issue, a `go` and a pull request of its own. The backlog therefore grows
> faster than it is worked, which is the reason for this amendment rather than
> any single incident.
>
> A defect that meets **all three** of these is corrected inside the pull
> request that found it, with no study, no issue and no `go`:
>
> 1. a tool decides it — `scripts/validate.sh` or a CI gate fails on it, or it
>    is a reference to something that no longer exists;
> 2. it is inside the PR's declared scope, or in a line that scope already
>    touches;
> 3. fixing it needs no choice between two defensible options.
>
> Anything else keeps the five phases. The trace is not waived: the pull
> request description states what was fixed along the way, which is what D3
> asks for minus the detour through an issue. Criterion 3 is the load-bearing
> one — the moment a fix has options, it is a decision, and decisions are the
> maintainer's (this ADR, phase 2).

### Consequences

- Good: scope stops leaking (closing integrity); duplicates are caught before
  restudy; the go/nogo gate keeps the product minimal; every item has one home
  for spec, priority and plan.
- Bad / cost: upfront ceremony per item; mitigated by the scale-down clause and
  by keeping the reference doc a short checklist, not a process manual.
- Follow-ups: the operational checklist lives in
  [`docs/work-intake-and-triage.md`](../work-intake-and-triage.md); the
  closing-integrity rule ships as the binding `docs/conventions.md` Delivery
  rule **D6** alongside this ADR; the Renovate custom-manager work (#20) is the
  first item re-run through this pipeline.

## More information

- Motivating leak: epic #102 (closed `completed`) → re-homed to #20 / #106.
- Related: `docs/roadmap.md` (prioritisation home), `docs/conventions.md`
  (Delivery D1–D6, Docs/language L2), ADR-0001 (roadmap + framework as SSOT).
- The ADR requirement itself: [`docs/adr/README.md`](README.md).
