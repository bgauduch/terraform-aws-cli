# 0025 — The image ships its named tools; runtime extras are the consumer's `FROM`

- Status: Accepted
- Date: 2026-09-20
- Deciders: @bgauduch

## Context and problem statement

Five requests over four years asked for one more tool in the image: the
Terraform AWS provider (#16), python3 (#80, #92, PR #88) and git-lfs (#91). The
answer existed only as a roadmap out-of-scope bullet, so each ask restarted the
argument and some got none.

## Decision drivers

- The image's stated purpose is minimalist and lightweight (README).
- The set of defensible extras is unbounded: there is no stopping point once the
  first is admitted.
- Every extra costs size, attack surface and pin maintenance (ADR-0010) for
  every consumer of every tag.
- Removing a bundled tool is breaking. python3 was bundled once, and its removal
  is what produced #80 and #92.

## Considered options

- **Bundle the requested extras.** Rejected: unbounded, and it breaks the
  minimalist purpose for everyone to serve some.
- **Ship variants here** (`-python`, `-lfs`). Rejected: each variant multiplies
  the publication matrix (ADR-0018) and the pull-request gate (ADR-0020).
- **Ship the named tools only; the consumer derives.** Chosen.

## Decision outcome

The image ships Terraform, the AWS CLI and the CI baseline the `Dockerfile`
installs alongside them. Any other runtime tool is out of scope. Three answers
to a requester, in order:

1. Derive an image: `FROM bgauduch/terraform-aws-cli:<tag>`, then install and
   pin the tool.
2. Split the CI job: run the step needing the extra on an image built for it.
3. Where demand recurs, a dedicated image is a candidate for the monorepo
   (#131). That is a new image, not a change to this one.

### Consequences

- Good: a citable answer, so the purpose stops being renegotiated per issue.
- Cost: requesters do work the image could have done for them, and individually
  reasonable requests keep being declined.
- Follow-ups: none. #131 holds the monorepo option without committing to it.

## More information

Baseline pin maintenance: ADR-0010, `docs/dependencies-upgrades.md`.
