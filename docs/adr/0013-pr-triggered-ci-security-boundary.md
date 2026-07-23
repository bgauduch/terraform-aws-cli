# 0013 — PR-triggered CI and its security boundary

- Status: Accepted
- Date: 2026-07-22
- Deciders: @bgauduch

## Context and problem statement

`lint-dockerfile` and `build-test` only triggered on branch pushes, so pull
requests from forks — the normal community contribution path — never ran a
single CI build before review (#46). Adding a PR trigger raises a security
question: GitHub Actions on PR-controlled code has known attack classes
(secret exfiltration, privilege escalation via `pull_request_target`), so the
boundary must be explicit.

## Decision drivers

- Every contribution, including fork PRs, must be build-verified before merge.
- No path from PR-controlled code to repository secrets or write access.
- Full test coverage on PRs (all supported versions, all platforms) —
  maintainer decision; compute abuse is mitigated by approval gates, not by
  reducing coverage.

## Considered options

- **`pull_request` on secret-free workflows.** Fork runs get **no secrets and a
  read-only `GITHUB_TOKEN` by design**; the workflow definition itself may be
  attacker-modified, but there is nothing to exfiltrate. Chosen.
- **`pull_request_target`** — runs PR code with base-repo secrets and a write
  token; the "pwn request" class. *Rejected — banned in this repository.*
- **Keep push-only triggers** — leaves fork PRs unverified. *Rejected.*

## Decision outcome

Chosen option: **`pull_request` triggers on the secret-free CI workflows**
(`lint-dockerfile`, `build-test`), replacing their branch-push triggers (a PR
run tests the merge result, and one run replaces two).

The security boundary, binding for all future workflow changes:

1. **A workflow triggered by `pull_request` MUST NOT use secrets.** The
   publication fix and any future secret-consuming step live only in
   push-to-`master` / release workflows.
2. **`pull_request_target` MUST NOT be used** in this repository.
3. **Publishing workflows keep their push-to-`master` trigger** and are never
   given PR triggers.
4. Workflows declare least-privilege `permissions:` explicitly
   (`contents: read` for CI), and `concurrency` cancels superseded runs.
5. Fork-run approval policy (who may trigger CI) is a GitHub repository
   setting, maintainer-managed in the UI — referenced here, not mirrored.

### Consequences

- Good: every PR — including forks — is lint- and build-verified across the
  full version matrix and all platforms; no secret exposure by construction.
- Cost: a branch pushed without a PR no longer runs build CI (open the PR to
  get CI — the normal flow); full-coverage fork runs cost compute, gated by
  the approval setting.
- Follow-ups: buildx cache hardening and multi-arch scoping belong to the
  CI/CD roadmap work (#103).

## More information

- GitHub: [Securely using pull_request_target](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target),
  [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use).
- Closes #46; part of epic #103.
