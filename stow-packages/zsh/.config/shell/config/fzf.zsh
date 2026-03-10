# FZF Configuration

# Load FZF if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF options with custom keybindings
export FZF_DEFAULT_OPTS='--bind=ctrl-e:down,ctrl-u:down,ctrl-y:up'

# Use fd instead of find for better performance
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Custom completion functions using fd
_fzf_compgen_path() {
	/usr/local/bin/fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
	/usr/local/bin/fd --type=d --hidden --exclude .git . "$1"
}

# Load FZF git integration if available
[ -f ~/fzf-git.sh/fzf-git.sh ] && source ~/fzf-git.sh/fzf-git.sh