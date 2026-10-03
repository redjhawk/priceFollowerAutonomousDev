#!/bin/bash
# Apply the k3s manifests and show the pods. Secrets come from scripts/create-secrets.sh.
# Usage: scripts/deploy.sh [deployment-to-restart]
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f k3s/cluster-manifests.yaml
if [ -n "${1:-}" ]; then
  kubectl rollout restart "deployment/$1"
fi
kubectl get pods
