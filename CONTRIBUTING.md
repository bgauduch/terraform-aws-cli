# Contributing

Thank you for your interest in contributing to this project!

## How to contribute

1. Fork the repository
2. Create a branch from `master`: `git checkout -b feat/my-feature`
3. Make your changes
4. Ensure tests pass locally: `./dev.sh`
5. Commit using [Conventional Commits](#commit-convention)
6. Push and open a Pull Request targeting `master`

## Commit convention

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

Format: `<type>(<scope>): <description>`

Common types:
| Type | Use for |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, dependency updates |
| `ci` | CI/CD changes |
| `docs` | Documentation only |
| `refactor` | Code refactoring |
| `test` | Test additions or fixes |
| `security` | Security improvements |

Examples:
```
feat: add support for terraform 2.0
fix(dev.sh): correct platform detection on arm64
chore(deps): update debian base image to bookworm-20250101-slim
ci: add trivy vulnerability scanning
```

PR titles must also follow this convention — the title becomes the squash-merge commit message.

## Local development

Requirements: Docker, `jq`, `envsubst`

```bash
# Build and test with latest supported versions
./dev.sh

# Build and test with specific versions
./dev.sh -a 2.17.0 -t 1.9.0

# Build with a custom tag
./dev.sh -a 2.17.0 -t 1.9.0 -i my-test
```

## Adding a new tool version

When Terraform or AWS CLI releases a new version:

1. Add the version to `supported_versions.json`
2. Download the verification files to `security/` — see [`docs/binaries-verifications.md`](docs/binaries-verifications.md)
3. Open a PR with the changes

## Code review

All PRs require at least one approval. The CI must pass (lint, build, tests) before merging.
