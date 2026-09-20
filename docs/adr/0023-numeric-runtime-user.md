# 0023 — Declare the runtime user by numeric UID and GID

- Status: Accepted
- Date: 2026-09-20
- Deciders: bgauduch

## Context and problem statement

The final stage creates `nonroot` (uid/gid 1001) and declared `USER nonroot`.
A name in `USER` resolves only from the image's own `/etc/passwd`, which an
orchestrator does not read before starting the container: Kubernetes cannot
satisfy a `runAsNonRoot` security context against a named user and refuses the
pod. hadolint states the same finding as `DL3066`.

## Decision drivers

- The image starts under a `runAsNonRoot` security context without the consumer
  supplying `runAsUser`.
- The account, its home (where the AWS CLI writes credentials) and `/workspace`
  ownership do not change.

## Considered options

- Declare `USER 1001:1001`, leaving the `nonroot` account unchanged
- Ignore `DL3066` in `hadolint.yaml`
- Raise the lint `failure-threshold` above `info`

## Decision outcome

Chosen option: **declare `USER 1001:1001`**, because it addresses the finding's
subject rather than suppressing it, and is behaviour-identical inside the
container: the uid resolves to `nonroot`, `HOME` stays `/home/nonroot`, and
`/workspace` ownership is unchanged. Both suppression options keep an image
that a `runAsNonRoot` pod spec cannot start, and the second one blinds the gate
to every future info-level rule.

### Consequences

- Good: the image starts under `runAsNonRoot` with no consumer-side
  `runAsUser`; the structure tests assert the declared user, so a regression
  fails the gate.
- Cost: a consumer reading the image config gets `1001:1001` where it read
  `nonroot`.
- Follow-ups: none.

## More information

- [DL3066](https://github.com/hadolint/hadolint/wiki/DL3066)
- [Kubernetes security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- ADR-0011 (Debian 13 base) — the `nonroot` account and its home mode.
