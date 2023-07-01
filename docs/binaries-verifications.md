# Binary verifications

## Terraform signature and PGP verification

Both Terraform SHA256SUM and signature files are verified against [Hashicorp public GPG key](https://www.hashicorp.com/security).

Terraform archives are verified against there SHA256SUMS after donwload.

Theses files need to be added to the [/security](https://github.com/zenika-open-source/terraform-aws-cli/tree/master/security) folder.

They can be downloaded from the [official Terraform releases](https://releases.hashicorp.com/terraform).

## AWS CLI signature and PGP verification

Both AWS CLI archives and signatures files are verified against AWS public GPG key.

Theses files need to be added to the [/security](https://github.com/zenika-open-source/terraform-aws-cli/tree/master/security) folder.

They can be downloaded locally using this command:

```shell
# Export target aws cli version
export AWS_CLI_VERSION=2.12.5

# Download signature file
curl -o security/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip.sig
```
