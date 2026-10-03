# ADR-0002: Linear as the ticket trigger

- **Date:** 2026-10-03
- **Status:** Superseded by ADR-0009

## Context
The agent needs a source of work and an event when a ticket should be implemented.

## Decision
Use Linear. A webhook on Issue updates hits `agent-engine`; it acts when a high-priority issue
moves to **In Progress**. Requests are verified with the `Linear-Signature` HMAC.

## Consequences
- The webhook endpoint must be reachable from the internet (tunnel or reverse proxy).
- Requires `LINEAR_WEBHOOK_SECRET` / `LINEAR_API_KEY` secrets.
- GitHub Issues is not supported for now.
