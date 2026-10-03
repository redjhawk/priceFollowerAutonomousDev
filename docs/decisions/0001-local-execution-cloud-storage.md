# ADR-0001: Cloud code storage, local execution on k3s

- **Date:** 2026-10-03
- **Status:** Accepted

## Context
We want an autonomous agent → CI → deploy pipeline without paying for cloud compute.

## Decision
Host code in a free GitHub repo; run the AI agent, the GitHub Actions self-hosted runner and the
deployed app on a private local server, orchestrated by single-node k3s. Images are built locally
and imported into k3s containerd (`imagePullPolicy: Never`), so no registry is needed.

## Consequences
- No cloud compute cost; capacity is bounded by the local server.
- Self-hosted runner executes repo code → repo must be private.
- Each image rebuild requires a `docker save` + `k3s ctr images import` step.
