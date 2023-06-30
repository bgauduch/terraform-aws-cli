# ⬆️ Dependencies upgrades checklist

* Supported versions:
  * check available **AWS CLI** version on the [PyPip release page](https://pypi.org/project/awscli/)
  * check available **Terraform CLI** version (keep all minor versions from 0.11) available on the [project release page](https://github.com/hashicorp/terraform/releases)
    * [Report to the doc](https://github.com/zenika-open-source/terraform-aws-cli/tree/master/docs/terraform-binaries-verifications.md) to add required security files when adding a new supported Terraform version
* Dockerfile:
  * check **base image** version [on DockerHub](https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye)
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
