# priceFollower Autonomous Dev — Autonomous Software Factory

A local software factory for [redjhawk/pricetracker](https://github.com/redjhawk/pricetracker).
You open a GitHub issue with the label `ai-dev`; Claude implements it on the self-hosted runner on
**barcelona**, following the project's skills and roles, and opens a pull request. When you merge it,
the same runner tests, builds and deploys the app to the Raspberry Pi **teruel**.

```
[ issue + label ai-dev ] --> [ barcelona: ai-dev (Claude) ] --> PR --you merge--> main
                                                                                   │
[ teruel: pricefollower ] <------ deploy ------ [ barcelona: ci-deploy ] <---------┘
```

## Documentation map

| Doc | What it tracks |
|-----|----------------|
| [docs/SETUP.md](docs/SETUP.md) | Step-by-step setup of the whole system |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Ideas for later versions (Linear integration, browser QA, …) |
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
pipelines/      GitHub Actions workflows to copy into pricetracker (ai-dev, ci-deploy)
runner/         GitHub Actions self-hosted runner image (Dockerfile, entrypoint.sh)
k3s/            Kubernetes manifests (Secrets, Deployments, Services)
scripts/        Setup and operation scripts (server, Pi, secrets, build, deploy) — register each in docs/SCRIPTS.md
docs/           All project documentation
```

## Quick start

Full step-by-step guide: [docs/SETUP.md](docs/SETUP.md). Short command list: [docs/runbooks/bootstrap.md](docs/runbooks/bootstrap.md).
