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

- 2026-10-03 — AI developer: `ai-dev` workflow (GitHub issue → Claude → PR) following pricetracker's
  AGENTS.md, skills and roles (ADR-0009); setup and usage steps in SETUP.md.
- 2026-10-03 — Roadmap keeping the Linear integration for a later version.

### Changed
- 2026-10-04 — `ai-dev` uses the Claude subscription (`CLAUDE_CODE_OAUTH_TOKEN`) instead of an API key.
- 2026-10-04 — Claude token kept on barcelona in `factory-secrets` instead of a GitHub secret (ADR-0010).
- 2026-10-04 — Runner image bundles Playwright Chromium; Claude runs interface QA on barcelona.
- 2026-10-04 — `ai-dev` uses Claude Opus 5.5 with low effort (was Sonnet 5.5).

### Removed
- 2026-10-03 — Agent engine skeleton (FastAPI/LangGraph) and its k3s Deployment; Linear trigger and
  direct commits to `main` superseded by ADR-0009.

### Fixed
- 2026-10-03 — Runner image installs `unzip`, required by claude-code-action.
- 2026-10-03 — `setup-teruel.sh` reads the root-only deploy public key through sudo.

### Changed
- 2026-10-03 — ADR-0005: deploy a cross-compiled Go binary as a systemd service on teruel (no Docker on the Pi).
- 2026-10-03 — Removed `k3s/secrets.example.yaml` in favour of `scripts/create-secrets.sh`.
