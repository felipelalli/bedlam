# syntax=docker/dockerfile:1.7
FROM igorhvr/bedlam-ubuntu

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# -------------------------------
# System deps (headless + build tools)
# -------------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
    build-essential curl file git procps ca-certificates \
    sudo locales dialog gnupg lsb-release unzip xz-utils \
    python3 python3-dev python3-pip \
    chromium xvfb \
    ; \
    rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install GitHub CLI (gh)
# -------------------------------
RUN set -eux; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y gh; \
    rm -rf /var/lib/apt/lists/*; \
    gh --version

# -------------------------------
# Homebrew (Linuxbrew) – manual, Docker-safe
# -------------------------------
RUN set -eux; \
    useradd -m -d /home/linuxbrew -s /bin/bash linuxbrew; \
    mkdir -p /home/linuxbrew/.linuxbrew; \
    chown -R linuxbrew:linuxbrew /home/linuxbrew

USER linuxbrew
ENV HOME=/home/linuxbrew

RUN set -eux; \
    git clone --depth=1 https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew; \
    mkdir -p /home/linuxbrew/.linuxbrew/bin; \
    ln -sf ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
    brew --version

USER root
ENV HOME=/root

RUN set -eux; \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > /etc/profile.d/brew.sh

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

# -------------------------------
# npm reliability settings
# -------------------------------
RUN set -eux; \
    npm config set fund false; \
    npm config set audit false; \
    npm config set update-notifier false; \
    npm config set progress false; \
    npm config set fetch-retries 5; \
    npm config set fetch-retry-mintimeout 20000; \
    npm config set fetch-retry-maxtimeout 120000

# -------------------------------
# Tooling installs (cached)
# -------------------------------
ENV OPENCLAW_STATE_DIR=/root/.openclaw
RUN --mount=type=cache,target=/root/.npm \
    npm install -g openclaw@latest --no-audit --no-fund

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @google/gemini-cli --no-audit --no-fund

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @openai/codex --no-audit --no-fund

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @anthropic-ai/claude-code --no-audit --no-fund

# -------------------------------
# Headless defaults
# -------------------------------
ENV CHROME_FLAGS="--window-size=1920,1080 --disable-gpu --no-sandbox"
# ENV DISPLAY=:99

# -------------------------------
# Copy OpenClaw start script
# -------------------------------
COPY openclaw-start /bin/openclaw-start
RUN chmod 0755 /bin/openclaw-start

# -------------------------------
# Global ZSH banner (after oh-my-zsh)
# -------------------------------
RUN cat <<'EOF' > /etc/zsh/zshrc
# Show OpenClaw help once per interactive shell
if [[ -o interactive ]]; then
  echo
  echo "OpenClaw quickstart:"
  echo "  First run (one time only): openclaw onboard"
  echo "  Start gateway:             openclaw-start"
  echo "  Gateway UI:                http://127.0.0.1:18789/"
  echo
fi
EOF

CMD ["/bin/zsh"]
