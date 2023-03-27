# Setup build arguments
ARG AWS_CLI_VERSION
ARG TERRAFORM_VERSION
ARG PYTHON_MAJOR_VERSION=3.9
ARG DEBIAN_VERSION=bullseye-20230109-slim
ARG DEBIAN_FRONTEND=noninteractive

# Download Terraform binary
FROM debian:${DEBIAN_VERSION} as terraform
ARG TARGETARCH
ARG TERRAFORM_VERSION
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    libcurl4=7.74.0-1.3+deb11u3 \
    curl=7.74.0-1.3+deb11u3 \
    ca-certificates=20210119 \
    unzip=6.0-26+deb11u1 \
    gnupg=2.2.27-2+deb11u2

WORKDIR /workspace
RUN curl --silent --show-error --fail --remote-name https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip
COPY security/hashicorp.asc ./
COPY security/terraform_${TERRAFORM_VERSION}** ./
RUN gpg --import hashicorp.asc
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum --check --strict --ignore-missing terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip

# Install AWS CLI using PIP
FROM debian:${DEBIAN_VERSION} as aws-cli
ARG AWS_CLI_VERSION
ARG PYTHON_MAJOR_VERSION
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3=${PYTHON_MAJOR_VERSION}.2-3
    python3-pip=20.3.4-4+deb11u1
RUN pip3 install --no-cache-dir setuptools==67.1.0 awscli==${AWS_CLI_VERSION}

# Build final image
FROM debian:${DEBIAN_VERSION} as build
LABEL maintainer="bgauduch@github"
ARG PYTHON_MAJOR_VERSION
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119\
    git=1:2.30.2-1 \
    jq=1.6-2.1 \
    python3=${PYTHON_MAJOR_VERSION}.2-3 \
    openssh-client=1:8.4p1-5+deb11u1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_MAJOR_VERSION} 1
WORKDIR /workspace
COPY --from=terraform /workspace/terraform /usr/local/bin/terraform
COPY --from=aws-cli /usr/local/bin/aws* /usr/local/bin/
COPY --from=aws-cli /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages
COPY --from=aws-cli /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages

RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store aws credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && chown nonroot:nonroot /workspace
USER nonroot

CMD ["bash"]
