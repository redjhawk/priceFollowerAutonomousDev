# Component: runner

- **Status:** Done (image + entrypoint)
- **Source:** `runner/`

## Responsibility
Containerised GitHub Actions self-hosted runner, running as a k3s Deployment on the x86 build server.

## Files
| File | Description |
|------|-------------|
| `Dockerfile` | Debian 12 (bookworm-slim) + curl, git, jq, sudo, build-essential, python3; non-root `runner` user with passwordless sudo; downloads runner `RUNNER_VERSION` (x64) and its dependencies |
| `entrypoint.sh` | Validates env, `config.sh --unattended --replace`, `trap cleanup EXIT` de-registers, then `./run.sh` |

## Interfaces
- In: `REPO_URL`, `RUNNER_TOKEN` (registration token).
- Out: an online runner in the GitHub repo; jobs with `runs-on: self-hosted` execute here.

## Known limitations / TODO
- Registration token expires after 1 h → pod restarts fail later. Consider fetching a fresh token at start via the GitHub API using a PAT/App.
- `config.sh remove` on exit reuses the registration token, which may have expired.
- Runner 2.311.0 is old; GitHub refuses runners that are too outdated — bump `RUNNER_VERSION`.
- Base image is Debian by preference (ADR-0006); the agent image (python:3.11-slim) is Debian too.
- No Docker/buildx inside the container yet: needed to cross-build `linux/arm/v7` for the Pi (ADR-0005).
- Passwordless sudo in a runner that executes repo code: acceptable only with a private repo.
