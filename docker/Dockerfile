# Dockerfile for testing complete dotfiles setup
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Install essential packages and tools needed for complete setup
RUN apt-get update && apt-get install -y \
    # Core utilities
    curl \
    wget \
    git \
    zsh \
    tmux \
    vim \
    neovim \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    # Stow and build tools
    stow \
    build-essential \
    make \
    # Tools for version managers
    gcc \
    g++ \
    libc6-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    # Development tools that dotfiles might reference
    fd-find \
    fzf \
    ripgrep \
    # Other tools commonly used in dotfiles
    less \
    tree \
    htop \
    jq \
    # Additional requirements for Homebrew
    file \
    procps \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Create a test user (non-root) BEFORE installing Homebrew
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser:testuser" | chpasswd && \
    usermod -aG sudo testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to testuser for Homebrew installation
USER testuser
WORKDIR /home/testuser

# Install Homebrew as testuser
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc && \
    # Verify Homebrew installation
    /home/linuxbrew/.linuxbrew/bin/brew --version

# Set up environment variables for Homebrew and Docker
ENV DOCKER_ENV=1
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
ENV INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"

# Create some mock existing files to test migration
RUN echo "# Existing .zshrc" > .zshrc && \
    echo "# Existing .vimrc" > .vimrc && \
    echo "# Existing .tmux.conf" > .tmux.conf && \
    echo "# Existing .gitconfig" > .gitconfig && \
    mkdir -p .config/nvim && \
    echo "-- Existing nvim config" > .config/nvim/init.lua && \
    mkdir -p shell/config && \
    echo "# Existing shell config" > shell/config/aliases.zsh

# Set up environment
ENV HOME=/home/testuser
ENV USER=testuser

# Default command
CMD ["/bin/zsh"]