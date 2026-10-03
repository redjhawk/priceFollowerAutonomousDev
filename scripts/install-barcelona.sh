#!/bin/bash
# One-time setup of the factory server (barcelona, Debian): Docker, k3s, storage, deploy key.
# Usage: sudo scripts/install-barcelona.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: run as root (sudo)." >&2
  exit 1
fi

FACTORY_DIR=/srv/factory
OWNER_UID=1000  # uid of the "runner" user inside the image

echo "Installing base packages and Docker..."
apt-get update
apt-get install -y ca-certificates curl git jq openssh-client rsync docker.io
systemctl enable --now docker

if ! command -v k3s >/dev/null 2>&1; then
  echo "Installing k3s..."
  curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
fi

echo "Creating persistent storage under $FACTORY_DIR..."
for dir in runner/work runner/cache runner/go runner/npm ssh; do
  install -d -m 0750 "$FACTORY_DIR/$dir"
done
chown -R "$OWNER_UID:$OWNER_UID" "$FACTORY_DIR/runner"
chmod 0700 "$FACTORY_DIR/ssh"

if [ ! -f "$FACTORY_DIR/ssh/id_ed25519" ]; then
  echo "Generating the deploy key used by the runner to reach teruel..."
  ssh-keygen -t ed25519 -N "" -C "factory-runner@barcelona" -f "$FACTORY_DIR/ssh/id_ed25519"
fi

echo
echo "Done. Next steps:"
echo "  1. scripts/setup-teruel.sh <user>@teruel   (authorize the deploy key on the Pi)"
echo "  2. scripts/create-secrets.sh"
echo "  3. scripts/build-and-import.sh runner && scripts/deploy.sh"
