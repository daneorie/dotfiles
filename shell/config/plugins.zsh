# Zsh Plugins (Antigen)

# Load antigen
source /usr/local/share/antigen/antigen.zsh

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
fpath=($HOME/dotfiles/shell/completions/ $fpath)