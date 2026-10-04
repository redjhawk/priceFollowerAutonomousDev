# Component: k3s

- **Status:** Done
- **Source:** `k3s/`

## Files
| File | Description |
|------|-------------|
| `cluster-manifests.yaml` | Deployments `runner-dev` and `runner-deploy` (Recreate strategy, fsGroup 1000, hostPath volumes under `/srv/factory/runner-<role>`, `imagePullPolicy: Never`). Only `runner-dev` gets the Claude token; only `runner-deploy` mounts `factory-ssh` (ADR-0011) and maps the device name to its IP via `hostAliases` (ADR-0013) |

Secrets are created by `scripts/create-secrets.sh`, never stored in git.

## Known limitations / TODO
- No resource requests/limits, no liveness probes.
