#!/usr/bin/env bash
#
# Agent SessionStart bootstrap (agnostic core; wired by the Claude Code adapter
# in .claude/settings.json). Makes a remote agent session build- and
# verify-ready so a change to the image can be checked locally before it is
# pushed — hadolint, base-image pulls and OS-package pin gathering all need a
# Docker daemon that can reach the network through the egress proxy.
#
# What it does (idempotent, non-interactive):
#   1. Starts the Docker daemon behind the egress proxy, with the proxy CA
#      trusted, if a daemon is not already running.
#   2. Prints a "resume here" pointer to the sources of truth.
#
# The full multi-arch image build stays in CI; locally this unblocks lint,
# base-image pulls, pin installs and the version assertions — the checks that
# catch most breakage before a push. See docs/agent-framework.md.
#
set -euo pipefail

log() { printf '[agent-session-start] %s\n' "$*" >&2; }

# Only meaningful in the remote (Claude Code on the web) sandbox; a local
# workstation already has its own Docker setup.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# 1) Docker daemon, behind the egress proxy, CA trusted.
#    The proxy re-terminates TLS, so the daemon must use the proxy env for pulls;
#    the CA bundle is already in the system trust store in this environment.
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    log "docker daemon already running"
  elif command -v dockerd >/dev/null 2>&1; then
    log "starting dockerd (proxy: ${HTTPS_PROXY:-none})"
    sudo env \
      HTTP_PROXY="${HTTP_PROXY:-}"  HTTPS_PROXY="${HTTPS_PROXY:-}"  NO_PROXY="${NO_PROXY:-}" \
      http_proxy="${HTTP_PROXY:-}"  https_proxy="${HTTPS_PROXY:-}"  no_proxy="${NO_PROXY:-}" \
      dockerd >/tmp/agent-dockerd.log 2>&1 &
    for _ in $(seq 1 20); do docker info >/dev/null 2>&1 && break; sleep 1; done
  fi
  docker info >/dev/null 2>&1 \
    && log "docker ready — local lint/pull/pin-verify available" \
    || log "docker unavailable — see /tmp/agent-dockerd.log (local image checks limited)"
else
  log "docker CLI not found — skipping daemon bootstrap"
fi

# 2) Resume pointer — where the plan and live status live.
cat >&2 <<'PTR'
[agent-session-start] Resume here:
  * tracking issue #106  — live status, open PRs/issues, next actions (status SSOT)
  * AGENTS.md            — rules entry point (-> docs/conventions.md)
  * docs/roadmap.md      — the plan (phases, decisions)
  * docs/adr/            — the decisions and their rationale
  Local image verify recipe (Debian/version bumps): docs/agent-framework.md
PTR

exit 0
