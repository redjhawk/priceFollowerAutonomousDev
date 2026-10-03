# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/). Dates are ISO (YYYY-MM-DD).

## Unreleased

### Added
- 2026-10-03 — Documentation skeleton: architecture, scripts registry, features, configuration,
  component pages, ADRs and runbooks.
- 2026-10-03 — ADRs 0002–0005: Linear trigger, direct commits to `main`, Claude LLM, Raspberry Pi 2 target.
- 2026-10-03 — Commit rules in CLAUDE.md.
- 2026-10-03 — ADR-0006: Debian base images (runner on `debian:bookworm-slim`).
- 2026-10-03 — Runner image and entrypoint, agent-engine skeleton, k3s manifests, secrets template,
  `scripts/build-and-import.sh` and `scripts/deploy.sh` (from implementation guide, adapted).
- 2026-10-03 — Server/Pi setup scripts, interactive secrets, runner with Node/Go/ssh and PAT
  self-registration, `/srv/factory` host storage, ci-deploy pipeline for pricetracker (ADR-0007, 0008).

- 2026-10-03 — Step-by-step setup guide `docs/SETUP.md`.

### Fixed
- 2026-10-03 — `setup-teruel.sh` reads the root-only deploy public key through sudo.

### Changed
- 2026-10-03 — ADR-0005: deploy a cross-compiled Go binary as a systemd service on teruel (no Docker on the Pi).
- 2026-10-03 — Removed `k3s/secrets.example.yaml` in favour of `scripts/create-secrets.sh`.
