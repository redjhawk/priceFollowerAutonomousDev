# Runbook: bootstrap

Everything runs on **barcelona** from the repo root unless stated otherwise.

## 1. Install the server (once)
```bash
sudo scripts/install-barcelona.sh
```
Installs Docker, k3s, git/jq/rsync/ssh, creates `/srv/factory`, generates `/srv/factory/ssh/id_ed25519`.

## 2. Prepare teruel (once)
```bash
scripts/setup-teruel.sh <admin-user>@teruel
ssh -i /srv/factory/ssh/id_ed25519 deploy@teruel true   # must succeed without a password
```

## 3. Secrets
Create a fine-grained GitHub PAT for `redjhawk/pricetracker` with *Administration: read and write*.
```bash
scripts/create-secrets.sh
```

## 4. Build, import, deploy
```bash
scripts/build-and-import.sh runner
scripts/deploy.sh
kubectl get pods -w
```

## 5. Install the pipeline in pricetracker
Copy `pipelines/pricetracker/ci-deploy.yml` to `pricetracker/.github/workflows/ci-deploy.yml` and push.
In GitHub: *Settings › Actions › General › Fork pull request workflows* → require approval for all
outside contributors (repo is public, ADR-0008).

## 6. Verify
- GitHub → pricetracker → *Settings › Actions › Runners*: `barcelona` is **Idle**.
- Run the workflow manually (*Actions › ci-deploy › Run workflow*); then on teruel:
  `systemctl status pricefollower` and open `http://teruel:3001`.

## Logs
```bash
kubectl logs -l app=github-runner -f
ssh deploy@teruel journalctl -u pricefollower -f   # may need sudo depending on groups
```
