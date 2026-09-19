# CLAUDE.md

Fallback shim (ADR-0009, amended 2026-09-19). Claude Code reads `AGENTS.md`
natively from v2.1.277 — but only when no `CLAUDE.md` exists, and older or
managed clients (Bedrock/Vertex) read only this file. Everything lives in
`AGENTS.md`, whose own imports load the binding docs; this file must stay a
single import so both loading paths carry identical context. Delete it once
every client in use reads `AGENTS.md` natively.

@AGENTS.md
