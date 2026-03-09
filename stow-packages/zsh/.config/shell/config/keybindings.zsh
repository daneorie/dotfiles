# Shell Options and Keybindings

# Shell options
setopt interactivecomments  # Allow comments in interactive mode

# Vi mode setup
bindkey -v

# Command line editing
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^v' edit-command-line  # Edit command in nvim with Ctrl-v

# Custom keybindings for Colemak layout
# Circle of mappings: n -> h -> i -> k -> o -> l -> e -> j -> n
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

# Tmux sessionizer
bindkey -s ^f "tmux-sessionizer\n"