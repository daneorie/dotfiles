export NVIM_HOME=~/.config/nvim
export MAVEN_HOME=~/apache-maven-3.8.1

if [[ -n "/usr/local/bin/brew" ]]; then
	export PATH="$PATH:/opt/homebrew/bin"
fi

# Add any new paths to this list
paths_to_add=(
	"/usr/local/sbin"
	"$MAVEN_HOME/bin"
	"$HOME/.jenv/bin"
)
# Add paths to PATH if they don't already exist
for path_to_add in "${paths_to_add[@]}"; do
	if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
		export PATH="$PATH:$path_to_add"
	fi
done

export EDITOR=nvim
export PAGER=less
export LESSKEY=~/.lesskey
alias l='ls -lH'
alias la='ls -a'
alias ll='l'
alias lla='l -a'
alias lld='l -d'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias cdu='cd-gitroot'
alias less="$(brew --prefix)/Cellar/less/590/bin/less"
alias excel="open -a /Applications/Microsoft\ Excel.app"
alias refresh="exec $SHELL -l"

# git aliases
alias g='git'
alias gu='gitui'

# yabai aliases
alias yq='yabai -m query'
alias yqd='yq --displays'
alias yqs='yq --spaces'
alias yqw='yq --windows'
alias yqdw='yqd --window'
alias yqds='yqd --space'
alias yqdd='yqd --display'
alias yqsw='yqs --window'
alias yqss='yqs --space'
alias yqsd='yqs --display'
alias yqww='yqw --window'
alias yqws='yqw --space'
alias yqwd='yqw --display'

#cat() {
	#[[ "$(file $1)" =~ ": directory" ]] && ll $1 || /bin/cat $1
#}

export KEYTIMEOUT=1 # this lowers the time it takes to switch from viins to vicmd and vice versa
eval "$(jenv init -)"

# Plugins (Antigen)
source /usr/local/share/antigen/antigen.zsh

antigen bundle mollifier/cd-gitroot # type "cd-gitroot<CR>" to get to the root directory of a git repo; aliased above

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

# Setting the prompt
NEWLINE=$'\n'
## Options
THEME_VI_INS_MODE_SYMBOL=${THEME_VI_INS_MODE_SYMBOL:-'??'}
THEME_VI_CMD_MODE_SYMBOL=${THEME_VI_CMD_MODE_SYMBOL:-'???'}

## Set symbol for the initial mode
THEME_VI_MODE_SYMBOL="${THEME_VI_INS_MODE_SYMBOL}"

# on keymap change, define the mode and redraw prompt
zle-keymap-select() {
	if [ "${KEYMAP}" = "vicmd" ]; then
		THEME_VI_MODE_SYMBOL="${THEME_VI_CMD_MODE_SYMBOL}"
	else
		THEME_VI_MODE_SYMBOL="${THEME_VI_INS_MODE_SYMBOL}"
	fi
	set-prompt
	zle reset-prompt
}
#zle -N zle-keymap-init
zle -N zle-keymap-select

# reset to default mode at the end of line input reading
zle-line-finish() {
	THEME_VI_MODE_SYMBOL="${THEME_VI_INS_MODE_SYMBOL}"
}
zle -N zle-line-finish

# Fix a bug when you C-c in CMD mode, you'd be prompted with CMD mode indicator
# while in fact you would be in INS mode.
# Fixed by catching SIGINT (C-c), set mode to INS and repropagate the SIGINT,
# so if anything else depends on it, we will not break it.
TRAPINT() {
	THEME_VI_MODE_SYMBOL="${THEME_VI_INS_MODE_SYMBOL}"
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
		# Oh hey, nothing from vcs_info, so we got more space.
		# Let's print a longer part of $PWD...
		PS1="%n@%m [%F{red}%5~%f]$NEWLINE%F{green}$THEME_VI_MODE_SYMBOL%f "
		RPS1="%{$(echotc UP 1)%}%K{white}%F{black} %D{%T} %f%k%{$(echotc DO 1)%}"
	else
		# vcs_info found something, that needs space. So a shorter $PWD
		# makes sense.
		#PS1="%n@%m [%F{red}%3~%f]$NEWLINE${vcs_info_msg_0_} %F{green}$THEME_VI_MODE_SYMBOL%f "
		PS1="%n@%m [%F{red}%3~%f]$NEWLINE%F{green}$THEME_VI_MODE_SYMBOL%f "
		RPS1="%{$(echotc UP 1)%}${vcs_info_msg_0_} %K{white}%F{black} %D{%T} %f%k%{$(echotc DO 1)%}"
	fi
}
