# Dockerfile for testing dotfiles stow setup
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Install essential packages
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
    # Stow and build tools
    stow \
    build-essential \
    # Development tools that dotfiles might reference
    fd-find \
    fzf \
    ripgrep \
    # Other tools commonly used in dotfiles
    less \
    tree \
    htop \
    jq \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Create a test user (non-root)
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser:testuser" | chpasswd && \
    usermod -aG sudo testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create some mock existing files to test migration
USER testuser
WORKDIR /home/testuser

# Create mock existing dotfiles to simulate migration scenario
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