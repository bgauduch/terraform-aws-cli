#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: script failed at line ${LINENO}" >&2' ERR

usage() {
  echo "Usage: $0 [-a AWS_CLI_VERSION] [-t TF_VERSION] [-i IMAGE_TAG]"
  echo "  -a  AWS CLI version (default: latest from supported_versions.json)"
  echo "  -t  Terraform version (default: latest from supported_versions.json)"
  echo "  -i  Image tag (default: dev)"
  exit 1
}

while getopts "a:t:i:h" opt; do
  case ${opt} in
    a) AWS_VERSION="${OPTARG}" ;;
    t) TF_VERSION="${OPTARG}" ;;
    i) IMAGE_TAG="${OPTARG}" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# Set AWS and TF CLI to latest supported versions if not specified
AWS_VERSION="${AWS_VERSION:-$(jq -r '.awscli_versions | sort | .[-1]' supported_versions.json)}"
TF_VERSION="${TF_VERSION:-$(jq -r '.tf_versions | sort | .[-1]' supported_versions.json)}"

# Set image name and tag (dev if not specified)
IMAGE_NAME="zenika/terraform-aws-cli"
IMAGE_TAG="${IMAGE_TAG:-dev}"

SEMVER_REGEX="^[0-9]+\.[0-9]+\.[0-9]+$"

validate_semver() {
  local version="$1"
  local name="$2"
  if [[ ! "${version}" =~ ${SEMVER_REGEX} ]]; then
    echo "Error: ${name} '${version}' is not a valid semver (expected X.Y.Z)"
    exit 1
  fi
}

validate_semver "${AWS_VERSION}" "AWS_CLI_VERSION"
validate_semver "${TF_VERSION}" "TERRAFORM_VERSION"

# Set platform for Hadolint image (only linux/amd64 or linux/arm64 supported)
PLATFORM="linux/$(uname -m)"

# Lint Dockerfile
echo "Linting Dockerfile..."
docker container run --rm --interactive \
  --volume "${PWD}":/data \
  --workdir /data \
  --platform "${PLATFORM}" \
  hadolint/hadolint:2.12.0-alpine /bin/hadolint \
  --config hadolint.yaml Dockerfile
echo "Lint Successful!"

# Build image
echo "Building images with AWS_CLI_VERSION=${AWS_VERSION} and TERRAFORM_VERSION=${TF_VERSION}..."
docker buildx build \
  --progress plain \
  --platform "${PLATFORM}" \
  --build-arg AWS_CLI_VERSION="${AWS_VERSION}" \
  --build-arg TERRAFORM_VERSION="${TF_VERSION}" \
  --tag ${IMAGE_NAME}:${IMAGE_TAG} .
echo "Image successfully builded!"

# Test image
echo "Generating test config with AWS_CLI_VERSION=${AWS_VERSION} and TERRAFORM_VERSION=${TF_VERSION}..."
export AWS_VERSION=${AWS_VERSION} && export TF_VERSION=${TF_VERSION}
envsubst '${AWS_VERSION},${TF_VERSION}' < tests/container-structure-tests.yml.template > tests/container-structure-tests.yml
echo "Test config successfully generated!"
echo "Executing container structure test..."
docker container run --rm --interactive \
  --volume "${PWD}"/tests/container-structure-tests.yml:/tests.yml:ro \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  gcr.io/gcp-runtimes/container-structure-test:v1.15.0 test \
  --image ${IMAGE_NAME}:${IMAGE_TAG} \
  --config /tests.yml

# cleanup
unset AWS_VERSION
unset TF_VERSION
