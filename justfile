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

# Package Management
# ==================

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

# Run migration workflow (backup existing files and migrate to stow)
[group('Migration')]
migrate:
    @./scripts/migrate.sh

# Testing
# =======

# Run comprehensive test suite
[group('Testing')]
test:
    @echo "{{BLUE}}Running comprehensive test suite...{{NC}}"
    @cd scripts && ./test.sh

# Start interactive testing session
[group('Testing')]
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

# Development
# ===========

# Build Docker test environment without running tests
[group('Development')]
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
    @echo "📋 Available packages:"
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
    @echo "✓ Checking Docker environment..."
    @command -v docker >/dev/null && echo "{{GREEN}}✓ Docker is available{{NC}}" || echo "{{YELLOW}}⚠ Docker not found (testing will be limited){{NC}}"

# Show this help message
[group('Information')]
help:
    @echo "{{BLUE}}Dotfiles Management{{NC}}"
    @echo "{{BLUE}}==================={{NC}}"
    @echo ""
    @echo "A modern task runner for dotfiles management using GNU Stow"
    @echo ""
    @echo "Usage:"
    @echo "  just {{BLUE}}<target>{{NC}}"
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
