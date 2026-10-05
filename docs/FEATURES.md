# Features & functionality

Status: `Planned` → `In progress` → `Done` (→ `Deprecated`).

| ID | Feature | Component | Location | Status | Notes |
|----|---------|-----------|----------|--------|-------|
| F-01 | Self-hosted runner image (Debian 12 (bookworm-slim), curl/git/jq/sudo, runner binaries) | runner | `runner/Dockerfile` | Done | |
| F-02 | Dynamic runner registration from env | runner | `runner/entrypoint.sh` | Done | De-registers on exit/SIGTERM |
| F-06 | k8s Secrets created interactively | k3s | `scripts/create-secrets.sh` | Done | Runner + SSH secrets |
| F-07 | Deployments `runner-dev` and `runner-deploy` (`imagePullPolicy: Never`) | k3s | `k3s/cluster-manifests.yaml` | Done | Separate secrets and storage (ADR-0011) |
| F-08 | CI workflow on self-hosted runner (vet, test, build) | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | Must be copied into pricetracker |
| F-09 | Deploy to teruel over SSH via `deploy-armv6.sh` | CI | `pipelines/pricetracker/ci-deploy.yml` | Done | |
| F-11 | Server install (Docker, k3s, storage) | ops | `scripts/install-barcelona.sh` | Done | |
| F-12 | Pi setup (deploy user, restricted sudo) | ops | `scripts/setup-teruel.sh` | Done | |
| F-13 | Persistent host storage | k3s | `/srv/factory` hostPath | Done (runner) | ADR-0007 |
| F-14 | Runner self-registration via PAT | runner | `runner/entrypoint.sh` | Done | ADR-0008 |
| F-15 | GitHub issue (label `ai-dev`) → Claude implements it following AGENTS.md, skills and roles → PR | ai-dev | `pipelines/pricetracker/ai-dev.yml` | Done | ADR-0009; copy into pricetracker |
| F-18 | Claude opens its own PRs, several per issue for big work | ai-dev | `ai-dev.yml`, dev image (`gh`) | Done | ADR-0014 |
| F-19 | PR size check: fail the ai-dev run if an issue PR exceeds 500 changed lines (generated files excluded) | ai-dev | `ai-dev.yml` | Done | Limit from pricetracker AGENTS.md |
| F-17 | Deploy target set in k3s (`DEPLOY_HOST` + IP in `hostAliases`), no IP in secrets | k3s, CI | `k3s/cluster-manifests.yaml`, `ci-deploy.yml` | Done | ADR-0012, ADR-0013 |
| F-16 | Linear integration | — | — | Planned | See ROADMAP.md |
| F-03, F-04, F-05, F-10 | Linear webhook agent engine | agent-engine | — | Deprecated | Replaced by F-15 (ADR-0009) |
