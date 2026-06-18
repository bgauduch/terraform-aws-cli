# Contributing

Thanks for contributing to **terraform-aws-cli** — a minimal Docker image
bundling Terraform CLI + AWS CLI on Debian. This guide is the short version; the
authoritative plan and decisions live in [`docs/roadmap.md`](docs/roadmap.md) and
[`docs/adr/`](docs/adr/).

## Commit & PR conventions

- **[Conventional Commits](https://www.conventionalcommits.org/)** are required
  for **both** commit messages **and** the PR title — `type(scope): subject`.
  The PR title becomes the squash-merge subject and feeds the release-please
  changelog, so it matters.
- Types: `feat`, `fix`, `docs`, `chore`, `ci`, `refactor`, `build`, `test`,
  `perf`. Breaking changes: append `!` (`feat!: …`) or a `BREAKING CHANGE:`
  footer.
- One commit per logical change; avoid mega-commits.
- This is enforced in CI (commitlint on each commit and on the PR title).

## Branches

- `type/topic` (kebab-case), e.g. `fix/aws-cli-checksum`.
- Roadmap-phase work: `type/phase-N-topic`, e.g. `ci/phase-5-trivy`.
- No tool or agent names in branch names. See [ADR-0008](docs/adr/0008-conventional-branch-naming.md).

## Architecture Decision Records

A **structural change** (Dockerfile, workflows, `supported_versions.json`,
release/commit/dependency config, or the agent framework) must ship with an ADR
under [`docs/adr/`](docs/adr/). CI (`adr-check`) enforces this; a reviewer can
bypass with the `adr-not-needed` label when truly non-structural. See
[`docs/adr/README.md`](docs/adr/README.md).

## Local development

Build and test the image locally with the dev script:

```bash
./dev.sh                       # latest supported versions
./dev.sh <AWS_CLI_VERSION> <TERRAFORM_VERSION>
```

It lints the Dockerfile (hadolint), builds the image, and runs the
container-structure tests. Adding a new tool version also requires the matching
signature files under `security/` — see
[`docs/binaries-verifications.md`](docs/binaries-verifications.md) and
[`docs/dependencies-upgrades.md`](docs/dependencies-upgrades.md).

## Pull request flow

1. Branch off the default branch using the naming above.
2. Commit (Conventional Commits) and push.
3. Open a PR; fill the template, including the ADR checkbox.
4. CI must pass; the maintainer reviews and **squash-merges** (one commit on the
   default branch). Head branches are auto-deleted.

## Releases & dependencies

- Releases are automated by **release-please** (version bump, changelog, GitHub
  release) from the merged Conventional Commits — see
  [ADR-0002](docs/adr/0002-contribution-and-release-workflow.md).
- Dependency updates are handled by **Renovate** only.

## Security

See [`SECURITY.md`](SECURITY.md) to report a vulnerability.
