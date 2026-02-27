# Prompt Configuration

# Prompt symbols
THEME_VI_INS_MODE_SYMBOL=${THEME_VI_INS_MODE_SYMBOL:-'λ'}
THEME_VI_CMD_MODE_SYMBOL=${THEME_VI_CMD_MODE_SYMBOL:-'ᐅ'}

# Initial prompt setup
PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "

# Mode indicator functions for vi mode
zle-keymap-select() {
	if [ "${KEYMAP}" = "vicmd" ]; then
		PS1="%F{green}${THEME_VI_CMD_MODE_SYMBOL}%f "
	else
		PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
	fi
	zle reset-prompt
}
zle -N zle-keymap-select

# Reset to default mode at the end of line input reading
zle-line-finish() {
	PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
}
zle -N zle-line-finish

# Fix C-c in CMD mode to show correct mode indicator
TRAPINT() {
	PS1="%F{green}${THEME_VI_INS_MODE_SYMBOL}%f "
	return $(( 128 + $1 ))
}

# VCS info setup
autoload -Uz vcs_info
zstyle ":vcs_info:*" formats "%s(%F{red}%b%f)" # git(main)

# Precmd hook to update prompt
precmd() {
	set-prompt
}

# Set the main prompt with git info and timestamp
set-prompt() {
	vcs_info
	if [[ -z ${vcs_info_msg_0_} ]]; then
		print -rP "%K{white}%F{black} %D{%T} %f%k %n@%m [%F{red}%5~%f]"
	else
		print -rP "%K{white}%F{black} %D{%T} %f%k %n@%m [%F{red}%3~%f] ${vcs_info_msg_0_}"
	fi
}