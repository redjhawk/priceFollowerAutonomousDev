# Architecture

## Overview

| # | Layer | Component | Technology | Role |
|---|-------|-----------|------------|------|
| 1 | Trigger / Plan | Tickets | GitHub Issues (label `ai-dev`) | Holds the backlog; labelling an issue starts the AI developer |
| 2 | AI developer | `ai-dev` workflow | `anthropics/claude-code-action` + Claude | Follows pricetracker's AGENTS.md, skills and roles; opens a PR |
| 3 | Compute | Local orchestration | k3s on barcelona | Runs the dev and deploy runner pods |
| 4 | CI/CD | `ci-deploy` workflow | GitHub Actions (self-hosted) | Vet, test, build, deploy on every push to `master` |
| 5 | Target | Final deployment | Raspberry Pi 2 (teruel) | Runs the `pricefollower` systemd service |

```
[ GitHub issue + label ai-dev ] --> [ barcelona runner: ai-dev / Claude ] --> branch + PR
                                                                                 │ you merge
                                                                                 ▼
[ teruel: pricefollower ] <-- deploy-armv6.sh <-- [ barcelona runner: ci-deploy ] <-- push to master
```

## Principles

- **Code storage:** cloud-hosted free GitHub repository.
- **Execution boundary:** all heavy work (Claude's tool runs, builds, deploys) runs on barcelona.
- **Orchestration:** Docker images managed by a single-node k3s cluster.
- **Human gate:** AI changes reach `master` (the default branch) only through a merged PR.

## End-to-end flow

1. You open an issue in pricetracker and add the label `ai-dev`.
2. The `ai-dev` workflow runs on the `barcelona-dev` runner; Claude reads AGENTS.md, the skills and roles,
   asks questions in the issue if needed, and pushes a branch `ai-dev/...` with a PR link.
3. You review and merge the PR.
4. The push to `master` triggers `ci-deploy` on the `barcelona-deploy` runner: `go vet`, `go test`, `npm run build`, then
   `scripts/deploy-armv6.sh $DEPLOY_USER@$DEPLOY_HOST` (cross-compiled Go binary, installed over SSH as a systemd service).

## Trust boundaries & security notes

- pricetracker is public: both workflows refuse fork code; `ai-dev` runs only for `redjhawk`.
- Claude's tools are an allow-list (no arbitrary shell, no push); the action pushes the branch.
- The dev runner (Claude) has no deploy key; the deploy runner has no Claude token (ADR-0011).
- Runner PAT and deploy key live in k8s Secrets; so does the Claude token (ADR-0010). None in git or GitHub secrets.
- The `deploy` user on teruel can only run the installer as root.

## Decisions in effect

| Topic | Decision | ADR |
|-------|----------|-----|
| Trigger & git flow | GitHub Issues + claude-code-action; changes land through PRs (supersedes 0002, 0003) | [0009](decisions/0009-github-issues-claude-action.md) |
| LLM | Claude (Anthropic API) | [0004](decisions/0004-claude-llm.md) |
| Deploy target | Raspberry Pi 2 (ARMv7, 1 GB RAM) | [0005](decisions/0005-raspberry-pi-2-target.md) |
| Base images | Debian (`bookworm-slim`) | [0006](decisions/0006-debian-base-images.md) |
| Storage | `hostPath` under `/srv/factory` on barcelona | [0007](decisions/0007-host-storage.md) |
| Claude token | k8s Secret on barcelona, not a GitHub secret | [0010](decisions/0010-claude-token-on-barcelona.md) |
| Pull requests | Claude opens its own PRs, several per issue when useful, on `ai-dev/...` branches | [0014](decisions/0014-claude-opens-its-own-prs.md) |
| Runners | Separate dev and deploy runners, one Dockerfile with two targets | [0011](decisions/0011-separate-dev-and-deploy-runners.md) |
| Deploy target | `DEPLOY_HOST` in k3s; its IP in the pod's `hostAliases` | [0012](decisions/0012-deploy-target-by-name.md), [0013](decisions/0013-deploy-target-ip-in-hostaliases.md) |
| Runner auth & triggers | PAT-based self-registration; push-only pipeline | [0008](decisions/0008-runner-registration.md) |

## Hosts

| Host | Role |
|------|------|
| barcelona | Factory server (Debian, x86): Docker, k3s, runners `barcelona-dev` and `barcelona-deploy`, `/srv/factory` storage |
| teruel | Raspberry Pi 2 target: `pricefollower` systemd service on port 3001, data in `/var/lib/pricefollower` |
| GitHub | `redjhawk/pricetracker` (public): source code, dev-agent roles in `.agents/roles/`, workflow |
