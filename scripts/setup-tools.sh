#!/bin/bash

# Version Managers Setup Script
# Sets up jenv, rbenv, antigen, and other version management tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Version Managers Setup${NC}"
echo -e "${BLUE}======================${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
	local missing=()

	if ! command -v brew &>/dev/null; then
		missing+=("Homebrew")
	fi

	if ! command -v git &>/dev/null; then
		missing+=("Git")
	fi

	if [[ ${#missing[@]} -gt 0 ]]; then
		echo -e "${RED}Error: Missing prerequisites: ${missing[*]}${NC}"
		echo "Please run: ./scripts/bootstrap.sh first"
		exit 1
	fi

	echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
}

# Install jenv (Java version manager)
setup_jenv() {
	if command -v jenv &>/dev/null; then
		echo -e "${GREEN}✓ jenv is already installed${NC}"
	else
		echo -e "${YELLOW}Installing jenv...${NC}"
		brew install jenv
		echo -e "${GREEN}✓ jenv installed${NC}"
	fi

	# Setup jenv directory
	if [[ ! -d "$HOME/.jenv" ]]; then
		mkdir -p "$HOME/.jenv"
	fi

	echo -e "${YELLOW}Setting up jenv configuration...${NC}"

	# Enable plugins
	if command -v jenv &>/dev/null; then
		jenv enable-plugin export || true
		jenv enable-plugin gradle || true
		jenv enable-plugin maven || true
		echo -e "${GREEN}✓ jenv plugins enabled${NC}"
	fi

	# Add Java versions if OpenJDK is installed
	if [[ -d "/opt/homebrew/opt/openjdk" ]]; then
		jenv add "/opt/homebrew/opt/openjdk" || true
	elif [[ -d "/usr/local/opt/openjdk" ]]; then
		jenv add "/usr/local/opt/openjdk" || true
	fi

	echo -e "${GREEN}✓ jenv setup completed${NC}"
	echo ""
}

# Install rbenv (Ruby version manager)
setup_rbenv() {
	if command -v rbenv &>/dev/null; then
		echo -e "${GREEN}✓ rbenv is already installed${NC}"
	else
		echo -e "${YELLOW}Installing rbenv...${NC}"
		brew install rbenv ruby-build
		echo -e "${GREEN}✓ rbenv installed${NC}"
	fi

	echo -e "${YELLOW}Setting up rbenv...${NC}"

	# Initialize rbenv
	if command -v rbenv &>/dev/null; then
		rbenv init || true
		echo -e "${GREEN}✓ rbenv initialized${NC}"
	fi

	echo -e "${GREEN}✓ rbenv setup completed${NC}"
	echo ""
}

# Install pyenv (Python version manager)
setup_pyenv() {
	if command -v pyenv &>/dev/null; then
		echo -e "${GREEN}✓ pyenv is already installed${NC}"
	else
		echo -e "${YELLOW}Installing pyenv...${NC}"
		brew install pyenv pyenv-virtualenv
		echo -e "${GREEN}✓ pyenv installed${NC}"
	fi

	echo -e "${YELLOW}Setting up pyenv...${NC}"

	# Initialize pyenv
	if command -v pyenv &>/dev/null; then
		pyenv init - || true
		echo -e "${GREEN}✓ pyenv initialized${NC}"
	fi

	echo -e "${GREEN}✓ pyenv setup completed${NC}"
	echo ""
}

# Install nvm (Node.js version manager)
setup_nvm() {
	if [[ -s "$HOME/.nvm/nvm.sh" ]] || command -v nvm &>/dev/null; then
		echo -e "${GREEN}✓ nvm is already installed${NC}"
	else
		echo -e "${YELLOW}Installing nvm...${NC}"
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
		echo -e "${GREEN}✓ nvm installed${NC}"
	fi

	echo -e "${GREEN}✓ nvm setup completed${NC}"
	echo ""
}

# Install antigen (Zsh plugin manager)
setup_antigen() {
	local antigen_dir="$HOME/.antigen"

	# Check if antigen is already available via Homebrew
	if command -v brew >/dev/null 2>&1; then
		local brew_antigen_path="$(brew --prefix)/share/antigen/antigen.zsh"
		if [[ -f "$brew_antigen_path" ]]; then
			echo -e "${GREEN}✓ antigen is already installed via Homebrew${NC}"
			echo -e "${BLUE}  Location: $brew_antigen_path${NC}"
			echo -e "${GREEN}✓ antigen setup completed${NC}"
			echo ""
			return 0
		fi
	fi

	# Check if our custom installation exists
	if [[ -f "$antigen_dir/antigen.zsh" ]]; then
		echo -e "${GREEN}✓ antigen is already installed${NC}"
		echo -e "${BLUE}  Location: $antigen_dir/antigen.zsh${NC}"
	else
		echo -e "${YELLOW}Installing antigen...${NC}"

		# Create antigen directory
		mkdir -p "$antigen_dir"

		# Download antigen
		curl -L git.io/antigen >"$antigen_dir/antigen.zsh"
		chmod +x "$antigen_dir/antigen.zsh"

		echo -e "${GREEN}✓ antigen installed${NC}"
		echo -e "${BLUE}  Location: $antigen_dir/antigen.zsh${NC}"
	fi

	echo -e "${GREEN}✓ antigen setup completed${NC}"
	echo ""
}

# Install Rust tools
setup_rust_tools() {
	if command -v rustup &>/dev/null; then
		echo -e "${GREEN}✓ Rustup is already installed${NC}"
	else
		echo -e "${YELLOW}Installing Rustup...${NC}"
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		source "$HOME/.cargo/env"
		echo -e "${GREEN}✓ Rustup installed${NC}"
	fi

	echo -e "${GREEN}✓ Rust tools setup completed${NC}"
	echo ""
}

# Create shell environment setup helper
create_env_helper() {
	local env_file="$HOME/.dotfiles-env-setup"

	echo -e "${YELLOW}Creating environment setup helper...${NC}"

	cat >"$env_file" <<'EOF'
#!/bin/bash
# Dotfiles Environment Setup Helper
# Source this file to load all version managers in your current shell

# Load jenv
if command -v jenv &> /dev/null; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# Load rbenv
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
fi

# Load pyenv
if command -v pyenv &> /dev/null; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Load nvm
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
    [[ -s "$HOME/.nvm/bash_completion" ]] && source "$HOME/.nvm/bash_completion"
fi

# Load Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

echo "Environment managers loaded successfully!"
echo "Available commands: jenv, rbenv, pyenv, nvm, cargo"
EOF

	chmod +x "$env_file"
	echo -e "${GREEN}✓ Environment helper created: $env_file${NC}"
	echo ""
}

# Show usage
usage() {
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  -h, --help      Show this help message"
	echo "  -j, --java      Setup only jenv (Java)"
	echo "  -r, --ruby      Setup only rbenv (Ruby)"
	echo "  -p, --python    Setup only pyenv (Python)"
	echo "  -n, --node      Setup only nvm (Node.js)"
	echo "  -z, --zsh       Setup only Zsh tools (antigen/oh-my-zsh)"
	echo "  -R, --rust      Setup only Rust tools"
	echo "  -a, --all       Setup all version managers (default)"
	echo ""
	echo "Examples:"
	echo "  $0              # Setup all version managers"
	echo "  $0 --java       # Setup only jenv"
	echo "  $0 --zsh        # Setup only Zsh tools"
}

# Main function
main() {
	local setup_java=false
	local setup_ruby=false
	local setup_python=false
	local setup_node=false
	local setup_zsh=false
	local setup_rust=false
	local setup_all=true

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		-h | --help)
			usage
			exit 0
			;;
		-j | --java)
			setup_java=true
			setup_all=false
			shift
			;;
		-r | --ruby)
			setup_ruby=true
			setup_all=false
			shift
			;;
		-p | --python)
			setup_python=true
			setup_all=false
			shift
			;;
		-n | --node)
			setup_node=true
			setup_all=false
			shift
			;;
		-z | --zsh)
			setup_zsh=true
			setup_all=false
			shift
			;;
		-R | --rust)
			setup_rust=true
			setup_all=false
			shift
			;;
		-a | --all)
			setup_all=true
			shift
			;;
		*)
			echo -e "${RED}Error: Unknown option $1${NC}"
			usage
			exit 1
			;;
		esac
	done

	check_prerequisites

	if [[ "$setup_all" == "true" ]]; then
		setup_jenv
		setup_rbenv
		setup_pyenv
		setup_nvm
		setup_antigen
		setup_rust_tools
	else
		if [[ "$setup_java" == "true" ]]; then
			setup_jenv
		fi
		if [[ "$setup_ruby" == "true" ]]; then
			setup_rbenv
		fi
		if [[ "$setup_python" == "true" ]]; then
			setup_pyenv
		fi
		if [[ "$setup_node" == "true" ]]; then
			setup_nvm
		fi
		if [[ "$setup_zsh" == "true" ]]; then
			setup_antigen
		fi
		if [[ "$setup_rust" == "true" ]]; then
			setup_rust_tools
		fi
	fi

	create_env_helper

	echo -e "${GREEN}✅ Version managers setup completed!${NC}"
	echo ""
	echo "To load all environment managers in your current shell:"
	echo "  source ~/.dotfiles-env-setup"
	echo ""
	echo "Next steps:"
	echo "  1. Restart your shell or source your shell configuration"
	echo "  2. Run: make install-core     # Install dotfiles"
	echo "  3. Run: make health          # Check system health"
	echo ""
}

# Run main function if script is executed directly
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
	main "$@"
fi
