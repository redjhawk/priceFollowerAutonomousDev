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
`gofmt`, `go run`, `npm ci`, `npm run build|dev|test:*`, `npx tsc`, `npx playwright test`, `curl` to
localhost, read-only git, `git add`, `git commit`, creating/switching to `ai-dev/...` branches,
`git push [-u] origin HEAD` (exact), and `gh pr create|list|view` (ADR-0014). It cannot push to `main`.

## Flow
1. Issue labelled `ai-dev` → Claude posts a progress comment.
2. If a product/API/refactoring decision is needed, Claude asks in the issue and stops; you answer
   with an `@claude` comment and it continues.
3. Claude commits on `ai-dev/...` branches and opens the PRs itself, titled `ai-dev #<issue>: …`.
   Big work may be split into several PRs, stacked with `--base` when they depend on each other.
   If Claude committed on the run branch without opening a PR, the workflow's last step opens one.
4. You review and merge (in dependency order for stacked PRs) → `ci-deploy` deploys to teruel.

## Configuration
- `CLAUDE_CODE_OAUTH_TOKEN` in the runner pod, from k8s Secret `factory-secrets` on barcelona
  (`claude setup-token`; Claude subscription, no API billing; never stored in GitHub, ADR-0010).
- Claude GitHub App installed on pricetracker (provides the GitHub token for comments and pushes).
- Model `claude-opus-5-5` with effort `low`, max 200 turns, 120 min timeout (in the workflow file).

## Known limitations
