# priceFollower Autonomous Dev — Autonomous Software Factory

A local software factory: project-management tickets (Linear) trigger an AI agent
(Python + LangGraph + Claude) running in a local **k3s** cluster. The agent writes code and pushes it to a cloud
GitHub repo. A **self-hosted GitHub Actions runner**, also in k3s, compiles, tests and deploys locally.

```
[ Linear ] --webhook--> [ k3s: AI Agent Engine ] --push--> [ GitHub repo ]
                                                                              │ Actions job
                                                                              ▼
                                                        [ k3s: self-hosted runner ] -> Raspberry Pi 2
```

## Documentation map

| Doc | What it tracks |
|-----|----------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design, data flow, tech stack, trust boundaries |
| [docs/SCRIPTS.md](docs/SCRIPTS.md) | Registry of **every** script/entrypoint: purpose, inputs, outputs |
| [docs/FEATURES.md](docs/FEATURES.md) | Functionality list and implementation status |
| [docs/CONFIGURATION.md](docs/CONFIGURATION.md) | Env vars, secrets, ports, images |
| [docs/components/](docs/components/) | One technical page per component |
| [docs/decisions/](docs/decisions/) | Architecture Decision Records (ADRs) |
| [docs/runbooks/](docs/runbooks/) | Bootstrap, deploy and troubleshooting procedures |
| [CHANGELOG.md](CHANGELOG.md) | Dated record of changes |

## Repository layout

```
agent-engine/   FastAPI webhook listener + LangGraph agent (Dockerfile, main.py, agent/)
runner/         GitHub Actions self-hosted runner image (Dockerfile, entrypoint.sh)
k3s/            Kubernetes manifests (Secrets, Deployments, Services)
scripts/        Helper scripts (build/import images, deploy) — register each in docs/SCRIPTS.md
docs/           All project documentation
```

## Quick start

See [docs/runbooks/bootstrap.md](docs/runbooks/bootstrap.md).
