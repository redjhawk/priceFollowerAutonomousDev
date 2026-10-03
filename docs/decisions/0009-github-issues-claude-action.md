# ADR-0009: GitHub Issues + claude-code-action, changes land through PRs

- **Date:** 2026-10-03
- **Status:** Accepted — supersedes ADR-0002 and ADR-0003

## Context
The planned agent engine (Linear webhook → headless Claude Code → push to `main`) needed a public
webhook endpoint, a custom service, and an unattended agent with write access to `main`. Building it
was stopped by a safety check pending a decision on guardrails.

## Decision
- Tickets are **GitHub Issues** in pricetracker. Label `ai-dev` (or an `@claude` comment) triggers
  `anthropics/claude-code-action` on the self-hosted runner (`pipelines/pricetracker/ai-dev.yml`).
- Claude works on a branch and offers a **pull request**; a human merges it. Commits to `main`
  happen only by merge.
- Only `redjhawk` can trigger it; Claude's tools are an explicit allow-list.
- The custom agent engine (FastAPI/LangGraph) is dropped.
- Linear stays on the roadmap ([ROADMAP.md](../ROADMAP.md)).

## Consequences
- Nothing to host besides the runner; no inbound network exposure.
- A human review gate before deploy, at the cost of one manual merge per ticket.
- Claude can ask questions in the issue, which fits the workflow's approval gates (API contract,
  product decisions).
- The commit rules (small Conventional Commits) still apply to every commit in the PR.
