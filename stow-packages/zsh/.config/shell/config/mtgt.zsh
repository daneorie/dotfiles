PATH_TO_MTGT_MAIN="${HOME}/repos/mtgt/main"

export MTGT_SQLITE_PATH="$HOME/.mtgt/database.db"
export MTGT_SCRYFALL_BULK_DOWNLOAD_PATH="$HOME/.mtgt/scryfall_cards.json"
export MTGT_SQLITE_BACKUP_DIR="$HOME/.mtgt/snapshots"
export MTGT_LOGGING_PATH="$HOME/.mtgt/mtgt.log"
export MTGT_ALLOW_HYPERLINKS=true
export MTGT_IMGCAT_FORMAT=iterm2

# PATH management - Add new paths to this list
paths_to_add=(
	"$PATH_TO_MTGT_MAIN/bin"
)

# Add paths to PATH if they don't already exist
for path_to_add in "${paths_to_add[@]}"; do
	if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
		export PATH="$PATH:$path_to_add"
	fi
done

. "$PATH_TO_MTGT_MAIN/scripts/zsh/mtgt_completions.zsh"
. "$PATH_TO_MTGT_MAIN/scripts/zsh/functions.zsh"

# Register mtgt completions after antigen's deferred compinit runs
# Antigen stubs out `compdef` as a no-op during .zshrc loading, then restores
# it when _antigen_compinit fires on the first precmd. This hook ensures all
# mtgt completions are registered at that point.
autoload -Uz add-zsh-hook
_mtgt_precmd_setup() {
	_mtgt_register_all_compdefs
	add-zsh-hook -D precmd _mtgt_precmd_setup
}
add-zsh-hook precmd _mtgt_precmd_setup

