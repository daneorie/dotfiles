# Shell Aliases

# File operations
alias l='ls -lH'
alias la='ls -a'
alias ll='l'
alias lla='l -a'
alias lld='l -d'

# Editor aliases
alias v='nvim'
alias v.='nvim .'
alias vi='nvim'
alias vim='nvim'

# Navigation
alias cdu='cd-gitroot'

# System utilities
alias less="$(brew --prefix)/Cellar/less/590/bin/less"
alias excel="open -a /Applications/Microsoft\ Excel.app"
alias refresh="exec $SHELL -l"
alias wiki="nvim $WIKI_HOME/index.md"

# Git aliases
alias g='git'
alias gu='gitui'
alias ga='git aliases'
alias refreshGithub='ssh -T git@github.com'

# Yabai window manager aliases
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