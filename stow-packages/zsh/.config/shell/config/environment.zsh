# Environment Variables and PATH Configuration

# Application directories
export NVIM_HOME=~/.config/nvim
export MAVEN_HOME=~/apache-maven-3.8.1
export WIKI_HOME=~/wiki
export XDG_CONFIG_HOME="$HOME/.config"

# Editor and pager configuration
export EDITOR=nvim
export PAGER=nvimpager
export LESSKEY=~/.lesskey
export KEYTIMEOUT=1 # Lower time for vi mode switching

# Work-specific environment variables (C1)
export BA=BACoolTeam
export ASV=ASVCOOLTEAM
export AWS_DEV=0123456789
export AWS_QA=9876543210
export AWS_PROFILE_DEV=GR_GG_COF_AWS_${AWS_DEV}_Developer
export AWS_PROFILE_QA=GR_GG_COF_AWS_${AWS_QA}_Developer
export AWS_PROFILE=${AWS_PROFILE_DEV}

# Homebrew path
if [[ -n "/usr/local/bin/brew" ]]; then
	export PATH="$PATH:/opt/homebrew/bin"
fi

# PATH management - Add new paths to this list
paths_to_add=(
	"/usr/local/sbin"
	"$MAVEN_HOME/bin"
	"$HOME/.jenv/bin"
	"$HOME/Library/Python/3.11/bin"
	"/Users/daneorie/.local/bin"  # pipx
)

# Add paths to PATH if they don't already exist
for path_to_add in "${paths_to_add[@]}"; do
	if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
		export PATH="$PATH:$path_to_add"
	fi
done

# Load private keys if available
if [[ -e "~/.keys" ]]; then
	. ~/.keys
fi

# Initialize development tools
eval "$(jenv init -)"
eval "$(rbenv init - zsh)"