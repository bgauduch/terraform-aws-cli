[![lint-dockerfile](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/lint-dockerfile.yml)
[![build-test](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/build-test.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/build-test.yml)
[![push-edge](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/push-edge.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/push-edge.yml)
[![release-please](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/release-please.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/release-please.yml)

[![dockerhub-description-update](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/bgauduch/terraform-aws-cli.svg?label=pulls)](https://hub.docker.com/r/bgauduch/terraform-aws-cli/)
[![Docker Pulls (legacy zenika)](https://img.shields.io/docker/pulls/zenika/terraform-aws-cli.svg?label=pulls%20%28legacy%20zenika%29&color=inactive)](https://hub.docker.com/r/zenika/terraform-aws-cli/)

# Terraform and AWS CLI Docker image

> **📦 New registry — please migrate.** This image now lives at
> [`bgauduch/terraform-aws-cli`](https://hub.docker.com/r/bgauduch/terraform-aws-cli).
> The legacy [`zenika/terraform-aws-cli`](https://hub.docker.com/r/zenika/terraform-aws-cli)
> repository is frozen: update your `docker pull` / `FROM` references to the new
> one. Historical tags are being copied across, migration in progress — see
> [#137](https://github.com/bgauduch/terraform-aws-cli/issues/137).

## 📦 Supported tags and respective Dockerfile links

Available image tags can be found on the Docker Hub registry: [bgauduch/terraform-aws-cli](https://hub.docker.com/r/bgauduch/terraform-aws-cli/tags)

Supported versions are listed in the [`supported_versions.json`](https://github.com/bgauduch/terraform-aws-cli/blob/master/supported_versions.json) file.

The following image tag strategy is applied:

| Tag | What it points at | Moves |
|---|---|---|
| `bgauduch/terraform-aws-cli:latest` | the newest release, with the latest versions in [`supported_versions.json`](https://github.com/bgauduch/terraform-aws-cli/blob/master/supported_versions.json) | on every release |
| `bgauduch/terraform-aws-cli:edge` | the tip of `master`, same version selection | on every image change merged to `master` |
| `bgauduch/terraform-aws-cli:vX.Y` | the latest patch of that minor line | on every release of that line |
| `bgauduch/terraform-aws-cli:vX.Y.Z` | that release, with its latest Terraform and AWS CLI versions | never |
| `bgauduch/terraform-aws-cli:vX.Y.Z_tf-A.B.C_aws-D.E.F` | that release, fully pinned to a Terraform (`A.B.C`) and AWS CLI (`D.E.F`) combination | **never** — pin this one for reproducibility |

Which one to use: `vX.Y.Z_tf-A.B.C_aws-D.E.F` when a build must never change
under you, `latest` or `vX.Y` for everyday use, `edge` only to try what is
merged but not released.

Please report to the [releases page](https://github.com/bgauduch/terraform-aws-cli/releases) for the changelogs.

> Any other tags are not supported even if available.

**Version support policy:** supported Terraform versions follow upstream EOL —
the latest three minor lines (the two [HashiCorp still patches](https://support.hashicorp.com/hc/en-us/articles/360021185113-Support-Period-and-End-of-Life-EOL-Policy)
plus one kept as grace), one patch per line
(see [ADR-0015](docs/adr/0015-version-support-follows-upstream-eol.md)).
Retiring a version stops **new builds only**: every previously published
fully-pinned tag (`vX.Y.Z_tf-A.B.C_aws-D.E.F`) is immutable and stays pullable
forever — pin one of those to keep using an older combination.

**Platform support policy:** images are published for **`linux/amd64` and
`linux/arm64`**, the platforms AWS distributes a Linux CLI v2 bundle for
(see [ADR-0019](docs/adr/0019-platform-support-follows-upstream.md)). As with
versions, dropping a platform stops new builds only: tags published earlier
keep the manifests they were pushed with.

## 💡 Motivation

The goal is to create a **minimalist** and **lightweight** image with these tools in order to reduce network and storage impact.

This image gives you the flexibility to be used for development or as a base image as you see fits.

## 🔧 What's inside ?

Tools included:

* [Terraform CLI](https://www.terraform.io/docs/commands/index.html)
* [AWS CLI](https://aws.amazon.com/fr/cli/)
* [Git](https://git-scm.com/) for Terraform remote module usage
* [jq](https://stedolan.github.io/jq/) to process JSON returned by AWS
* [OpenSSH Client](https://www.openssh.com/) to handle Terraform module clone over SSH
* This image uses a non-root user with a UID and GID of 1001 to conform with docker security best practices.

## 🚀 Usage

### 🐚 Launch the CLI

Set your AWS credentials (optional) and use the CLI as you would on any other platform, for instance using the latest image:

```bash
echo AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
echo AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
echo AWS_DEFAULT_REGION=YOUR_DEFAULT_REGION

docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace bgauduch/terraform-aws-cli:latest
```

> The `--rm` flag will completely destroy the container and its data on exit.

### ⚙️ Build the image

The image can be built and verified locally with the validation script.

It will :

* Run the structural checks on the repository;
* Lint the Dockerfile with [Hadolint](https://github.com/hadolint/hadolint);
* Build and tag the image `bgauduch/terraform-aws-cli:dev` for your platform;
* Execute [container structure tests](https://github.com/GoogleContainerTools/container-structure-test) on the image.

```bash
# build and verify with the latest supported versions
./scripts/validate.sh --full
```

Optionally, it is possible to choose the tools desired versions :

```bash
# Set tools desired versions
AWS_CLI_VERSION=2.12.6
TERRAFORM_VERSION=1.5.2

# build and verify these versions
./scripts/validate.sh --full $AWS_CLI_VERSION $TERRAFORM_VERSION
```

## 🙏 Contributions

Before contributing, please read the [contributing guide](CONTRIBUTING.md), the [code of conduct](CODE_OF_CONDUCT.md) and the [security policy](SECURITY.md).

Do not hesitate to contribute by [filling an issue](https://github.com/bgauduch/terraform-aws-cli/issues) or [a PR](https://github.com/bgauduch/terraform-aws-cli/pulls) !

## 📚 Documentations

* [Contributing guide](CONTRIBUTING.md)
* [Code of conduct](CODE_OF_CONDUCT.md)
* [Security policy](SECURITY.md)
* [Publishing & registry auth](docs/publishing.md)
* [Rollback policy](docs/rollback.md)
* [Dependencies upgrades checklist](docs/dependencies-upgrades.md)
* [Binaries verifications](docs/binaries-verifications.md)

## 🚩 Similar repositories

* For Azure: [zenika-open-source/terraform-azure-cli](https://github.com/zenika-open-source/terraform-azure-cli)

## 📖 License
This project is under the [Apache License 2.0](https://raw.githubusercontent.com/bgauduch/terraform-aws-cli/master/LICENSE)

[![with love by zenika](https://img.shields.io/badge/With%20%E2%9D%A4%EF%B8%8F%20by-Zenika-b51432.svg)](https://oss.zenika.com)
