# 0024 — The dependency bot declares the ADR gate's exemption

- Status: Accepted
- Date: 2026-09-20
- Deciders: bgauduch

## Context and problem statement

`adr-check` demands an ADR from any pull request touching a structural path,
while [the ADR requirement](README.md) exempts a pure version bump. Every
Renovate pull request is a pure version bump on a structural path (`Dockerfile`
for the base image, `.github/workflows/` for the actions), so the gate fails all
of them and each one needs a hand-applied label to go green. The gate tests the
path; the policy turns on the change.

## Decision drivers

- A bot pull request reaches green with no human gesture.
- A major bump is not a pure version bump: carrying a base image or an action
  across a major is a decision (ADR-0011 records one).
- The bypass stays visible and revocable on the pull request.

## Considered options

- Renovate labels its own pull requests by update type: non-major gets
  `adr-not-needed`, major gets `needs-adr`
- Teach `adr-check` to exempt a diff that changes only version literals
- Label every Renovate pull request by hand

## Decision outcome

Chosen option: **Renovate labels by update type**, because the update type is
the fact the policy turns on, and Renovate is the only party that classifies it
reliably. It reuses the two labels the gate already reads, leaves the gate's
logic untouched, and keeps a major bump gated. Reading the diff would
re-implement in shell a classification the bot already publishes, on a gate
whose path-versus-intent gap is the defect being fixed.

### Consequences

- Good: bot pull requests reach green unattended; a major dependency bump still
  demands an ADR, including off a structural path.
- Cost: on a bot pull request `adr-not-needed` is a bot's declaration rather
  than a reviewer's, carried in the pull request's label history and revocable
  by removing it.
- Good: Renovate's `automerge` rule (ADR-0012, amended) can complete on a bot
  pull request, which a permanently red gate prevented.
- Follow-ups: an update type Renovate does not classify (`replacement`,
  `rollback`) carries no label, so the gate demands an ADR. That is the intended
  default.

## More information

- [Renovate `addLabels`](https://docs.renovatebot.com/configuration-options/#addlabels)
- ADR-0002 (Renovate as the only dependency bot) · ADR-0012 (the human owns the
  merge) · ADR-0014 (what reaches delivery without a study).
