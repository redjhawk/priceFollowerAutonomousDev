# Runbook: troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Pod `ErrImageNeverPull` | Image not imported into k3s containerd | Re-run `k3s ctr images import` |
| Runner pod crash-loops, 401/403/404 from api.github.com | PAT expired or lacks *Administration* permission | New PAT → `scripts/create-secrets.sh` → `scripts/deploy.sh runner-dev` and `runner-deploy` |
| Runner leaves stale "Offline" entries in GitHub | Pod killed before `config.sh remove` ran | Remove manually in Settings › Actions › Runners |
| Agent pod `CrashLoopBackOff`, "Could not import module" | Wrong uvicorn target | CMD must be `main:app`, not `main.py:app` |
| Pod stuck `ContainerCreating`, hostPath error | `/srv/factory/...` missing | Re-run `scripts/install-barcelona.sh` |
| Deploy step: `Host key verification failed` | teruel reinstalled / key changed | Re-run `scripts/setup-teruel.sh`, then `scripts/create-secrets.sh` |
| Deploy step: `sudo: a password is required` | sudoers rule missing or command differs | Check `/etc/sudoers.d/pricefollower-deploy` on teruel |
| Workflow queued forever | Runner offline or label mismatch | `ai-dev` needs `barcelona-dev`, `ci-deploy` needs `barcelona-deploy`; check `kubectl logs -l app=runner-<role>` |
| ai-dev does not start after labelling | Label added by another account, label name differs, or workflow not on `main` | Only `redjhawk` triggers it; label must be exactly `ai-dev` |
| ai-dev fails at "Install Bun" | Old runner image without `unzip` | `scripts/build-and-import.sh runner-dev && scripts/deploy.sh runner-dev` |
| ai-dev fails with an authentication error | Claude GitHub App not installed or Claude token revoked | SETUP.md step 10 |
| ai-dev fails at "Load Claude token from barcelona" | Token not in `factory-secrets` | `claude setup-token` → `scripts/create-secrets.sh` → `scripts/deploy.sh runner-dev` |
| ai-dev stops with a usage-limit message | Claude subscription limit reached | Wait for the limit to reset, then comment `@claude continue` |
| Claude says a command is not allowed | Not in `--allowedTools` of `ai-dev.yml` | Add it to the allow-list in this repo, copy the workflow to pricetracker again |
| ci-deploy: "Cannot resolve teruel from barcelona" | Name not in LAN DNS or barcelona's `/etc/hosts` (mDNS-only names are not seen) | Add it to the router's DNS or `/etc/hosts`; check `kubectl exec deploy/runner-deploy -- getent hosts teruel` |
| ci-deploy fails with "DEPLOY_HOST is not set" | Old runner-deploy pod or manifest | `scripts/deploy.sh runner-deploy` |
| Old runner `barcelona` shown Offline in GitHub | Registration from before the split | Remove it in *Settings › Actions › Runners* |
