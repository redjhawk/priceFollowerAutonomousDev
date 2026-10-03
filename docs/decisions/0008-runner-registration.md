# ADR-0008: Runner registers itself with a PAT; push-only pipeline on a public repo

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
Runner registration tokens expire after 1 h, so a pod restart with a stored token fails.
pricetracker is a **public** repository; GitHub warns that self-hosted runners on public repos
can run code from fork pull requests.

## Decision
- Store a fine-grained PAT (pricetracker, *Administration: read/write*) in Secret `factory-secrets`;
  the entrypoint requests fresh registration and removal tokens from the GitHub API on each start.
- The runner is labelled `barcelona`; the workflow (`pipelines/pricetracker/ci-deploy.yml`) runs only
  on `push` to `main` and `workflow_dispatch`, never on `pull_request`, and only in `redjhawk/pricetracker`.

## Consequences
- Pod restarts are self-healing.
- Recommended: make pricetracker private, or set *Settings › Actions › Fork pull request workflows*
  to require approval for all outside contributors.
