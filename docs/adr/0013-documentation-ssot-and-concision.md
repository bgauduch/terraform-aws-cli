# 0013 — Documentation is SSOT-pointered and concise

- Status: Accepted
- Date: 2026-07-20
- Deciders: @bgauduch

## Context and problem statement

Rule 19 ("SSOT — one home per fact") already existed, yet the agent-foundations
docs still shipped the same rules three times — `AGENTS.md` and the roadmap each
restated the hard rules that `docs/agent-conventions.md` owns. The drift risk was
immediate: amending rule 3 (ADR-0012) meant editing the same sentence in three
places. Verbose, low-content intros compounded the noise. Tracing the doctrine is
not enough on its own — it was traced and still violated; it needs to be a sharp,
decided-once rule with a review checkpoint.

## Decision drivers

- One home per fact — restated content drifts and doubles maintenance.
- Concise docs get read; verbose ones get skimmed and rot.
- Enforcement must fit the repo: semantic duplication is not reliably
  CI-lintable, so the lever is a clear rule + a review checkpoint, not a new gate.

## Considered options

- **Rule text only** — sharpen `docs/agent-conventions.md`. *Insufficient alone —
  a rule already existed and was violated.*
- **CI check** — lint for duplication/verbosity. *Rejected — semantic duplication
  is not reliably detectable; it would give false confidence.*
- **Rule + ADR + PR-template checkbox.** Chosen — the repo's established trace
  pattern (cf. ADR enforcement).

## Decision outcome

Chosen option: **make it a sharp rule, record the decision, and check it at
review.**

- **Rule** — `docs/agent-conventions.md` rule 21: docs point, never restate a fact
  that has a home; entry points (`AGENTS.md`, `CLAUDE.md`, the roadmap) are
  pointers; prose is lean (intros/sections must add information).
- **Review checkpoint** — a `.github/PULL_REQUEST_TEMPLATE.md` checklist item.
- **Periodic sweep** — the roadmap's doc-consolidation / SSOT audit (Phase 9)
  verifies every cross-pointer resolves and no fact is restated.
- **No CI gate** — semantic duplication is not reliably lintable; the orchestrator
  diff-review before push (rule 14) plus the checkpoint are the realistic ceiling.

### Consequences

- Good: one editable home per fact; leaner, more readable docs; drift caught at
  review instead of by the next reader.
- Cost: a judgement call ("does this restate, or legitimately reference?") — ADRs
  are the explicit exception (frozen records may repeat, rule 19).
- Follow-ups: applied to the agent-foundations docs in this PR; swept repo-wide in
  the Phase 9 audit.

## More information

Rules home: [`docs/agent-conventions.md`](../agent-conventions.md) (rules 19, 21);
entry point `AGENTS.md`; ADR-0009 (agnostic core / adapter split).
