# ADR-0003: Agent commits directly to `main`

- **Date:** 2026-10-03
- **Status:** Superseded by ADR-0009

## Context
A PR-based flow adds review latency; for now we want a fast autonomous loop.

## Decision
The agent pushes straight to `main`. To keep history clean and safe, commits must be small,
atomic and use Conventional Commit messages (see CLAUDE.md › Commit rules).

## Consequences
- No human review gate: CI on the self-hosted runner is the only safety net, so tests matter.
- A bad commit is undone with `git revert`, which small commits make easy.
- May be revisited (PR flow) once the factory is stable.
