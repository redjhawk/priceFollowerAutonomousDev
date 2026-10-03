# ADR-0004: Claude as the agent LLM

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
The LangGraph agent needs a model strong at code reasoning and tool use.

## Decision
Use Claude through the Anthropic API (`langchain-anthropic` / `anthropic` SDK). The model id is
configurable via `ANTHROPIC_MODEL`.

## Consequences
- Requires `ANTHROPIC_API_KEY` secret; usage is billed per token.
- The model can be changed without code changes.

## Update 2026-10-04
The `ai-dev` workflow authenticates with a Claude Code OAuth token (`claude setup-token`) instead of
an API key: runs are covered by the Claude Pro/Max subscription and share its usage limits; there is
no per-token API bill.
