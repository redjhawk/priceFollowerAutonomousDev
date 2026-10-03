# Runbook: troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Pod `ErrImageNeverPull` | Image not imported into k3s containerd | Re-run `k3s ctr images import` |
| Runner offline in GitHub | Expired `RUNNER_TOKEN` | Generate a new token, update Secret, restart pod |
| Runner pod crash-loops, "token expired"/404 | Registration token older than 1 h or already used | New token → update Secret → `kubectl rollout restart deploy/github-runner` |
| Runner leaves stale "Offline" entries in GitHub | Pod killed before `config.sh remove` ran | Remove manually in Settings › Actions › Runners |
| Agent pod `CrashLoopBackOff`, "Could not import module" | Wrong uvicorn target | CMD must be `main:app`, not `main.py:app` |
