# ADR-0005: Raspberry Pi 2 as the deployment target

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
The final app runs on a Raspberry Pi 2 (ARMv7 32-bit, 900 MHz quad-core, 1 GB RAM).

## Decision
The self-hosted runner on barcelona (x86) runs pricetracker's own `scripts/deploy-armv6.sh teruel`:
it cross-compiles one Go binary (`GOARM=6`, frontend embedded, runs on the Pi 2's ARMv7) and installs
it over SSH as the `pricefollower` systemd service. The Pi runs neither Docker nor k3s.

## Consequences
- No ARM container images needed; the runner only needs Go, Node 22, ssh and rsync.
- Data stays on the Pi in `/var/lib/pricefollower` (SQLite) across deploys.
- Unattended deploys need a `deploy` user on teruel with passwordless sudo restricted to the
  installer command (`scripts/setup-teruel.sh`).
