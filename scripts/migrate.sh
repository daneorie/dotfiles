#!/bin/bash

# Dotfiles Migration Script
# This script helps migrate from manual symlinks to GNU Stow management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find install.sh - handle both normal structure and Docker testing
if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
    # Scripts are in the same directory (Docker testing or scripts/ directory)
    INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"  # For compatibility with existing checks
else
    # Fallback to relative path
    INSTALL_SCRIPT="./install.sh"
    PROJECT_ROOT="."  # Current directory
fi

echo -e "${BLUE}Dotfiles Migration to GNU Stow${NC}"
echo "This script will help you migrate from manual symlinks to GNU Stow management."
echo ""

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Function to backup and remove existing files/symlinks
backup_existing() {
    local file="$1"
    local target="$HOME/$file"
    
    if [[ -e "$target" || -L "$target" ]]; then
        echo -e "${YELLOW}Backing up existing: $file${NC}"
        
        # Create backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        
        # Move the existing file/symlink to backup
        mv "$target" "$BACKUP_DIR/$file"
        return 0
    fi
    return 1
}

# Files that need to be backed up for core packages
CORE_FILES=(
    # ZSH package
    ".zshrc"
    "shell/config/aliases.zsh"
    "shell/config/environment.zsh" 
    "shell/config/functions.zsh"
    "shell/config/fzf.zsh"
    "shell/config/keybindings.zsh"
    "shell/config/plugins.zsh"
    "shell/config/prompt.zsh"
    "shell/scripts/cht.sh"
    "shell/completions/_cht"
    
    # WezTerm package
    ".wezterm.lua"
    "wezterm/appearance.lua"
    "wezterm/events.lua"
    "wezterm/key_tables.lua"
    "wezterm/keybindings.lua"
    "wezterm/neovim.lua"
    "wezterm/utils.lua"
    "wezterm/workspace.lua"
    
    # Tmux package
    ".tmux.conf"
    
    # Git package
    ".gitattributes"
    ".gitconfig"
    ".gitignore"
    
    # Vim package
    ".exrc"
    ".inputrc"
    ".lesskey"
    ".nvim/session"
    ".vimrc"
    
    # Nvim package
    ".config/nvim"
    
    # Yabai package
    ".skhdrc"
    ".yabairc"
    ".yabairc.old"
)

# Function to show migration options
show_options() {
    echo "Migration options:"
    echo "1. Backup existing files and install core packages"
    echo "2. Backup existing files and install all packages"
    echo "3. Show what files would be backed up (dry run)"
    echo "4. Just backup existing files (no stow installation)"
    echo "5. Cancel"
    echo ""
}

# Get user choice
get_user_choice() {
    while true; do
        read -p "Choose an option (1-5): " choice
        case $choice in
            1|2|3|4|5) return $choice ;;
            *) echo "Invalid option. Please choose 1-5." ;;
        esac
    done
}

# Perform backup
perform_backup() {
    local dry_run="$1"
    local backup_count=0
    
    echo -e "${BLUE}Processing core package files...${NC}"
    
    for file in "${CORE_FILES[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            if [[ -e "$HOME/$file" || -L "$HOME/$file" ]]; then
                echo "Would backup: $file"
                backup_count=$((backup_count + 1))
            fi
        else
            if backup_existing "$file"; then
                backup_count=$((backup_count + 1))
            fi
        fi
    done
    
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo "Would backup $backup_count files to: $BACKUP_DIR"
    else
        echo ""
        if [[ $backup_count -gt 0 ]]; then
            echo -e "${GREEN}✓ Backed up $backup_count files to: $BACKUP_DIR${NC}"
        else
            echo -e "${YELLOW}No files needed backing up${NC}"
        fi
    fi
}

# Main function
main() {
    show_options
    get_user_choice
    choice=$?
    
    case $choice in
        1)
            echo -e "${BLUE}Backing up existing files and installing core packages...${NC}"
            perform_backup "false"
            echo ""
            echo -e "${BLUE}Installing core packages with stow...${NC}"
            cd "$PROJECT_ROOT" && ./scripts/install.sh --core
            ;;
        2)
            echo -e "${BLUE}Backing up existing files and installing all packages...${NC}"
            perform_backup "false"
            echo ""
            echo -e "${BLUE}Installing all packages with stow...${NC}"
            cd "$PROJECT_ROOT" && ./scripts/install.sh --all
            ;;
        3)
            echo -e "${BLUE}Dry run - showing what would be backed up...${NC}"
            perform_backup "true"
            ;;
        4)
            echo -e "${BLUE}Backing up existing files only...${NC}"
            perform_backup "false"
            echo ""
            echo -e "${YELLOW}Files backed up. Run './scripts/install.sh --core' or './scripts/install.sh --all' when ready to install with stow.${NC}"
            ;;
        5)
            echo -e "${YELLOW}Migration cancelled${NC}"
            exit 0
            ;;
    esac
    
    if [[ $choice -eq 1 || $choice -eq 2 ]]; then
        echo ""
        echo -e "${GREEN}✓ Migration completed successfully!${NC}"
        echo ""
        echo "Your original files have been backed up to:"
        echo "  $BACKUP_DIR"
        echo ""
        echo "Your dotfiles are now managed by GNU Stow!"
        echo ""
        echo "Useful commands:"
        echo "  ./scripts/install.sh --list                 # List all packages"
        echo "  ./scripts/install.sh --unstow <package>     # Remove a package" 
        echo "  ./scripts/install.sh <package>              # Install a specific package"
    fi
}

# Check if we're in the right directory and install script exists
if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    echo -e "${RED}Error: install.sh not found at $INSTALL_SCRIPT. Please run this script from the dotfiles directory or ensure the project structure is correct.${NC}"
    exit 1
fi

# Check if stow is available
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU Stow is not installed${NC}"
    echo "Install it with: brew install stow"
    exit 1
fi

# Run main function
main