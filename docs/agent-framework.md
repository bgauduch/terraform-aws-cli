# Agent framework

How the framework fits together and how to **verify an image change locally
before pushing**. Rules: [`docs/conventions.md`](conventions.md);
entry point: [`AGENTS.md`](../AGENTS.md).

## Architecture: agnostic core + tool adapter (ADR-0009)

```
AGENTS.md ─────────────► tool-agnostic entry point (any agent reads this)
  ├─ docs/conventions.md   the binding hard rules
  ├─ docs/roadmap.md             the plan
  └─ docs/adr/                   the decisions + rationale

CLAUDE.md ─────────────► thin Claude Code adapter → AGENTS.md
  └─ .claude/{settings.json, README.md}   hook wiring + role→model map + perms

scripts/agent-session-start.sh ► agnostic bootstrap (reused by the adapter)
```

Work is organised by **role** (`orchestrator`/`executor`/`reviewer`, ADR-0006);
the model per role lives only in `.claude/settings.json`. Another agent adds its
own adapter and reuses the core unchanged.

## The local verify harness

Why it matters: the agent opens PRs and drives their CI to green (ADR-0012), so a
change should be checked *before* it is pushed — "green locally" should predict
"green in CI".

The image uses **exact-pinned** OS packages (ADR-0010) on a **digest-pinned** base
(ADR-0011); the recurring risk is a base bump or a superseded pin. The
[`scripts/agent-session-start.sh`](../scripts/agent-session-start.sh) SessionStart
hook brings up a Docker daemon **behind the egress proxy** (proxy env for pulls,
CA trusted system-wide) so the checks below need no manual setup.

### Runs locally (fast feedback)

- **Lint** — `hadolint` on the `Dockerfile` (CI's version), via `dev.sh` or directly.
- **Base pull + pin gather** — pull the target base, read candidate OS package versions ([`docs/dependencies-upgrades.md`](dependencies-upgrades.md)).
- **Pin install check** — confirm the *exact* pins install on the target base (catches a superseded pin before CI).
- **Assertion values** — read the real tool outputs (`git`/`jq`/`ssh` versions, home-dir mode) the `container-structure-test` assertions must match.

> apt traffic inside a container must go through the proxy over **HTTPS**
> (`--network=host`, `https_proxy`, sources switched to `https://` + the CA
> bundle) — the proxy only tunnels HTTPS/CONNECT; plain HTTP returns 405.

### Stays in CI (authoritative gate)

The full multi-arch build (`amd64,arm64,arm/v7,386`) + end-to-end
`container-structure-test` run on GitHub Actions — the final say. The local harness
covers lint, base pull, pin install and assertion values (the fast checks that
catch most breakage); it does not reproduce the multi-arch build.
