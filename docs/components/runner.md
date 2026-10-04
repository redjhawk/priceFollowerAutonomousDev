# Component: runner

- **Status:** Done
- **Source:** `runner/`

## Responsibility
Containerised GitHub Actions self-hosted runners for `redjhawk/pricetracker`, two k3s Deployments on
barcelona (ADR-0011):

| Deployment | Runner name/label | Image | Runs |
|------------|-------------------|-------|------|
| `runner-dev` | `barcelona-dev` | `local-gh-runner-dev` | `ai-dev`: Claude develops and tests |
| `runner-deploy` | `barcelona-deploy` | `local-gh-runner-deploy` | `ci-deploy`: vet, test, build, deploy to the target device |

## Files
| File | Description |
|------|-------------|
| `Dockerfile` | Target `deploy`: Debian 12 slim; git, ssh, rsync, jq, unzip (Bun install for claude-code-action), build-essential; Node 22 (NodeSource); Go `GO_VERSION`; runner `RUNNER_VERSION` (latest by default) + its dependencies; user `runner` uid 1000. Target `dev`: `deploy` + Playwright Chromium in `/ms-playwright` (`PLAYWRIGHT_VERSION`) + GitHub CLI `gh` |
| `entrypoint.sh` | Copies SSH files from `/etc/factory-ssh` if mounted, gets registration token via PAT, `config.sh --replace`, `run.sh`, removal token + `config.sh remove` on exit/SIGTERM |

## Interfaces
- Both: `REPO_URL`, `GITHUB_PAT`, `RUNNER_NAME`, `RUNNER_LABELS`.
- `runner-dev` only: `CLAUDE_CODE_OAUTH_TOKEN`.
- `runner-deploy` only: Secret `factory-ssh` mounted at `/etc/factory-ssh`.

## Storage
`/srv/factory/runner-dev/{work,cache,go,npm}` and `/srv/factory/runner-deploy/{work,cache,go,npm}` (ADR-0007).

## Known limitations / TODO
- Passwordless sudo inside the image (used only for `installdependencies.sh`); repo is public — see ADR-0008.
- `RUNNER_VERSION=latest` makes builds non-reproducible; pin when stable.
