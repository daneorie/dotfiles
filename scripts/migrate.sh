#!/bin/bash

# Dotfiles Migration Script
# This script helps migrate from manual symlinks to GNU Stow management
# Supports flexible package selection: individual packages, core, or all

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
	PROJECT_ROOT="$(dirname "$SCRIPT_DIR")" # For compatibility with existing checks
else
	# Fallback to relative path
	INSTALL_SCRIPT="./install.sh"
	PROJECT_ROOT="." # Current directory
fi

# Configuration
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
PACKAGES_DIR="$PROJECT_ROOT/stow-packages"

# Default values
INTERACTIVE_MODE=true
DRY_RUN=false
BACKUP_ONLY=false
PACKAGE_SELECTION=""

# Help message
show_help() {
	cat << EOF
Dotfiles Migration Script

Migrate from manual symlinks to GNU Stow management with flexible package selection.

Usage: $0 [OPTIONS] [PACKAGES...]

Options:
  -h, --help              Show this help message
  --core                  Migrate core packages only
  --all                   Migrate all available packages
  --dry-run               Show what would be migrated without making changes
  --backup-only           Only backup existing files, don't install packages
  --yes                   Skip confirmation prompts (non-interactive mode)

Package Selection:
  If no options are specified, runs in interactive mode.
  
  Individual packages:    $0 zsh git tmux
  Core packages:          $0 --core
  All packages:           $0 --all
  Custom with core:       $0 --core nvim yabai
  
Examples:
  $0                      # Interactive mode
  $0 --core               # Migrate core packages  
  $0 --all                # Migrate all packages
  $0 zsh git tmux         # Migrate specific packages
  $0 --core --dry-run     # Preview core migration
  $0 --backup-only        # Just backup, no installation
  $0 --all --yes          # Migrate all without prompts

The script will:
1. Backup existing dotfiles to ~/.dotfiles-backup-TIMESTAMP
2. Install selected packages using GNU Stow
3. Create clean symlinks from package configurations

Backup directory: $BACKUP_DIR
EOF
}

# Parse command line arguments
parse_args() {
	local packages=()
	
	while [[ $# -gt 0 ]]; do
		case $1 in
			-h|--help)
				show_help
				exit 0
				;;
			--core)
				PACKAGE_SELECTION="core"
				INTERACTIVE_MODE=false
				shift
				;;
			--all)
				PACKAGE_SELECTION="all"
				INTERACTIVE_MODE=false
				shift
				;;
			--dry-run)
				DRY_RUN=true
				shift
				;;
			--backup-only)
				BACKUP_ONLY=true
				shift
				;;
			--yes)
				INTERACTIVE_MODE=false
				shift
				;;
			-*)
				echo "Error: Unknown option $1" >&2
				echo "Use --help for usage information." >&2
				exit 1
				;;
			*)
				packages+=("$1")
				shift
				;;
		esac
	done
	
	# Handle package specification
	if [[ ${#packages[@]} -gt 0 ]]; then
		if [[ -n "$PACKAGE_SELECTION" ]]; then
			# Combine core/all with additional packages
			if [[ "$PACKAGE_SELECTION" == "core" ]]; then
				PACKAGE_SELECTION="core,$(IFS=,; echo "${packages[*]}")"
			else
				PACKAGE_SELECTION="all,$(IFS=,; echo "${packages[*]}")"
			fi
		else
			# Just the specified packages
			PACKAGE_SELECTION="$(IFS=,; echo "${packages[*]}")"
		fi
		INTERACTIVE_MODE=false
	fi
}

# Get available packages
get_available_packages() {
	if [[ ! -d "$PACKAGES_DIR" ]]; then
		echo "Error: Package directory not found: $PACKAGES_DIR" >&2
		exit 1
	fi
	
	find "$PACKAGES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

# Get core packages
get_core_packages() {
	echo "zsh wezterm tmux git vim nvim yabai"
}

# Resolve package list based on selection
resolve_packages() {
	local selection="$1"
	local resolved_packages=()
	
	if [[ -z "$selection" ]]; then
		echo ""
		return
	fi
	
	# Split by commas and process each item
	IFS=',' read -ra ITEMS <<< "$selection"
	for item in "${ITEMS[@]}"; do
		item=$(echo "$item" | xargs) # trim whitespace
		
		case "$item" in
			"core")
				resolved_packages+=($(get_core_packages))
				;;
			"all")
				resolved_packages+=($(get_available_packages))
				;;
			*)
				# Validate package exists
				if [[ -d "$PACKAGES_DIR/$item" ]]; then
					resolved_packages+=("$item")
				else
					echo "Warning: Package '$item' not found, skipping" >&2
				fi
				;;
		esac
	done
	
	# Remove duplicates and sort
	printf '%s\n' "${resolved_packages[@]}" | sort -u | tr '\n' ' '
}

# Get all files and directories from specified packages that might conflict
get_package_files() {
	local packages="$1"
	local all_files=()
	
	if [[ -z "$packages" ]]; then
		return
	fi
	
	for package in $packages; do
		if [[ -d "$PACKAGES_DIR/$package" ]]; then
			# Find all files that stow will create
			while IFS= read -r -d '' file; do
				local relative_path="${file#$PACKAGES_DIR/$package/}"
				if [[ "$relative_path" != "$file" && "$relative_path" != "." ]]; then
					all_files+=("$relative_path")
				fi
			done < <(find "$PACKAGES_DIR/$package" -type f -print0)
			
			# Find directories that would conflict - only leaf directories that stow will link
			# For yazi case: .config/yazi (not .config itself since stow can descend into existing dirs)
			while IFS= read -r -d '' dir; do
				local relative_path="${dir#$PACKAGES_DIR/$package/}"
				if [[ "$relative_path" != "$dir" && "$relative_path" != "." ]]; then
					# Check if this directory would be linked by stow (contains files or no subdirs)
					local full_dir="$PACKAGES_DIR/$package/$relative_path"
					if [[ -n "$(find "$full_dir" -maxdepth 1 -type f 2>/dev/null)" ]] || \
					   [[ -z "$(find "$full_dir" -mindepth 1 -type d 2>/dev/null)" ]]; then
						# This directory contains files or has no subdirs, stow will try to link it
						local target="$HOME/$relative_path"
						if [[ -e "$target" || -L "$target" ]]; then
							all_files+=("$relative_path")
						fi
					fi
				fi
			done < <(find "$PACKAGES_DIR/$package" -type d -print0)
		fi
	done
	
	# Remove duplicates and sort
	printf '%s\n' "${all_files[@]}" | sort -u
}

# Check if a symlink points to old dotfiles structure
is_old_dotfiles_symlink() {
	local target="$1"
	
	if [[ -L "$target" ]]; then
		local link_target=$(readlink "$target")
		# Check if it points to old dotfiles structure (not stow-packages)
		if [[ "$link_target" == */dotfiles/* && "$link_target" != */stow-packages/* ]]; then
			return 0
		fi
	fi
	return 1
}

# Function to backup and remove existing files/symlinks
backup_existing() {
	local file="$1"
	local target="$HOME/$file"

	if [[ -e "$target" || -L "$target" ]]; then
		if [[ "$DRY_RUN" == "true" ]]; then
			if is_old_dotfiles_symlink "$target"; then
				echo "Would remove conflicting old dotfiles symlink: $file"
			else
				echo "Would backup: $file"
			fi
		else
			# Check if this is an old dotfiles symlink that conflicts with stow
			if is_old_dotfiles_symlink "$target"; then
				echo -e "${YELLOW}Removing conflicting old dotfiles symlink: $file${NC}"
				local link_target=$(readlink "$target")
				echo -e "${BLUE}  Old symlink pointed to: $link_target${NC}"
				
				# If the old symlink target contains actual files, back them up
				if [[ -d "$link_target" ]] && [[ -n "$(ls -A "$link_target" 2>/dev/null)" ]]; then
					echo -e "${YELLOW}  Backing up files from old location: $link_target${NC}"
					mkdir -p "$BACKUP_DIR/$(dirname "$file")"
					cp -r "$link_target" "$BACKUP_DIR/$file-old-location"
				fi
				
				# Remove the conflicting symlink
				rm "$target"
			else
				echo -e "${YELLOW}Backing up existing: $file${NC}"

				# Create backup directory if it doesn't exist
				mkdir -p "$BACKUP_DIR/$(dirname "$file")"

				# Move the existing file/symlink to backup
				mv "$target" "$BACKUP_DIR/$file"
			fi
		fi
		return 0
	fi
	return 1
}

# Interactive mode options
show_interactive_options() {
	echo "Migration options:"
	echo "1. Migrate core packages (${BLUE}zsh, wezterm, tmux, git, vim, nvim, yabai${NC})"
	echo "2. Migrate all packages"
	echo "3. Choose specific packages"
	echo "4. Show what files would be backed up (dry run)"
	echo "5. Just backup existing files (no stow installation)"
	echo "6. Cancel"
	echo ""
}

# Get user choice for interactive mode
get_user_choice() {
	local user_choice
	while true; do
		echo -n "Choose an option (1-6): " >&2
		if read user_choice; then
			case $user_choice in
				1|2|3|4|5|6) 
					echo "$user_choice"
					return 0
					;;
				*) echo "Invalid option. Please choose 1-6." >&2 ;;
			esac
		else
			echo "" >&2
			echo "Input terminated. Exiting." >&2
			exit 1
		fi
	done
}

# Interactive package selection
select_packages_interactive() {
	echo "Available packages:"
	local packages=($(get_available_packages))
	local i=1
	
	for package in "${packages[@]}"; do
		echo "  $i. $package"
		((i++))
	done
	echo ""
	
	echo "Enter package numbers (space-separated, e.g., '1 3 5') or package names (e.g., 'zsh git tmux'):"
	read -r selection
	
	local selected_packages=()
	
	# Check if input contains numbers or names
	if [[ "$selection" =~ ^[0-9[:space:]]+$ ]]; then
		# Numbers provided
		for num in $selection; do
			if [[ $num -ge 1 && $num -le ${#packages[@]} ]]; then
				selected_packages+=("${packages[$((num-1))]}")
			else
				echo "Warning: Invalid package number: $num" >&2
			fi
		done
	else
		# Package names provided
		for package in $selection; do
			if [[ -d "$PACKAGES_DIR/$package" ]]; then
				selected_packages+=("$package")
			else
				echo "Warning: Package '$package' not found" >&2
			fi
		done
	fi
	
	echo "${selected_packages[*]}"
}

# Perform backup and migration
perform_migration() {
	local packages="$1"
	local backup_count=0
	
	if [[ -z "$packages" ]]; then
		echo -e "${YELLOW}No packages specified for migration${NC}"
		return
	fi
	
	echo -e "${BLUE}Processing packages: ${YELLOW}$packages${NC}"
	echo ""
	
	# Get all files from the packages
	local files=($(get_package_files "$packages"))
	
	if [[ ${#files[@]} -eq 0 ]]; then
		echo -e "${YELLOW}No files found in specified packages${NC}"
		return
	fi
	
	echo -e "${BLUE}Backing up existing files...${NC}"
	
	for file in "${files[@]}"; do
		if backup_existing "$file"; then
			backup_count=$((backup_count + 1))
		fi
	done
	
	if [[ "$DRY_RUN" == "true" ]]; then
		echo ""
		echo -e "${BLUE}Would backup $backup_count files to: ${YELLOW}$BACKUP_DIR${NC}"
		echo -e "${BLUE}Would install packages: ${YELLOW}$packages${NC}"
	else
		echo ""
		if [[ $backup_count -gt 0 ]]; then
			echo -e "${GREEN}✓ Backed up $backup_count files to: $BACKUP_DIR${NC}"
		else
			echo -e "${YELLOW}No files needed backing up${NC}"
		fi
		
		if [[ "$BACKUP_ONLY" == "false" ]]; then
			echo ""
			echo -e "${BLUE}Installing packages with stow...${NC}"
			cd "$PROJECT_ROOT"
			
			# Convert space-separated to individual installs
			for package in $packages; do
				echo "Installing package: $package"
				"$INSTALL_SCRIPT" "$package"
			done
		fi
	fi
}

# Interactive mode handler
run_interactive() {
	show_interactive_options
	choice=$(get_user_choice)
	
	case $choice in
		1)
			echo -e "${BLUE}Migrating core packages...${NC}"
			perform_migration "$(get_core_packages)"
			;;
		2)
			echo -e "${BLUE}Migrating all packages...${NC}"
			perform_migration "$(get_available_packages | tr '\n' ' ')"
			;;
		3)
			echo -e "${BLUE}Select packages to migrate...${NC}"
			selected=$(select_packages_interactive)
			if [[ -n "$selected" ]]; then
				echo -e "${BLUE}Migrating selected packages...${NC}"
				perform_migration "$selected"
			else
				echo -e "${YELLOW}No packages selected${NC}"
				exit 0
			fi
			;;
		4)
			echo -e "${BLUE}Dry run - showing what would be migrated...${NC}"
			DRY_RUN=true
			perform_migration "$(get_core_packages)"
			;;
		5)
			echo -e "${BLUE}Backing up existing files only...${NC}"
			BACKUP_ONLY=true
			perform_migration "$(get_core_packages)"
			;;
		6)
			echo -e "${YELLOW}Migration cancelled${NC}"
			exit 0
			;;
	esac
}

# Show completion summary
show_completion() {
	if [[ "$DRY_RUN" == "true" ]]; then
		echo ""
		echo -e "${BLUE}Dry run completed. Use --yes to perform the actual migration.${NC}"
		return
	fi
	
	echo ""
	echo -e "${GREEN}✓ Migration completed successfully!${NC}"
	echo ""
	
	if [[ "$BACKUP_ONLY" == "false" ]]; then
		echo "Your dotfiles are now managed by GNU Stow!"
		echo ""
		echo "Useful commands:"
		echo "  $INSTALL_SCRIPT --list                 # List all packages"
		echo "  $INSTALL_SCRIPT --unstow <package>     # Remove a package"
		echo "  $INSTALL_SCRIPT <package>              # Install a specific package"
		echo "  make list                              # List packages (if using Make)"
		echo "  make install PACKAGES=\"pkg1 pkg2\"     # Install multiple packages"
	else
		echo "Files have been backed up. To install packages, run:"
		echo "  $INSTALL_SCRIPT --core                 # Install core packages"
		echo "  $INSTALL_SCRIPT --all                  # Install all packages"
		echo "  $INSTALL_SCRIPT pkg1 pkg2              # Install specific packages"
	fi
	
	echo ""
	echo "Your original files have been backed up to:"
	echo "  $BACKUP_DIR"
}

# Check prerequisites
check_prerequisites() {
	# Check if we're in the right directory and install script exists
	if [[ ! -f "$INSTALL_SCRIPT" ]]; then
		echo -e "${RED}Error: install.sh not found at $INSTALL_SCRIPT${NC}" >&2
		echo "Please run this script from the dotfiles directory or ensure the project structure is correct." >&2
		exit 1
	fi

	# Check if stow is available
	if ! command -v stow &>/dev/null; then
		echo -e "${RED}Error: GNU Stow is not installed${NC}" >&2
		echo "Install it with: brew install stow" >&2
		exit 1
	fi
	
	# Check if packages directory exists
	if [[ ! -d "$PACKAGES_DIR" ]]; then
		echo -e "${RED}Error: Packages directory not found: $PACKAGES_DIR${NC}" >&2
		exit 1
	fi
}

# Main function
main() {
	# Parse arguments
	parse_args "$@"
	
	# Check prerequisites
	check_prerequisites
	
	# Show banner
	echo -e "${BLUE}Dotfiles Migration to GNU Stow${NC}"
	echo "This script will help you migrate from manual symlinks to GNU Stow management."
	echo ""
	
	if [[ "$INTERACTIVE_MODE" == "true" ]]; then
		# Interactive mode
		run_interactive
	else
		# Non-interactive mode with specific packages
		packages=$(resolve_packages "$PACKAGE_SELECTION")
		
		if [[ -z "$packages" ]]; then
			echo -e "${YELLOW}No valid packages specified${NC}"
			exit 1
		fi
		
		# Show what will be migrated
		echo "Migration plan:"
		echo "  Packages: $packages"
		echo "  Backup directory: $BACKUP_DIR"
		[[ "$DRY_RUN" == "true" ]] && echo "  Mode: Dry run (no changes will be made)"
		[[ "$BACKUP_ONLY" == "true" ]] && echo "  Mode: Backup only (no installation)"
		echo ""
		
		# Confirm unless --yes was specified
		if [[ "$INTERACTIVE_MODE" == "true" ]]; then
			read -p "Continue? [y/N] " -n 1 -r
			echo
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				echo -e "${YELLOW}Migration cancelled${NC}"
				exit 0
			fi
			echo
		fi
		
		perform_migration "$packages"
	fi
	
	show_completion
}

# Run main function
main "$@"