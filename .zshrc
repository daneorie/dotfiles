export NVIM_HOME=~/.config/nvim
export MAVEN_HOME=~/apache-maven-3.8.1
export WIKI_HOME=~/wiki
export XDG_CONFIG_HOME="$HOME/.config"

if [[ -n "/usr/local/bin/brew" ]]; then
	export PATH="$PATH:/opt/homebrew/bin"
fi

# Add any new paths to this list
paths_to_add=(
	"/usr/local/sbin"
	"$MAVEN_HOME/bin"
	"$HOME/.jenv/bin"
	"$HOME/Library/Python/3.11/bin"
)
# Add paths to PATH if they don't already exist
for path_to_add in "${paths_to_add[@]}"; do
	if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
		export PATH="$PATH:$path_to_add"
	fi
done

if [[ -e "~/.keys" ]]; then
	. ~/.keys
fi

# C1 vars and functions
export BA=BACoolTeam
export ASV=ASVCOOLTEAM
export AWS_DEV=0123456789
export AWS_QA=9876543210
export AWS_PROFILE_DEV=GR_GG_COF_AWS_${AWS_DEV}_Developer
export AWS_PROFILE_QA=GR_GG_COF_AWS_${AWS_QA}_Developer
export AWS_PROFILE=${AWS_PROFILE_DEV}
function awsCredentials {
	cloudsentry access get --account ${1:-$AWS_PROFILE} --ba ${2:-$BA}
}

# When typing '#' in normal/vicmd mode, append a '#' at the beginning of the line and return.
# This stops the current line from running but keeps it in the history.
setopt interactivecomments

# When in normal/vicmd mode, typing <C-v> will enter the current line into a nvim buffer for editing.
# Save and quit the buffer to output the line back to the terminal.
export EDITOR=nvim
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^v' edit-command-line

export PAGER=nvimpager
export LESSKEY=~/.lesskey
alias l='ls -lH'
alias la='ls -a'
alias ll='l'
alias lla='l -a'
alias lld='l -d'
alias v='nvim'
alias v.='nvim .'
alias vi='nvim'
alias vim='nvim'
alias cdu='cd-gitroot'
alias less="$(brew --prefix)/Cellar/less/590/bin/less"
alias excel="open -a /Applications/Microsoft\ Excel.app"
alias refresh="exec $SHELL -l"
alias wiki="nvim $WIKI_HOME/index.md"

# `define` but remove the last 4 lines
define() {
	/usr/local/bin/define $* | grep -n "." | sort -nr | sed '1,4d' | sort -n | sed 's/^[0-9]*://' | $PAGER
}

c() {
    $HOME/dotfiles/shell/scripts/cht.sh "$@" | $PAGER
}

# git aliases
alias g='git'
alias gu='gitui'
alias ga='git aliases'
alias refreshGithub='ssh -T git@github.com'
function gc {
	git clone git@github.com:ORG/backend.git "$1" && cd "$1" && git checkout "$1"
}
function mergeMain {
	cd ../main && git pull && git merge main && npm run install:all
}

# yabai aliases
alias yaq='yabai -m query'
alias yqd='yaq --displays'
alias yqs='yaq --spaces'
alias yqw='yaq --windows'
alias yqdw='yqd --window'
alias yqds='yqd --space'
alias yqdd='yqd --display'
alias yqsw='yqs --window'
alias yqss='yqs --space'
alias yqsd='yqs --display'
alias yqww='yqw --window'
alias yqws='yqw --space'
alias yqwd='yqw --display'

function reverseOrder {
	grep -n "" | sort -rn | sed 's/^[0-9]*://'
}

function readresponse {
	gunzip -c | jq
}

function readbody {
	read body
	if [[ -n "$body" ]]; then
		echo "$body" | base64 --decode | gunzip -c | jq
	else
		echo "$1" | base64 --decode | gunzip -c | jq
	fi
}

function urldecode {
	read url
	if [[ -n "$url" ]]; then
		echo "$url" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	else
		echo "$1" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	fi
}

function rmpwd {
	dir="$(pwd)"
	cd ..
	rm -rf "$dir"
}

export KEYTIMEOUT=1 # this lowers the time it takes to switch from viins to vicmd and vice versa
eval "$(jenv init -)"
eval "$(rbenv init - zsh)"

# Plugins (Antigen)
source /usr/local/share/antigen/antigen.zsh

antigen bundle kutsan/zsh-system-clipboard
antigen bundle mollifier/cd-gitroot # type "cd-gitroot<CR>" to get to the root directory of a git repo; aliased above
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle mrjohannchang/zsh-interactive-cd

antigen apply

# Use vi modes in command line and change keybindings for Colemak
#   Here's the circle of mappings: n -> h -> i -> k -> o -> l -> e -> j -> n
#   Use this circle to determine the original mappings. (I used the reverse to generate the below mappings.)
bindkey -v
bindkey -M vicmd "h" vi-insert
bindkey -M vicmd "j" vi-repeat-search
bindkey -M vicmd "k" vi-open-line-below
bindkey -M vicmd "l" vi-forward-word-end
bindkey -M vicmd "n" vi-backward-char
bindkey -M vicmd "e" down-line-or-history
bindkey -M vicmd "i" up-line-or-history
bindkey -M vicmd "o" vi-forward-char
bindkey -M vicmd "J" vi-rev-repeat-search
bindkey -M vicmd "H" vi-insert-bol
bindkey -M vicmd "K" vi-open-line-above
bindkey -M vicmd "L" vi-forward-blank-word-end
bindkey -M vicmd "E" vi-join
bindkey -M vicmd "^J" down-history

bindkey -s ^f "tmux-sessionizer\n"

# Setting the prompt
NEWLINE=$'\n'
## Options
THEME_VI_INS_MODE_SYMBOL=${THEME_VI_INS_MODE_SYMBOL:-'λ'}
THEME_VI_CMD_MODE_SYMBOL=${THEME_VI_CMD_MODE_SYMBOL:-'ᐅ'}

## Set symbol for the initial prompt
PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "

# on keymap change, define the mode and redraw prompt
zle-keymap-select() {
	if [ "${KEYMAP}" = "vicmd" ]; then
		PS1="%F{green}${THEME_VI_CMD_MODE_SYMBOL}%f "
	else
		PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
	fi
	zle reset-prompt
}
#zle -N zle-keymap-init
zle -N zle-keymap-select

# reset to default mode at the end of line input reading
zle-line-finish() {
	PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
}
zle -N zle-line-finish

# Fix a bug when you C-c in CMD mode, you'd be prompted with CMD mode indicator
# while in fact you would be in INS mode.
# Fixed by catching SIGINT (C-c), set mode to INS and repropagate the SIGINT,
# so if anything else depends on it, we will not break it.
TRAPINT() {
	PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
	return $(( 128 + $1 ))
}

autoload -Uz vcs_info # enable vcs_info
zstyle ":vcs_info:*" formats "%s(%F{red}%b%f)" # git(main)
precmd() {
	set-prompt
}

set-prompt() {
	vcs_info
	if [[ -z ${vcs_info_msg_0_} ]]; then
		print -rP "%K{white}%F{black} %D{%T} %f%k %n@%m [%F{red}%5~%f]"
	else
		print -rP "%K{white}%F{black} %D{%T} %f%k %n@%m [%F{red}%3~%f] ${vcs_info_msg_0_}"
	fi
}

# ---- FZF ----

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
	
export FZF_DEFAULT_OPTS='--bind=ctrl-e:down,ctrl-u:down,ctrl-y:up'

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd for listing path candidates. The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
	/usr/local/bin/fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
	/usr/local/bin/fd --type=d --hidden --exclude .git . "$1"
}

[ -f ~/fzf-git.sh/fzf-git.sh ] && source ~/fzf-git.sh/fzf-git.sh

# Path to custom completions
fpath=($HOME/dotfiles/shell/completions/ $fpath)

# Created by `pipx` on 2023-05-18 05:50:54
export PATH="$PATH:/Users/daneorie/.local/bin"
