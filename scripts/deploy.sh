#!/bin/bash
# Apply the k3s manifests and show the pods. Secrets come from scripts/create-secrets.sh.
# Usage: scripts/deploy.sh [deployment-to-restart]
set -euo pipefail
cd "$(dirname "$0")/.."

if grep -q '"TERUEL_IP"' k3s/cluster-manifests.yaml; then
  echo "Error: set the target device's IP in k3s/cluster-manifests.yaml (hostAliases of runner-deploy)." >&2
  exit 1
fi
kubectl apply -f k3s/cluster-manifests.yaml
if [ -n "${1:-}" ]; then
  kubectl rollout restart "deployment/$1"
fi
kubectl get pods
