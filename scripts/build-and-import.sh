#!/bin/bash
# Build a runner image target and import it into k3s containerd.
# Usage: scripts/build-and-import.sh <runner-dev|runner-deploy|all>
set -euo pipefail
cd "$(dirname "$0")/.."

build() {
  local target="$1" image="local-gh-runner-$1:latest" tar
  tar="$(mktemp --suffix=.tar)"
  docker build --target "$target" -t "$image" runner
  docker save "$image" -o "$tar"
  sudo k3s ctr images import "$tar"
  rm -f "$tar"
}

case "${1:-}" in
  runner-dev)    build dev ;;
  runner-deploy) build deploy ;;
  all)           build deploy && build dev ;;
  *) echo "Usage: $0 <runner-dev|runner-deploy|all>" >&2; exit 1 ;;
esac
