#!/bin/bash
# Build a local image and import it into k3s containerd.
# Usage: scripts/build-and-import.sh runner
set -e

case "$1" in
  runner)       dir=runner;       image=local-gh-runner:latest ;;
  *) echo "Usage: $0 runner"; exit 1 ;;
esac

tar="$(mktemp --suffix=.tar)"
docker build -t "$image" "$dir"
docker save "$image" -o "$tar"
sudo k3s ctr images import "$tar"
rm -f "$tar"
