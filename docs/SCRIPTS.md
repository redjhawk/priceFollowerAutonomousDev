# Scripts & entrypoints registry

Every executable file in the repo gets one entry. Keep the table sorted by path.

| Path | Purpose | Run by | Inputs (args / env) | Outputs / side effects | Status |
|------|---------|--------|---------------------|------------------------|--------|
| `runner/entrypoint.sh` | Registers the runner (`config.sh --unattended --replace`), runs `./run.sh`, de-registers on exit | Runner container `ENTRYPOINT` | `REPO_URL`, `RUNNER_TOKEN` | Runner online in GitHub repo settings | Done |
| `agent-engine/main.py` | FastAPI app: `GET /health`, `POST /webhook/ticket` (placeholder, agent not wired yet) | `uvicorn main:app` on :8000 | See CONFIGURATION.md | Logs the event | Skeleton |
| `scripts/build-and-import.sh` | Build an image, `docker save`, `k3s ctr images import` | Operator | `runner` or `agent-engine` | Image available in k3s containerd (needs sudo) | Done |
| `scripts/deploy.sh` | Applies `k3s/factory.secret.yaml` (if present) and `k3s/cluster-manifests.yaml`, lists pods | Operator | kubeconfig | Resources applied | Done |

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
