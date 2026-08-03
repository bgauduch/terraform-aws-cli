# 0018 — One publisher per tag: `latest` follows releases, `edge` follows master

- Status: Accepted
- Date: 2026-08-01
- Deciders: @bgauduch

## Context and problem statement

ADR-0003 defined the tag *vocabulary* but never said **who publishes what**.
Two workflows ended up writing `latest`: the master-push workflow on every
commit touching the image, and the release workflow for each new release. A
commit landing after a release therefore repointed `latest` at an unreleased
build, and nothing detected it — `verify_release` only asserts that a tag
exists, not what it contains.

Two tags ADR-0003 declared, `edge` and `vX.Y`, were never published at all, so
the README, the ADR and the epic's task list each described a different tag
set.

## Decision drivers

- A mutable tag with two writers has no defined content: the last workflow to
  finish wins, silently.
- A tag name is a promise to the user; `latest` is universally read as "the
  latest release", not "the tip of the default branch".
- Reproducibility must stay available: one tag form has to be immutable.
- Every published tag needs an owner that can be named, so publication can be
  verified mechanically rather than remembered.

## Considered options

- **Keep two publishers for `latest`** and add ordering rules between them:
  the race stays, only better documented.
- **`latest` from `master` only**, releases publish version tags: keeps
  today's meaning, but leaves `latest` pointing at unreleased code.
- **`latest` from releases only, `master` publishes `edge`** (chosen): each
  tag gets exactly one publisher, and both names mean what they say.

## Decision outcome

Chosen option: **one publisher per tag**. The published set:

| Tag | Publisher | Trigger | Mutable | Points at |
|---|---|---|---|---|
| `edge` | `push-edge.yml` | push to `master` touching the image | yes | latest supported combination, built from `master` |
| `latest` | `release-please.yml` | release created | yes | the newest release, latest supported combination |
| `vX.Y` | `release-please.yml` | release created | yes | latest patch of that minor line |
| `vX.Y.Z` | `release-please.yml` | release created | no | that release, latest supported combination |
| `vX.Y.Z_tf-A.B.C_aws-D.E.F` | `release-please.yml` | release created | **no** | one fixed combination, never re-pushed |

- **`latest` changes meaning**: it now follows releases, not `master`. This is
  the reversal that makes this ADR supersede ADR-0003 rather than amend it.
  Users who want the tip of `master` have `edge`, which is what that name was
  reserved for.
- **`vX.Y` is activated** as declared in ADR-0003, and joins the tags
  `verify_release` asserts — an unasserted tag is an unpublished tag waiting
  to happen.
- **No `tf-A.B_aws-D.E` alias.** It appeared only in the epic's task list,
  never in a decision. The fully-pinned tag already serves reproducibility;
  every extra mobile alias is one more surface that can drift and one more
  thing to verify for no new capability.
- **Project semver stays the source of the version tags** (ADR-0002
  release-please), unchanged from ADR-0003: image tags are derived from the
  release version, never set by hand.
- The immutability policy is unchanged and is the reason the pinned form
  exists: `vX.Y.Z_tf-A.B.C_aws-D.E.F` is never re-pushed, so rollback is a
  consumer re-pinning an older tag ([`docs/rollback.md`](../rollback.md)).

### Consequences

- Good: `latest` has one writer, so its content is defined at all times. The
  race that could publish an unreleased build as `latest` cannot occur.
- Good: the tag set is stated once, in [`docs/publishing.md`](../publishing.md),
  with a publisher per row; the README states the same set for users and the
  workflows implement it.
- Cost: `latest` moves less often than before. A user tracking `master`
  through it must switch to `edge`, which is stated in the README and in the
  release notes of the first release published under this ADR.
- Cost: two more tags to push per release (`vX.Y`, and `edge` on master
  pushes), which is build cache reuse rather than new builds.
- Follow-ups: a check asserting that each declared tag has exactly one
  publisher belongs to the verification oracle (ADR-0016) and is tracked in
  #152; GHCR as a second registry stays with epic #100.

## More information

Supersedes [ADR-0003](0003-image-versioning-and-tag-strategy.md), whose tag
vocabulary this ADR keeps and whose publication ownership it defines.
Arbitration: #100 (2026-08-01).
