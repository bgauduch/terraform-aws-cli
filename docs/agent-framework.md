# Agent framework

How the framework fits together and how to **verify an image change locally
before pushing**. Working conventions: [`docs/conventions.md`](conventions.md);
agent entry point and session rules: [`AGENTS.md`](../AGENTS.md).

## Architecture: agnostic core + tool adapter (ADR-0009)

```
AGENTS.md ─────────────► agent entry point + session rules (any agent reads this)
  ├─ docs/conventions.md         the shared working conventions
  ├─ docs/roadmap.md             the plan
  └─ docs/adr/                   the decisions + rationale

CLAUDE.md ─────────────► thin Claude Code adapter — imports AGENTS.md,
  │                       docs/conventions.md and docs/adr/README.md into the
  │                       session context at start (ADR-0009, amended)
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

- **Lint** — `hadolint` on the `Dockerfile` (CI's version), via `scripts/validate.sh` or directly.
- **Base pull + pin gather** — pull the target base, read candidate OS package versions ([`docs/dependencies-upgrades.md`](dependencies-upgrades.md)).
- **Pin install check** — confirm the *exact* pins install on the target base (catches a superseded pin before CI).
- **Assertion values** — read the real tool outputs (`git`/`jq`/`ssh` versions, home-dir mode) the `container-structure-test` assertions must match.

> apt traffic inside a container must go through the proxy over **HTTPS**
> (`--network=host`, `https_proxy`, sources switched to `https://` + the CA
> bundle) — the proxy only tunnels HTTPS/CONNECT; plain HTTP returns 405.

### What a hosted session cannot do

Facts about the environment, not about the code — they change what a session
can promise, and none of them is discoverable from the repository:

- **`--full` cannot complete in a hosted agent session.** The egress proxy
  terminates TLS and the build containers do not trust its CA, so the image
  build inside `--full` fails on certificate verification. `--fast` and
  `--published` are unaffected: the first needs no network, the second is
  network-only and goes through the proxy like any other HTTPS call. A `--full`
  verdict has to come from real hardware.
- **A bot-authored pull request does not run CI on its own.** Its workflow runs
  wait for a maintainer's approval, so a green tick can be absent because
  nobody clicked, not because something failed.
- **A session cannot delete a remote ref**, and does not need to: branches
  merged through the pull-request flow are deleted by the repository setting.
- **Parallel work uses one designated branch per session**; any further branch
  it opens follows [B1](conventions.md#branching), like a human's.

### Stays in CI (authoritative gate)

On a pull request, `build-test` builds and runs `container-structure-test` on
every supported combination on every published platform, `arm64` under emulation
(ADR-0020). The release workflow publishes and has the final say. The local
harness covers lint, base pull, pin install and assertion values (the fast checks
that catch most breakage); it does not reproduce the emulated builds.
