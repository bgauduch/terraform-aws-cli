# Agent framework

How the agent development framework of this repository is put together, and how
to **verify a change locally before pushing it**. This is the architecture note;
the binding rules are in [`docs/agent-conventions.md`](agent-conventions.md) and
the entry point is [`AGENTS.md`](../AGENTS.md).

## Architecture: agnostic core + tool adapter (ADR-0009)

```
AGENTS.md ─────────────► tool-agnostic entry point (any agent reads this)
  ├─ docs/agent-conventions.md   the binding hard rules (SSOT)
  ├─ docs/roadmap.md             the plan (phases, decisions)
  └─ docs/adr/                   the decisions + rationale

CLAUDE.md ─────────────► thin Claude Code adapter → points at AGENTS.md
  └─ .claude/
       ├─ settings.json          SessionStart hook wiring + role→model map + perms
       └─ README.md              adapter map

scripts/agent-session-start.sh ► agnostic bootstrap (reused by the adapter)
```

Another agent (e.g. a different CLI) adds its own thin adapter and reuses the
agnostic core unchanged.

### Roles, not models (ADR-0006)

Work is organised by **role** — `orchestrator` (planning, diff review before
push, ADR drafting), `executor` (scoped implementation), `reviewer` (diff /
security / lint). Docs cite the role; the concrete model per role lives **only**
in `.claude/settings.json` (tier aliases, so a swap is one edit and never drifts
into prose).

### PR autonomy (ADR-0012)

The agent opens PRs and drives their CI to green; the human owns the merge. The
local verify harness below is what makes that safe — a change is checked before
it is pushed, so "green locally" predicts "green in CI".

## The local verify harness

The image is built from a Debian base with **exact-pinned** OS packages
(ADR-0010) on a **digest-pinned** base (ADR-0011). The recurring risk is a base
bump or a superseded pin. The [`scripts/agent-session-start.sh`](../scripts/agent-session-start.sh)
SessionStart hook brings up a Docker daemon **behind the egress proxy** (the
proxy re-terminates TLS; the daemon uses the proxy env for pulls and the CA is
trusted system-wide) so the checks below work with no manual setup.

### What runs locally (fast feedback)

- **Lint** — `hadolint` on the `Dockerfile` (same version as CI), via
  `dev.sh` or directly.
- **Base pull + pin gather** — pull the target base and read the candidate OS
  package versions (the procedure in
  [`docs/dependencies-upgrades.md`](dependencies-upgrades.md)).
- **Pin install check** — confirm the *exact* pins actually install on the
  target base (catches a superseded pin before CI does).
- **Assertion values** — read the real tool outputs (`git --version`,
  `jq --version`, `ssh -V`, home-dir mode) that the
  `container-structure-test` assertions must match.

> Package/apt traffic inside a container must go through the proxy over **HTTPS**
> (`--network=host`, `https_proxy`, and the sources switched to `https://` with
> the CA bundle) — the proxy only tunnels HTTPS/CONNECT, plain HTTP returns 405.
> This is the recipe the session-start bootstrap and the steps above rely on.

### What stays in CI (authoritative gate)

The **full multi-arch image build** (`linux/amd64,arm64,arm/v7,386`) and the
end-to-end `container-structure-test` run on GitHub Actions — that is the
authoritative gate. The local harness deliberately covers lint, base pull, pin
install and assertion values: the fast checks that catch most breakage. It does
**not** reproduce the full multi-arch build locally, so CI remains the final say.

## Resuming a session

A fresh session should read, in order: tracking issue **#106** (live status),
[`AGENTS.md`](../AGENTS.md) (rules), [`docs/roadmap.md`](roadmap.md) (plan) and
[`docs/adr/`](adr/) (decisions). The SessionStart hook prints this pointer.
