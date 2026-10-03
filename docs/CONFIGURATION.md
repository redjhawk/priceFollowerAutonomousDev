# Configuration

## Environment variables

| Name | Used by | Required | Source | Description |
|------|---------|----------|--------|-------------|
| `REPO_URL` | runner | yes | Deployment env | GitHub repo URL the runner registers to |
| `RUNNER_TOKEN` | runner | yes | Secret | Runner **registration** token (expires after 1 h; not a PAT) |
| `GITHUB_TOKEN` | agent-engine | yes | Secret | Token used to clone and push |
| `ANTHROPIC_API_KEY` | agent-engine | yes | Secret | Claude API key |
| `ANTHROPIC_MODEL` | agent-engine | no | Deployment env | Claude model id (default `claude-sonnet-5-5`) |
| `LINEAR_API_KEY` | agent-engine | yes | Secret | Read ticket details / post status comments |
| `LINEAR_WEBHOOK_SECRET` | agent-engine | yes | Secret | Linear webhook signing secret |

## Kubernetes Secrets

| Secret | Keys | Consumed by |
|--------|------|-------------|
| `factory-secrets` | `github-token`, `runner-token`, `anthropic-api-key`, `linear-api-key`, `linear-webhook-secret` | ai-agent-engine, github-runner |

Template: `k3s/secrets.example.yaml` → copy to `k3s/factory.secret.yaml` (git-ignored).

## Images

| Image | Built from | Pull policy |
|-------|-----------|-------------|
| `local-gh-runner:latest` | `runner/` (Debian 12 (bookworm-slim), runner `RUNNER_VERSION` build arg, default 2.311.0) | `Never` |
| `ai-agent-engine:latest` | `agent-engine/` (python:3.11-slim, Debian-based) | `Never` |

## Ports / Services

| Service | Port | Exposed how | Purpose |
|---------|------|-------------|---------|
| ai-agent-engine | 8000 (container) | _tbd_ (tunnel needed: Linear must reach it) | Receives Linear webhooks |

## Deploy target (runner → Raspberry Pi 2)

| Name | Used by | Source | Description |
|------|---------|--------|-------------|
| `PI_HOST` | CI workflow | Secret | Pi hostname/IP on the LAN |
| `PI_USER` | CI workflow | Secret | SSH user on the Pi |
| `PI_SSH_KEY` | CI workflow | Secret | Private key for deploy |
