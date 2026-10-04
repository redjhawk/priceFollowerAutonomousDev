# ADR-0012: Deploy target set in k3s and resolved by name through the host network

- **Date:** 2026-10-04
- **Status:** Accepted — name resolution via host network superseded by ADR-0013

## Context
The deploy target was hard-coded (`teruel` in `ci-deploy.yml`), and because pods use the cluster DNS
(CoreDNS), which does not know LAN-only names, `create-secrets.sh` asked for the device's IP and wrote
an SSH config mapping `teruel` to it. Changing the IP or the device meant re-creating secrets.

## Decision
- The `runner-deploy` Deployment sets `DEPLOY_HOST` (default `teruel`) and `DEPLOY_USER` (default
  `deploy`). `ci-deploy` runs `deploy-armv6.sh "$DEPLOY_USER@$DEPLOY_HOST"` and first checks the name
  resolves (`getent hosts`) and SSH works.
- `runner-deploy` runs with `hostNetwork: true` and `dnsPolicy: Default`: it uses barcelona's own
  resolver configuration and `/etc/hosts`, so it finds the device exactly as barcelona does. No IP is
  stored anywhere.
- `known_hosts` is keyed by the device name (`setup-teruel.sh` scans the name you give it); the SSH
  config Secret entry is gone.

Alternatives considered: a CoreDNS forward/override for the LAN zone (cluster-wide change, needs the
LAN DNS server address or a hosts entry kept in a ConfigMap) and `hostAliases` (still needs the IP).

## Consequences
- Works if barcelona resolves the name via the LAN DNS (router) or its `/etc/hosts`. Names that only
  resolve through mDNS (`teruel.local`, avahi) are not seen by the pod: add the device to barcelona's
  `/etc/hosts` or the router's DNS in that case.
- `runner-deploy` shares barcelona's network namespace; it opens no ports, and the dev runner (which
  runs Claude) stays on the isolated pod network.
- To deploy to another device: change `DEPLOY_HOST`, run `setup-teruel.sh <admin>@<name>` for it,
  then `create-secrets.sh` and `deploy.sh runner-deploy`.
