# Dotfiles Management - Just Task Runner
# Modern task runner for dotfiles management
# Install just: https://github.com/casey/just

# Default recipe
default: help

# Colors
blue := '\033[0;34m'
green := '\033[0;32m'
yellow := '\033[1;33m'
red := '\033[0;31m'
reset := '\033[0m'

# Package Management
# ==================

# List all available packages
list:
    @./scripts/install.sh --list

# Install core packages (zsh, wezterm, tmux, git, vim, nvim, yabai)
install-core:
    @./scripts/install.sh --core

# Install all packages
install-all:
    @./scripts/install.sh --all

# Install specific packages (usage: just install zsh git tmux)
install *packages:
    @./scripts/install.sh {{packages}}

# Remove specific packages (usage: just uninstall zsh git)
uninstall *packages:
    @./scripts/install.sh --unstow {{packages}}

# Preview what would be installed (core packages)
dry-run:
    @./scripts/install.sh --dry-run --core

# Preview what would be installed (all packages)
dry-run-all:
    @./scripts/install.sh --dry-run --all

# Verify package structure
verify:
    @./scripts/verify.sh

# Migration
# =========

# Run migration workflow (backup existing files and migrate to stow)
migrate:
    @./scripts/migrate.sh

# Testing
# =======

# Run comprehensive test suite
test:
    @echo -e "{{blue}}Running comprehensive test suite...{{reset}}"
    @cd scripts && ./test.sh

# Start interactive testing session
test-interactive:
    @echo -e "{{blue}}Starting interactive testing session...{{reset}}"
    @cd scripts && ./test.sh interactive

# Check testing container status
test-status:
    @cd scripts && ./test.sh status

# Show testing container logs
test-logs:
    @cd scripts && ./test.sh logs

# Clean up test environment
test-clean:
    @cd scripts && ./test.sh cleanup

# Development
# ===========

# Build Docker test environment without running tests
dev-build:
    @echo -e "{{blue}}Building Docker test environment...{{reset}}"
    @cd docker && docker-compose build

# Get shell access to test container
dev-shell:
    @cd scripts && ./test.sh interactive

# Maintenance
# ===========

# Clean up temporary files and test artifacts
clean:
    @echo -e "{{yellow}}Cleaning up temporary files...{{reset}}"
    @rm -f test1.log test2.log test3.log 2>/dev/null || true
    @rm -f *.log 2>/dev/null || true
    @echo -e "{{green}}Cleanup completed!{{reset}}"

# Full cleanup (test environment + temp files)
clean-all: test-clean clean

# Information
# ===========

# Show current dotfiles status
status:
    @echo -e "{{blue}}Dotfiles Status{{reset}}"
    @echo -e "{{blue}}==============={{reset}}"
    @echo ""
    @echo "📁 Package count: $(ls stow-packages/ | wc -l | tr -d ' ')"
    @echo "📋 Available packages:"
    @ls stow-packages/ | sed 's/^/  - /'
    @echo ""
    @echo "🔗 Current symlinks in home directory:"
    @find ~/ -maxdepth 1 -type l 2>/dev/null | head -10 || echo "  (none found at top level)"

# Health check - verify everything is working
health:
    @echo -e "{{blue}}Running health check...{{reset}}"
    @echo ""
    @echo "✓ Checking package structure..."
    @./scripts/verify.sh > /dev/null && echo -e "{{green}}✓ Package structure is valid{{reset}}" || echo -e "{{red}}✗ Package structure issues found{{reset}}"
    @echo "✓ Checking script permissions..."
    @[ -x scripts/install.sh ] && [ -x scripts/migrate.sh ] && [ -x scripts/verify.sh ] && echo -e "{{green}}✓ All scripts are executable{{reset}}" || echo -e "{{red}}✗ Script permission issues{{reset}}"
    @echo "✓ Checking Docker environment..."
    @command -v docker >/dev/null && echo -e "{{green}}✓ Docker is available{{reset}}" || echo -e "{{yellow}}⚠ Docker not found (testing will be limited){{reset}}"

# Show this help message
help:
    @echo -e "{{blue}}Dotfiles Management (Just Task Runner){{reset}}"
    @echo -e "{{blue}}======================================{{reset}}"
    @echo ""
    @echo "A modern task runner for dotfiles management using GNU Stow"
    @echo ""
    @echo "📦 Package Management:"
    @echo "  just list                    # List all available packages"
    @echo "  just install-core            # Install essential packages"
    @echo "  just install-all             # Install all packages"
    @echo "  just install zsh git tmux    # Install specific packages"
    @echo "  just uninstall zsh git       # Remove specific packages"
    @echo "  just dry-run                 # Preview core installation"
    @echo "  just dry-run-all             # Preview all installations"
    @echo "  just verify                  # Verify package structure"
    @echo ""
    @echo "🔄 Migration:"
    @echo "  just migrate                 # Migrate existing dotfiles to stow"
    @echo ""
    @echo "🧪 Testing:"
    @echo "  just test                    # Run comprehensive test suite"
    @echo "  just test-interactive        # Interactive testing session"
    @echo "  just test-status            # Check container status"
    @echo "  just test-clean             # Clean up test environment"
    @echo ""
    @echo "🔧 Development:"
    @echo "  just dev-build              # Build test environment"
    @echo "  just dev-shell              # Access test container"
    @echo ""
    @echo "🧹 Maintenance:"
    @echo "  just clean                  # Clean temporary files"
    @echo "  just clean-all              # Full cleanup"
    @echo "  just status                 # Show dotfiles status"
    @echo "  just health                 # Run health check"
    @echo ""