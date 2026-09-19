# ⬆️ Dependencies upgrades checklist

* Supported tools versions:
  * bump with `scripts/bump-version.sh <terraform|awscli> X.Y.Z` (ADR-0021): it fetches and GPG-verifies the `security/` material and updates `supported_versions.json` within the ADR-0015 window; [`docs/binaries-verifications.md`](binaries-verifications.md) is the manual fallback
  * check available **AWS CLI** version on the [project release page](https://github.com/aws/aws-cli/tags)
  * check available **Terraform CLI** version (version window: ADR-0015) on the [project release page](https://github.com/hashicorp/terraform/releases)
* Dockerfile:
  * check **base image** version [on DockerHub](https://hub.docker.com/_/debian?tab=tags&page=1&name=trixie)
  * check OS package versions on Debian package repository
    * Final image stage packages: **ca-certificates**, **git**, **jq**, **openssh-client**
    * Build stage additional packages: **curl**, **gnupg**, **unzip**
    * Available **ca-certificates** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=ca-certificates)
    * Available **Git** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=git)
    * Available **JQ** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=jq)
    * Available **openssh-client** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=openssh-client)
    * Available **curl** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=curl)
    * Available **gnupg** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=gnupg)
    * Available **unzip** versions on the [Debian Packages repository](https://packages.debian.org/search?suite=trixie&arch=any&searchon=names&keywords=unzip)
  * OS packages are **pinned to exact versions** in the Dockerfile (see ADR-0010). When a build fails with `apt-get ... exit code 100`, a pin was superseded by Debian — run `scripts/refresh-apt-pins.sh` (ADR-0021): it refreshes every pin to the current candidates and syncs the version assertions in [`tests/container-structure-tests.yml.template`](../tests/container-structure-tests.yml.template) in the same write.
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
