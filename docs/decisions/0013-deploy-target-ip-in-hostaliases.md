# ADR-0013: Target device IP set in k3s through hostAliases

- **Date:** 2026-10-04
- **Status:** Accepted — supersedes the name-resolution part of ADR-0012

## Context
ADR-0012 let `runner-deploy` use barcelona's network and resolver to find the device by name. On the
real setup `getent hosts teruel` failed inside the pod: barcelona finds teruel through a mechanism a
container cannot use (typically mDNS/avahi or systemd-resolved's local names), and the LAN DNS does
not know it.

## Decision
- The `runner-deploy` Deployment declares `hostAliases` (`<teruel IP> → teruel`). Kubernetes writes it
  into the container's `/etc/hosts` when the pod is created, so the name resolves with no DNS.
- `DEPLOY_HOST`/`DEPLOY_USER` stay as in ADR-0012; the hostAliases hostname must equal `DEPLOY_HOST`.
- `runner-deploy` goes back to the normal pod network (`hostNetwork` removed).
- The IP lives in the manifest (it is not a secret), not in a Secret or SSH config.
  `scripts/deploy.sh` refuses to apply while the placeholder `TERUEL_IP` is still there.

## Consequences
- Works whatever barcelona uses to resolve names.
- teruel needs a fixed IP (DHCP reservation); when it changes, edit the manifest and run
  `scripts/deploy.sh runner-deploy`.
- The deploy runner is isolated from barcelona's network namespace again.
