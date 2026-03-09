# Zsh Plugins (Antigen)
# This file should only be sourced in a Zsh shell

# Only proceed if we're in zsh
if [[ -z "$ZSH_VERSION" ]]; then
    echo "Warning: plugins.zsh should only be sourced in a Zsh shell"
    return 1
fi

# Load antigen from various possible locations
if [[ -f "$HOME/.antigen/antigen.zsh" ]]; then
    # Custom installation via setup-tools.sh
    source "$HOME/.antigen/antigen.zsh"
elif [[ -f "/opt/homebrew/share/antigen/antigen.zsh" ]]; then
    # Homebrew on Apple Silicon
    source "/opt/homebrew/share/antigen/antigen.zsh"
elif [[ -f "/usr/local/share/antigen/antigen.zsh" ]]; then
    # Homebrew on Intel Mac
    source "/usr/local/share/antigen/antigen.zsh"
elif [[ -f "/home/linuxbrew/.linuxbrew/share/antigen/antigen.zsh" ]]; then
    # Homebrew on Linux
    source "/home/linuxbrew/.linuxbrew/share/antigen/antigen.zsh"
elif command -v brew >/dev/null 2>&1; then
    # Try to find via brew if available
    brew_antigen_path="$(brew --prefix)/share/antigen/antigen.zsh"
    if [[ -f "$brew_antigen_path" ]]; then
        source "$brew_antigen_path"
    else
        echo "Warning: antigen installed via Homebrew but antigen.zsh not found at expected location"
        return 1
    fi
else
    echo "Warning: antigen.zsh not found in any expected location. Please install antigen or update the path in ~/.zshrc"
    return 1
fi

# Plugin bundles
antigen bundle kutsan/zsh-system-clipboard
antigen bundle mollifier/cd-gitroot  # type "cd-gitroot<CR>" to get to the root directory of a git repo
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle mrjohannchang/zsh-interactive-cd

# Apply all plugins
antigen apply

# Custom completions
if [[ -d "$HOME/shell/completions" ]]; then
    fpath=("$HOME/shell/completions" $fpath)
elif [[ -d "$HOME/.dotfiles/stow-packages/zsh/shell/completions" ]]; then
    fpath=("$HOME/.dotfiles/stow-packages/zsh/shell/completions" $fpath)
fi