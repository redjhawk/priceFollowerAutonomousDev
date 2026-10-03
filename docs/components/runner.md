# Component: runner

- **Status:** Done
- **Source:** `runner/`

## Responsibility
Containerised GitHub Actions self-hosted runner for `redjhawk/pricetracker`, a k3s Deployment on
barcelona. Runs `pipelines/pricetracker/ci-deploy.yml`: vet, test, build, deploy to teruel.

## Files
| File | Description |
|------|-------------|
| `Dockerfile` | Debian 12 slim; git, ssh, rsync, jq, build-essential; Node 22 (NodeSource); Go `GO_VERSION`; runner `RUNNER_VERSION` (latest by default) + its dependencies; user `runner` uid 1000 |
| `entrypoint.sh` | Copies SSH files from `/etc/factory-ssh`, gets registration token via PAT, `config.sh --replace`, `run.sh`, removal token + `config.sh remove` on exit/SIGTERM |

## Interfaces
- In: `REPO_URL`, `GITHUB_PAT`, `RUNNER_NAME`, `RUNNER_LABELS`; Secret `factory-ssh`.
- Out: runner `barcelona` online; SSH to `teruel` as `deploy`.

## Storage
`/srv/factory/runner/{work,cache,go,npm}` (ADR-0007).

## Known limitations / TODO
- Passwordless sudo inside the image (used only for `installdependencies.sh`); repo is public — see ADR-0008.
- `RUNNER_VERSION=latest` makes builds non-reproducible; pin when stable.
