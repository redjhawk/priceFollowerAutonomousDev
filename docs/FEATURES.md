# Features & functionality

Status: `Planned` → `In progress` → `Done` (→ `Deprecated`).

| ID | Feature | Component | Location | Status | Notes |
|----|---------|-----------|----------|--------|-------|
| F-01 | Self-hosted runner image (Debian 12 (bookworm-slim), curl/git/jq/sudo, runner binaries) | runner | `runner/Dockerfile` | Done | |
| F-02 | Dynamic runner registration from env | runner | `runner/entrypoint.sh` | Done | De-registers via `trap EXIT`; needs a still-valid token |
| F-03 | Linear webhook listener (FastAPI) | agent-engine | `agent-engine/main.py` | In progress | Endpoint exists; `Linear-Signature` verification |
| F-04 | Ticket filter: high priority + "In Progress" | agent-engine | `agent-engine/main.py` | Planned | |
| F-05 | Pull repo, read Linear ticket, run dev-agent roles (`.agents/roles/`), commit & push | agent-engine | `agent-engine/` | Blocked | Needs a decision on how much autonomy the agent gets — see agent-engine component page |
| F-06 | k8s Secrets created interactively | k3s | `scripts/create-secrets.sh` | Done | Runner + SSH secrets; agent keys pending |
| F-07 | Deployments `ai-agent-engine` and `github-runner` (`imagePullPolicy: Never`) | k3s | `k3s/cluster-manifests.yaml` | Done | |
| F-08 | CI workflow on self-hosted runner (vet, test, build) | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | Must be copied into pricetracker |
| F-09 | Deploy to teruel over SSH via `deploy-armv6.sh` | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | |
| F-11 | Server install (Docker, k3s, storage) | ops | `scripts/install-barcelona.sh` | Done | |
| F-12 | Pi setup (deploy user, restricted sudo) | ops | `scripts/setup-teruel.sh` | Done | |
| F-13 | Persistent host storage | k3s | `/srv/factory` hostPath | Done (runner) | ADR-0007 |
| F-14 | Runner self-registration via PAT | runner | `runner/entrypoint.sh` | Done | ADR-0008 |
| F-10 | Small, atomic commits with Conventional Commit messages | agent-engine | `agent-engine/agent/` | Planned | See ADR-0003 |
