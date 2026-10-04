# Component: ai-dev (Claude developer workflow)

- **Status:** Done (to be copied into pricetracker)
- **Source:** `pipelines/pricetracker/ai-dev.yml`

## Responsibility
Turn a GitHub issue in `redjhawk/pricetracker` into a pull request written by Claude, following the
project's own rules: `AGENTS.md`, the four skills in `.agents/skills/` and `project-skills/`, and the
staged role workflow in `doc/workflow/WORKFLOW.md` with `.agents/roles/`.

## How it is triggered
| Event | Condition |
|-------|-----------|
| Issue opened or labelled | Has label `ai-dev` |
| Comment on an issue or PR | Contains `@claude` (answers to Claude's questions, review requests) |

Only `redjhawk` can trigger it (`github.actor` check); the action also refuses users without
write access. The job runs on the dev runner `barcelona-dev`, which has no deploy key.

## What Claude may do
`--allowedTools`: read/edit/write files, search, Task subagents (one per role), `go build|test|vet`,
`gofmt`, `go run`, `npm ci`, `npm run build|dev|test:*`, `npx tsc`, `npx playwright test`,
`curl` to localhost, read-only git. Commits and the branch push are done by
the action itself on a branch `ai-dev/...`; it never pushes to `main`.

## Flow
1. Issue labelled `ai-dev` → Claude posts a progress comment.
2. If a product/API/refactoring decision is needed, Claude asks in the issue and stops; you answer
   with an `@claude` comment and it continues.
3. Claude pushes a branch and posts a link to open the PR.
4. You review and merge → `ci-deploy` deploys to teruel.

## Configuration
- `CLAUDE_CODE_OAUTH_TOKEN` in the runner pod, from k8s Secret `factory-secrets` on barcelona
  (`claude setup-token`; Claude subscription, no API billing; never stored in GitHub, ADR-0010).
- Claude GitHub App installed on pricetracker (provides the GitHub token for comments and pushes).
- Model `claude-opus-5-5` with effort `low`, max 200 turns, 120 min timeout (in the workflow file).

## Known limitations
