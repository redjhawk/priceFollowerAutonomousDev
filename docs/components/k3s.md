# Component: k3s

- **Status:** Done (manifests)
- **Source:** `k3s/`

## Files
| File | Description |
|------|-------------|
| `cluster-manifests.yaml` | Deployments `ai-agent-engine` (port 8000) and `github-runner`, both `imagePullPolicy: Never`, env from `factory-secrets` |
| `secrets.example.yaml` | Template for the `factory-secrets` Secret; real copy `factory.secret.yaml` is git-ignored |

## Known limitations / TODO
- No Service/Ingress for the agent yet: Linear cannot reach it (needs Service + tunnel).
- No resource requests/limits, no liveness probe on `/health`.
- `REPO_URL` is a placeholder in the manifest.
