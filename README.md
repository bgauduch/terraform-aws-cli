[![lint-dockerfile](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/lint-dockerfile.yml)
[![build-test](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/build-test.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/build-test.yml)
[![push-latest](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/push-latest.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/push-latest.yml)
[![release](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/release.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/release.yml)

[![dockerhub-description-update](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml/badge.svg)](https://github.com/bgauduch/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/bgauduch/terraform-aws-cli.svg)](https://hub.docker.com/r/bgauduch/terraform-aws-cli/)

# Terraform and AWS CLI Docker image

## 📦 Supported tags and respective Dockerfile links

The image is available on two registries:

- **Docker Hub**: [bgauduch/terraform-aws-cli](https://hub.docker.com/r/bgauduch/terraform-aws-cli/tags)
- **GitHub Container Registry**: [ghcr.io/bgauduch/terraform-aws-cli](https://github.com/bgauduch/terraform-aws-cli/pkgs/container/terraform-aws-cli)

Supported versions are listed in the [`supported_versions.json`](https://github.com/bgauduch/terraform-aws-cli/blob/master/supported_versions.json) file.

The following image tag strategy is applied:

* `bgauduch/terraform-aws-cli:latest` / `ghcr.io/bgauduch/terraform-aws-cli:latest` - build from master
  * Included CLI versions are the latest in [`supported_versions.json`](https://github.com/bgauduch/terraform-aws-cli/blob/master/supported_versions.json) file.
* `bgauduch/terraform-aws-cli:vX.Y.Z_tf-A.B.C_aws-D.E.F` / `ghcr.io/bgauduch/terraform-aws-cli:vX.Y.Z_tf-A.B.C_aws-D.E.F` - build from releases (full pinned tag)
  * `vX.Y.Z` is the release version tag
  * `tf-A.B.C` is the **Terraform** version included in the image
  * `aws-D.E.F` is the **AWS CLI** version included in the image
* `bgauduch/terraform-aws-cli:tf-A.B_aws-D.E` / `ghcr.io/bgauduch/terraform-aws-cli:tf-A.B_aws-D.E` - floating minor version tags
  * Always point to the latest release for the given minor versions of Terraform and AWS CLI

Please report to the [releases page](https://github.com/bgauduch/terraform-aws-cli/releases) for the changelogs.

> Any other tags are not supported even if available.

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

Set your AWS credentials (optional) and use the CLI as you would on any other platform, for instance using the latest image from Docker Hub:

```bash
echo AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
echo AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
echo AWS_DEFAULT_REGION=YOUR_DEFAULT_REGION

docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace bgauduch/terraform-aws-cli:latest
```

Or pull from the GitHub Container Registry:

```bash
docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace ghcr.io/bgauduch/terraform-aws-cli:latest
```

> The `--rm` flag will completely destroy the container and its data on exit.

### ⚙️ Build the image

The image can be built locally directly from the Dockerfiles, using the build script.

It will :

* Lint the Dockerfile with [Hadolint](https://github.com/hadolint/hadolint);
* Build and tag the image `bgauduch/terraform-aws-cli:dev`;
* Execute [container structure tests](https://github.com/GoogleContainerTools/container-structure-test) on the image.

```bash
# launch build script
./dev.sh
```

Optionally, it is possible to choose the tools desired versions :

```bash
# Set tools desired versions
AWS_CLI_VERSION=2.12.6
TERRAFORM_VERSION=1.5.2

# launch the build script with parameters
./dev.sh $AWS_CLI_VERSION $TERRAFORM_VERSION
```

## 🙏 Contributions
Do not hesitate to contribute by [filling an issue](https://github.com/bgauduch/terraform-aws-cli/issues) or [a PR](https://github.com/bgauduch/terraform-aws-cli/pulls) !

## 📚 Documentations

* [Dependencies upgrades checklist](https://github.com/bgauduch/terraform-aws-cli/tree/master/docs/dependencies-upgrades.md)
* [Binaries verifications](https://github.com/bgauduch/terraform-aws-cli/tree/master/docs/binaries-verifications.md)

## 🚩 Similar repositories

* For Azure: [zenika-open-source/terraform-azure-cli](https://github.com/zenika-open-source/terraform-azure-cli)

## 📖 License
This project is under the [Apache License 2.0](https://raw.githubusercontent.com/bgauduch/terraform-aws-cli/master/LICENSE)
