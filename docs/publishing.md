# Publishing

How the image is built, published, and authenticated. The user-facing tag list
lives in the [`README`](../README.md#-supported-tags-and-respective-dockerfile-links);
the tag scheme rationale is [ADR-0003](adr/0003-image-tag-strategy.md).

## Registries

- **Docker Hub** — `bgauduch/terraform-aws-cli` (primary). The legacy
  `zenika/terraform-aws-cli` is frozen; tag migration is tracked in #137.
- **GHCR** — planned as a second registry (#100).

## Workflows

- **`push-latest`** — builds and pushes `:latest` (multi-arch) on every relevant
  push to `master`.
- **`release-please`** — on a release, builds the version and fully-pinned tags.
- **`dockerhub-description-update`** — syncs the Docker Hub description from
  `README.md`.

## Registry authentication

Credentials are GitHub repository secrets (values live in **Settings → Secrets**,
never in the repo). Scopes follow least privilege — the token that pushes images
never carries `Delete`:

| Secret | Docker Hub scope | Used by | Why |
|--------|------------------|---------|-----|
| `DOCKERHUB_USERNAME` | — | all three | account name |
| `DOCKERHUB_PAT` | Read & Write | `push-latest`, `release-please` | push image tags |
| `DOCKERHUB_DESCRIPTION_PAT` | Read, Write & Delete | `dockerhub-description-update` | the description API rejects tokens without `Delete` |

The `Delete`-scoped token exists only for the description update and appears only
in this push-to-`master` workflow — never in a `pull_request`-triggered one, per
[ADR-0013](adr/0013-pr-triggered-ci-security-boundary.md).
