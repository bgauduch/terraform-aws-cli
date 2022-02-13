[![lint-dockerfile](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/lint-dockerfile.yml/badge.svg)](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/lint-dockerfile.yml)
[![build-test](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/build-test.yml/badge.svg)](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/build-test.yml)
[![push-latest](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/push-latest.yml/badge.svg)](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/push-latest.yml)
[![release](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/release.yml/badge.svg)](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/release.yml)

[![dockerhub-description-update](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml/badge.svg)](https://github.com/zenika-open-source/terraform-aws-cli/actions/workflows/dockerhub-description-update.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/zenika/terraform-aws-cli.svg)](https://hub.docker.com/r/zenika/terraform-aws-cli/)

# Terraform and AWS CLI Docker image

## 📦 Supported tags and respective Dockerfile links
Available image tags can be found on the Docker Hub registry: [zenika/terraform-aws-cli](https://hub.docker.com/r/zenika/terraform-aws-cli/tags)

Supported versions are listed in the [`supported_versions.json`](https://github.com/Zenika/terraform-aws-cli/blob/master/supported_versions.json) file in project root folder.

The following image tag strategy is applied:
* `zenika/terraform-aws-cli:latest` - build from master
  * Included CLI versions are the newest in the [`supported_versions.json` ](https://github.com/Zenika/terraform-aws-cli/blob/master/supported_versions.json) file.
* `zenika/terraform-aws-cli:release-S.T_terraform-UU.VV.WW_awscli-XX.YY.ZZ` - build from releases
  * `release-S.T` is the release tag
  * `terraform-UU.VV.WWW` is the **Terraform** version included in the image
  * `awscli-XX.YY.ZZ` is the **AWS CLI** version included in the image

Please report to the [releases page](https://github.com/Zenika/terraform-aws-cli/releases) for the changelogs.

> Any other tags are not supported even if available.

## 💡 Motivation
The goal is to create a **minimalist** and **lightweight** image with these tools in order to reduce network and storage impact.

This image gives you the flexibility to be used for development or as a base image as you see fits.

## 🔧 What's inside ?
Tools included:

* [Terraform CLI](https://www.terraform.io/docs/commands/index.html)
* [AWS CLI](https://aws.amazon.com/fr/cli/)
* [Git](https://git-scm.com/) for Terraform remote module usage
* [Python 3](https://www.python.org/)
* [jq](https://stedolan.github.io/jq/) to process JSON returned by AWS
* This image uses a non-root user with a UID and GID of 1001 to conform with docker security best practices.

## 🚀 Usage

### 🐚 Launch the CLI
Set your AWS credentials (optional) and use the CLI as you would on any other platform, for instance using the latest image:

```bash
echo AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
echo AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
echo AWS_DEFAULT_REGION=YOUR_DEFAULT_REGION

docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace zenika/terraform-aws-cli:latest
```

> The `--rm` flag will completely destroy the container and its data on exit.

### ⚙️ Build the image
You can build the image locally directly from the Dockerfiles, using the build script.

It will :
* Lint the Dockerfile with [Hadolint](https://github.com/hadolint/hadolint);
* Build and tag the image `zenika/terraform-aws-cli:dev`;
* Execute [container structure tests](https://github.com/GoogleContainerTools/container-structure-test) on the image.

```bash
# launch build script
./dev.sh
```

Optionally, it is possible to choose the tools desired versions :

```bash
# Set tools desired versions
AWS_CLI_VERSION=1.18.189
TERRAFORM_VERSION=0.14.0

# launch the build script with parameters
./dev.sh $AWS_CLI_VERSION $TERRAFORM_VERSION
```

## 🙏 Contributions
Do not hesitate to contribute by [filling an issue](https://github.com/Zenika/terraform-aws-cli/issues) or [a PR](https://github.com/Zenika/terraform-aws-cli/pulls) !

## ⬆️ Dependencies upgrades checklist

* Supported versions:
  * check available **AWS CLI** version on the [project release page](https://github.com/aws/aws-cli/releases)
  * check available **Terraform CLI** version (keep all minor versions from 0.11) available on the [project release page](https://github.com/hashicorp/terraform/releases)
* Dockerfile:
  * check **base image** version on DockerHub
  * check OS package versions on Debian package repository
    * Available **Git** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bullseye&arch=any&searchon=names&keywords=git)
    * Available **Python** versions on the [Debian packages repository](https://packages.debian.org/search?suite=bullseye&arch=any&searchon=names&keywords=python3)
    * Available **JQ** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bullseye&arch=any&searchon=names&keywords=jq)
    * same process for all other packages
  * check **Pip** package versions on [pypi](https://pypi.org/)
* Github actions:
  * check [runner version](https://github.com/actions/virtual-environments#available-environments)
  * check **each action release** versions
* Build scripts:
  * check **container tags**:
    * [Hadolint releases](https://github.com/hadolint/hadolint/releases)
    * [Container-structure-test](https://github.com/GoogleContainerTools/container-structure-test/releases)
* Readme:
  * update version in code exemples

## 🚩 Similar repositories

* For Azure: [zenika-open-source/terraform-azure-cli](https://github.com/zenika-open-source/terraform-azure-cli)

## 📖 License
This project is under the [Apache License 2.0](https://raw.githubusercontent.com/Zenika/terraform-aws-cli/master/LICENSE)

[![with love by zenika](https://img.shields.io/badge/With%20%E2%9D%A4%EF%B8%8F%20by-Zenika-b51432.svg)](https://oss.zenika.com)
