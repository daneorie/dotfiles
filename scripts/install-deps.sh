#!/bin/bash

# Dependencies Installation Script
# Installs development tools, CLI utilities, and applications via package managers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory for relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Dependencies Installation${NC}"
echo -e "${BLUE}=========================${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    local missing=()
    
    if ! command -v brew &> /dev/null; then
        missing+=("Homebrew")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("Git")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing prerequisites: ${missing[*]}${NC}"
        echo "Please run: ./scripts/bootstrap.sh first"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
}

# Core CLI tools and utilities
BREW_CORE_PACKAGES=(
    # Essential CLI tools
    "fd"                    # Better find
    "fzf"                   # Fuzzy finder
    "ripgrep"               # Better grep
    "bat"                   # Better cat
    "eza"                   # Better ls
    "tree"                  # Directory tree
    "htop"                  # Better top
    "neovim"                # Text editor
    "tmux"                  # Terminal multiplexer
    "zsh"                   # Shell
    
    # Development tools
    "jq"                    # JSON processor
    "yq"                    # YAML processor
    "curl"                  # HTTP client
    "wget"                  # Download tool
    "rsync"                 # File sync
    "git-delta"             # Better git diff
    "lazygit"               # Git TUI
    "gh"                    # GitHub CLI
    
    # Compression and archives
    "unzip"
    "p7zip"
    
    # Network tools
    "nmap"
    "mtr"
)

# GUI applications (casks for macOS)
BREW_GUI_PACKAGES=(
    "alacritty"             # Terminal emulator
    "wezterm"               # Terminal emulator
    "kitty"                 # Terminal emulator
)

# Development language tools
BREW_LANG_PACKAGES=(
    # Java
    "openjdk"
    
    # Python
    "python@3.11"
    "python@3.12"
    
    # Node.js
    "node"
    "yarn"
    
    # Ruby
    "ruby"
    
    # Go
    "go"
    
    # Rust
    "rust"
    
    # Other
    "lua"
    "luarocks"
)

# Install packages with error handling
install_package() {
    local package="$1"
    local type="${2:-formula}"  # formula or cask
    
    if [[ "$type" == "cask" ]]; then
        if brew list --cask "$package" &> /dev/null; then
            echo -e "${GREEN}✓ $package (cask) already installed${NC}"
            return 0
        fi
        echo -e "${YELLOW}Installing $package (cask)...${NC}"
        if brew install --cask "$package"; then
            echo -e "${GREEN}✓ $package (cask) installed successfully${NC}"
        else
            echo -e "${YELLOW}⚠ Failed to install $package (cask) - continuing...${NC}"
            return 1
        fi
    else
        if brew list "$package" &> /dev/null; then
            echo -e "${GREEN}✓ $package already installed${NC}"
            return 0
        fi
        echo -e "${YELLOW}Installing $package...${NC}"
        if brew install "$package"; then
            echo -e "${GREEN}✓ $package installed successfully${NC}"
        else
            echo -e "${YELLOW}⚠ Failed to install $package - continuing...${NC}"
            return 1
        fi
    fi
}

# Install core packages
install_core_packages() {
    echo -e "${BLUE}Installing core CLI tools...${NC}"
    local failed=0
    
    for package in "${BREW_CORE_PACKAGES[@]}"; do
        if ! install_package "$package"; then
            failed=$((failed + 1))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✓ All core packages installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ $failed core packages failed to install${NC}"
    fi
    echo ""
}

# Install GUI applications
install_gui_packages() {
    echo -e "${BLUE}Installing GUI applications...${NC}"
    local failed=0
    
    # Check if we're on macOS for cask support
    if [[ "$OSTYPE" == "darwin"* ]]; then
        for package in "${BREW_GUI_PACKAGES[@]}"; do
            if ! install_package "$package" "cask"; then
                failed=$((failed + 1))
            fi
        done
    else
        echo -e "${YELLOW}GUI packages (casks) are only available on macOS${NC}"
    fi
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✓ All GUI packages installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ $failed GUI packages failed to install${NC}"
    fi
    echo ""
}

# Install language tools
install_language_packages() {
    echo -e "${BLUE}Installing development language tools...${NC}"
    local failed=0
    
    for package in "${BREW_LANG_PACKAGES[@]}"; do
        if ! install_package "$package"; then
            failed=$((failed + 1))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✓ All language packages installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ $failed language packages failed to install${NC}"
    fi
    echo ""
}

# Update Homebrew and upgrade packages
update_homebrew() {
    echo -e "${BLUE}Updating Homebrew...${NC}"
    brew update
    echo -e "${GREEN}✓ Homebrew updated${NC}"
    echo ""
}

# Setup shell completions and integrations
setup_integrations() {
    echo -e "${BLUE}Setting up tool integrations...${NC}"
    
    # FZF key bindings and completions
    if command -v fzf &> /dev/null; then
        echo -e "${YELLOW}Setting up fzf integrations...${NC}"
        if [[ -f "/opt/homebrew/opt/fzf/install" ]]; then
            /opt/homebrew/opt/fzf/install --completion --key-bindings --no-update-rc
        elif [[ -f "/usr/local/opt/fzf/install" ]]; then
            /usr/local/opt/fzf/install --completion --key-bindings --no-update-rc
        fi
        echo -e "${GREEN}✓ fzf integrations setup${NC}"
    fi
    
    echo ""
}

# Show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -c, --core      Install only core CLI tools"
    echo "  -g, --gui       Install only GUI applications"
    echo "  -l, --lang      Install only language tools"
    echo "  -a, --all       Install all packages (default)"
    echo "  -u, --update    Update Homebrew before installing"
    echo ""
    echo "Examples:"
    echo "  $0              # Install all packages"
    echo "  $0 --core       # Install only core CLI tools"
    echo "  $0 --update     # Update Homebrew and install all packages"
}

# Main function
main() {
    local install_core=false
    local install_gui=false
    local install_lang=false
    local update_brew=false
    local install_all=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--core)
                install_core=true
                install_all=false
                shift
                ;;
            -g|--gui)
                install_gui=true
                install_all=false
                shift
                ;;
            -l|--lang)
                install_lang=true
                install_all=false
                shift
                ;;
            -a|--all)
                install_all=true
                shift
                ;;
            -u|--update)
                update_brew=true
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
    
    check_prerequisites
    
    if [[ "$update_brew" == "true" ]]; then
        update_homebrew
    fi
    
    if [[ "$install_all" == "true" ]]; then
        install_core_packages
        install_gui_packages
        install_language_packages
    else
        if [[ "$install_core" == "true" ]]; then
            install_core_packages
        fi
        if [[ "$install_gui" == "true" ]]; then
            install_gui_packages
        fi
        if [[ "$install_lang" == "true" ]]; then
            install_language_packages
        fi
    fi
    
    setup_integrations
    
    echo -e "${GREEN}✅ Dependencies installation completed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: make setup-tools      # Setup version managers"
    echo "  2. Run: make install-core     # Install dotfiles"
    echo ""
}

# Run main function if script is executed directly
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
