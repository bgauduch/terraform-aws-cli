#!/usr/bin/env bash

set -eo pipefail

# FIXME: use getopts function to parse aguments
# FIXME: if provided, both TF and AWS CLI semvers should be regex-validated

# Set AWS and TF CLI to latest supported versions if not specified
[[ -n $1 ]] && AWS_VERSION=$1 || AWS_VERSION=$(jq -r '.awscli_version | sort | .[-1]' supported_versions.json)
[[ -n $2 ]] && TF_VERSION=$2 || TF_VERSION=$(jq -r '.tf_version | sort | .[-1]' supported_versions.json)

# Set image name and tag (dev if not specified)
IMAGE_NAME="zenika/terraform-aws-cli"
[[ -n $3 ]] && IMAGE_TAG=$3 || IMAGE_TAG="dev"

# Lint Dockerfile
echo "Linting Dockerfile..."
docker run --rm --interactive --volume "${PWD}":/data --workdir /data hadolint/hadolint:2.5.0-alpine /bin/hadolint --config hadolint.yaml Dockerfile
echo "Lint Successful!"

# Build image
echo "Building images with AWS_CLI_VERSION=${AWS_VERSION} and TERRAFORM_VERSION=${TF_VERSION}..."
docker image build --build-arg AWS_CLI_VERSION="$AWS_VERSION" --build-arg TERRAFORM_VERSION="$TF_VERSION" -t $IMAGE_NAME:$IMAGE_TAG .
echo "Image successfully builded!"

# Test image
echo "Generating test config with AWS_CLI_VERSION=${AWS_VERSION} and TERRAFORM_VERSION=${TF_VERSION}..."
export AWS_VERSION=${AWS_VERSION} && export TF_VERSION=${TF_VERSION}
envsubst '${AWS_VERSION},${TF_VERSION}' < tests/container-structure-tests.yml.template > tests/container-structure-tests.yml
echo "Test config successfully generated!"
echo "Executing container structure test..."
docker container run --rm --interactive --volume "${PWD}"/tests/container-structure-tests.yml:/tests.yml:ro -v /var/run/docker.sock:/var/run/docker.sock:ro gcr.io/gcp-runtimes/container-structure-test:v1.10.0 test --image $IMAGE_NAME:$IMAGE_TAG --config /tests.yml

# cleanup
unset AWS_VERSION
unset TF_VERSION
