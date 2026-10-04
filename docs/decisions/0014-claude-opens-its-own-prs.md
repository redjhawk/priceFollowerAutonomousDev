# ADR-0014: Claude opens its own pull requests, possibly several per issue

- **Date:** 2026-10-04
- **Status:** Accepted

## Context
Big refactorings and large features are easier to review as several PRs (possibly stacked), but the
`ai-dev` allow-list only let Claude commit and push its single run branch, and the workflow opened
one PR at the end.

## Decision
- The dev image ships the GitHub CLI; the action step exports `GH_TOKEN` (the job's `GITHUB_TOKEN`).
- Claude may create and switch only to branches named `ai-dev/...`
  (`git checkout -b ai-dev/…`, `git switch [-c] ai-dev/…`), push only its current branch
  (`git push [-u] origin HEAD`, exact match), and run `gh pr create|list|view`.
- PR convention: title `ai-dev #<issue>: <part>`, body `Part of #<issue>` or `Closes #<issue>` on the
  last one; dependent PRs use `--base <previous branch>`.
- The workflow's "Open pull request" step stays as a safety net for a run branch left without a PR.

## Consequences
- Several PRs per issue are possible; reviewing and merging them stays a human task.
- Claude still cannot push to `main` or to branches outside `ai-dev/`: it can neither switch to them
  nor use a refspec (`git push` is allowed only in its exact `origin HEAD` form).
- PRs created with `GITHUB_TOKEN` do not trigger other workflows; this is fine because `ci-deploy`
  runs on pushes to `main` only.
- Requires *Settings › Actions › General › Allow GitHub Actions to create and approve pull requests*.
