# 0012 — The agent opens and drives pull requests; the human owns the merge

- Status: Accepted
- Date: 2026-07-20
- Deciders: @bgauduch

## Context and problem statement

The hard rules (`docs/agent-conventions.md`, formerly inlined in the roadmap)
included: *"NEVER create a pull request without an explicit request from the user
— the agent commits, pushes, then reports; the user decides when to open the
PR."* In practice this makes every delivery a two-step hand-off: the agent pushes
a branch and stops, then waits for the human to open the PR before CI can even
run against the PR context. The maintainer wants the agent to be **as independent
as practical** — opening PRs and driving them to green on its own — while keeping
the irreversible actions human-gated. The question is where to draw the new line.

## Decision drivers

- Maximise autonomy: the agent should carry a change from branch to green PR
  without a manual relay for each one.
- Keep every **irreversible / shared-state** action human-owned (merge, `master`
  pushes, force-push, ref deletion).
- Safety comes from a strong test harness (local + CI), not from withholding the
  ability to open a PR.
- Consistency with the existing authorization rules and the review discipline.

## Considered options

- **Status quo** — agent pushes, human opens the PR. *Rejected — the relay adds
  latency and defeats the autonomy goal.*
- **Full autonomy incl. merge** — agent also merges on green. *Rejected — merge is
  the irreversible act that must stay human-owned.*
- **Agent opens and drives PRs; human merges.** Chosen.

## Decision outcome

Chosen option: **the agent opens pull requests and drives their CI to green on
its own; the human still owns the merge.**

- The agent opens the PR (Conventional-Commits title, PR template filled),
  subscribes to its activity, and **fixes CI failures autonomously** — re-running,
  rebasing, and pushing fixes as needed.
- The agent **reports and waits** when a fix is ambiguous, architecturally
  significant, or would exceed the PR's declared scope (unchanged escalation
  discipline).
- **Unchanged and still human-owned:** merging, direct `master` pushes, force-push
  / history rewrite, and branch/tag/ref deletion. Hooks are never bypassed.

This **amends the authorization rule** that formerly forbade opening a pull request
without an explicit request, in `docs/agent-conventions.md` (its single home); the
roadmap's hard-rules section points there.

### Consequences

- Good: one-step delivery — branch → green PR — without a manual relay; faster
  iteration; the human reviews and merges a PR that is already green.
- Cost: the agent must be trustworthy about escalation and scope, and needs a
  test harness strong enough that "green locally" predicts "green in CI" — built
  as the agent-foundations harness work (SessionStart bootstrap +
  local build/test).
- Follow-ups: `AGENTS.md` and the roadmap point to the amended rule (single home
  in `docs/agent-conventions.md`); the SessionStart hook + local build/test make
  self-verification-before-push routine.

## More information

- Rules home: [`docs/agent-conventions.md`](../agent-conventions.md); entry point
  `AGENTS.md`; adapter `CLAUDE.md` (ADR-0009).
- The merge gate and branch-protection settings remain maintainer-managed in
  GitHub (see ADR-0002 for the squash-merge decision).
