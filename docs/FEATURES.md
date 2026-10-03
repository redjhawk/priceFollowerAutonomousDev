# Features & functionality

Status: `Planned` → `In progress` → `Done` (→ `Deprecated`).

| ID | Feature | Component | Location | Status | Notes |
|----|---------|-----------|----------|--------|-------|
| F-01 | Self-hosted runner image (Debian 12 (bookworm-slim), curl/git/jq/sudo, runner binaries) | runner | `runner/Dockerfile` | Done | |
| F-02 | Dynamic runner registration from env | runner | `runner/entrypoint.sh` | Done | De-registers on exit/SIGTERM |
| F-06 | k8s Secrets created interactively | k3s | `scripts/create-secrets.sh` | Done | Runner + SSH secrets |
| F-07 | Deployment `github-runner` (`imagePullPolicy: Never`) | k3s | `k3s/cluster-manifests.yaml` | Done | |
| F-08 | CI workflow on self-hosted runner (vet, test, build) | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | Must be copied into pricetracker |
| F-09 | Deploy to teruel over SSH via `deploy-armv6.sh` | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | |
| F-11 | Server install (Docker, k3s, storage) | ops | `scripts/install-barcelona.sh` | Done | |
| F-12 | Pi setup (deploy user, restricted sudo) | ops | `scripts/setup-teruel.sh` | Done | |
| F-13 | Persistent host storage | k3s | `/srv/factory` hostPath | Done (runner) | ADR-0007 |
| F-14 | Runner self-registration via PAT | runner | `runner/entrypoint.sh` | Done | ADR-0008 |
| F-15 | GitHub issue (label `ai-dev`) → Claude implements it following AGENTS.md, skills and roles → PR | ai-dev | `pipelines/pricetracker/ai-dev.yml` | Done | ADR-0009; copy into pricetracker |
| F-16 | Linear integration | — | — | Planned | See ROADMAP.md |
| F-03, F-04, F-05, F-10 | Linear webhook agent engine | agent-engine | — | Deprecated | Replaced by F-15 (ADR-0009) |
