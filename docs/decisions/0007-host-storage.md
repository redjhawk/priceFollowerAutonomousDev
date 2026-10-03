# ADR-0007: Persistent storage on the host, outside containers

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
Pods are disposable; runner work dirs, build caches, agent workspaces and logs must survive restarts
and image rebuilds.

## Decision
Single-node cluster, so use `hostPath` volumes under `/srv/factory` on barcelona, created by
`scripts/install-barcelona.sh` and owned by uid 1000 (the user inside the images):

| Path | Mounted at | Purpose |
|------|-----------|---------|
| `/srv/factory/runner/work` | `/home/runner/_work` | Checked-out code and job workspaces |
| `/srv/factory/runner/cache` | `/home/runner/.cache` | Go build cache |
| `/srv/factory/runner/go` | `/home/runner/go` | Go module cache |
| `/srv/factory/runner/npm` | `/home/runner/.npm` | npm cache |
| `/srv/factory/agent` | (agent engine, pending) | Workspaces, job records, logs |
| `/srv/factory/ssh` | — (copied into Secret `factory-ssh`) | Deploy key, known_hosts |

## Consequences
- Backups: `/srv/factory` is the only directory to back up (plus the Secrets' sources).
- Not portable to multi-node clusters; would need PVCs then.
