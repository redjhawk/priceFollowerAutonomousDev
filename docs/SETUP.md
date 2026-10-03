# Setting up the autonomous factory, step by step

This guide takes you from two blank machines to a working pipeline: code pushed to
`redjhawk/pricetracker` is tested on **barcelona** and deployed to **teruel** automatically.

> **Current status.** The runner, storage and deploy pipeline are ready. The AI dev agent
> (Linear ticket → code → commit) is not built yet; see [step 10](#10-ai-dev-agent-not-available-yet).

## Overview

| Machine | What it is | What runs there |
|---------|-----------|-----------------|
| **barcelona** | Factory server, Debian, x86-64 | Docker, k3s, GitHub Actions runner, `/srv/factory` storage |
| **teruel** | Raspberry Pi 2 | The `pricefollower` app as a systemd service on port 3001 |
| **GitHub** | `redjhawk/pricetracker` | Source code and the `ci-deploy` workflow |

Flow: push to `main` → GitHub queues `ci-deploy` → the runner pod on barcelona runs vet, tests
and build → `scripts/deploy-armv6.sh teruel` copies the binary to teruel and restarts the service.

## 1. Prerequisites

**barcelona**
- Debian 12 or newer, x86-64, with internet access.
- An account with `sudo`.
- At least 4 GB RAM and 20 GB free disk (images, Go and npm caches).
- Can reach teruel over SSH on the LAN.

**teruel**
- Raspberry Pi OS (or another Debian-based OS) with `systemd`, `sudo` and an SSH server enabled.
- An admin account that can `sudo` (used once, in step 4).
- A fixed IP address (DHCP reservation in your router is enough).

**GitHub**
- Admin access to `redjhawk/pricetracker`.

## 2. Get this repository onto barcelona

```bash
git clone <url-of-this-repo> ~/priceFollowerAutonomousDev
cd ~/priceFollowerAutonomousDev
```

Every command below is run on **barcelona**, from this directory, unless stated otherwise.

## 3. Install the server

```bash
sudo scripts/install-barcelona.sh
```

This script:
- installs `docker.io`, `git`, `jq`, `rsync`, `openssh-client` and `curl`;
- installs k3s, with a kubeconfig readable by your user;
- creates the persistent storage under `/srv/factory` (runner work dir, Go and npm caches, agent
  folder, SSH folder), owned by uid 1000, the user inside the containers;
- generates the deploy key `/srv/factory/ssh/id_ed25519`.

Check it:

```bash
kubectl get nodes          # barcelona  Ready
sudo docker info >/dev/null && echo docker ok
ls /srv/factory            # agent  runner  ssh
```

To run `docker` without `sudo`, add yourself to the docker group and log in again:
`sudo usermod -aG docker $USER`.

## 4. Prepare teruel

```bash
scripts/setup-teruel.sh <admin-user>@teruel
```

You will be asked for the admin's SSH password and/or sudo password on teruel. The script:
- installs `rsync` on teruel;
- creates a `deploy` user that logs in only with the barcelona deploy key;
- allows `deploy` to run exactly one command as root, without a password:
  `bash ./install-pricefollower.sh ./pricefollower` (what `deploy-armv6.sh` runs);
- saves teruel's SSH host key to `/srv/factory/ssh/known_hosts`.

Check it (must not ask for a password):

```bash
sudo ssh -i /srv/factory/ssh/id_ed25519 deploy@teruel true && echo ssh ok
```

## 5. Create the GitHub token for the runner

The runner uses a token to register itself with GitHub every time it starts.

1. GitHub → your avatar → **Settings › Developer settings › Personal access tokens › Fine-grained tokens › Generate new token**.
2. **Repository access:** *Only select repositories* → `redjhawk/pricetracker`.
3. **Permissions › Repository › Administration:** *Read and write*.
4. Pick an expiry date and write it down: the runner stops working when the token expires.
5. Copy the token; you need it in the next step.

## 6. Create the Kubernetes secrets

```bash
scripts/create-secrets.sh
```

It asks for:
- **teruel's IP address.** Pods cannot resolve LAN host names, so the runner's SSH config
  maps the name `teruel` to this IP.
- **The GitHub token** from step 5 (input is hidden).

It creates two Secrets; nothing is written to the repository:
- `factory-secrets` holds the token;
- `factory-ssh` holds the deploy key, `known_hosts` and the SSH config.

Check it: `kubectl get secrets` lists `factory-secrets` and `factory-ssh`.

## 7. Build the runner image and deploy it

```bash
scripts/build-and-import.sh runner
scripts/deploy.sh
kubectl get pods -w        # wait for github-runner-... Running, then Ctrl+C
```

The build downloads Node 22, Go and the latest GitHub Actions runner, so the first build takes a
few minutes. The `ai-agent-engine` deployment is created with 0 replicas, so no pod appears for it.

Check it:

```bash
kubectl logs -l app=github-runner --tail=20     # "Listening for Jobs"
```

GitHub → pricetracker → **Settings › Actions › Runners**: runner `barcelona` is **Idle**.

## 8. Install the pipeline in pricetracker

The workflow lives in this repo and must be added to pricetracker:

```bash
git clone https://github.com/redjhawk/pricetracker.git ~/pricetracker
mkdir -p ~/pricetracker/.github/workflows
cp pipelines/pricetracker/ci-deploy.yml ~/pricetracker/.github/workflows/
cd ~/pricetracker
git add .github/workflows/ci-deploy.yml
git commit -m "ci: add test and deploy-to-teruel workflow"
git push origin main
```

**Protect barcelona** (pricetracker is public): GitHub → pricetracker → **Settings › Actions › General**
→ *Approval for running fork pull request workflows from contributors* → **Require approval for all
external contributors**. Making the repository private is safer still.

## 9. First deployment and verification

The push in step 8 already starts a run. You can also start one by hand: GitHub → pricetracker →
**Actions › ci-deploy › Run workflow**.

1. Follow the run in the **Actions** tab; all steps should turn green, ending with
   *Deployment complete: pricefollower is active on teruel*.
2. Open `http://<teruel-ip>:3001` in a browser.
3. On teruel, if needed: `systemctl status pricefollower` and `sudo journalctl -u pricefollower -f`.

From now on, every push to `main` of pricetracker is tested and deployed automatically. The app's
data (`/var/lib/pricefollower/pricefollower.sqlite` on teruel) is kept across deployments.

## 10. AI dev agent (not available yet)

Planned flow: a high-priority Linear ticket moves to *In Progress* → the agent engine on barcelona
pulls pricetracker, runs the dev-agent roles in `.agents/roles/` → commits → push → step 9 deploys.

It is waiting for a decision on how much freedom the agent gets: what it may run and whether it may
push to `main` unattended. See [components/agent-engine.md](components/agent-engine.md). Once it is
built, this guide will gain these steps:
- creating the Anthropic and Linear API keys;
- exposing the webhook (for example with a Cloudflare tunnel);
- configuring the Linear webhook.

## Day-to-day operations

| Task | Command |
|------|---------|
| Runner logs | `kubectl logs -l app=github-runner -f` |
| Restart the runner | `scripts/deploy.sh github-runner` |
| Rebuild the runner image (e.g. new Go version) | `scripts/build-and-import.sh runner && scripts/deploy.sh github-runner` |
| Renew the GitHub token | New token (step 5) → `scripts/create-secrets.sh` → `scripts/deploy.sh github-runner` |
| teruel IP or OS changed | `scripts/setup-teruel.sh …` → `scripts/create-secrets.sh` → `scripts/deploy.sh github-runner` |
| Back up the factory | Copy `/srv/factory` (the Secrets can be recreated with step 6) |

When something fails, see [runbooks/troubleshooting.md](runbooks/troubleshooting.md).
