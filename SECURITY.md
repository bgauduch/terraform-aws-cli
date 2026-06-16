# Security policy

## Supported versions

This project ships a Docker image bundling Terraform CLI + AWS CLI. The actively
maintained image tags and bundled tool versions are listed in
[`supported_versions.json`](supported_versions.json); `latest` always tracks the
newest supported combination. Security fixes target the latest supported
versions — older pinned, immutable image tags are not rebuilt (re-pin to a newer
tag to receive fixes; see [ADR-0003](docs/adr/0003-image-versioning-and-tag-strategy.md)).

## Reporting a vulnerability

Please report vulnerabilities **privately** — do not open a public issue.

- Preferred: **GitHub → Security → "Report a vulnerability"** (private
  vulnerability reporting) on this repository.

What to expect:

- Acknowledgement within **5 business days**.
- An initial assessment and, if confirmed, a remediation plan.
- Coordinated disclosure once a fix is available.

## Supply-chain notes

Bundled binaries are verified at build time: Terraform and AWS CLI archives are
checked against their publishers' GPG signatures and checksums (material under
[`security/`](security/)). Additional supply-chain hardening (image
vulnerability scanning, SBOM, provenance, signing) is **planned** — see
[`docs/roadmap.md`](docs/roadmap.md).
