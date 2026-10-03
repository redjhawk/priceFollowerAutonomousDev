#!/bin/bash
# Apply secrets (if present) and manifests, then show pods.
# Usage: scripts/deploy.sh
set -e
cd "$(dirname "$0")/.."

if [ -f k3s/factory.secret.yaml ]; then
  kubectl apply -f k3s/factory.secret.yaml
fi
kubectl apply -f k3s/cluster-manifests.yaml
kubectl get pods
