# 0021 — Deterministic scripts own structured writes; agents orchestrate

- Status: Accepted
- Date: 2026-09-19
- Deciders: @bgauduch

## Context and problem statement

Two recurring changes write several files that must move together: a Terraform
or AWS CLI bump writes `supported_versions.json` and the matching GPG material
under `security/` (ADR-0015 also retires a line in the same gesture), and an
apt-pin refresh writes the `Dockerfile` pins and the tool assertions in
`tests/container-structure-tests.yml.template` (ADR-0010). Both have been done
by hand, by humans and by agent sessions, and the drift class has a live cost
record: #168 (a withdrawn `jq` pin left `master` unbuildable) and the
2026-09-19 `push-edge` failure (a superseded `curl` pin), each repaired by a
hand-written fix. The #152 study qualified this as its PR 4: detection can be
a bot's job (#20), but no bot can *materialise* these writes — a bump of
`supported_versions.json` alone fails the oracle on three counts.

## Decision drivers

- A multi-file invariant maintained by hand drifts; both halves of a paired
  write must land together or not at all.
- The same change is performed by humans, agents and (via #20) a bot trigger —
  it needs one implementation, not one procedure per actor (the ADR-0016
  principle applied to writes).
- Signature material must be verified before anything in the repository moves.
- Assertions must be measured, not derived: Debian package versions and
  upstream banners differ (openssh `10.0p1-7` reports `OpenSSH_10.0p2`).

## Considered options

- Status quo: documented manual procedures (`docs/dependencies-upgrades.md`,
  `docs/binaries-verifications.md`), executed by whoever bumps.
- Dependency-bot ownership: let Renovate custom managers write everything.
- **Deterministic scripts own every structured write; humans, agents and bot
  triggers orchestrate them.**

## Decision outcome

Chosen option: **deterministic scripts own every structured write**, because a
script is the only actor that can make a paired write atomic and verified for
all callers at once. A bot can only edit single files it understands
(rejected: the `supported_versions.json`-only bump that fails the oracle), and
prose procedures have the drift record above.

- `scripts/bump-version.sh <terraform|awscli> X.Y.Z` — downloads and
  GPG-verifies the signature material, then writes `supported_versions.json`
  and `security/` as one unit, applying the ADR-0015 window (superseded patch
  dropped, oldest line retired when a new line arrives).
- `scripts/refresh-apt-pins.sh` — probes the pinned base image for the current
  candidates and the actual tool banners, then writes the `Dockerfile` and the
  test template together.
- Scripts verify first and write last; each ends by running
  `scripts/validate.sh --fast`. The oracle stays the verdict (ADR-0016);
  these scripts only produce the change it judges.
- Agents and humans no longer hand-edit these files for a bump or a pin
  refresh; they run the script and review its diff. The manual procedures are
  re-scoped as fallback documentation.

### Consequences

- Good: the #168 / curl-pin drift class is closed at the source; a #20
  detection can be materialised mechanically; one implementation serves every
  caller.
- Bad / cost: two more shell scripts to maintain; Docker and network become
  prerequisites for a pin refresh.
- Follow-ups: #20 (the detection trigger), #152 PR 5 (thin skill wrappers over
  these scripts), the monorepo constraint that `scripts/` stay product-agnostic
  (#131).

## More information

Qualified in #152 (PR 4 of its sequencing; second-gate `go` 2026-09-19).
Related: ADR-0010 (pinning), ADR-0015 (version window), ADR-0016 (oracle),
ADR-0017 (per-architecture AWS CLI material).
