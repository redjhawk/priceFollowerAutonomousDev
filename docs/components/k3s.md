# Component: k3s

- **Status:** Done
- **Source:** `k3s/`

## Files
| File | Description |
|------|-------------|
| `cluster-manifests.yaml` | Deployment `github-runner` (Recreate strategy, fsGroup 1000, hostPath volumes under `/srv/factory/runner`, SSH Secret), `imagePullPolicy: Never` |

Secrets are created by `scripts/create-secrets.sh`, never stored in git.

## Known limitations / TODO
- No resource requests/limits, no liveness probe.
- One runner replica: ai-dev and ci-deploy jobs run one at a time.
