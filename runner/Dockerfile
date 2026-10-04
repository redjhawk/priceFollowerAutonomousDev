# Two targets from one file (ADR-0011):
#   deploy: build/test/deploy toolchain, used by ci-deploy  -> local-gh-runner-deploy
#   dev:    deploy + Playwright Chromium, used by ai-dev    -> local-gh-runner-dev
FROM debian:bookworm-slim AS deploy

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Build and deploy toolchain for pricetracker: git, ssh, rsync, Node 22, Go
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    openssh-client \
    rsync \
    unzip \
    sudo \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

ARG GO_VERSION=1.25.0
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH=/usr/local/go/bin:$PATH

# Create a non-root runner user (sudo is needed by installdependencies.sh only)
RUN useradd -m -u 1000 runner && usermod -aG sudo runner
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER runner
WORKDIR /home/runner

# Download GitHub Actions Runner (x64: runs on barcelona, not on the Pi); "latest" by default
ARG RUNNER_VERSION=latest
RUN version="$RUNNER_VERSION" \
    && if [ "$version" = latest ]; then \
         version=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//'); \
       fi \
    && curl -fsSL https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

COPY --chown=runner:runner entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

FROM deploy AS dev

# Chromium for pricetracker's Playwright tests (QA role); version matches its package.json
USER root
ARG PLAYWRIGHT_VERSION=1.63.0
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN npx -y playwright@${PLAYWRIGHT_VERSION} install --with-deps chromium \
    && rm -rf /var/lib/apt/lists/* /root/.npm

# GitHub CLI so Claude can open its own pull requests (ADR-0014)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*
USER runner
