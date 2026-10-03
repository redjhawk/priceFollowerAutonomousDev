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

TERUEL_ADDRESS="$(read -rp "teruel IP address (as seen from barcelona): " a; echo "$a")"
RUNNER_PAT="$(read_secret "GitHub PAT for runner registration (pricetracker: Administration read/write)")"

kubectl create secret generic factory-secrets \
  --from-literal=runner-pat="$RUNNER_PAT" \
  --dry-run=client -o yaml | kubectl apply -f -

# Pods do not resolve LAN hostnames, so the SSH config maps "teruel" to its address
SSH_CONFIG="$(printf 'Host teruel\n  HostName %s\n  HostKeyAlias teruel\n  User deploy\n  IdentityFile ~/.ssh/id_ed25519\n' "$TERUEL_ADDRESS")"
sudo kubectl create secret generic factory-ssh \
  --from-file=id_ed25519="$SSH_DIR/id_ed25519" \
  --from-file=known_hosts="$SSH_DIR/known_hosts" \
  --from-literal=config="$SSH_CONFIG" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets factory-secrets and factory-ssh applied."
