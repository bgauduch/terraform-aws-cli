# Contributing

Thanks for contributing to **terraform-aws-cli**! This file is the contribution
**workflow**; the conventions it applies live in
[`docs/conventions.md`](docs/conventions.md) — each step links to the relevant
section.

## Workflow

1. **Branch** off `master` — naming: [branching conventions](docs/conventions.md#branching).
2. **Commit** — [commit conventions](docs/conventions.md#commits): Conventional
   Commits, enforced by commitlint on every commit **and** the PR title.
3. **Test locally**:

   ```bash
   ./dev.sh                                        # latest supported versions
   ./dev.sh <AWS_CLI_VERSION> <TERRAFORM_VERSION>  # specific versions
   ```

   The script lints the Dockerfile (hadolint), builds the image, and runs the
   container-structure tests. Adding a new tool version also requires its
   signature files under `security/` — see
   [`docs/binaries-verifications.md`](docs/binaries-verifications.md) and
   [`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md).
4. **Open a PR** and fill the template. A structural change ships with an ADR —
   see the [ADR requirement](docs/adr/README.md).
5. **Review & merge** — CI must pass; the maintainer reviews and squash-merges
   ([delivery conventions](docs/conventions.md#delivery)). Head branches are
   auto-deleted.

## Releases & dependencies

Releases are automated by **release-please** from the merged Conventional
Commits ([ADR-0002](docs/adr/0002-contribution-and-release-workflow.md));
dependency updates are handled by **Renovate**.

## Security

See [`SECURITY.md`](SECURITY.md) to report a vulnerability.
