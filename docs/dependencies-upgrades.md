# ⬆️ Dependencies upgrades checklist

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
