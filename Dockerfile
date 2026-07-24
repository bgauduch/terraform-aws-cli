# Setup build arguments
ARG AWS_CLI_VERSION
ARG TERRAFORM_VERSION
ARG DEBIAN_VERSION=trixie-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd
ARG DEBIAN_FRONTEND=noninteractive

# Download Terraform binary
FROM debian:${DEBIAN_VERSION} as terraform
ARG TARGETARCH
ARG TERRAFORM_VERSION
RUN apt-get update
RUN apt-get install --no-install-recommends -y ca-certificates=20250419
RUN apt-get install --no-install-recommends -y curl=8.14.1-2+deb13u4
RUN apt-get install --no-install-recommends -y gnupg=2.4.7-21+deb13u1
RUN apt-get install --no-install-recommends -y unzip=6.0-29
WORKDIR /workspace
# --retry alone does not cover connection resets (curl exit 35) — --retry-all-errors does
RUN curl --silent --show-error --fail --retry 5 --retry-delay 2 --retry-all-errors --remote-name https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip
COPY security/hashicorp.asc ./
COPY security/terraform_${TERRAFORM_VERSION}** ./
RUN gpg --import hashicorp.asc
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum --check --strict --ignore-missing terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip

# Install AWS CLI version 2
FROM debian:${DEBIAN_VERSION} as aws-cli
ARG AWS_CLI_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates=20250419
RUN apt-get install -y --no-install-recommends curl=8.14.1-2+deb13u4
RUN apt-get install -y --no-install-recommends gnupg=2.4.7-21+deb13u1
RUN apt-get install -y --no-install-recommends unzip=6.0-29
RUN apt-get install -y --no-install-recommends git=1:2.47.3-0+deb13u1
RUN apt-get install -y --no-install-recommends jq=1.7.1-6+deb13u2
WORKDIR /workspace
# --retry alone does not cover connection resets (curl exit 35) — --retry-all-errors does
RUN curl --show-error --fail --retry 5 --retry-delay 2 --retry-all-errors --output "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
COPY security/awscliv2.asc ./
COPY security/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig ./awscliv2.sig
RUN gpg --import awscliv2.asc
RUN gpg --verify awscliv2.sig awscliv2.zip
RUN unzip -u awscliv2.zip
RUN ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin

# Build final image
FROM debian:${DEBIAN_VERSION} as build
LABEL maintainer="bgauduch@github"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20250419 \
    git=1:2.47.3-0+deb13u1 \
    jq=1.7.1-6+deb13u2 \
    openssh-client=1:10.0p1-7+deb13u4 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY --from=terraform /workspace/terraform /usr/local/bin/terraform
COPY --from=aws-cli /usr/local/bin/ /usr/local/bin/
COPY --from=aws-cli /usr/local/aws-cli /usr/local/aws-cli

RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store aws credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && chown nonroot:nonroot /workspace
USER nonroot

CMD ["bash"]
