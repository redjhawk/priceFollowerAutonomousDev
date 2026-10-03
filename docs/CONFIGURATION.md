# Configuration

## Environment variables

| Name | Used by | Required | Source | Description |
|------|---------|----------|--------|-------------|
| `REPO_URL` | runner | yes | Deployment env | `https://github.com/redjhawk/pricetracker` |
| `GITHUB_PAT` | runner | yes | Secret `runner-pat` | Fine-grained PAT (Administration r/w) used to get registration/removal tokens |
| `RUNNER_NAME` / `RUNNER_LABELS` | runner | no | Deployment env | Default `barcelona`; workflows target `runs-on: [self-hosted, barcelona]` |
| `GITHUB_TOKEN` | agent-engine | yes | Secret | Token used to clone and push |
| `ANTHROPIC_API_KEY` | agent-engine | yes | Secret | Claude API key |
| `ANTHROPIC_MODEL` | agent-engine | no | Deployment env | Claude model id (default `claude-sonnet-5-5`) |
| `LINEAR_API_KEY` | agent-engine | yes | Secret | Read ticket details / post status comments |
| `LINEAR_WEBHOOK_SECRET` | agent-engine | yes | Secret | Linear webhook signing secret |

## Kubernetes Secrets

Created by `scripts/create-secrets.sh` (interactive, nothing stored in git).

| Secret | Keys | Consumed by |
|--------|------|-------------|
| `factory-secrets` | `runner-pat` (+ agent keys once the agent engine is built) | github-runner |
| `factory-ssh` | `id_ed25519`, `known_hosts`, `config` (maps `teruel` → IP, user `deploy`) | github-runner, mounted at `/etc/factory-ssh` |

## Images

| Image | Built from | Pull policy |
|-------|-----------|-------------|
| `local-gh-runner:latest` | `runner/` (Debian 12, Node 22, Go `GO_VERSION` 1.25.0, runner `RUNNER_VERSION`=latest) | `Never` |
| `ai-agent-engine:latest` | `agent-engine/` (python:3.11-slim) — pending | `Never` |

## Storage

See [ADR-0007](decisions/0007-host-storage.md): everything persistent is under `/srv/factory` on barcelona.

## Target device (teruel)

| Item | Value |
|------|-------|
| SSH user | `deploy` (key-only; sudo limited to `bash ./install-pricefollower.sh ./pricefollower`) |
| App | `/opt/pricefollower/pricefollower`, systemd `pricefollower`, port 3001 |
| Data | `/var/lib/pricefollower/pricefollower.sqlite` |
