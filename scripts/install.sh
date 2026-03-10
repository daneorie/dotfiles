#!/bin/bash

# Dotfiles Stow Installation Script
# This script uses GNU Stow to create symlinks for dotfile configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find stow-packages directory - handle both normal structure and Docker testing
# First, try to resolve all paths to absolute paths to avoid stow issues
if [[ -d "$SCRIPT_DIR/stow-packages" ]]; then
    # Docker testing environment - stow-packages is in the same directory
    STOW_DIR="$(cd "$SCRIPT_DIR/stow-packages" && pwd)"
elif [[ -d "$(dirname "$SCRIPT_DIR")/stow-packages" ]]; then
    # Normal structure - stow-packages is in parent directory
    PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"
    STOW_DIR="$PROJECT_ROOT/stow-packages"
else
    # Last resort - check current directory and make it absolute
    if [[ -d "./stow-packages" ]]; then
        STOW_DIR="$(cd "./stow-packages" && pwd)"
    else
        # Try one more approach - look for stow-packages relative to where we think we are
        if [[ -d "../stow-packages" ]]; then
            STOW_DIR="$(cd "../stow-packages" && pwd)"
        else
            echo "ERROR: Cannot find stow-packages directory"
            echo "Looked in:"
            echo "  $SCRIPT_DIR/stow-packages"
            echo "  $(dirname "$SCRIPT_DIR")/stow-packages"
            echo "  ./stow-packages"
            echo "  ../stow-packages"
            exit 1
        fi
    fi
fi

# Check if stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        echo -e "${RED}Error: GNU Stow is not installed${NC}"
        echo "Install it with:"
        echo "  macOS: brew install stow"
        echo "  Ubuntu/Debian: sudo apt install stow"
        echo "  Arch: sudo pacman -S stow"
        exit 1
    fi
}

# Available packages
CORE_PACKAGES=(
    "zsh"
    "wezterm"
    "tmux"
    "git"
    "vim"
    "nvim"
    "yabai"
)

GUI_PACKAGES=(
    "alacritty"
    "kitty"
    "hammerspoon"
    "karabiner"
    "aerospace"
    "sketchybar"
    "yazi"
    "gitui"
    "lazygit"
    "borders"
    "ubersicht"
    "nvimpager"
)

OTHER_PACKAGES=(
    "scripts"
)

ALL_PACKAGES=("${CORE_PACKAGES[@]}" "${GUI_PACKAGES[@]}" "${OTHER_PACKAGES[@]}")

# Print usage
usage() {
    echo "Usage: $0 [OPTIONS] [PACKAGES...]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List all available packages"
    echo "  -c, --core     Install core packages only"
    echo "  -a, --all      Install all packages"
    echo "  -u, --unstow   Remove (unstow) packages instead of installing"
    echo "  -d, --dry-run  Show what would be done without making changes"
    echo "  -f, --force    Overwrite existing files (use with caution)"
    echo ""
    echo "Examples:"
    echo "  $0 --core                    # Install core packages"
    echo "  $0 --all                     # Install all packages"
    echo "  $0 zsh tmux git              # Install specific packages"
    echo "  $0 --unstow zsh              # Remove zsh package"
    echo "  $0 --dry-run --all           # Preview all package installations"
    echo "  $0 --force --all             # Install all packages, overwriting conflicts"
}

# List available packages
list_packages() {
    echo -e "${BLUE}Available Packages:${NC}"
    echo ""
    echo -e "${YELLOW}Core Packages:${NC}"
    printf '  %s\n' "${CORE_PACKAGES[@]}"
    echo ""
    echo -e "${YELLOW}GUI Applications:${NC}"
    printf '  %s\n' "${GUI_PACKAGES[@]}"
    echo ""
    echo -e "${YELLOW}Other:${NC}"
    printf '  %s\n' "${OTHER_PACKAGES[@]}"
}

# Convert relative symlinks to absolute
convert_to_absolute_symlinks() {
    local package="$1"
    
    echo -e "${BLUE}Converting relative symlinks to absolute for package: $package${NC}"
    
    # Find symlinks in home directory (limit to reasonable depth to avoid system dirs)
    find "$HOME" -maxdepth 3 -type l 2>/dev/null | while IFS= read -r symlink; do
        # Skip if this is a backup directory symlink
        if [[ "$symlink" == *"/.dotfiles-backup-"* ]]; then
            continue
        fi
        
        target=$(readlink "$symlink")
        
        # Check if this symlink points to our stow package (relative path patterns)
        if [[ "$target" == *"stow-packages/$package"* ]] || \
           [[ "$target" == *"dotfiles/stow-packages/$package"* ]] || \
           [[ "$target" == "../dotfiles/stow-packages/$package"* ]]; then
            
            # Get the absolute path of the current target
            symlink_dir=$(dirname "$symlink")
            if absolute_target=$(cd "$symlink_dir" && readlink -f "$symlink" 2>/dev/null); then
                # Only update if the absolute path exists and is different from current
                if [[ -e "$absolute_target" && "$target" != "$absolute_target" ]]; then
                    echo "  Converting: $symlink -> $absolute_target"
                    rm -f "$symlink"
                    ln -sf "$absolute_target" "$symlink"
                fi
            fi
        fi
    done
}

# Clean up any potential stow conflicts
cleanup_stow_conflicts() {
    local package="$1"
    echo -e "${YELLOW}Cleaning up potential stow conflicts for package: $package${NC}"
    
    # Remove any broken symlinks that might interfere
    find "$HOME" -maxdepth 2 -type l -exec test ! -e {} \; -delete 2>/dev/null || true
    
    # Handle .config directory specially - this is the main source of conflicts
    if [[ -e "$HOME/.config" ]]; then
        if [[ -L "$HOME/.config" ]]; then
            echo -e "${YELLOW}Found existing .config symlink, removing it to prevent conflicts${NC}"
            local old_target=$(readlink "$HOME/.config")
            echo -e "${BLUE}  Old .config pointed to: $old_target${NC}"
            rm "$HOME/.config"
            
            # If the old target had actual content, back it up
            if [[ -d "$old_target" && -n "$(ls -A "$old_target" 2>/dev/null)" ]]; then
                echo -e "${YELLOW}  Backing up content from old .config location${NC}"
                local backup_timestamp
                backup_timestamp=$(date +%s)
                mkdir -p "$HOME/.dotfiles-emergency-backup-${backup_timestamp}"
                cp -r "$old_target" "$HOME/.dotfiles-emergency-backup-${backup_timestamp}/.config-from-$(basename "$(dirname "$old_target")")"
            fi
        elif [[ -d "$HOME/.config" ]]; then
            # Check if this package would create .config as a TOP-LEVEL symlink
            # Only move existing .config if package has .config with no subdirectories
            # (which indicates it's trying to own the entire .config directory)
            if [[ -d "$STOW_DIR/$package/.config" ]]; then
                # Check if package .config has content (subdirectories or files)
                local config_subdirs=$(find "$STOW_DIR/$package/.config" -maxdepth 1 -type d | wc -l)
                local config_files=$(find "$STOW_DIR/$package/.config" -maxdepth 1 -type f | wc -l)
                
                if [[ $config_subdirs -le 1 && $config_files -eq 0 ]]; then
                    # Package .config is empty - dangerous, would create symlink to empty directory
                    echo -e "${YELLOW}Package $package has empty .config directory - this would overwrite existing .config${NC}"
                    echo -e "${YELLOW}Moving existing .config to backup${NC}"
                    mkdir -p "$HOME/.dotfiles-emergency-backup-$(date +%s)"
                    mv "$HOME/.config" "$HOME/.dotfiles-emergency-backup-$(date +%s)/.config"
                else
                    # Package .config has content (subdirectories or files) - safe to merge
                    if [[ $config_subdirs -gt 1 ]]; then
                        echo -e "${BLUE}Package $package will merge subdirectories with existing .config directory${NC}"
                    else
                        echo -e "${BLUE}Package $package will merge files with existing .config directory${NC}"
                    fi
                fi
            fi
        fi
    fi
}

# Stow a package
stow_package() {
    local package="$1"
    local action="$2"  # "stow" or "unstow"
    local dry_run="$3" # "true" or "false"
    local force="$4"   # "true" or "false"
    
    if [ ! -d "$STOW_DIR/$package" ]; then
        echo -e "${RED}Error: Package '$package' not found${NC}"
        return 1
    fi
    
    local stow_cmd="stow"
    local action_text="Installing"
    local past_text="installed"
    
    if [ "$action" = "unstow" ]; then
        stow_cmd="stow -D"
        action_text="Removing"
        past_text="removed"
    fi
    
    if [ "$dry_run" = "true" ]; then
        stow_cmd="$stow_cmd -n"
        action_text="Would $action_text"
        past_text="would be $past_text"
    fi
    
    # Add force flag for adopting existing files
    if [ "$force" = "true" ] && [ "$action" = "stow" ]; then
        stow_cmd="$stow_cmd --adopt"
        action_text="$action_text (adopting existing files)"
    fi
    
    echo -e "${BLUE}$action_text package: $package${NC}"
    
    # Clean up any potential conflicts first
    cleanup_stow_conflicts "$package"
    
    # Ensure STOW_DIR is absolutely absolute by resolving it one more time
    local ABSOLUTE_STOW_DIR
    if [[ "$STOW_DIR" = /* ]]; then
        # Already absolute
        ABSOLUTE_STOW_DIR="$STOW_DIR"
    else
        # Make it absolute relative to current directory
        ABSOLUTE_STOW_DIR="$(cd "$STOW_DIR" && pwd)"
    fi
    
    # Use parent directory approach to avoid path resolution issues
    local STOW_PARENT_DIR=$(dirname "$ABSOLUTE_STOW_DIR")
    local STOW_DIR_NAME=$(basename "$ABSOLUTE_STOW_DIR")
    
    # Use the parent directory approach
    local stow_success=false
    if (cd "$STOW_PARENT_DIR" && $stow_cmd -d "$STOW_DIR_NAME" -t "$HOME" "$package") 2>&1; then
        stow_success=true
    fi
    
    if [ "$stow_success" = true ]; then
        if [ "$dry_run" = "false" ] && [ "$action" = "stow" ]; then
            echo -e "${GREEN}✓ Package '$package' $past_text successfully${NC}"
            convert_to_absolute_symlinks "$package"
        elif [ "$dry_run" = "false" ]; then
            echo -e "${GREEN}✓ Package '$package' $past_text successfully${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to $action package '$package'${NC}"
        return 1
    fi
}

# Main function
main() {
    check_stow
    
    local packages=()
    local action="stow"
    local dry_run="false"
    local force="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -l|--list)
                list_packages
                exit 0
                ;;
            -c|--core)
                packages=("${CORE_PACKAGES[@]}")
                shift
                ;;
            -a|--all)
                packages=("${ALL_PACKAGES[@]}")
                shift
                ;;
            -u|--unstow)
                action="unstow"
                shift
                ;;
            -d|--dry-run)
                dry_run="true"
                shift
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            -*)
                echo -e "${RED}Error: Unknown option $1${NC}"
                usage
                exit 1
                ;;
            *)
                packages+=("$1")
                shift
                ;;
        esac
    done
    
    # If no packages specified, show help
    if [ ${#packages[@]} -eq 0 ]; then
        echo -e "${YELLOW}No packages specified${NC}"
        usage
        exit 1
    fi
    
    echo -e "${BLUE}Dotfiles Stow Management${NC}"
    echo "Target directory: $HOME"
    echo "Stow directory: $STOW_DIR"
    echo ""
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi
    
    if [ "$force" = "true" ]; then
        echo -e "${YELLOW}FORCE MODE - Existing files will be adopted by stow${NC}"
        echo ""
    fi
    
    # Process each package
    local failed=0
    for package in "${packages[@]}"; do
        if ! stow_package "$package" "$action" "$dry_run" "$force"; then
            failed=$((failed + 1))
        fi
    done
    
    echo ""
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✓ All packages processed successfully!${NC}"
    else
        echo -e "${RED}✗ $failed package(s) failed to process${NC}"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
