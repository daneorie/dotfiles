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

# Dedup PATH entries
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
export TSTRUCT_TOKEN="tstruct_eyJ2ZXJzaW9uIjoxLCJkYXRhIjp7InVzZXJJRCI6MTY5NTU1OTkwMCwidXNlckVtYWlsIjoiZGFuZS5vcmllQGljbG91ZC5jb20iLCJ0ZWFtSUQiOjE2MTY3ODk4MjQsInRlYW1OYW1lIjoiZGFuZS5vcmllQGljbG91ZC5jb20ncyB0ZWFtIiwicmVuZXdhbERhdGUiOiIyMDI2LTA4LTIzVDIwOjE1OjQ4LjgwNzg4MjM3MloiLCJjcmVhdGVkQXQiOiIyMDI2LTA4LTE2VDIwOjE1OjQ4LjgwNzg4MjYwMloifSwic2lnbmF0dXJlIjoiZk55MG5wbHAvNnBDazNVeXFwUG44U1pRMHRUUDNmQjZzeWNnUW5VK2UzTk91bUMzTFY0b21LS3pEZE9vRzZVWkQyN291YzhQODRMS1VOaklIcGJaQWc9PSJ9"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/dorie/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
