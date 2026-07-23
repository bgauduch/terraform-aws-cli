# Publishing

Authentication for the image-publishing workflows. What each workflow publishes
and which secret it consumes is defined in the workflows themselves
([`.github/workflows/`](../.github/workflows/)); the user-facing tags are in the
[README](../README.md#-supported-tags-and-respective-dockerfile-links) (scheme:
[ADR-0003](adr/0003-image-versioning-and-tag-strategy.md)). This page is the single home for the
**credential model** only.

## Registry credentials (least privilege)

Credentials are GitHub repository secrets (values live in **Settings → Secrets**).
Scopes stay minimal so the token that pushes images never carries `Delete`:

| Secret | Docker Hub scope | For |
|--------|------------------|-----|
| `DOCKERHUB_USERNAME` | — | account name |
| `DOCKERHUB_PAT` | Read & Write | pushing image tags |
| `DOCKERHUB_DESCRIPTION_PAT` | Read, Write & Delete | the description API, which rejects tokens without `Delete` |

The `Delete`-scoped token is used only by the push-to-`master` description
workflow, never in a `pull_request`-triggered one ([ADR-0013](adr/0013-pr-triggered-ci-security-boundary.md)).
