# 0004 — Deprecate Terraform versions below 1.0

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

`supported_versions.json` still lists Terraform 0.11–0.15. These are long EOL,
require maintaining matching signature material in `security/`, and expand the
build matrix for versions virtually no one should still run.

## Decision drivers

- Reduce maintenance surface (build matrix, `security/` files).
- Encourage users onto supported, secure Terraform.
- Keep the supported set meaningful.

## Considered options

- Keep all versions from 0.11 (status quo, per the old upgrade doc).
- Drop everything below 1.0.
- Drop everything below the latest two minor lines.

## Decision outcome

Chosen option: **drop all Terraform versions `< 1.0`** from
`supported_versions.json` (and their `security/` artifacts). Recent lines
(1.7.x → 1.11.x) are added in roadmap Phase 3.

### Consequences

- Good: smaller matrix, fewer signature files, clearer support promise.
- Bad: users pinned to pre-1.0 tags must use an older immutable image tag
  (which remain available — they are immutable, ADR-0003).
- Follow-ups: roadmap Phase 1 (cleanup) + Phase 3 (add recent versions);
  `validate-supported-versions` check (Phase 5/6) guards JSON ↔ `security/`.

## More information

Pre-1.0 images already published remain pullable; this only changes which
versions are actively built going forward.
