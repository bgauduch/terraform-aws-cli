# 0022 — Publication asserts the artefact before any tag moves

- Status: Accepted
- Date: 2026-09-19
- Deciders: @bgauduch

## Context and problem statement

The pull-request gate builds and structure-tests every supported combination
on every published platform (ADR-0020). Publication did neither: `push-edge`
pushed with no assertion at all, and the release publisher's only check was
`validate.sh --published`, which compares digests — where the tags point,
never whether the image runs. A defect appearing between the merge and the
publication (a different build, cache and manifest-assembly path than the
gate's) escaped every gate the repository has: the #161 class, a
non-executable binary behind years of green multi-arch builds. Study and
plan: #183.

## Decision drivers

- A green build is not a working image (ADR-0020's driver, reaching
  publication — the artefact users actually pull).
- The assertions must be the gate's: one rendered config (ADR-0016), so the
  two cannot drift.
- `--published` stays network-only, runnable anywhere with no Docker and no
  credentials; executing an image is a different cost and a different mode.
- A failed publication must alert: the 2026-09-19 `edge` failure was found by
  a session reading CI, not by anything the repository raised.

## Considered options

- Status quo: digest assertions only.
- **Detect after the push**: publish the tags, then pull each architecture
  and assert; a failure is an alert plus a repair while the bad image is
  public.
- **Prevent before the tags move**: push the image **by digest, with no
  tag**, assert each architecture of that exact artefact, and only then move
  the tags onto the asserted manifest.

## Decision outcome

Chosen option: **prevent before the tags move** (maintainer's call on the
#183 plan, 2026-09-19, over the study's detect-first recommendation).

- Both publishers build as before, but push with
  `push-by-digest=true` and no tag. An untagged digest is unreachable by any
  tag a consumer pulls, so nothing bad ever becomes public.
- `validate.sh --assert-image <repo@digest>` pulls the pushed artefact for
  each published architecture (ADR-0019) and runs the pinned
  `container-structure-test` against it, with the config rendered by
  `--render-tests` — the gate's own assertions.
- Only after the assertion do the tags move, via
  `docker buildx imagetools create`, onto the asserted manifest: every pinned
  combination tag, and the release/`vX.Y`/`latest` aliases for the latest
  combination (`edge` for the master publisher). The publication matrix
  itself is unchanged (ADR-0018).
- On failure the workflow is red and an issue is opened: `verify_release`
  already covers the release path (the missing tags fail `--published`), and
  `push-edge` gains its own issue step — a stale `edge` must not stay silent.

### Consequences

- Good: no tag ever points at an image that did not pass the structure tests
  on both architectures; the asserted artefact is byte-identical to the
  shipped one (asserted from the registry by digest, not from a look-alike
  local build).
- Bad / cost: per release, three combinations × two architectures of
  pull-and-assert (`arm64` emulated), and two per `edge` push; a failed
  assertion leaves an untagged digest in the registry (invisible to
  consumers, garbage-collected by the registry's own policy).
- The manifest tagging moves from `buildx`'s internal push path to explicit
  `imagetools create` calls — new code on the publish path, accepted as the
  price of prevention; the #171 repair commands become the normal path.
- Follow-ups: #183 records the rejected detect-first branch should this shape
  ever need revisiting.

## More information

Study, plan and fork decision: #183. Related: ADR-0016 (oracle), ADR-0018
(publication matrix), ADR-0019 (platforms), ADR-0020 (the gate's principle),
#161 (the defect class), #171/#172 (digest assertions).
