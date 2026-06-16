# Monorepo refactor plan — consolidate the Terraform + cloud-CLI images

> **Scope:** merge the sibling image repositories
> [`terraform-aws-cli`](https://github.com/bgauduch/terraform-aws-cli) and
> [`terraform-azure-cli`](https://github.com/bgauduch/terraform-azure-cli) into a
> single **monorepo**, structured so additional providers (e.g. a future
> `terraform-gcp-cli`) drop in without rework.
>
> Status: **Proposed** · Last updated: 2026-06-16 · Decision record: [ADR-0011](adr/0011-consolidate-cloud-cli-images-into-a-monorepo.md)
>
> Validated direction (2026-06-16):
> **promote `terraform-aws-cli` in place** as the monorepo home ·
> **`aws` + `azure` now, extensible to more** ·
> **execute *after* the single-repo modernization (Phases 1–8) lands** — this is
> roadmap **Phase 9**.

## Why this document exists

`terraform-aws-cli` and `terraform-azure-cli` are near-identical projects: a
minimalist, multi-stage Debian image that bundles the **Terraform CLI** plus a
**single cloud CLI**, GPG/checksum-verified, published to Docker Hub. They share
~80% of their Dockerfile, their entire CI/CD topology, their release ritual, and
their maintenance cadence (bump Terraform, bump the cloud CLI, bump the base
image, cut a release). Maintaining them as two repositories means **doing every
piece of work twice** and letting the two drift apart.

The single-repo modernization already underway (`docs/roadmap.md`, Phases 0–8)
turns `terraform-aws-cli` into a hardened, well-governed reference: release-please
automation, supply-chain security, an agent framework, ADR discipline. Rebuilding
all of that a second time in `terraform-azure-cli` would be wasteful. Instead,
once the reference repo is polished, we **fold Azure into it** and apply the
framework **once** across both images.

This plan is the single authority for that consolidation. It freezes the agreed
direction, survives context loss, and is enforced by ADR-0011.

---

## Goals and non-goals

### Goals
- One repository, one CI/CD topology, one governance/agent framework for **all**
  Terraform + cloud-CLI images.
- **No drift**: shared logic (Terraform builder stage, security-verification
  chain, base-image policy, workflows, skills) lives in exactly one place.
- **Preserve git history** of both source repositories.
- **Preserve published image names** so existing consumers are not broken:
  `bgauduch/terraform-aws-cli` and `bgauduch/terraform-azure-cli` keep shipping
  as Docker Hub repositories, regardless of the source layout.
- **Independent release cadence per image** — a new AWS CLI version ships an
  `aws` release without forcing an `azure` release, and vice versa.
- A layout where adding `gcp` (or another provider) is a *new directory + matrix
  entry*, not a structural change.

### Non-goals
- Merging the **published images** themselves into one fat image — each image
  stays single-cloud and minimal (that is the product's whole point).
- A shared *version* for the images — they version independently.
- Re-doing the modernization work — Phases 1–8 are a prerequisite, not part of
  this plan (see Sequencing).
- Bundling extra tools (python3, etc.) — out of scope per `docs/roadmap.md`.

---

## Target repository layout

```
terraform-cloud-cli/                 # (repo promoted in place; rename is a late, optional step)
├── images/
│   ├── aws/
│   │   ├── Dockerfile                # AWS-CLI stage + final assembly
│   │   ├── supported_versions.json   # awscli_versions (+ tf range reference)
│   │   ├── security/                 # awscliv2.asc, *.sig
│   │   ├── tests/
│   │   │   └── container-structure-tests.yml.template
│   │   └── README.md                 # Docker Hub description (per image)
│   └── azure/
│       ├── Dockerfile                # Azure-CLI stage + final assembly
│       ├── supported_versions.json   # azurecli_versions (+ tf range reference)
│       ├── security/
│       ├── tests/
│       └── README.md
├── shared/
│   ├── terraform.Dockerfile          # the identical Terraform builder stage, defined once
│   ├── security/
│   │   └── hashicorp.asc             # shared HashiCorp signing key + tf SHA256SUMS/.sig
│   └── supported_terraform.json      # the single Terraform version matrix, shared by all images
├── docker-bake.hcl                   # build targets, version matrix, shared stage wiring
├── docs/
│   ├── roadmap.md                    # unchanged authority; gains Phase 9 (this work)
│   ├── monorepo-refactor-plan.md     # this file
│   └── adr/                          # ADR-0001…0011 (framework reused as-is)
├── .github/
│   ├── workflows/                    # one matrixed topology, path-filtered per image
│   └── ...
├── .release-please-manifest.json     # per-image versions
├── release-please-config.json        # per-image components (aws, azure), tag prefixes
├── AGENTS.md / CLAUDE.md             # agent SSOT + adapter (from Phase 2), provider-parametrized
└── dev.sh                            # local build helper, now provider-aware
```

**Principles**
- `shared/` holds anything byte-identical across images today: the Terraform
  builder stage, the HashiCorp signing key + Terraform `SHA256SUMS`, the single
  Terraform version list, the base-image pin policy.
- `images/<provider>/` holds only what differs: the cloud-CLI download/verify
  stage, that CLI's version list and signing material, the per-image Docker Hub
  README, and provider-specific structure tests.
- Adding a provider = new `images/<provider>/` + one matrix entry. No edits to
  shared logic.

---

## Build system: one Terraform stage, per-provider assembly

Today both Dockerfiles contain an **identical** `terraform` builder stage
(download → import `hashicorp.asc` → verify `.sig` → `sha256sum --check` →
`unzip`). That stage is extracted to `shared/terraform.Dockerfile` and consumed
by every image, so the verification chain is defined **once**.

The chosen orchestration is **Docker Bake** (`docker buildx bake`), which fits a
monorepo of images far better than per-workflow `docker build` invocations:

- a `group "default"` builds all images;
- one `target` per image (`aws`, `azure`, …);
- a **matrix** over the supported version tuples (Terraform × cloud-CLI), reading
  `shared/supported_terraform.json` and `images/<p>/supported_versions.json`;
- shared `args`, `cache-from`/`cache-to`, `platforms`, and `tags` defined once and
  inherited — this also resolves roadmap Phase 4's "harmonise cache + restrict
  multi-arch to publish" items for *all* images at once.

`dev.sh` becomes provider-aware (`./dev.sh --image aws --tf 1.11.x --cli 2.17.x`)
and delegates to Bake so local and CI builds share one definition.

> Each image's final stage still produces a **single-cloud, minimal** image.
> Bake is a build-orchestration choice; it does not change the shipped artifacts.

---

## Versioning, releases, and registries

### Independent versions in one repo — release-please *manifest* mode
A single repo shipping multiple independently-versioned artifacts is exactly what
release-please **manifest mode** is for:

- `release-please-config.json` declares two **components**, `images/aws` and
  `images/azure`, each with its own changelog, version, and **tag prefix**
  (`aws-vX.Y.Z`, `azure-vX.Y.Z`);
- `.release-please-manifest.json` tracks each component's current version;
- Conventional-Commit **scopes** route changes — `feat(aws): …` bumps only the
  `aws` component; `fix(shared): …` (or a `shared/**` touch) fans out to **every**
  image, since a Terraform-stage or base-image change rebuilds all of them.

This preserves ADR-0002 (Conventional Commits, squash-merge, release-please) and
ADR-0003 (semver → derived image tags) verbatim — they now operate **per image**.

### Registries and tags — consumer continuity is non-negotiable
The published Docker Hub repositories **do not change**:
`bgauduch/terraform-aws-cli` and `bgauduch/terraform-azure-cli` keep receiving
images, so no consumer `docker pull` breaks. The GHCR mirror from roadmap Phase 3
(`ghcr.io/bgauduch/terraform-aws-cli`, `…/terraform-azure-cli`) likewise stays
per-image. The full ADR-0003 tag strategy (`latest`, `edge`, `vX.Y.Z`, `vX.Y`,
fully-pinned `vX.Y.Z_tf-A.B.C_<cli>-D.E.F`) is applied **independently per image**.

> The source collapses to one repo; the **products stay separate**. Map: one repo
> → N components → N Docker Hub repos.

---

## CI/CD topology

One set of workflows, matrixed and path-filtered:

- **Path filters** decide what rebuilds. `images/aws/**` → AWS job only;
  `images/azure/**` → Azure job only; `shared/**`, `docker-bake.hcl`, base-image
  policy, or `.github/workflows/**` → **all** images (a shared change can break
  any of them). This generalises Phase 0's path-filter fixes to a provider matrix.
- **Matrix builds** — `build-test`, `lint-dockerfile`, and the publish workflows
  run over `strategy.matrix.image: [aws, azure]`, each pulling its own
  `supported_versions.json` and structure-test template.
- **`adr-check.yml`** keeps guarding structural paths — now including `shared/**`,
  `docker-bake.hcl`, and `release-please-config.json`.
- **`dockerhub-description-update.yml`** pushes `images/<p>/README.md` to the
  matching Docker Hub repo, matrixed.
- **Security gates** (Phase 5 — Trivy, SBOM, SLSA provenance, cosign) run per
  matrix entry, so every image is scanned, attested, and signed independently.

Net effect: the six workflows that exist today become one matrixed topology that
covers two (then N) images, with no duplicated YAML.

---

## History preservation

- **AWS** content is *moved*, not copied: `git mv` the current top-level files into
  `images/aws/` and `shared/`. History follows the tree move (`git log --follow`).
- **Azure** is merged in with full history via **`git subtree`**:

  ```bash
  git remote add azure https://github.com/bgauduch/terraform-azure-cli
  git fetch azure
  git subtree add --prefix=images/azure azure/<default-branch>
  ```

  Then a follow-up commit lifts Azure's identical Terraform-stage / HashiCorp
  material out of `images/azure/` into `shared/` (deduplication), and reshapes the
  rest to the `images/<provider>/` contract.

  `git-filter-repo` is the fallback if subtree's merge geometry proves awkward;
  subtree is preferred for being a single, reversible, well-understood operation.

No history is rewritten on `master`; every step lands as new commits on the
Phase 9 branch (hard rule 4).

---

## Agent framework & docs reconciliation

The framework from Phases 2/6 is **reused**, lightly generalised:

- **`supported_versions.json` split** — the Terraform list moves to
  `shared/supported_terraform.json` (one matrix for all images); each image keeps
  only its cloud-CLI list. Skills and the `validate-supported-versions` check read
  both.
- **Skills become provider-parametrized** — `bump-terraform-version` operates on
  the shared list (fans out to all images); `bump-awscli-version` /
  `bump-azurecli-version` are per-image. A new provider adds a `bump-<cli>-version`
  skill, nothing else.
- **`AGENTS.md` / `CLAUDE.md`** gain a short "images & shared layout" section; the
  hard rules, roles/tiers, and ADR discipline are unchanged.
- **ADRs** carry over untouched — ADR-0011 is simply the next record. The MADR
  format, enforcement (`adr-check.yml`, PR template, CODEOWNERS) all apply to the
  monorepo as-is.

---

## Deprecating the old repository

- `terraform-aws-cli` **is** the monorepo (promoted in place) — it keeps its
  stars, issues, forks, and SEO. A repo **rename** to `terraform-cloud-cli` is an
  *optional, late* step; GitHub auto-redirects the old path, and the Docker Hub
  image names are independent of it, so the rename is low-risk and reversible.
- `terraform-azure-cli` is **archived** after the merge: its README is replaced
  with a pointer to the monorepo, open issues/PRs are triaged into the monorepo's
  tracker, and the repo is set read-only. Its Docker Hub repository keeps being
  **published from the monorepo**, so Azure consumers are unaffected.
- A short migration note is added to both READMEs and announced in the next
  release changelog.

---

## Execution — Phase 9 sub-steps

Delivered as roadmap **Phase 9**, *after* Phases 1–8. Each sub-step is one
reviewable PR (hard rule 8), strictly scoped.

| Step | Title | Outcome |
|---|---|---|
| 9a | **Reshape AWS in place** | `git mv` current files into `images/aws/` + `shared/`; introduce `shared/terraform.Dockerfile`; AWS still builds & publishes byte-identically. No Azure yet. |
| 9b | **Bake + matrixed CI** | Add `docker-bake.hcl`; convert the six workflows to a single-entry matrix (`image: [aws]`) with path filters. Pure topology change, AWS-only. |
| 9c | **Merge Azure (history-preserving)** | `git subtree add` Azure into `images/azure/`; dedupe its Terraform/HashiCorp material into `shared/`; conform to the `images/<provider>/` contract. |
| 9d | **Two-image matrix** | Extend the CI matrix and Bake group to `[aws, azure]`; per-image structure tests, security gates, Docker Hub READMEs all green. |
| 9e | **Per-image releases** | release-please **manifest** mode with `aws`/`azure` components, tag prefixes, scope→component routing; first independent release of each. |
| 9f | **Archive & document** | Archive `terraform-azure-cli` with a redirect README; triage its issues; migration notes; (optional) rename repo → `terraform-cloud-cli`. |

Each step is independently shippable and leaves `master` releasable.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Breaking consumers' `docker pull` | Published image **names are preserved**; only the source layout changes. Verify Docker Hub publish targets in 9b before adding Azure. |
| Azure history lost in the merge | `git subtree add` (full history) with `git-filter-repo` as fallback; verify `git log --follow` post-merge before archiving the source. |
| `shared/` change silently breaks one image | Path filter routes `shared/**` to **all** images; matrix build + structure tests + Trivy must be green for every image before merge. |
| Version-matrix explosion (TF × CLI) | Bake matrix limited to the **supported** tuples from the JSON files (already curated post-Phase-1 cleanup); not a full cross-product. |
| Release routing mistakes (wrong component bumped) | release-please dry-run in CI on the PR; Conventional-Commit **scope** is mandatory and lint-enforced (Phase 1 commitlint). |
| Doing it on a moving base | Sequenced **after** Phases 1–8 — the reference repo is frozen/hardened before the merge. |
| Repo rename surprises | Rename is the **last**, optional step; GitHub redirects the old slug; image names are decoupled. Easy to defer or skip. |

---

## Open decisions (to confirm at Phase 9 kickoff)

1. **Final repo name** — keep `terraform-aws-cli`, or rename to
   `terraform-cloud-cli` (or `terraform-cli-images`)? Recommendation: rename in
   9f, relying on GitHub redirects. *Structural → records an ADR when executed.*
2. **Build orchestrator** — Docker Bake (recommended here) vs. a workflow matrix
   calling plain `docker buildx build`. Confirm before 9b; the choice is an ADR.
3. **GCP timing** — design now (this plan) but only add `images/gcp/` when a real
   `terraform-gcp-cli` need exists; not part of Phase 9.
4. **Issue migration mechanism** — bulk transfer vs. manual triage for
   `terraform-azure-cli`'s open issues. Operational, decided at 9f.

---

## Relationship to the roadmap

This plan is roadmap **Phase 9**. The roadmap's Decisions table records the
consolidation decision (→ ADR-0011) and the "after modernization" sequencing. All
hard rules (authorization, branching, commits, roles, scope discipline) and prior
ADRs apply unchanged — this work reuses the framework it consolidates.
