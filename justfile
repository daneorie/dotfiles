# Dotfiles Management
# Modern task runner for dotfiles management
# Install just: https://github.com/casey/just

# Default recipe: help
[group('Information')]
default: help

# Colors
BLUE := '\033[0;34m'
GREEN := '\033[0;32m'
YELLOW := '\033[1;33m'
RED := '\033[0;31m'
NC := '\033[0m'

# Setup
# ========

# Install package managers and essential tools (run this first)
[group('Setup')]
bootstrap:
    @./scripts/bootstrap.sh

# Install development tools and CLI utilities
[group('Setup')]
install-deps:
    @./scripts/install-deps.sh

# Install only core CLI tools
[group('Setup')]
install-deps-core:
    @./scripts/install-deps.sh --core

# Install only GUI applications
[group('Setup')]
install-deps-gui:
    @./scripts/install-deps.sh --gui

# Install only programming language tools
[group('Setup')]
install-deps-lang:
    @./scripts/install-deps.sh --lang

# Setup version managers (jenv, rbenv, pyenv, nvm, antigen)
[group('Setup')]
setup-tools:
    @./scripts/setup-tools.sh

# Setup only Java version manager (jenv)
[group('Setup')]
setup-java:
    @./scripts/setup-tools.sh --java

# Setup only Ruby version manager (rbenv)
[group('Setup')]
setup-ruby:
    @./scripts/setup-tools.sh --ruby

# Setup only Python version manager (pyenv)
[group('Setup')]
setup-python:
    @./scripts/setup-tools.sh --python

# Setup only Node.js version manager (nvm)
[group('Setup')]
setup-node:
    @./scripts/setup-tools.sh --node

# Setup Zsh tools (antigen)
[group('Setup')]
setup-zsh:
    @./scripts/setup-tools.sh --zsh

# Complete comprehensive setup (dependencies + stow packages)
[group('Setup')]
complete-setup:
    @./scripts/complete-setup.sh

# Complete setup with all packages  
[group('Setup')]
complete-setup-all:
    @./scripts/complete-setup.sh --packages all

# Complete setup with core dependencies only (faster)
[group('Setup')]
complete-setup-core-deps:
    @./scripts/complete-setup.sh --deps-core

# Complete setup with verbose output
[group('Setup')]
complete-setup-verbose:
    @./scripts/complete-setup.sh --verbose

# Complete setup with migration (backup existing files)
[group('Setup')]
complete-setup-migrate:
    @./scripts/complete-setup.sh --migrate

# Complete setup with migration (all packages)
[group('Setup')]
complete-setup-migrate-all:
    @./scripts/complete-setup.sh --migrate --packages all

# Complete setup (bootstrap + deps + tools + dotfiles)
[group('Setup')]
full-setup: bootstrap install-deps setup-tools install-core

# Package Management
# ====================

# List all available packages
[group('Package Management')]
list:
    @./scripts/install.sh --list

# Install core packages (zsh, wezterm, tmux, git, vim, nvim, yabai)
[group('Package Management')]
install-core:
    @./scripts/install.sh --core

# Install all packages
[group('Package Management')]
install-all:
    @./scripts/install.sh --all

# Install specific packages (usage: just install zsh git tmux)
[group('Package Management')]
install *packages:
    @./scripts/install.sh {{packages}}

# Remove specific packages (usage: just uninstall zsh git)
[group('Package Management')]
uninstall *packages:
    @./scripts/install.sh --unstow {{packages}}

# Preview what would be installed (core packages)
[group('Package Management')]
dry-run:
    @./scripts/install.sh --dry-run --core

# Preview what would be installed (all packages)
[group('Package Management')]
dry-run-all:
    @./scripts/install.sh --dry-run --all

# Verify package structure
[group('Package Management')]
verify:
    @./scripts/verify.sh

# Migration
# =========

# Migrate core packages only
[group('Migration')]
migrate-core:
    @./scripts/migrate.sh --core

# Migrate all packages
[group('Migration')]
migrate-all:
    @./scripts/migrate.sh --all

# Migrate specific packages (usage: just migrate-packages zsh git tmux)
[group('Migration')]
migrate +packages:
    @./scripts/migrate.sh {{packages}}

# Run migration workflow (backup existing files and migrate to stow)
[group('Migration')]
migrate-interactive:
    @./scripts/migrate.sh

# Preview migration (core packages)
[group('Migration')]
migrate-dry-run:
    @./scripts/migrate.sh --core --dry-run

# Backup existing files without installing packages
[group('Migration')]
migrate-backup-only:
    @./scripts/migrate.sh --core --backup-only

# Testing
# =======

# Run comprehensive test suite
[group('Testing')]
test:
    @echo "{{BLUE}}Running comprehensive test suite...{{NC}}"
    @cd scripts && ./test.sh

# Start interactive testing session
[group('🧪 Testing')]
test-interactive:
    @echo "{{BLUE}}Starting interactive testing session...{{NC}}"
    @cd scripts && ./test.sh interactive

# Check testing container status
[group('Testing')]
test-status:
    @cd scripts && ./test.sh status

# Show testing container logs
[group('Testing')]
test-logs:
    @cd scripts && ./test.sh logs

# Clean up test environment
[group('Testing')]
test-clean:
    @cd scripts && ./test.sh cleanup

# Test complete setup process in Docker
[group('Testing')]
test-complete:
    @echo "{{BLUE}}Testing complete setup process...{{NC}}"
    @cd docker && docker-compose up --build dotfiles-test

# Test stow-only process in Docker  
[group('Testing')]
test-stow-only:
    @echo "{{BLUE}}Testing stow-only process...{{NC}}"
    @cd docker && docker-compose up --build dotfiles-stow-test

# Development
# ===========

# Build Docker test environment without running tests
[group('🔧 Development')]
dev-build:
    @echo "{{BLUE}}Building Docker test environment...{{NC}}"
    @cd docker && docker-compose build

# Get shell access to test container
[group('Development')]
dev-shell:
    @cd scripts && ./test.sh interactive

# Maintenance
# ===========

# Clean up temporary files and test artifacts
[group('Maintenance')]
clean:
    @echo "{{YELLOW}}Cleaning up temporary files...{{NC}}"
    @rm -f test1.log test2.log test3.log 2>/dev/null || true
    @rm -f *.log 2>/dev/null || true
    @echo "{{GREEN}}Cleanup completed!{{NC}}"

# Full cleanup (test environment + temp files)
[group('Maintenance')]
clean-all: test-clean clean

# Show current dotfiles status
[group('Maintenance')]
status:
    @echo "{{BLUE}}Dotfiles Status{{NC}}"
    @echo "{{BLUE}}==============={{NC}}"
    @echo ""
    @echo "📁 Package count: $(ls stow-packages/ | wc -l | tr -d ' ')"
    @echo "Available packages:"
    @ls stow-packages/ | sed 's/^/  - /'
    @echo ""
    @echo "🔗 Current symlinks in home directory:"
    @find ~/ -maxdepth 1 -type l 2>/dev/null | head -10 || echo "  (none found at top level)"

# Health check - verify everything is working
[group('Maintenance')]
health:
    @echo "{{BLUE}}Running health check...{{NC}}"
    @echo ""
    @echo "✓ Checking package structure..."
    @./scripts/verify.sh > /dev/null && echo "{{GREEN}}✓ Package structure is valid{{NC}}" || echo "{{RED}}✗ Package structure issues found{{NC}}"
    @echo "✓ Checking script permissions..."
    @[ -x scripts/install.sh ] && [ -x scripts/migrate.sh ] && [ -x scripts/verify.sh ] && echo "{{GREEN}}✓ All scripts are executable{{NC}}" || echo "{{RED}}✗ Script permission issues{{NC}}"
    @echo "✓ Checking essential tools..."
    @command -v git >/dev/null && echo "{{GREEN}}✓ Git is available{{NC}}" || echo "{{RED}}✗ Git not found{{NC}}"
    @command -v stow >/dev/null && echo "{{GREEN}}✓ GNU Stow is available{{NC}}" || echo "{{RED}}✗ GNU Stow not found{{NC}}"
    @echo "✓ Checking package managers..."
    @command -v brew >/dev/null && echo "{{GREEN}}✓ Homebrew is available{{NC}}" || echo "{{YELLOW}}⚠ Homebrew not found{{NC}}"
    @echo "✓ Checking development tools..."
    @command -v nvim >/dev/null && echo "{{GREEN}}✓ Neovim is available{{NC}}" || echo "{{YELLOW}}⚠ Neovim not found{{NC}}"
    @command -v fzf >/dev/null && echo "{{GREEN}}✓ fzf is available{{NC}}" || echo "{{YELLOW}}⚠ fzf not found{{NC}}"
    @command -v fd >/dev/null && echo "{{GREEN}}✓ fd is available{{NC}}" || echo "{{YELLOW}}⚠ fd not found{{NC}}"
    @echo "✓ Checking version managers..."
    @command -v jenv >/dev/null && echo "{{GREEN}}✓ jenv is available{{NC}}" || echo "{{YELLOW}}⚠ jenv not found{{NC}}"
    @command -v rbenv >/dev/null && echo "{{GREEN}}✓ rbenv is available{{NC}}" || echo "{{YELLOW}}⚠ rbenv not found{{NC}}"
    @command -v pyenv >/dev/null && echo "{{GREEN}}✓ pyenv is available{{NC}}" || echo "{{YELLOW}}⚠ pyenv not found{{NC}}"
    @[[ -s "$HOME/.nvm/nvm.sh" ]] && echo "{{GREEN}}✓ nvm is available{{NC}}" || echo "{{YELLOW}}⚠ nvm not found{{NC}}"
    @[[ -f "$HOME/.antigen/antigen.zsh" ]] && echo "{{GREEN}}✓ antigen is available{{NC}}" || echo "{{YELLOW}}⚠ antigen not found{{NC}}"
    @echo "✓ Checking Docker environment..."
    @command -v docker >/dev/null && echo "{{GREEN}}✓ Docker is available{{NC}}" || echo "{{YELLOW}}⚠ Docker not found (testing will be limited){{NC}}"

# Show this help message
[group('Information')]
help:
    @echo "{{BLUE}}Dotfiles Management{{NC}}"
    @echo "{{BLUE}}===================={{NC}}"
    @echo ""
    @echo "A modern task runner for dotfiles management using GNU Stow"
    @echo ""
    @echo "Usage:"
    @echo "  just {{BLUE}}<target>{{NC}}"
    @echo ""
    @just --list | awk 'BEGIN {FS = "#"} /\[/ { printf "\n{{YELLOW}}%s{{NC}}\n", substr($0, 6, length($0)-6) } /#/ { printf "  {{BLUE}}%-20s{{NC}}%s\n", substr($1, 5), $2 }'
    @echo ""
    @echo "Examples:"
    @echo "  just list                    # List all available packages"
    @echo "  just install-core            # Install essential packages"
    @echo "  just install zsh git tmux    # Install specific packages"
    @echo "  just test                    # Run comprehensive test suite"
    @echo "  just migrate                 # Migrate existing dotfiles to stow"
    @echo "  just --choose                # Select recipes from an interactive chooser"
    @echo ""
