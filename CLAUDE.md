# Instructions for AI agents working in this repo

This repo documents itself. **Every change must keep the docs in sync — in the same commit.**

- Added/changed/removed a script or entrypoint → update [docs/SCRIPTS.md](docs/SCRIPTS.md).
- Added/changed a feature → update its row in [docs/FEATURES.md](docs/FEATURES.md) (status + location).
- New env var, secret, port or image → [docs/CONFIGURATION.md](docs/CONFIGURATION.md).
- Changed a component's internals → its page in [docs/components/](docs/components/).
- Made a non-obvious technical choice (library, protocol, security trade-off) → new ADR in
  [docs/decisions/](docs/decisions/) using `0000-template.md`, next free number.
- Every user-visible change → one line under `Unreleased` in [CHANGELOG.md](CHANGELOG.md).

Locally built images use `imagePullPolicy: Never` and are imported with `k3s ctr images import`.
Never commit secrets; manifests reference Secrets whose values come from outside git.

## Commit rules (apply to humans and the agent alike)

Each commit must be safe and reviewable on its own (in pricetracker, AI changes reach `main` through
PRs, ADR-0009; this repo commits to `main`):
- One logical change per commit; keep diffs small (aim for < ~50 changed lines, split otherwise).
- Conventional Commits subject: `type(scope): imperative summary` (≤ 72 chars),
  types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`.
- Body (optional) explains *why*; reference the issue when there is one (e.g. `Refs: #12`).
- No unrelated formatting churn, no generated files, no secrets.
- Code + its doc update belong in the same commit.

Deploy target is a **Raspberry Pi 2 (ARMv7 32-bit, 1 GB RAM)**: the app is a
cross-compiled Go binary (`deploy-armv6.sh`); keep its runtime footprint small.
