# Security Policy

## Supported Versions

Only the latest release is actively supported with security updates.

| Version | Supported |
| ------- | --------- |
| latest  | ✅        |
| older   | ❌        |

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public GitHub issues.

Instead, report them by opening a [GitHub Security Advisory](https://github.com/bgauduch/terraform-aws-cli/security/advisories/new).

You can expect:
- **Acknowledgement** within 48 hours
- **Status update** within 7 days
- **Fix or mitigation** within 90 days depending on severity

## Security Measures

This project implements the following supply chain security measures:

- **Binary verification**: Terraform and AWS CLI binaries are verified using GPG signatures and SHA256 checksums before inclusion in the image
- **Non-root container**: The image runs as a non-root user (`nonroot`, UID 1001)
- **Minimal base image**: Uses Debian slim to reduce attack surface
- **Vulnerability scanning**: Images are scanned with [Trivy](https://github.com/aquasecurity/trivy) on every build
- **SBOM**: A Software Bill of Materials (SPDX format) is attached to every release
- **Image signing**: Released images are signed using [cosign](https://github.com/sigstore/cosign) with keyless signing (Sigstore)

### Verifying image signatures

```bash
cosign verify ghcr.io/bgauduch/terraform-aws-cli:<tag> \
  --certificate-identity-regexp="https://github.com/bgauduch/terraform-aws-cli/.github/workflows/release.yml@refs/tags/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```
