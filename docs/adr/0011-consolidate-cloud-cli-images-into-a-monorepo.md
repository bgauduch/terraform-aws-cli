# 0011 — Consolidate the Terraform + cloud-CLI images into a monorepo

- Status: Proposed
- Date: 2026-06-16
- Deciders: @bgauduch

## Context and problem statement

`terraform-aws-cli` and `terraform-azure-cli` are maintained as two separate
repositories, yet they are the same product with one variable: the bundled cloud
CLI. They share an identical Terraform builder stage, the same multi-stage Debian
approach, the same CI/CD topology, the same release ritual, and the same
maintenance cadence. Every change — a base-image bump, a workflow fix, the whole
modernization in `docs/roadmap.md` (Phases 0–8) — has to be done twice and tends
to drift. The question is whether to keep them separate or consolidate, and if so,
how, without breaking consumers or losing history.

## Decision drivers

- Eliminate duplicated work and drift across structurally identical projects.
- Apply the modernization/agent framework **once**, not once per provider.
- **Preserve published image names** — no consumer `docker pull` may break.
- **Preserve git history** of both repositories.
- Keep images **independently versioned and released** (an AWS-CLI bump must not
  force an Azure release).
- Make adding a future provider (e.g. GCP) a *new directory*, not a refactor.

## Considered options

- **Status quo — two repos.** Rejected: institutionalises double-work and drift;
  the framework would be rebuilt in `terraform-azure-cli`.
- **Fresh monorepo repository** (e.g. `terraform-cli-images`), both repos merged
  in. Rejected as the home: discards the active repo's stars/SEO and forces
  migrating 38+35 open issues up front.
- **Promote `terraform-aws-cli` in place** into a monorepo, merge Azure via
  `git subtree`, structure as `images/<provider>/` + `shared/`. **Chosen.**
- **One fat multi-cloud image.** Rejected: violates the product's minimal,
  single-cloud premise (a non-goal in the plan).

Two sequencing options were weighed: consolidate first vs. **modernize first**.

## Decision outcome

Chosen option: **promote `terraform-aws-cli` in place as the monorepo**, with an
`images/<provider>/` + `shared/` layout covering **`aws` and `azure`** now and
extensible to more providers, executed **after** the single-repo modernization
(roadmap Phases 1–8) — captured as roadmap **Phase 9** and detailed in
[`docs/monorepo-refactor-plan.md`](../monorepo-refactor-plan.md).

Rationale: promoting in place keeps the most active repo's history, stars, and
issue tracker; `git subtree` preserves Azure's history; per-image Docker Hub
names are kept so no consumer breaks; release-please **manifest** mode gives each
image its own version, changelog, and tag prefix from one repo. Modernizing first
means the merge happens onto a hardened, frozen base and the framework is applied
exactly once.

### Consequences

- Good: one CI/CD topology, one framework, no drift; shared logic (Terraform
  stage, security chain, base-image policy) defined once; new providers are
  additive.
- Good: consumers unaffected (image names preserved); both histories retained.
- Cost: a non-trivial migration (history merge, manifest-mode releases, matrixed
  CI) — mitigated by the six small, independently shippable Phase 9 sub-steps.
- Cost: prior single-repo ADRs/skills/workflows are generalised to a provider
  matrix (per-image scopes, `shared/**` path routing).
- Follow-ups: ADRs to be recorded at execution time for the **repo rename**
  (`terraform-aws-cli` → `terraform-cloud-cli`, if taken) and the **build
  orchestrator** choice (Docker Bake vs. workflow matrix). GCP is designed-for but
  deferred until real demand.

## More information

- Plan: [`docs/monorepo-refactor-plan.md`](../monorepo-refactor-plan.md)
- Builds on ADR-0002 (Conventional Commits / squash / release-please → now
  per-component), ADR-0003 (versioning & tag strategy → now per image), and the
  agent framework (ADR-0006/0009). No prior ADR is superseded.
- Roadmap entry: `docs/roadmap.md` → Phase 9.
