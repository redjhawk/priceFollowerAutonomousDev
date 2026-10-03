# Component: k3s

- **Status:** Runner done; agent engine pending
- **Source:** `k3s/`

## Files
| File | Description |
|------|-------------|
| `cluster-manifests.yaml` | Deployment `ai-agent-engine` (skeleton) and `github-runner` (Recreate strategy, fsGroup 1000, hostPath volumes, SSH Secret), both `imagePullPolicy: Never` |

Secrets are created by `scripts/create-secrets.sh`, never stored in git.

## Known limitations / TODO
- No Service/tunnel for the agent webhook yet.
- No resource requests/limits, no liveness probes.
