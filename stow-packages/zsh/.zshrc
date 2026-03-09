# ~/.zshrc - Main ZSH Configuration File
# This file loads modular configuration files for better organization

# Function to get the real directory of this config file (handles symlinks)
get_config_dir() {
    local config_path="${HOME}/.zshrc"
    
    # Check if the config file is a symlink and resolve it
    if [[ -L "$config_path" ]]; then
        # Use realpath if available, otherwise readlink
        if command -v realpath >/dev/null 2>&1; then
            local real_path=$(realpath "$config_path")
        else
            local real_path=$(readlink "$config_path")
            # If it's a relative path, make it absolute
            if [[ "$real_path" != /* ]]; then
                real_path="${HOME}/${real_path}"
            fi
        fi
        # Extract directory from file path
        echo "${real_path%/*}"
    else
        # Fallback: assume it's in the dotfiles directory
        echo "${HOME}/dotfiles"
    fi
}

# Configuration directory - automatically detects real location
ZSH_CONFIG_DIR="$(get_config_dir)/shell/config"

# Load configuration modules in order of dependency
source "$ZSH_CONFIG_DIR/environment.zsh"  # Environment variables and PATH
source "$ZSH_CONFIG_DIR/keybindings.zsh"  # Shell options and keybindings
source "$ZSH_CONFIG_DIR/plugins.zsh"      # Zsh plugins (must load before prompt)
source "$ZSH_CONFIG_DIR/aliases.zsh"      # Command aliases
source "$ZSH_CONFIG_DIR/functions.zsh"    # Custom functions
source "$ZSH_CONFIG_DIR/prompt.zsh"       # Prompt configuration
source "$ZSH_CONFIG_DIR/fzf.zsh"          # FZF fuzzy finder configuration
