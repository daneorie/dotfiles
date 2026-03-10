#!/usr/bin/env bash

set -euo pipefail

# Complete Dotfiles Setup Script
# This script performs a full installation including dependencies + stow packages
# Usage: ./scripts/complete-setup.sh [options]

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Get script directory and project root
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default configuration
INSTALL_DEPENDENCIES=true
INSTALL_VERSION_MANAGERS=true
INSTALL_STOW_PACKAGES=true
PACKAGE_SELECTION="core"  # core, all, or comma-separated list
DEPENDENCY_TYPE="all"     # all, core, or none
SKIP_HEALTH_CHECK=false
VERBOSE=false
MIGRATE_MODE=false        # Run migration instead of fresh install
MIGRATE_BACKUP_ONLY=false # Only backup during migration

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_header() {
    echo
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 ${#1}))${NC}"
    echo
}

# Help message
show_help() {
    cat << EOF
Complete Dotfiles Setup Script

This script performs a comprehensive dotfiles installation including:
1. Bootstrap (package managers and essential tools)
2. Dependencies (development tools and CLI utilities)  
3. Version managers (jenv, rbenv, pyenv, nvm, antigen)
4. Stow packages (dotfiles configuration)

Usage: $0 [OPTIONS]

Options:
  -h, --help                 Show this help message
  -v, --verbose              Enable verbose output
  --skip-deps               Skip dependency installation
  --deps-core               Install only core dependencies (faster)
  --skip-version-managers   Skip version manager setup
  --skip-stow               Skip stow package installation
  --skip-health-check       Skip final health check
  --packages SELECTION      Stow packages to install:
                            - core: Essential packages (default)
                            - all: All available packages
                            - list: Comma-separated package names
  --migrate                 Run migration mode (backup existing files first)
  --migrate-backup-only     Backup existing files only, don't install

Migration Mode:
  When --migrate is used, existing dotfiles are backed up before installation.
  This is useful when you have existing dotfiles that need to be preserved.

Examples:
  $0                        # Full setup with core packages
  $0 --packages all         # Full setup with all packages
  $0 --packages "zsh,git"   # Full setup with specific packages
  $0 --deps-core            # Install only core dependencies (faster)
  $0 --skip-deps            # Skip dependencies, install only stow packages
  $0 --verbose              # Show detailed output
  $0 --migrate              # Backup existing files and install core packages
  $0 --migrate --packages all  # Backup existing files and install all packages
  $0 --migrate-backup-only  # Just backup existing files, no installation

Environment Variables:
  DOTFILES_HOME             Override dotfiles directory (default: current dir)
  DOTFILES_BACKUP_DIR       Override backup directory (default: ~/.dotfiles-backup)
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --skip-deps)
                INSTALL_DEPENDENCIES=false
                shift
                ;;
            --deps-core)
                DEPENDENCY_TYPE="core"
                shift
                ;;
            --skip-version-managers)
                INSTALL_VERSION_MANAGERS=false
                shift
                ;;
            --skip-stow)
                INSTALL_STOW_PACKAGES=false
                shift
                ;;
            --skip-health-check)
                SKIP_HEALTH_CHECK=true
                shift
                ;;
            --packages)
                PACKAGE_SELECTION="$2"
                shift 2
                ;;
            --migrate)
                MIGRATE_MODE=true
                shift
                ;;
            --migrate-backup-only)
                MIGRATE_MODE=true
                MIGRATE_BACKUP_ONLY=true
                INSTALL_DEPENDENCIES=false
                INSTALL_VERSION_MANAGERS=false
                INSTALL_STOW_PACKAGES=false
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    log_header "Checking Prerequisites"
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/Makefile" ]] || [[ ! -d "$PROJECT_ROOT/stow-packages" ]]; then
        log_error "This doesn't appear to be a dotfiles repository."
        log_error "Make sure you're running this from the dotfiles directory."
        exit 1
    fi
    
    # Check if Make is available
    if ! command -v make >/dev/null 2>&1; then
        log_error "Make is required but not installed."
        exit 1
    fi
    
    log_success "Prerequisites satisfied"
}

# Run bootstrap
run_bootstrap() {
    if [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
        log_header "Step 1: Bootstrap"
        log_info "Installing package managers and essential tools..."
        
        cd "$PROJECT_ROOT"
        if [[ "$VERBOSE" == "true" ]]; then
            make bootstrap
        else
            make bootstrap >/dev/null 2>&1
        fi
        
        log_success "Bootstrap completed"
    else
        log_info "Skipping bootstrap (--skip-deps specified)"
    fi
}

# Install dependencies
install_dependencies() {
    if [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
        log_header "Step 2: Install Dependencies"
        if [[ "$DEPENDENCY_TYPE" == "core" ]]; then
            log_info "Installing core development tools and CLI utilities..."
        else
            log_info "Installing development tools and CLI utilities..."
        fi
        log_info "This may take several minutes depending on your network speed and what's already installed..."
        
        cd "$PROJECT_ROOT"
        
        # Choose the appropriate make target based on dependency type
        local make_target="install-deps"
        if [[ "$DEPENDENCY_TYPE" == "core" ]]; then
            make_target="install-deps-core"
        fi
        
        if [[ "$VERBOSE" == "true" ]]; then
            make "$make_target"
        else
            # Show progress even in non-verbose mode to avoid appearing hung
            echo "  Installing packages (this may take a while)..."
            if make "$make_target" 2>&1 | grep -E '✓|Installing|Error|⚠|Failed' | while read -r line; do
                echo "    $line"
            done; then
                : # Success case handled below
            else
                log_warning "Some packages may have failed to install - continuing..."
            fi
        fi
        
        log_success "Dependencies installed"
    else
        log_info "Skipping dependency installation (--skip-deps specified)"
    fi
}

# Setup version managers
setup_version_managers() {
    if [[ "$INSTALL_VERSION_MANAGERS" == "true" ]]; then
        log_header "Step 3: Setup Version Managers"
        log_info "Installing jenv, rbenv, pyenv, nvm, antigen..."
        log_info "This step downloads and configures language version managers..."
        
        cd "$PROJECT_ROOT"
        if [[ "$VERBOSE" == "true" ]]; then
            make setup-tools
        else
            # Show progress to avoid appearing hung
            echo "  Setting up version managers (this may take a while)..."
            if make setup-tools 2>&1 | grep -E '✓|Installing|Setting up|Error|⚠|Failed|Cloning' | while read -r line; do
                echo "    $line"
            done; then
                : # Success case handled below
            else
                log_warning "Some version managers may have failed to install - continuing..."
            fi
        fi
        
        log_success "Version managers configured"
        log_info "Environment helper created: ~/.dotfiles-env-setup"
    else
        log_info "Skipping version manager setup (--skip-version-managers specified)"
    fi
}

# Install stow packages
install_stow_packages() {
    if [[ "$INSTALL_STOW_PACKAGES" == "true" ]]; then
        log_header "Step 4: Install Stow Packages"
        
        if [[ "$MIGRATE_MODE" == "true" ]]; then
            log_info "Running migration (backup existing files and install packages)..."
            
            cd "$PROJECT_ROOT"
            
            # Build migration command
            migrate_cmd="./scripts/migrate.sh --yes"
            
            if [[ "$MIGRATE_BACKUP_ONLY" == "true" ]]; then
                migrate_cmd="$migrate_cmd --backup-only"
            fi
            
            case "$PACKAGE_SELECTION" in
                "core")
                    migrate_cmd="$migrate_cmd --core"
                    ;;
                "all")
                    migrate_cmd="$migrate_cmd --all"
                    ;;
                *)
                    # Convert comma-separated to space-separated for migration
                    packages=$(echo "$PACKAGE_SELECTION" | tr ',' ' ')
                    migrate_cmd="$migrate_cmd $packages"
                    ;;
            esac
            
            if [[ "$VERBOSE" == "true" ]]; then
                log_info "Running: $migrate_cmd"
                eval "$migrate_cmd"
            else
                eval "$migrate_cmd" >/dev/null 2>&1
            fi
            
            log_success "Migration completed"
        else
            log_info "Installing dotfiles configuration packages..."
            
            cd "$PROJECT_ROOT"
            
            case "$PACKAGE_SELECTION" in
                "core")
                    log_info "Installing core packages..."
                    if [[ "$VERBOSE" == "true" ]]; then
                        make install-core
                    else
                        make install-core >/dev/null 2>&1
                    fi
                    ;;
                "all")
                    log_info "Installing all packages..."
                    if [[ "$VERBOSE" == "true" ]]; then
                        make install-all
                    else
                        make install-all >/dev/null 2>&1
                    fi
                    ;;
                *)
                    log_info "Installing custom packages: $PACKAGE_SELECTION"
                    if [[ "$VERBOSE" == "true" ]]; then
                        make install PACKAGES="$PACKAGE_SELECTION"
                    else
                        make install PACKAGES="$PACKAGE_SELECTION" >/dev/null 2>&1
                    fi
                    ;;
            esac
            
            log_success "Stow packages installed"
        fi
    else
        log_info "Skipping stow package installation (--skip-stow specified)"
    fi
}

# Run health check
run_health_check() {
    if [[ "$SKIP_HEALTH_CHECK" == "false" ]]; then
        log_header "Step 5: Health Check"
        log_info "Verifying installation..."
        
        cd "$PROJECT_ROOT"
        make health
        
        log_success "Health check completed"
    else
        log_info "Skipping health check (--skip-health-check specified)"
    fi
}

# Show completion summary
show_completion_summary() {
    log_header "🎉 Setup Complete!"
    
    echo "Your dotfiles environment is now fully configured:"
    echo
    
    if [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
        echo "✓ Package managers and dependencies installed"
    fi
    
    if [[ "$INSTALL_VERSION_MANAGERS" == "true" ]]; then
        echo "✓ Version managers configured (jenv, rbenv, pyenv, nvm, antigen)"
    fi
    
    if [[ "$INSTALL_STOW_PACKAGES" == "true" ]]; then
        echo "✓ Stow packages installed: $PACKAGE_SELECTION"
    fi
    
    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.dotfiles-env-setup"
    echo "  2. Check status: make status"
    echo "  3. Run health check: make health"
    echo
    
    if [[ "$INSTALL_STOW_PACKAGES" == "true" && "$PACKAGE_SELECTION" == "core" ]]; then
        log_info "To install additional packages:"
        echo "  make list                    # See all available packages"
        echo "  make install PACKAGES=\"...\" # Install specific packages"
        echo "  make install-all             # Install all packages"
    fi
}

# Main execution
main() {
    # Parse arguments
    parse_args "$@"
    
    # Show banner
    echo
    if [[ "$MIGRATE_MODE" == "true" ]]; then
        echo -e "${BLUE}Complete Dotfiles Setup (Migration Mode)${NC}"
        echo -e "${BLUE}=========================================${NC}"
        echo
        echo "This will backup existing dotfiles and configure your complete development environment."
    else
        echo -e "${BLUE}Complete Dotfiles Setup${NC}"
        echo -e "${BLUE}=======================${NC}"
        echo
        echo "This will install and configure your complete development environment."
    fi
    echo
    
    # Show what will be installed
    echo "Installation plan:"
    [[ "$INSTALL_DEPENDENCIES" == "true" ]] && echo "  ✓ Bootstrap + Dependencies"
    [[ "$INSTALL_VERSION_MANAGERS" == "true" ]] && echo "  ✓ Version Managers"
    if [[ "$INSTALL_STOW_PACKAGES" == "true" ]]; then
        if [[ "$MIGRATE_MODE" == "true" ]]; then
            if [[ "$MIGRATE_BACKUP_ONLY" == "true" ]]; then
                echo "  ✓ Backup Existing Files Only"
            else
                echo "  ✓ Migrate Existing + Install Stow Packages ($PACKAGE_SELECTION)"
            fi
        else
            echo "  ✓ Stow Packages ($PACKAGE_SELECTION)"
        fi
    fi
    [[ "$SKIP_HEALTH_CHECK" == "false" ]] && echo "  ✓ Health Check"
    echo
    
    # Confirm before proceeding
    if [[ -t 0 ]]; then  # Only prompt if stdin is a terminal
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled."
            exit 0
        fi
        echo
    fi
    
    # Execute setup steps
    check_prerequisites
    run_bootstrap
    install_dependencies  
    setup_version_managers
    install_stow_packages
    run_health_check
    show_completion_summary
}

# Handle interrupts gracefully
trap 'log_warning "Setup interrupted by user"; exit 130' INT TERM

# Run main function
main "$@"