# ⬆️ Dependencies upgrades checklist

## Automatisation via Renovate

La gestion des dépendances est en grande partie automatisée via [Renovate](https://docs.renovatebot.com/). La configuration se trouve dans [`renovate.json`](../renovate.json).

### Ce que Renovate gère automatiquement

| Scope | Comportement |
|---|---|
| **GitHub Actions** | PRs groupées chaque week-end ; patches/digests automerge |
| **Image de base Debian** (Dockerfile) | PRs groupées avec les paquets APT |
| **Dernière version Terraform** (`supported_versions.json`) | PR créée quand une nouvelle release sort sur GitHub |
| **Dernière version AWS CLI** (`supported_versions.json`) | PR créée quand un nouveau tag sort sur GitHub |

### Ce qui reste manuel après merge d'une PR Renovate sur les versions d'outils

Lorsque Renovate met à jour la dernière version Terraform ou AWS CLI dans `supported_versions.json`, les **fichiers de vérification GPG** associés doivent être ajoutés manuellement dans le répertoire `security/` avant de pouvoir builder l'image. Se référer à [`docs/binaries-verifications.md`](binaries-verifications.md) pour la procédure complète.

---

## Checklist manuelle (hors scope Renovate)

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
