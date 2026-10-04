# Setting up the autonomous factory, step by step

This guide takes you from two blank machines to a working factory: you open a GitHub issue in
`redjhawk/pricetracker`, Claude implements it on **barcelona** and opens a pull request, and once
you merge it the code is tested and deployed to **teruel** automatically.

## Overview

| Machine | What it is | What runs there |
|---------|-----------|-----------------|
| **barcelona** | Factory server, Debian, x86-64 | Docker, k3s, GitHub Actions runner, `/srv/factory` storage |
| **teruel** | Raspberry Pi 2 | The `pricefollower` app as a systemd service on port 3001 |
| **GitHub** | `redjhawk/pricetracker` | Source code, issues, the `ai-dev` and `ci-deploy` workflows |

Flow: issue labelled `ai-dev` → `ai-dev` runs Claude on barcelona → branch + PR → you merge →
`ci-deploy` runs vet, tests and build on barcelona → `scripts/deploy-armv6.sh teruel` copies the
binary to teruel and restarts the service.

## 1. Prerequisites

**barcelona**
- Debian 12 or newer, x86-64, with internet access.
- An account with `sudo`.
- At least 4 GB RAM and 20 GB free disk (images, Go and npm caches).
- Can reach teruel over SSH on the LAN.

**teruel**
- Raspberry Pi OS (or another Debian-based OS) with `systemd`, `sudo` and an SSH server enabled.
- An admin account that can `sudo` (used once, in step 4).
- A fixed IP address (DHCP reservation in your router is enough). You enter it in step 7.

**GitHub and Anthropic**
- Admin access to `redjhawk/pricetracker`.
- A Claude Pro or Max subscription and the `claude` CLI logged in on any machine, used to create
  the token for the `ai-dev` workflow.

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
- creates the persistent storage under `/srv/factory` (per-runner work dirs, Go and npm caches, SSH
  folder), owned by uid 1000, the user inside the containers;
- generates the deploy key `/srv/factory/ssh/id_ed25519`.

Check it:

```bash
kubectl get nodes          # barcelona  Ready
sudo docker info >/dev/null && echo docker ok
ls /srv/factory            # runner-deploy  runner-dev  ssh
```

To run `docker` without `sudo`, add yourself to the docker group and log in again:
`sudo usermod -aG docker $USER`.

## 4. Prepare teruel

```bash
scripts/setup-teruel.sh <admin-user>@teruel
```

You will be asked for your sudo password on barcelona (the deploy key is root-only), then the
admin's SSH and/or sudo password on teruel. The script:
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
- **The GitHub token** from step 5 (input is hidden).
- **Your Claude token** for the AI developer: on a machine where `claude` is logged in, run
  `claude setup-token`, log in in the browser and paste the printed token (input is hidden). Leave it
  empty to set up only deployments for now; re-run the script later to add it.

It creates two Secrets; nothing is written to the repository or to GitHub:
- `factory-secrets` holds the GitHub token and the Claude token;
- `factory-ssh` holds the deploy key and `known_hosts`, and is only given to the deploy runner.

teruel's IP is not a secret: it goes in the k3s manifest in step 7.

Check it: `kubectl get secrets` lists `factory-secrets` and `factory-ssh`.

## 7. Build the runner images and deploy them

There are two runners, each with only what it needs (ADR-0011):

| Runner | Runs | Has |
|--------|------|-----|
| `barcelona-dev` | `ai-dev` (Claude develops and tests) | Go, Node, Chromium, Claude token |
| `barcelona-deploy` | `ci-deploy` (test, build, deploy) | Go, Node, ssh, rsync, deploy key |

First, tell the deploy runner where teruel is. In `k3s/cluster-manifests.yaml`, Deployment
`runner-deploy`, replace the placeholder with teruel's LAN IP (ADR-0013):

```yaml
      hostAliases:
      - ip: "192.168.1.50"     # <- teruel's IP (example)
        hostnames:
        - "teruel"
```

Kubernetes writes this into the runner's `/etc/hosts`, so the name `teruel` works inside it.
`scripts/deploy.sh` refuses to run while the placeholder `TERUEL_IP` is still there.

```bash
scripts/build-and-import.sh all
scripts/deploy.sh
kubectl get pods -w        # wait for runner-dev-... and runner-deploy-... Running, then Ctrl+C
```

The build downloads Node 22, Go, Chromium and the latest GitHub Actions runner, so the first build
takes several minutes.

The device to deploy to is set in the same Deployment: `DEPLOY_HOST` (default `teruel`, must match
the `hostAliases` hostname) and `DEPLOY_USER` (default `deploy`). After changing them, run
`scripts/deploy.sh runner-deploy`.

Check it:

```bash
kubectl logs -l app=runner-dev --tail=20       # "Listening for Jobs"
kubectl logs -l app=runner-deploy --tail=20    # "Listening for Jobs"
kubectl exec deploy/runner-deploy -- getent hosts teruel   # prints teruel's address
```

GitHub → pricetracker → **Settings › Actions › Runners**: `barcelona-dev` and `barcelona-deploy` are
**Idle**.

## 8. Install the workflows in pricetracker

Both workflows live in this repo and must be added to pricetracker:

```bash
git clone https://github.com/redjhawk/pricetracker.git ~/pricetracker
mkdir -p ~/pricetracker/.github/workflows
cp pipelines/pricetracker/ci-deploy.yml pipelines/pricetracker/ai-dev.yml ~/pricetracker/.github/workflows/
cd ~/pricetracker
git add .github/workflows/ci-deploy.yml .github/workflows/ai-dev.yml
git commit -m "ci: add AI developer and deploy-to-teruel workflows"
git push origin main
```

**Protect barcelona** (pricetracker is public): GitHub → pricetracker → **Settings › Actions › General**
→ *Approval for running fork pull request workflows from contributors* → **Require approval for all
external contributors**. Making the repository private is safer still.

## 9. First deployment and verification

The push in step 8 already starts a `ci-deploy` run. You can also start one by hand: GitHub →
pricetracker → **Actions › ci-deploy › Run workflow**.

1. Follow the run in the **Actions** tab; all steps should turn green, ending with
   *Deployment complete: pricefollower is active on deploy@teruel*.
2. Open `http://teruel:3001` in a browser.
3. On teruel, if needed: `systemctl status pricefollower` and `sudo journalctl -u pricefollower -f`.

From now on, every push to `main` of pricetracker is tested and deployed automatically. The app's
data (`/var/lib/pricefollower/pricefollower.sqlite` on teruel) is kept across deployments.

## 10. Enable the AI developer

1. **Install the Claude GitHub App** on pricetracker: open https://github.com/apps/claude →
   *Install* → *Only select repositories* → `pricetracker`. It gives the workflow the GitHub token it
   uses to comment and push branches.
2. **Check your Claude token is on barcelona:** it was entered in step 6 and never goes to GitHub.
   If you skipped it, run `scripts/create-secrets.sh` again, then `scripts/deploy.sh runner-dev`.
   Check: `kubectl exec deploy/runner-dev -- printenv CLAUDE_CODE_OAUTH_TOKEN | wc -c` prints
   more than 1.
3. **Create the label:** pricetracker → **Issues › Labels › New label** → name `ai-dev`.

## 11. Use it: from issue to deployment

1. **Open an issue** in pricetracker describing what you want, as you would for a developer:
   the behaviour, where it shows up, and what "done" looks like. Clear issues avoid question rounds.
2. **Add the label `ai-dev`** (when creating the issue or later). Only your account (`redjhawk`)
   can start the workflow.
3. **Watch progress** in the issue: Claude posts a comment that it updates as it goes. It follows
   pricetracker's `AGENTS.md`: reads the four skills, writes functional and technical specifications,
   implements, reviews, and records everything under `doc/changes/`.
4. **Answer questions:** if Claude needs a product decision or approval of an API change, it asks
   in the issue and stops. Reply with a comment that starts with `@claude` and contains your answer.
5. **Open the PR:** when it is done, Claude's comment contains a link to create the pull request from
   its branch `ai-dev/...`. Review the changes; you can ask for fixes with `@claude` comments in the PR.
6. **Merge** the PR. `ci-deploy` starts on its own and deploys to teruel (step 9).

Notes:
- Claude works on `barcelona-dev`; deployments run in parallel on `barcelona-deploy`.
- Claude runs the QA role's Playwright tests on barcelona against `npm run dev`.
- Runs count against your Claude subscription limits, shared with your own Claude use; the model
  and turn limit are set in `ai-dev.yml`.
- Planning in Linear is on the [roadmap](ROADMAP.md).

## Day-to-day operations

| Task | Command |
|------|---------|
| Runner logs | `kubectl logs -l app=runner-dev -f` / `kubectl logs -l app=runner-deploy -f` |
| See what Claude did | pricetracker → **Actions › ai-dev** → the run's log, or the issue comments |
| Restart a runner | `scripts/deploy.sh runner-dev` or `scripts/deploy.sh runner-deploy` |
| Rebuild the images (e.g. new Go version) | `scripts/build-and-import.sh all && scripts/deploy.sh runner-dev && scripts/deploy.sh runner-deploy` |
| Renew the Claude token | `claude setup-token` → `scripts/create-secrets.sh` → `scripts/deploy.sh runner-dev` |
| Renew the GitHub token | New token (step 5) → `scripts/create-secrets.sh` → restart both runners |
| teruel reinstalled (new host key) | `scripts/setup-teruel.sh <admin>@teruel` → `scripts/create-secrets.sh` → `scripts/deploy.sh runner-deploy` |
| Deploy to another device | Set `DEPLOY_HOST` and `hostAliases` in `k3s/cluster-manifests.yaml` → `scripts/setup-teruel.sh <admin>@<name>` → `scripts/create-secrets.sh` → `scripts/deploy.sh runner-deploy` |
| teruel's IP changed | Update `hostAliases` in `k3s/cluster-manifests.yaml` → `scripts/deploy.sh runner-deploy` |
| Back up the factory | Copy `/srv/factory` (the Secrets can be recreated with step 6) |

When something fails, see [runbooks/troubleshooting.md](runbooks/troubleshooting.md).
