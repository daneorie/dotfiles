#!/bin/bash

# Bootstrap Script for Dotfiles Dependencies
# This script installs essential package managers and tools required for dotfiles setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Dotfiles Bootstrap${NC}"
echo -e "${BLUE}==================${NC}"
echo ""
echo "This script will install essential tools and package managers."
echo ""

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        echo -e "${RED}Error: Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
}

# Install Homebrew (macOS and Linux)
install_homebrew() {
    echo -e "${BLUE}Checking Homebrew installation...${NC}"
    
    # Function to setup Homebrew environment
    setup_brew_env() {
        local brew_path="$1"
        if [[ -x "$brew_path" ]]; then
            echo -e "${YELLOW}Found Homebrew at $brew_path, setting up environment...${NC}"
            eval "$($brew_path shellenv)"
            export PATH="$(dirname "$brew_path"):$PATH"
            # Debug output in Docker environment
            if [[ -n "$DOCKER_ENV" ]]; then
                echo -e "${BLUE}Debug: PATH after setup: $PATH${NC}"
                echo -e "${BLUE}Debug: brew command check: $(command -v brew || echo 'not found')${NC}"
            fi
            return 0
        fi
        return 1
    }
    
    # Check if brew is already in PATH
    if command -v brew &> /dev/null; then
        echo -e "${GREEN}✓ Homebrew is already installed and in PATH${NC}"
        brew_version=$(brew --version | head -n1)
        echo -e "${BLUE}  $brew_version${NC}"
        return 0
    fi
    
    # Check common Homebrew locations and set up environment
    brew_found=false
    if [[ "$OS" == "linux" ]]; then
        # Try standard Linux Homebrew locations
        for brew_path in "/home/linuxbrew/.linuxbrew/bin/brew" "/home/$(whoami)/.linuxbrew/bin/brew" "/usr/local/bin/brew"; do
            if setup_brew_env "$brew_path"; then
                brew_found=true
                break
            fi
        done
    elif [[ "$OS" == "macos" ]]; then
        # Try standard macOS Homebrew locations
        for brew_path in "/opt/homebrew/bin/brew" "/usr/local/bin/brew"; do
            if setup_brew_env "$brew_path"; then
                brew_found=true
                break
            fi
        done
    fi
    
    # Final check after setting up environment
    if [[ "$brew_found" == "true" ]] && command -v brew &> /dev/null; then
        echo -e "${GREEN}✓ Homebrew found and configured${NC}"
        brew_version=$(brew --version | head -n1)
        echo -e "${BLUE}  $brew_version${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    if [[ "$OS" == "macos" ]]; then
        # Install Xcode Command Line Tools first on macOS
        if ! xcode-select -p &> /dev/null; then
            echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
            xcode-select --install
            echo "Please complete Xcode installation and run this script again."
            exit 1
        fi
    fi
    
    # Install Homebrew
    echo -e "${BLUE}Running Homebrew installation script...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Set up environment after installation with multiple attempts
    brew_setup_success=false
    if [[ "$OS" == "macos" ]]; then
        for brew_path in "/opt/homebrew/bin/brew" "/usr/local/bin/brew"; do
            if setup_brew_env "$brew_path"; then
                brew_setup_success=true
                break
            fi
        done
    elif [[ "$OS" == "linux" ]]; then
        for brew_path in "/home/linuxbrew/.linuxbrew/bin/brew" "/home/$(whoami)/.linuxbrew/bin/brew"; do
            if setup_brew_env "$brew_path"; then
                brew_setup_success=true
                break
            fi
        done
    fi
    
    if [[ "$brew_setup_success" == "true" ]] && command -v brew &> /dev/null; then
        echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
    else
        echo -e "${RED}✗ Homebrew installation failed or could not be found in PATH${NC}"
        echo -e "${YELLOW}Please check your installation and try again${NC}"
        exit 1
    fi
}

# Install Git (if not present)
install_git() {
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✓ Git is already installed${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Installing Git...${NC}"
    if [[ "$OS" == "macos" ]]; then
        brew install git
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        else
            brew install git
        fi
    fi
    
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✓ Git installed successfully${NC}"
    else
        echo -e "${RED}✗ Git installation failed${NC}"
        exit 1
    fi
}

# Install GNU Stow
install_stow() {
    if command -v stow &> /dev/null; then
        echo -e "${GREEN}✓ GNU Stow is already installed${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Installing GNU Stow...${NC}"
    if [[ "$OS" == "macos" ]]; then
        brew install stow
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y stow
        elif command -v yum &> /dev/null; then
            sudo yum install -y stow
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm stow
        else
            brew install stow
        fi
    fi
    
    if command -v stow &> /dev/null; then
        echo -e "${GREEN}✓ GNU Stow installed successfully${NC}"
    else
        echo -e "${RED}✗ GNU Stow installation failed${NC}"
        exit 1
    fi
}

# Main bootstrap function
main() {
    echo -e "${BLUE}Detecting operating system...${NC}"
    detect_os
    echo -e "${GREEN}✓ Detected: $OS${NC}"
    echo ""
    
    echo -e "${BLUE}Installing package managers and essential tools...${NC}"
    install_homebrew
    install_git
    install_stow
    
    echo ""
    echo -e "${GREEN}✅ Bootstrap completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: make install-deps     # Install development tools"
    echo "  2. Run: make install-core     # Install dotfiles"
    echo "  3. Run: make setup-tools      # Setup version managers"
    echo ""
}

# Check if running interactively
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi