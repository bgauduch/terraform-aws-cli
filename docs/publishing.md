# Publishing

Authentication for the image-publishing workflows. What each workflow publishes
and which secret it consumes is defined in the workflows themselves
([`.github/workflows/`](../.github/workflows/)); the user-facing tags are in the
[README](../README.md#-supported-tags-and-respective-dockerfile-links) (scheme:
[ADR-0003](adr/0003-image-versioning-and-tag-strategy.md)). This page is the single home for the
**credential model** and the **publication reliability model**.

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

## Publication reliability

Publication is complete only when **every** expected tag exists on the
registry. Three guards enforce this, all defined in the workflows:

1. Tool downloads in the `Dockerfile` retry transient failures, including
   connection resets.
2. The publish and test matrices do not fail fast: matrix jobs produce
   independent immutable tags, so a failed combo never cancels its siblings.
3. The `verify_release` job asserts each expected tag on the registry after
   the builds and **opens an issue** when the publication is incomplete, even
   on partial matrix failure.

Rationale: two releases once shipped with zero images because a single
transient download failure cancelled the whole publish matrix, and the red
runs went unnoticed (incident record: #106, fix: #149).
