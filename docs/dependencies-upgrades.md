# ⬆️ Dependencies upgrades checklist

> **Note:** Dependency management is now partially automated via [Renovate](https://docs.renovatebot.com/):
> - **GitHub Actions** versions are updated automatically by Renovate.
> - **Base Debian image** version is updated automatically by Renovate.
>
> **Tool versions (Terraform, AWS CLI) still require manual steps:** when adding a new supported version, the binary verification files must be downloaded manually to `security/` — see [`docs/binaries-verifications.md`](binaries-verifications.md).

* Supported tools versions:
  * [Report to the doc](https://github.com/zenika-open-source/terraform-aws-cli/tree/master/docs/binaries-verifications.md) to add required security files when adding a new supported versions
  * check available **AWS CLI** version on the [project release page](https://github.com/aws/aws-cli/tags)
  * check available **Terraform CLI** version (keep all minor versions from 0.11) on the [project release page](https://github.com/hashicorp/terraform/releases)
* Dockerfile:
  * check **base image** version [on DockerHub](https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye)
  * check OS package versions on Debian package repository
    * Available **Git** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bullseye&arch=any&searchon=names&keywords=git)
    * Available **JQ** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bullseye&arch=any&searchon=names&keywords=jq)
    * same process for all other packages
* Dockerfile tests : update version according to changes in Dockerfile in [tests/container-structure-tests.yml.template](tests/container-structure-tests.yml.template)
* Github actions:
  * check [runner version](https://github.com/actions/virtual-environments#available-environments)
  * check **each action release** versions
* Build scripts:
  * check **container tags**:
    * [Hadolint releases](https://github.com/hadolint/hadolint/releases)
    * [Container-structure-test](https://github.com/GoogleContainerTools/container-structure-test/releases)
* Readme:
  * update version in code exemples
