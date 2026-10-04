# Configuration

## Environment variables

| Name | Used by | Required | Source | Description |
|------|---------|----------|--------|-------------|
| `REPO_URL` | runner | yes | Deployment env | `https://github.com/redjhawk/pricetracker` |
| `GITHUB_PAT` | runner | yes | Secret `runner-pat` | Fine-grained PAT (Administration r/w) used to get registration/removal tokens |
| `CLAUDE_CODE_OAUTH_TOKEN` | runner-dev only | for ai-dev | Secret `claude-oauth-token` | Claude subscription token from `claude setup-token` (ADR-0010) |
| `DEPLOY_HOST` | runner-deploy | yes | Deployment env | Target device name (default `teruel`); must match the `hostAliases` hostname (ADR-0012, ADR-0013) |
| `DEPLOY_USER` | runner-deploy | yes | Deployment env | SSH user on the target (default `deploy`) |
| `RUNNER_NAME` / `RUNNER_LABELS` | runner | yes | Deployment env | `barcelona-dev` / `barcelona-deploy`; workflows target `runs-on: [self-hosted, <label>]` |

## Kubernetes Secrets

Created by `scripts/create-secrets.sh` (interactive, nothing stored in git).

| Secret | Keys | Consumed by |
|--------|------|-------------|
| `factory-secrets` | `runner-pat` (both runners), `claude-oauth-token` (optional, runner-dev only) | referenced per key |
| `factory-ssh` | `id_ed25519`, `known_hosts` (keyed by device name) | runner-deploy only, mounted at `/etc/factory-ssh` |

## Images

| Image | Built from | Pull policy |
|-------|-----------|-------------|
| `local-gh-runner-deploy:latest` | `runner/`, target `deploy` (Debian 12, Node 22, Go `GO_VERSION` 1.25.0, runner `RUNNER_VERSION`=latest) | `Never` |
| `local-gh-runner-dev:latest` | `runner/`, target `dev` (= deploy + Playwright Chromium `PLAYWRIGHT_VERSION` 1.63.0 + GitHub CLI) | `Never` |

## GitHub secrets

None. The Claude token is kept on barcelona (ADR-0010). Model, turn limit and allowed tools are set
in `pipelines/pricetracker/ai-dev.yml`.

## Storage

See [ADR-0007](decisions/0007-host-storage.md): everything persistent is under `/srv/factory` on barcelona.

## Target device (teruel)

| Item | Value |
|------|-------|
| Address | LAN IP in `hostAliases` of `runner-deploy` (`k3s/cluster-manifests.yaml`), mapped to `DEPLOY_HOST` |
| SSH user | `deploy` (key-only; sudo limited to `bash ./install-pricefollower.sh ./pricefollower`) |
| App | `/opt/pricefollower/pricefollower`, systemd `pricefollower`, port 3001 |
| Data | `/var/lib/pricefollower/pricefollower.sqlite` |
