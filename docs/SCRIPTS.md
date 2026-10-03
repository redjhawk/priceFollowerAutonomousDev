# Scripts & entrypoints registry

Every executable file in the repo gets one entry. Keep the table sorted by path.

| Path | Purpose | Run by / where | Inputs (args / env) | Outputs / side effects | Status |
|------|---------|----------------|---------------------|------------------------|--------|
| `agent-engine/main.py` | FastAPI app: `GET /health`, `POST /webhook/ticket` (placeholder) | `uvicorn main:app` :8000 | See CONFIGURATION.md | Logs the event | Skeleton (blocked, see FEATURES F-05) |
| `pipelines/pricetracker/ci-deploy.yml` | GitHub Actions workflow: vet, test, build, deploy to teruel | Runner on barcelona, on push to `main` | — | pricefollower updated on teruel | Done (to be copied into pricetracker) |
| `runner/entrypoint.sh` | Gets a registration token with the PAT, registers, runs, de-registers on exit/SIGTERM; installs SSH files | Runner container `ENTRYPOINT` | `REPO_URL`, `GITHUB_PAT`, `RUNNER_NAME`, `RUNNER_LABELS` | Runner online in GitHub | Done |
| `scripts/build-and-import.sh` | Build an image, `docker save`, `k3s ctr images import` | Operator on barcelona | `runner` or `agent-engine` | Image in k3s containerd (sudo) | Done |
| `scripts/create-secrets.sh` | Creates `factory-secrets` and `factory-ssh` from prompts | Operator on barcelona | teruel IP, runner PAT | Secrets applied | Done |
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
