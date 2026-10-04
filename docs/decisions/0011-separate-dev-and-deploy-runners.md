# ADR-0011: Separate dev and deploy runners, one Dockerfile with two targets

- **Date:** 2026-10-04
- **Status:** Accepted

## Context
A single runner ran both `ai-dev` (Claude writing code) and `ci-deploy` (build, test, deploy to the
Pi). It therefore held every credential at once: Claude could reach the deploy key, and deploy jobs
could read the Claude token. Jobs also queued behind each other.

## Decision
Two runners, each a k3s Deployment with its own storage and only its own secrets:

| Runner | Labels | Workflow | Image | Secrets | Storage |
|--------|--------|----------|-------|---------|---------|
| `barcelona-dev` | `self-hosted, barcelona-dev` | ai-dev | `local-gh-runner-dev` | runner PAT, Claude token | `/srv/factory/runner-dev` |
| `barcelona-deploy` | `self-hosted, barcelona-deploy` | ci-deploy | `local-gh-runner-deploy` | runner PAT, SSH deploy key | `/srv/factory/runner-deploy` |

Images come from **one Dockerfile with two build targets**: `deploy` (Debian, Go, Node, ssh, rsync,
runner) and `dev` (= `deploy` + Playwright Chromium). The toolchains stay identical, so code that
passes on the dev runner builds the same way on the deploy runner, while the deploy image skips
~0.5 GB of browser and its libraries. Two separate Dockerfiles would duplicate the toolchain setup.

## Consequences
- A compromised dev job (Claude, or code it runs) cannot read the deploy key; deploy jobs cannot read
  the Claude token. Secrets are referenced per key, never mounted wholesale.
- `ai-dev` and `ci-deploy` run in parallel.
- `scripts/build-and-import.sh all` builds both targets; the shared layers are built once.
- The old registration `barcelona` must be removed from GitHub by hand.
