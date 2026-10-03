# Roadmap

Ideas kept for later versions. When one is picked up, write an ADR and move it to FEATURES.md.

## Linear integration (F-16)

Goal: plan and prioritise in Linear, while the `ai-dev` workflow keeps running from GitHub Issues.

Options, simplest first:

1. **Linear's GitHub Issues sync.** Connect the Linear team to `redjhawk/pricetracker`, so issues
   are mirrored between both tools. Starting work = getting the `ai-dev` label onto the GitHub
   issue (check whether label sync covers this or a manual step is needed).
   No code on our side.
2. **Small bridge workflow.** A Linear webhook (high priority → *In Progress*) calls GitHub's
   `repository_dispatch` through a serverless relay; a workflow creates or labels the GitHub
   issue. Needs a public relay endpoint and a Linear API key.
3. **Report back to Linear.** After `ci-deploy` succeeds, comment on or close the Linear issue
   through the Linear API (`LINEAR_API_KEY` as a GitHub secret).

Previous design for reference: ADR-0002 (superseded by ADR-0009).

## Other ideas

- Browser QA (Playwright + Chromium) in the runner image, so the QA role can run interface tests.
- Health check of `http://teruel:3001` after each deploy, with automatic rollback.
- Notifications (e.g. Telegram) when Claude asks a question or a deploy fails.
- Direct commits to `main` without PR review, once the factory has proven reliable (ADR-0003 idea).
