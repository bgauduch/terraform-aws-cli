# 0006 — Generic, config-driven agent orchestration strategy

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

The roadmap described the agent orchestration as prose (naming specific models
as orchestrator/executor) with model names hard-coded into the narrative. Model names
drift, and a per-repo prose strategy is not portable to other repositories. We
want the strategy to be generic, configurable, and a single source of truth.

## Decision drivers

- Model IDs change; embedding them in prose causes drift (violates the
  "reference, don't embed" SSOT rule).
- The orchestration core should be portable / template-able across repos.
- Swapping a model should be a one-line change, not a doc-wide edit.

## Considered options

- Keep prose with named models (status quo).
- Hard-code models in each subagent definition.
- **Role/tier abstraction** with a single tier→model mapping in config.

## Decision outcome

Chosen option: **role/tier abstraction, config-driven**.

- Define **roles**, not models: `orchestrator`, `executor`, optional `reviewer`.
- Subagents and docs reference a **role**; never a concrete model name.
- A **single mapping** lives in the active tool's adapter (`.claude/settings.json`
  for Claude Code; see ADR-0009), created as part of the agent-foundations
  roadmap work:

  ```jsonc
  // illustrative shape — the authoritative version lands with the adapter
  {
    "agentRoles": {
      "orchestrator": { "model": "<current-flagship>", "purpose": "planning, review-before-push, ADR drafting, structural decisions" },
      "executor":     { "model": "<current-workhorse>", "purpose": "scoped implementation, refactors, docs" },
      "reviewer":     { "model": "<current-workhorse>", "purpose": "diff review, security/lint passes" }
    }
  }
  ```

- Swapping a model = edit one value. Docs cite the role; the config holds the
  current model.
- **Generic core vs repo specifics:** the orchestration core (roles, mapping,
  hard rules, session hook) is portable to any repo; repo-specific skills
  (`bump-terraform-version`, etc.) stay separate.

### Consequences

- Good: portable, drift-free, one-edit model swaps; consistent with SSOT rule.
- Cost: one indirection (role → model) to learn.
- Follow-ups: delivered as roadmap work — the role→model mapping
  (`.claude/settings.json`, `docs/agent-framework.md`), then the subagents that
  reference roles rather than model names.

## More information

The hard rules (authorization, branching, commits, delegation review) in
`docs/roadmap.md` remain the binding conventions; this ADR only genericises the
model/role mapping.
