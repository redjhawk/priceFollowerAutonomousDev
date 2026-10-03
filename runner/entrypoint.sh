#!/bin/bash
# Registers this container as a self-hosted runner, runs it, and de-registers on exit.
# A PAT is used to request short-lived registration/removal tokens, so restarts never
# depend on a token that has already expired.
set -euo pipefail

if [ -z "${REPO_URL:-}" ] || [ -z "${GITHUB_PAT:-}" ]; then
  echo "Error: REPO_URL and GITHUB_PAT must be provided."
  exit 1
fi

REPO_PATH="${REPO_URL#https://github.com/}"
REPO_PATH="${REPO_PATH%.git}"

runner_token() {
  curl -fsSL -X POST \
    -H "Authorization: Bearer $GITHUB_PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$REPO_PATH/actions/runners/$1" | jq -r .token
}

# SSH material for deploying to the Pi comes from a mounted Secret
if [ -d /etc/factory-ssh ]; then
  install -d -m 700 ~/.ssh
  install -m 600 /etc/factory-ssh/* ~/.ssh/
fi

echo "Configuring GitHub Actions Runner for $REPO_URL..."
./config.sh --url "$REPO_URL" --token "$(runner_token registration-token)" \
  --name "${RUNNER_NAME:-barcelona}" --labels "${RUNNER_LABELS:-barcelona}" \
  --work /home/runner/_work --unattended --replace

cleanup() {
  echo "Removing runner from GitHub..."
  ./config.sh remove --token "$(runner_token remove-token)" || true
}
trap cleanup EXIT
trap "exit 143" TERM INT

echo "Starting GitHub Actions Runner..."
./run.sh &
wait $!
