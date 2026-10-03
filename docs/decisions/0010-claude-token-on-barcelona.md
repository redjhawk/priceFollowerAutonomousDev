# ADR-0010: Keep the Claude token on barcelona, not in GitHub

- **Date:** 2026-10-04
- **Status:** Accepted

## Context
The `ai-dev` workflow needs the Claude subscription token (`claude setup-token`). Storing it as a
GitHub secret places a credential tied to the owner's Claude account on GitHub's side.

## Decision
Store it in the k8s Secret `factory-secrets` (key `claude-oauth-token`, created by
`scripts/create-secrets.sh`) and expose it to the runner pod as `CLAUDE_CODE_OAUTH_TOKEN`. The
workflow's first step masks it in logs and hands it to `claude-code-action`. No GitHub secret.

## Consequences
- The token never leaves barcelona; revoking it = new token + `create-secrets.sh` + restart runner.
- Every job on this runner can read it, including `ci-deploy` and the tests it runs. Acceptable
  because only `redjhawk` can trigger `ai-dev` and no workflow runs fork code (ADR-0008); the
  SSH deploy key already has the same exposure.
- If pricetracker gets a second runner, it needs the same Secret.
