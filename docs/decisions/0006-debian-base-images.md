# ADR-0006: Debian base images

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
The implementation guide used Ubuntu 22.04 for the runner image.

## Decision
Use Debian for all images: `debian:bookworm-slim` for the runner, `python:3.11-slim` (Debian-based)
for the agent engine.

## Consequences
- Smaller images; same `apt` tooling. Slim images need `ca-certificates` installed explicitly.
- The GitHub runner's `installdependencies.sh` supports Debian 12.
