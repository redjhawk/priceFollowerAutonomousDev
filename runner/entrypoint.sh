#!/bin/bash
set -e

# Check if required environment variables are provided
if [ -z "$REPO_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
  echo "Error: REPO_URL and RUNNER_TOKEN must be provided."
  exit 1
fi

echo "Configuring GitHub Actions Runner for $REPO_URL..."
./config.sh --url "$REPO_URL" --token "$RUNNER_TOKEN" --unattended --replace

cleanup() {
  echo "Removing runner from GitHub..."
  ./config.sh remove --token "$RUNNER_TOKEN"
}

trap cleanup EXIT

echo "Starting GitHub Actions Runner..."
./run.sh
