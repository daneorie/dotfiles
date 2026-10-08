# ~/.zshrc - Main ZSH Configuration File
# This file loads modular configuration files for better organization

ZSH_CONFIG_DIR="${HOME}/.config/shell/config"

# Load configuration modules in order of dependency
source "$ZSH_CONFIG_DIR/environment.zsh"  # Environment variables and PATH
source "$ZSH_CONFIG_DIR/keybindings.zsh"  # Shell options and keybindings
source "$ZSH_CONFIG_DIR/plugins.zsh"      # Zsh plugins (must load before prompt)
source "$ZSH_CONFIG_DIR/aliases.zsh"      # Command aliases
source "$ZSH_CONFIG_DIR/functions.zsh"    # Custom functions
source "$ZSH_CONFIG_DIR/prompt.zsh"       # Prompt configuration
source "$ZSH_CONFIG_DIR/fzf.zsh"          # FZF fuzzy finder configuration
source "$ZSH_CONFIG_DIR/mtgt.zsh"         # mtgt: environment variables, PATH, completions, aliases, and functions

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/dorie/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
