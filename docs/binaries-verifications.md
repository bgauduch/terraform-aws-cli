# Binary verifications — manual fallback

`scripts/bump-version.sh` is the normal path (ADR-0021): it downloads,
GPG-verifies and writes the material below in one gesture. This page is the
fallback when the script cannot run, and the record of what the material is.

Every bundled binary is verified at image build time (see the `Dockerfile`):
Terraform archives against their GPG-signed `SHA256SUMS`, AWS CLI archives
against their per-architecture GPG signature (ADR-0017). The verifying
material lives under [`/security`](../security/):

- `hashicorp.asc` / `awscliv2.asc` — the vendors' public GPG keys
  ([HashiCorp security](https://www.hashicorp.com/security),
  [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)).
- `terraform_X.Y.Z_SHA256SUMS` and `.sig`, one pair per supported version —
  from the [official Terraform releases](https://releases.hashicorp.com/terraform).
- `awscli-exe-linux-<arch>-X.Y.Z.zip.sig`, one per published architecture
  (`x86_64`, `aarch64`) — from `https://awscli.amazonaws.com/`.

Manual fetch, when the script is unavailable:

```shell
export TF_VERSION=1.15.8 AWS_CLI_VERSION=2.36.6

curl -o security/terraform_${TF_VERSION}_SHA256SUMS     https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS
curl -o security/terraform_${TF_VERSION}_SHA256SUMS.sig https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS.sig

for arch in x86_64 aarch64; do
  curl -o security/awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip.sig https://awscli.amazonaws.com/awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip.sig
done
```

Then verify each file against the vendor key before committing, update
`supported_versions.json` by hand within the ADR-0015 window, and run
`scripts/validate.sh --fast`.
