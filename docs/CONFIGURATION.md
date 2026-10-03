# Configuration

## Environment variables

| Name | Used by | Required | Source | Description |
|------|---------|----------|--------|-------------|
| `REPO_URL` | runner | yes | Deployment env | `https://github.com/redjhawk/pricetracker` |
| `GITHUB_PAT` | runner | yes | Secret `runner-pat` | Fine-grained PAT (Administration r/w) used to get registration/removal tokens |
| `CLAUDE_CODE_OAUTH_TOKEN` | runner (ai-dev jobs) | for ai-dev | Secret `claude-oauth-token` | Claude subscription token from `claude setup-token` (ADR-0010) |
| `RUNNER_NAME` / `RUNNER_LABELS` | runner | no | Deployment env | Default `barcelona`; workflows target `runs-on: [self-hosted, barcelona]` |

## Kubernetes Secrets

Created by `scripts/create-secrets.sh` (interactive, nothing stored in git).

| Secret | Keys | Consumed by |
|--------|------|-------------|
| `factory-secrets` | `runner-pat`, `claude-oauth-token` (optional) | github-runner |
| `factory-ssh` | `id_ed25519`, `known_hosts`, `config` (maps `teruel` → IP, user `deploy`) | github-runner, mounted at `/etc/factory-ssh` |

## Images

| Image | Built from | Pull policy |
|-------|-----------|-------------|
| `local-gh-runner:latest` | `runner/` (Debian 12, Node 22, Go `GO_VERSION` 1.25.0, Playwright Chromium `PLAYWRIGHT_VERSION` 1.63.0, runner `RUNNER_VERSION`=latest) | `Never` |

## GitHub secrets

None. The Claude token is kept on barcelona (ADR-0010). Model, turn limit and allowed tools are set
in `pipelines/pricetracker/ai-dev.yml`.

## Storage

See [ADR-0007](decisions/0007-host-storage.md): everything persistent is under `/srv/factory` on barcelona.

## Target device (teruel)

| Item | Value |
|------|-------|
| SSH user | `deploy` (key-only; sudo limited to `bash ./install-pricefollower.sh ./pricefollower`) |
| App | `/opt/pricefollower/pricefollower`, systemd `pricefollower`, port 3001 |
| Data | `/var/lib/pricefollower/pricefollower.sqlite` |
