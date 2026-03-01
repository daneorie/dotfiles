#!/bin/bash

# Verify Stow Packages Script
# This script verifies that stow packages are properly structured

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find stow-packages directory - handle both normal structure and Docker testing
if [[ -d "$SCRIPT_DIR/stow-packages" ]]; then
    # Docker testing environment - stow-packages is in the same directory
    STOW_DIR="$SCRIPT_DIR/stow-packages"
elif [[ -d "$(dirname "$SCRIPT_DIR")/stow-packages" ]]; then
    # Normal structure - stow-packages is in parent directory
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    STOW_DIR="$PROJECT_ROOT/stow-packages"
else
    # Last resort - check current directory
    STOW_DIR="./stow-packages"
fi

echo -e "${BLUE}Verifying Stow Package Structure${NC}"
echo ""

# Check if stow-packages directory exists
if [[ ! -d "$STOW_DIR" ]]; then
    echo -e "${RED}Error: stow-packages directory not found${NC}"
    exit 1
fi

total_packages=0
valid_packages=0

for package_dir in "$STOW_DIR"/*; do
    if [[ -d "$package_dir" ]]; then
        package_name=$(basename "$package_dir")
        total_packages=$((total_packages + 1))
        
        # Count files in package
        file_count=$(find "$package_dir" -type f | wc -l | tr -d ' ')
        
        if [[ $file_count -gt 0 ]]; then
            echo -e "${GREEN}✓${NC} $package_name ($file_count files)"
            valid_packages=$((valid_packages + 1))
            
            # Show structure for core packages
            case $package_name in
                zsh|wezterm|tmux|git|vim|yabai)
                    echo "    Files:"
                    find "$package_dir" -type f -exec basename {} \; | sort | sed 's/^/      /' | head -5
                    if [[ $file_count -gt 5 ]]; then
                        echo "      ... and $((file_count - 5)) more"
                    fi
                    ;;
            esac
        else
            echo -e "${RED}✗${NC} $package_name (empty)"
        fi
    fi
done

echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Total packages: $total_packages"
echo "  Valid packages: $valid_packages"
echo "  Empty packages: $((total_packages - valid_packages))"

if [[ $valid_packages -eq $total_packages ]]; then
    echo ""
    echo -e "${GREEN}✓ All packages are properly structured!${NC}"
    echo "Ready to use with: ./install.sh --core"
else
    echo ""
    echo -e "${YELLOW}! Some packages are empty and may need attention${NC}"
fi