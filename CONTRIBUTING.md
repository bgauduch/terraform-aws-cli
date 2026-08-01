# Contributing

Thanks for contributing to **terraform-aws-cli**! This file is the contribution
**workflow**; the conventions it applies live in
[`docs/conventions.md`](docs/conventions.md) — each step links to the relevant
section.

## Workflow

1. **Qualify** — net-new features and non-trivial changes flow through the
   [work-intake pipeline](docs/work-intake-and-triage.md) (ADR-0014): check for
   an existing home, then open an issue and get the maintainer's go before
   coding. Trivial hygiene (typos, pure version bumps, one-line fixes) skips
   straight to a PR.
2. **Branch** off `master` — naming: [branching conventions](docs/conventions.md#branching).
3. **Commit** — [commit conventions](docs/conventions.md#commits): Conventional
   Commits, enforced by commitlint on every commit **and** the PR title.
4. **Test locally** — one script, same checks as CI (ADR-0016):

   ```bash
   ./scripts/validate.sh --fast                                        # structural checks, no Docker, seconds
   ./scripts/validate.sh --full                                        # + lint, image build, structure tests
   ./scripts/validate.sh --full <AWS_CLI_VERSION> <TERRAFORM_VERSION>  # specific versions
   ```

   Adding a new tool version also requires its
   signature files under `security/` — see
   [`docs/binaries-verifications.md`](docs/binaries-verifications.md) and
   [`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md).
5. **Open a PR** and fill the template. A structural change ships with an ADR —
   see the [ADR requirement](docs/adr/README.md).
6. **Review & merge** — CI must pass; the maintainer reviews and squash-merges
   ([delivery conventions](docs/conventions.md#delivery)). Head branches are
   auto-deleted.

## Releases & dependencies

Releases are automated by **release-please** from the merged Conventional
Commits ([ADR-0002](docs/adr/0002-contribution-and-release-workflow.md));
dependency updates are handled by **Renovate**.

## Security

See [`SECURITY.md`](SECURITY.md) to report a vulnerability.
