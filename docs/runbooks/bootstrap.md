# Runbook: bootstrap

Run on the k3s server from the repo root.

## 1. Secrets
```bash
cp k3s/secrets.example.yaml k3s/factory.secret.yaml   # git-ignored
$EDITOR k3s/factory.secret.yaml
```
Get `runner-token` from GitHub → Settings › Actions › Runners › New self-hosted runner (valid 1 h).

## 2. Build & import images
```bash
scripts/build-and-import.sh runner
scripts/build-and-import.sh agent-engine
```
Manual equivalent:
```bash
docker build -t local-gh-runner:latest runner
docker save local-gh-runner:latest -o local-gh-runner.tar
sudo k3s ctr images import local-gh-runner.tar
```

## 3. Deploy
```bash
scripts/deploy.sh
kubectl get pods -w
```

## 4. Verify
- `kubectl get pods` → both pods `Running`.
- GitHub → **Settings › Actions › Runners**: runner is **Idle**.
- `kubectl port-forward deploy/ai-agent-engine 8000:8000` then `curl localhost:8000/health`.

## 5. Logs
```bash
kubectl logs -l app=ai-agent-engine -f
kubectl logs -l app=github-runner -f
```
