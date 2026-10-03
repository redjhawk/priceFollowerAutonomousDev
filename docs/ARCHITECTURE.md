# Architecture

## Overview

| # | Layer | Component | Technology | Role |
|---|-------|-----------|------------|------|
| 1 | Trigger / Plan | Project management | Linear | Holds backlog; fires webhooks on priority/state changes |
| 2 | Agent engine | Orchestration & LLM | Python 3.11, FastAPI, LangGraph | Reads ticket, reasons, edits code, commits & pushes |
| 3 | Compute | Local orchestration | k3s | Runs agent and runner pods |
| 4 | CI/CD | Gatekeeper & compiler | GitHub Actions (self-hosted) | Builds, tests, triggers local deploy |
| 5 | Target | Final deployment | Raspberry Pi 2 (ARMv7) | Hosts the compiled application |

## Principles

- **Code storage:** cloud-hosted free GitHub repository.
- **Execution boundary:** all heavy work (agent, builds, deploys) runs on the private local server.
- **Orchestration:** Docker images managed by a single-node k3s cluster.

## End-to-end flow

1. A high-priority ticket moves to **In Progress** → PM tool sends a webhook.
2. `agent-engine` (FastAPI) validates the webhook and filters on priority + state.
3. Engine clones the target repo into a workspace and runs the LangGraph agent loop.
4. Agent commits and pushes small, atomic commits directly to `main`.
5. Push triggers a GitHub Actions workflow with `runs-on: self-hosted`.
6. The runner pod in k3s picks up the job, runs `go vet`, `go test`, `npm run build`, then `scripts/deploy-armv6.sh teruel` (cross-compiled Go binary, installed over SSH as a systemd service).

## Trust boundaries & security notes

- Webhook endpoint must verify signatures (Linear `Linear-Signature` HMAC-SHA256).
- Self-hosted runners execute repo code: use on a **private** repo only.
- Tokens (GitHub PAT/App, runner registration, LLM API key) live in k8s Secrets, never in git.
- Agent pushes are the only write path from the agent to GitHub; scope its token minimally.

## Decisions in effect

| Topic | Decision | ADR |
|-------|----------|-----|
| Trigger | Linear webhooks | [0002](decisions/0002-linear-trigger.md) |
| Git flow | Agent commits directly to `main`, small atomic commits | [0003](decisions/0003-direct-commits-to-main.md) |
| LLM | Claude (Anthropic API) | [0004](decisions/0004-claude-llm.md) |
| Deploy target | Raspberry Pi 2 (ARMv7, 1 GB RAM) | [0005](decisions/0005-raspberry-pi-2-target.md) |
| Base images | Debian (`bookworm-slim`) | [0006](decisions/0006-debian-base-images.md) |
| Storage | `hostPath` under `/srv/factory` on barcelona | [0007](decisions/0007-host-storage.md) |
| Runner auth & triggers | PAT-based self-registration; push-only pipeline | [0008](decisions/0008-runner-registration.md) |

## Hosts

| Host | Role |
|------|------|
| barcelona | Factory server (Debian, x86): Docker, k3s, runner, agent engine, `/srv/factory` storage |
| teruel | Raspberry Pi 2 target: `pricefollower` systemd service on port 3001, data in `/var/lib/pricefollower` |
| GitHub | `redjhawk/pricetracker` (public): source code, dev-agent roles in `.agents/roles/`, workflow |
