# Rollback

This image follows the tag strategy in
[ADR-0003](adr/0003-image-versioning-and-tag-strategy.md). Some tags **float**
(their meaning moves over time) and one form is **immutable** (it never changes
meaning). That distinction is what makes rollback safe and predictable.

## Tags and their stability

| Tag form | Example | Stability |
|---|---|---|
| `latest` | `latest` | **Floating** — the latest supported tool versions, built from `master` |
| `vX.Y.Z` | `v8.1.0` | **Floating** project version — resolves to the latest bundled tool versions for that line |
| `vX.Y.Z_tf-A.B.C_aws-D.E.F` | `v8.1.0_tf-1.6.5_aws-2.14.5` | **Immutable** — one fixed Terraform + AWS CLI combination, never re-pushed |

> Additional floating tags (`edge`, `vX.Y`) and a second registry (GHCR) arrive
> with roadmap Phase 3 — see [ADR-0003](adr/0003-image-versioning-and-tag-strategy.md).

## Policy

- **Immutable fully-pinned tags are never mutated.** Once
  `vX.Y.Z_tf-A.B.C_aws-D.E.F` is published, that exact digest is fixed.
- There is **no "un-release".** A bad release is not deleted or overwritten;
  rolling back is done by consumers **re-pinning** an older immutable tag.

## How to roll back

1. Pin the **fully-pinned** tag — not a floating one — anywhere you need
   reproducibility (CI jobs, base images):

   ```dockerfile
   FROM zenika/terraform-aws-cli:v8.1.0_tf-1.6.5_aws-2.14.5
   ```

2. To roll back, change the pin to the previous known-good fully-pinned tag:

   ```dockerfile
   FROM zenika/terraform-aws-cli:v8.0.1_tf-1.6.5_aws-2.14.5
   ```

3. Browse available tags on the
   [Docker Hub tags page](https://hub.docker.com/r/zenika/terraform-aws-cli/tags)
   and the matching changelog on the
   [GitHub releases page](https://github.com/bgauduch/terraform-aws-cli/releases).

## Why not just delete the bad image?

Deleting or re-pushing a published immutable tag would silently change what
existing pins resolve to, breaking reproducibility for everyone already pinned to
it. Re-pinning **forward** to a fixed, known-good tag is the only safe path.
