# 0025 — The image ships its named tools; runtime extras are the consumer's `FROM`

- Status: Accepted
- Date: 2026-09-20
- Deciders: @bgauduch

## Context and problem statement

Five requests over four years asked for one more thing in the image: the
Terraform AWS provider (#16), python3 (#80, #92, and external PR #88) and
git-lfs (#91). Each is individually small and individually justified, and #80
carries the most community reactions of any issue in this repository. The
answer has so far existed only as a one line bullet in the roadmap's
out-of-scope list, which no external contributor reads, so every ask restarted
the argument from zero and some got no answer at all.

## Decision drivers

- The image's stated purpose is minimalist and lightweight (README), which is a
  promise to every consumer of every tag.
- The set of defensible extras is unbounded: python, git-lfs, providers,
  kubectl, helm, and the next one. There is no principled stopping point once
  the first is admitted.
- Every extra is paid for permanently, in size, attack surface and apt pin
  maintenance (ADR-0010), by every user, including those who never wanted it.
- The consumer's workaround is three lines and leaves them pinning the version
  they need, which the image could never do for all of them.
- Removing a bundled tool is breaking. python3 was bundled once and removed,
  which is what produced #80 and #92.

## Considered options

- **Bundle the requested extras.** Rejected: unbounded, and it breaks the
  minimalist promise for everyone to serve some.
- **Ship variants from this repository** (`-python`, `-lfs`). Rejected here: it
  multiplies the publication matrix (ADR-0018) and the PR gate (ADR-0020) per
  variant, in a repository built around exactly two version axes.
- **Ship the named tools only; the consumer derives.** Chosen.

## Decision outcome

Chosen option: **the image ships Terraform and the AWS CLI plus the minimum
needed to run them in CI, and any other runtime tool is the consumer's own
layer**, because the alternatives either break the product's one promise or
multiply the build matrix this repository is sized for.

Three answers to give a requester, in order:

1. Derive an image: `FROM bgauduch/terraform-aws-cli:<pinned tag>`, install the
   tool, pin it as they see fit.
2. Split the CI job: run the step that needs the extra on an image built for
   it, and keep Terraform on this one.
3. Where demand is real and recurring, a dedicated image is a candidate for the
   container monorepo (#131), which is designed to hold several images sharing
   one build. That is a new image, not a change to this one.

### Consequences

- Good: a citable answer, so the next ask gets a reasoning instead of silence,
  and the minimalist promise stops being renegotiated per issue.
- Bad / cost: requesters do work the image could have done for them, and this
  repository will keep declining requests that are individually reasonable.
- Follow-ups: this is the reasoning behind the disposition of #16, #80, #91 and
  #92, and behind declining PR #88. The monorepo option is recorded in #131;
  nothing here commits to building it.

## More information

- The minimum kept alongside the named tools is the CI baseline in the
  `Dockerfile`: ca-certificates, git, jq and openssh-client.
- Pin maintenance for that baseline: ADR-0010, `docs/dependencies-upgrades.md`.
- Related: ADR-0018 (publication matrix), ADR-0020 (pull-request gate), #131
  (monorepo).
