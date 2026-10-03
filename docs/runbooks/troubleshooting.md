# Runbook: troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Pod `ErrImageNeverPull` | Image not imported into k3s containerd | Re-run `k3s ctr images import` |
| Runner pod crash-loops, 401/403/404 from api.github.com | PAT expired or lacks *Administration* permission | New PAT → `scripts/create-secrets.sh` → `scripts/deploy.sh github-runner` |
| Runner leaves stale "Offline" entries in GitHub | Pod killed before `config.sh remove` ran | Remove manually in Settings › Actions › Runners |
| Agent pod `CrashLoopBackOff`, "Could not import module" | Wrong uvicorn target | CMD must be `main:app`, not `main.py:app` |
| Pod stuck `ContainerCreating`, hostPath error | `/srv/factory/...` missing | Re-run `scripts/install-barcelona.sh` |
| Deploy step: `Host key verification failed` | teruel reinstalled / key changed | Re-run `scripts/setup-teruel.sh`, then `scripts/create-secrets.sh` |
| Deploy step: `sudo: a password is required` | sudoers rule missing or command differs | Check `/etc/sudoers.d/pricefollower-deploy` on teruel |
| Workflow queued forever | Runner offline or label mismatch | `runs-on: [self-hosted, barcelona]`; check runner pod logs |
