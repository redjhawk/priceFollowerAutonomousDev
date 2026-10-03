# Instructions for AI agents working in this repo

This repo documents itself. **Every change must keep the docs in sync — in the same commit.**

- Added/changed/removed a script or entrypoint → update [docs/SCRIPTS.md](docs/SCRIPTS.md).
- Added/changed a feature → update its row in [docs/FEATURES.md](docs/FEATURES.md) (status + location).
- New env var, secret, port or image → [docs/CONFIGURATION.md](docs/CONFIGURATION.md).
- Changed a component's internals → its page in [docs/components/](docs/components/).
- Made a non-obvious technical choice (library, protocol, security trade-off) → new ADR in
  [docs/decisions/](docs/decisions/) using `0000-template.md`, next free number.
- Every user-visible change → one line under `Unreleased` in [CHANGELOG.md](CHANGELOG.md).

Implementation order (from the architecture guide): 1) runner image, 2) agent engine, 3) k3s manifests.
Locally built images use `imagePullPolicy: Never` and are imported with `k3s ctr images import`.
Never commit secrets; manifests reference Secrets whose values come from outside git.

## Commit rules (apply to humans and the agent alike)

Commits go **directly to `main`** (ADR-0003), so each one must be safe and reviewable on its own:
- One logical change per commit; keep diffs small (aim for < ~50 changed lines, split otherwise).
- Conventional Commits subject: `type(scope): imperative summary` (≤ 72 chars),
  types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`.
- Body (optional) explains *why*; reference the Linear ticket id (e.g. `Refs: PRI-123`).
- No unrelated formatting churn, no generated files, no secrets.
- Code + its doc update belong in the same commit.

Deploy target is a **Raspberry Pi 2 (ARMv7 32-bit, 1 GB RAM)**: build images/binaries for `linux/arm/v7`
and keep runtime footprint small.
