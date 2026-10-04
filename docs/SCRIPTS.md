# Scripts & entrypoints registry

Every executable file in the repo gets one entry. Keep the table sorted by path.

| Path | Purpose | Run by / where | Inputs (args / env) | Outputs / side effects | Status |
|------|---------|----------------|---------------------|------------------------|--------|
| `pipelines/pricetracker/ai-dev.yml` | GitHub Actions workflow: Claude implements an `ai-dev` issue on a branch, then the workflow opens the PR | `barcelona-dev` runner, on issue label / `@claude` comment by redjhawk | `CLAUDE_CODE_OAUTH_TOKEN` from the runner pod | Branch `ai-dev/...`, PR closing the issue, issue comments | Done (to be copied into pricetracker) |
| `pipelines/pricetracker/ci-deploy.yml` | GitHub Actions workflow: vet, test, build, deploy to teruel | `barcelona-deploy` runner, on push to `master` | — | pricefollower updated on teruel | Done (to be copied into pricetracker) |
| `runner/entrypoint.sh` | Gets a registration token with the PAT, registers, runs, de-registers on exit/SIGTERM; installs SSH files | Runner container `ENTRYPOINT` | `REPO_URL`, `GITHUB_PAT`, `RUNNER_NAME`, `RUNNER_LABELS` (+ `DEPLOY_HOST`/`DEPLOY_USER` on deploy) | Runner online in GitHub | Done |
| `scripts/build-and-import.sh` | Build a runner image target, `docker save`, `k3s ctr images import` | Operator on barcelona | `runner-dev`, `runner-deploy` or `all` | Image in k3s containerd (sudo) | Done |
| `scripts/create-secrets.sh` | Creates `factory-secrets` and `factory-ssh` from prompts | Operator on barcelona | runner PAT, Claude token (optional) | Secrets applied | Done |
| `scripts/deploy.sh` | `kubectl apply` manifests, optional rollout restart | Operator on barcelona | `[deployment]` | Resources applied | Done |
| `scripts/install-barcelona.sh` | Installs Docker, k3s, tools; creates `/srv/factory`; generates deploy key | `sudo`, once, on barcelona | — | Server ready | Done |
| `scripts/setup-teruel.sh` | Creates `deploy` user, authorizes key, restricted sudoers, installs rsync; records host key | Operator on barcelona, once | `<admin>@teruel` | teruel ready for unattended deploys | Done |

External scripts used by the pipeline (in pricetracker): `scripts/deploy-armv6.sh`, `build-release.sh`,
`copy-dist.sh`, `install-pricefollower.sh`.

## Entry template

```
### <path>
- **Purpose:**
- **Usage:** `<command>`
- **Inputs:** args / env vars
- **Outputs / side effects:**
- **Dependencies:**
- **Failure modes:**
```
