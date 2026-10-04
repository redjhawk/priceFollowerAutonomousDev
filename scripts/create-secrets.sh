#!/bin/bash
# Creates or updates the k3s Secrets from interactive input; nothing is written to the repo.
# Usage: scripts/create-secrets.sh
set -euo pipefail

SSH_DIR=/srv/factory/ssh

read_secret() {
  local value
  read -rsp "$1: " value
  echo >&2
  printf '%s' "$value"
}

RUNNER_PAT="$(read_secret "GitHub PAT for runner registration (pricetracker: Administration read/write)")"
CLAUDE_TOKEN="$(read_secret "Claude token from 'claude setup-token' (empty to skip ai-dev)")"

kubectl create secret generic factory-secrets \
  --from-literal=runner-pat="$RUNNER_PAT" \
  ${CLAUDE_TOKEN:+--from-literal=claude-oauth-token="$CLAUDE_TOKEN"} \
  --dry-run=client -o yaml | kubectl apply -f -

# The deploy runner resolves the device by name (ADR-0012); known_hosts is keyed by that name
sudo kubectl create secret generic factory-ssh \
  --from-file=id_ed25519="$SSH_DIR/id_ed25519" \
  --from-file=known_hosts="$SSH_DIR/known_hosts" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets factory-secrets and factory-ssh applied."
