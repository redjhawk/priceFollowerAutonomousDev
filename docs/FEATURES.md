# Features & functionality

Status: `Planned` → `In progress` → `Done` (→ `Deprecated`).

| ID | Feature | Component | Location | Status | Notes |
|----|---------|-----------|----------|--------|-------|
| F-01 | Self-hosted runner image (Debian 12 (bookworm-slim), curl/git/jq/sudo, runner binaries) | runner | `runner/Dockerfile` | Done | |
| F-02 | Dynamic runner registration from env | runner | `runner/entrypoint.sh` | Done | De-registers via `trap EXIT`; needs a still-valid token |
| F-03 | Linear webhook listener (FastAPI) | agent-engine | `agent-engine/main.py` | In progress | Endpoint exists; `Linear-Signature` verification |
| F-04 | Ticket filter: high priority + "In Progress" | agent-engine | `agent-engine/main.py` | Planned | |
| F-05 | Clone repo → LangGraph agent loop → commit & push | agent-engine | `agent-engine/agent/` | Planned | |
| F-06 | k8s Secrets for GitHub token, Anthropic key, Linear secrets | k3s | `k3s/secrets.example.yaml` | Done | Real file `factory.secret.yaml` is git-ignored |
| F-07 | Deployments `ai-agent-engine` and `github-runner` (`imagePullPolicy: Never`) | k3s | `k3s/cluster-manifests.yaml` | Done | |
| F-08 | CI workflow on self-hosted runner (build, test) | CI | `.github/workflows/` | Planned | Cross-build for `linux/arm/v7` |
| F-09 | Deploy to Raspberry Pi 2 over SSH | CI | `.github/workflows/` | Planned | 1 GB RAM: no k3s on the Pi |
| F-10 | Small, atomic commits with Conventional Commit messages | agent-engine | `agent-engine/agent/` | Planned | See ADR-0003 |
