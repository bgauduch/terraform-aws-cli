# 0005 — Use the MADR format for ADRs

- Status: Accepted
- Date: 2026-06-14
- Deciders: @bgauduch

## Context and problem statement

We are adopting ADRs (this directory) to record decisions. A consistent,
lightweight template is needed so ADRs are quick to write and easy to read —
including by AI agents scaffolding them via a skill.

## Decision drivers

- Low ceremony (low-traffic OSS project).
- Structured enough for machine scaffolding (`propose-adr` skill).
- Widely recognised.

## Considered options

- **MADR** (Markdown Any Decision Records).
- **Nygard**'s original lightweight format.
- A bespoke template.

## Decision outcome

Chosen option: **MADR**, see [`0000-template.md`](0000-template.md). Nygard was
considered but MADR's explicit "decision drivers / considered options /
consequences" sections suit machine scaffolding better, at acceptable extra
ceremony.

### Consequences

- Good: uniform structure; skill-friendly; familiar to contributors.
- Cost: slightly more sections than Nygard.
- Note: this ADR is itself written in the format it adopts; ADR-0001–0004 in the
  same batch follow it.

## More information

https://adr.github.io/madr/
