#!/bin/bash
# One-time setup of the Raspberry Pi (teruel), run from barcelona with an account that can sudo there.
# Creates a "deploy" user that accepts the factory key and may run only the pricefollower installer as root.
# Usage: scripts/setup-teruel.sh <admin-user>@teruel
set -euo pipefail

ADMIN_TARGET="${1:?Usage: $0 <admin-user>@teruel}"
KEY_FILE=/srv/factory/ssh/id_ed25519.pub
DEPLOY_USER=deploy

# /srv/factory/ssh is root-only, so read the public key through sudo
if ! PUBLIC_KEY="$(sudo cat "$KEY_FILE")"; then
  echo "Error: cannot read $KEY_FILE; run scripts/install-barcelona.sh first." >&2
  exit 1
fi

# Upload the setup script first, then run it with a terminal so sudo can ask for a password
ssh "$ADMIN_TARGET" "cat > /tmp/factory-setup-teruel.sh" <<REMOTE
set -euo pipefail
apt-get update && apt-get install -y rsync
id $DEPLOY_USER >/dev/null 2>&1 || useradd -m -s /bin/bash $DEPLOY_USER
install -d -m 700 -o $DEPLOY_USER -g $DEPLOY_USER /home/$DEPLOY_USER/.ssh
echo '$PUBLIC_KEY' > /home/$DEPLOY_USER/.ssh/authorized_keys
chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh/authorized_keys
chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys
# deploy-armv6.sh runs exactly: sudo bash ./install-pricefollower.sh ./pricefollower
echo '$DEPLOY_USER ALL=(root) NOPASSWD: /usr/bin/bash ./install-pricefollower.sh ./pricefollower, /bin/bash ./install-pricefollower.sh ./pricefollower' > /etc/sudoers.d/pricefollower-deploy
chmod 440 /etc/sudoers.d/pricefollower-deploy
visudo -cf /etc/sudoers.d/pricefollower-deploy
REMOTE
ssh -t "$ADMIN_TARGET" "sudo bash /tmp/factory-setup-teruel.sh; rm -f /tmp/factory-setup-teruel.sh"

echo "Recording teruel's host key for the runner..."
TERUEL_HOST="${ADMIN_TARGET#*@}"
# Keyed by the name you passed: use the same name as DEPLOY_HOST in k3s (ADR-0012)
ssh-keyscan "$TERUEL_HOST" 2>/dev/null | sudo tee /srv/factory/ssh/known_hosts >/dev/null
echo "Done. Test with: ssh -i /srv/factory/ssh/id_ed25519 $DEPLOY_USER@$TERUEL_HOST true"
