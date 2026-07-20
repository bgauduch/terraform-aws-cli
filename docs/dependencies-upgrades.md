# ⬆️ Dependencies upgrades checklist

* Supported tools versions:
  * [Report to the doc](https://github.com/zenika-open-source/terraform-aws-cli/tree/master/docs/binaries-verifications.md) to add required security files (stored under `security/`, e.g. `security/hashicorp.asc`) when adding a new supported versions
  * check available **AWS CLI** version on the [project release page](https://github.com/aws/aws-cli/tags)
  * check available **Terraform CLI** version (keep one patch per minor, from 1.0 — see ADR-0004) on the [project release page](https://github.com/hashicorp/terraform/releases)
* Dockerfile:
  * check **base image** version [on DockerHub](https://hub.docker.com/_/debian?tab=tags&page=1&name=bookworm)
  * check OS package versions on Debian package repository
    * Final image stage packages: **ca-certificates**, **git**, **jq**, **openssh-client**
    * Build stage additional packages: **curl**, **gnupg**, **unzip**
    * Available **ca-certificates** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=ca-certificates)
    * Available **Git** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=git)
    * Available **JQ** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=jq)
    * Available **openssh-client** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=openssh-client)
    * Available **curl** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=curl)
    * Available **gnupg** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=gnupg)
    * Available **unzip** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=bookworm&arch=any&searchon=names&keywords=unzip)
  * OS packages are **pinned to exact versions** in the Dockerfile (see ADR-0010). When a build fails with `apt-get ... exit code 100`, a pin was superseded by Debian — refresh **all** pins to the current candidates, then update the Dockerfile **and** the matching version assertions in [`tests/container-structure-tests.yml.template`](../tests/container-structure-tests.yml.template) (e.g. the git/jq/openssh versions):

    ```bash
    docker run --rm debian:bookworm-slim bash -c \
      'apt-get update -qq && for p in ca-certificates curl gnupg unzip git jq openssh-client; do \
         printf "%s=%s\n" "$p" "$(apt-cache policy "$p" | awk "/Candidate:/{print \$2}")"; done'
    ```
* Dockerfile tests : update version according to changes in Dockerfile in [tests/container-structure-tests.yml.template](../tests/container-structure-tests.yml.template)
* Github actions:
  * check [runner version](https://github.com/actions/virtual-environments#available-environments)
  * check **each action release** versions
* Build scripts:
  * check **container tags**:
    * [Hadolint releases](https://github.com/hadolint/hadolint/releases)
    * [Container-structure-test](https://github.com/GoogleContainerTools/container-structure-test/releases)
* Readme:
  * update version in code exemples
