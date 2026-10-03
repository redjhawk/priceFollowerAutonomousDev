# ADR-0005: Raspberry Pi 2 as the deployment target

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
The final app runs on a Raspberry Pi 2 (ARMv7 32-bit, 900 MHz quad-core, 1 GB RAM).

## Decision
The self-hosted runner (on the x86 server) builds for `linux/arm/v7` (Docker buildx + QEMU or
native cross-compile) and deploys to the Pi over SSH. The Pi does not run k3s; it runs the app as
a systemd service or a single Docker container.

## Consequences
- Dependencies must have ARMv7 (armhf) builds; many modern images are arm64-only.
- Tight memory budget: avoid heavy runtimes and multi-container stacks.
- Needs `PI_HOST`, `PI_USER`, `PI_SSH_KEY` secrets on the runner.
