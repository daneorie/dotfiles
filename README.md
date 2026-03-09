# Dotfiles

A modular dotfiles configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 🚀 Quick Start

### One-Command Complete Setup (Recommended)

For the ultimate "just works" experience on a fresh machine:

```bash
# 1. Clone this repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Complete setup - dependencies + stow packages in one command
make complete-setup        # Core packages (recommended)
make complete-setup-all     # All packages
make complete-setup-verbose # With detailed output

# Or use the script directly for more options
./scripts/complete-setup.sh --help
```

**What `complete-setup` does:**
1. **Bootstrap**: Installs package managers (Homebrew, Git, GNU Stow)
2. **Dependencies**: Installs CLI tools (fzf, fd, neovim, bat, etc.) 
3. **Version Managers**: Sets up jenv, rbenv, pyenv, nvm, antigen
4. **Stow Packages**: Installs your dotfiles configuration
5. **Health Check**: Verifies everything is working

### Migration from Existing Dotfiles

If you have existing dotfiles that need to be backed up first:

```bash
# Complete setup with automatic migration (recommended)
make complete-setup-migrate     # Migrate + install core packages
make complete-setup-migrate-all # Migrate + install all packages

# Or use migration commands directly
make migrate-core               # Migrate core packages only
make migrate-all                # Migrate all packages  
make migrate-dry-run            # Preview what would be migrated
make migrate-backup-only        # Just backup, no installation

# Migrate specific packages
./scripts/migrate.sh zsh git tmux --yes  # Migrate specific packages
just migrate-packages zsh git tmux       # Using just

# Advanced migration options
./scripts/migrate.sh --help     # See all migration options
```

**Migration process:**
1. **Backup**: Creates timestamped backup of existing dotfiles in `~/.dotfiles-backup-TIMESTAMP`
2. **Install**: Uses GNU Stow to create clean symlinks from packages
3. **Verify**: Ensures all packages are correctly installed

### Traditional Multi-Step Setup

For more control over the installation process:

```bash
# Run complete dependency setup first
make full-setup           # Bootstrap + dependencies + tools + dotfiles

# Or run each step individually:
make bootstrap           # Install package managers (Homebrew, Git, Stow)
make install-deps        # Install CLI tools (fzf, fd, neovim, etc.)
make setup-tools         # Install version managers (jenv, rbenv, pyenv, nvm, antigen)
make install-core        # Install core dotfiles
```

### Manual Installation (Advanced)

If you prefer more control or already have some tools installed:

1. **Bootstrap (if needed)**
   ```bash
   ./scripts/bootstrap.sh    # Installs Homebrew, Git, GNU Stow
   ```

2. **Install Dependencies (optional)**
   ```bash
   # Install all development tools
   make install-deps
   
   # Or install specific categories
   make install-deps-core    # Core CLI tools (fzf, fd, neovim, etc.)
   make install-deps-gui     # GUI applications (alacritty, wezterm, etc.)
   make install-deps-lang    # Language tools (node, python, ruby, etc.)
   ```

3. **Setup Version Managers (optional)**
   ```bash
   # Install all version managers
   make setup-tools
   
   # Or install specific ones
   make setup-java          # jenv (Java)
   make setup-ruby          # rbenv (Ruby)  
   make setup-python        # pyenv (Python)
   make setup-node          # nvm (Node.js)
   make setup-zsh           # antigen (Zsh plugins)
   ```

4. **Install Dotfiles**
   ```bash
   # Using Make (recommended)
   make install-core           # Install core packages
   make install-all            # Install all packages
   make install PACKAGES="zsh git tmux"  # Install specific packages
   
   # Using Just (alternative)
   just install-core           # Install core packages  
   just install-all            # Install all packages
   just install zsh git tmux   # Install specific packages
   
   # Using scripts directly
   ./scripts/install.sh --core
   ./scripts/install.sh --all
   ./scripts/install.sh zsh git tmux
   ```

### Health Check

Verify everything is working correctly:

```bash
make health              # Comprehensive system check
make status              # Show current dotfiles status
```

## 🛠️ Included Tools & Dependencies

### Package Managers
- **Homebrew** - Package manager for macOS/Linux
- **GNU Stow** - Symlink farm manager for dotfiles

### Essential CLI Tools
- **fd** - Better find command
- **fzf** - Fuzzy finder for command line
- **ripgrep** - Better grep command  
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colors and icons
- **neovim** - Modern vim-based editor
- **tmux** - Terminal multiplexer
- **lazygit** - Terminal UI for git
- **git-delta** - Better git diff viewer
- **jq/yq** - JSON/YAML processors

### Development Tools
- **GitHub CLI** - Official GitHub command line tool
- **curl/wget** - HTTP clients
- **rsync** - File synchronization
- **compression tools** - unzip, p7zip

### Version Managers
- **jenv** - Java version manager
- **rbenv** - Ruby version manager  
- **pyenv** - Python version manager
- **nvm** - Node.js version manager
- **antigen** - Zsh plugin manager
- **rustup** - Rust toolchain manager

### Programming Languages (Optional)
- **Java** - OpenJDK
- **Python** - Python 3.11/3.12
- **Node.js** - JavaScript runtime with yarn
- **Ruby** - Ruby language
- **Go** - Go programming language
- **Rust** - Rust programming language
- **Lua** - Lua with LuaRocks

### GUI Applications (macOS)
- **Alacritty** - GPU-accelerated terminal
- **WezTerm** - GPU-accelerated terminal
- **Kitty** - Fast terminal emulator

## Package Structure

This repository is organized into modular packages that can be installed independently:

### Core Packages
- **zsh** - ZSH shell configuration with modular structure
- **wezterm** - WezTerm terminal configuration
- **tmux** - Terminal multiplexer configuration  
- **git** - Git configuration and attributes
- **vim** - Vim/Neovim and related editor configurations
- **nvim** - Neovim configuration
- **yabai** - Yabai window manager and skhd hotkey daemon

### GUI Applications
- **alacritty** - Alacritty terminal configuration
- **kitty** - Kitty terminal configuration
- **hammerspoon** - Hammerspoon automation
- **karabiner** - Karabiner-Elements key remapping
- **aerospace** - AeroSpace window manager
- **sketchybar** - SketchyBar status bar
- **yazi** - Yazi file manager
- **gitui** - Git TUI configuration
- **lazygit** - LazyGit TUI configuration
- **borders** - JankyBorders configuration
- **ubersicht** - Übersicht desktop widgets
- **nvimpager** - Neovim-based pager

### Other
- **scripts** - Utility scripts

## Usage Examples

```bash
# Complete Setup (recommended for new machines)
make complete-setup              # Complete setup with core packages
make complete-setup-all          # Complete setup with all packages  
make complete-setup-verbose      # Complete setup with detailed output

# Complete Setup with Migration (for existing dotfiles)
make complete-setup-migrate      # Migration + core packages
make complete-setup-migrate-all  # Migration + all packages

# Advanced Setup Options
./scripts/complete-setup.sh --packages "zsh,git,tmux"  # Custom packages
./scripts/complete-setup.sh --skip-deps               # Skip dependencies  
./scripts/complete-setup.sh --skip-version-managers   # Skip version managers
./scripts/complete-setup.sh --migrate                 # With migration
./scripts/complete-setup.sh --migrate-backup-only     # Backup only

# Traditional Multi-Step Setup
make bootstrap                   # Install package managers first
make install-deps               # Install development tools
make setup-tools                # Setup version managers
make install-core               # Install core dotfiles

# Package Management
make list                       # List all available packages
make dry-run                    # Preview core installation
make install-core               # Install core packages
make install PACKAGES="zsh git tmux"  # Install specific packages
make uninstall PACKAGES="zsh git"     # Remove packages

# Migration (backup existing dotfiles)
make migrate                    # Interactive migration
make migrate-core               # Migrate core packages
make migrate-all                # Migrate all packages
make migrate-dry-run            # Preview migration
make migrate-backup-only        # Just backup files

# Testing & Maintenance
make test                       # Run comprehensive tests
make test-complete              # Test complete setup in Docker
make test-stow-only             # Test stow-only process in Docker
make health                     # Health check
make status                     # Show current status

# Or using Just
just complete-setup             # Complete setup with core packages
just complete-setup-migrate     # Complete setup with migration
just migrate-packages zsh git   # Migrate specific packages
just list                       # List all available packages
just dry-run                    # Preview core installation  
just install-core               # Install core packages
just uninstall zsh git          # Remove packages
```

## Task Runners

This repository includes modern task runners for easier management:

### Make (Makefile)
```bash
make help                        # Show all available commands

# Complete Setup
make complete-setup              # Complete setup with core packages
make complete-setup-all          # Complete setup with all packages
make complete-setup-verbose      # Complete setup with detailed output
make complete-setup-migrate      # Complete setup with migration
make complete-setup-migrate-all  # Complete setup with migration (all packages)

# Traditional Setup
make bootstrap                   # Install package managers
make install-deps               # Install development tools
make setup-tools                # Setup version managers
make full-setup                 # Complete dependency setup

# Package Management  
make install-core               # Install essential packages
make install PACKAGES="zsh git"  # Install specific packages
make list                       # List available packages

# Migration
make migrate                    # Interactive migration
make migrate-core               # Migrate core packages  
make migrate-all                # Migrate all packages
make migrate-dry-run            # Preview migration
make migrate-backup-only        # Backup files only

# Testing & Health
make test                       # Run comprehensive tests
make test-complete              # Test complete setup in Docker
make health                     # Health check
make status                     # Show current status
```

### Just (justfile) 
Install [Just](https://github.com/casey/just) for an alternative task runner:
```bash
just help                      # Show all available commands

# Complete Setup  
just complete-setup            # Complete setup with core packages
just complete-setup-all        # Complete setup with all packages
just complete-setup-migrate    # Complete setup with migration
just complete-setup-migrate-all # Complete setup with migration (all packages)

# Migration
just migrate                   # Interactive migration
just migrate-core              # Migrate core packages
just migrate-all               # Migrate all packages
just migrate-packages zsh git  # Migrate specific packages
just migrate-dry-run           # Preview migration
just migrate-backup-only       # Backup files only

# Package Management
just install-core              # Install essential packages
just install zsh git           # Install specific packages (simpler syntax)
just list                      # List available packages
just test                      # Run comprehensive tests
just migrate                   # Migrate existing dotfiles
```

### Direct Script Usage
You can also run scripts directly:
```bash
./scripts/complete-setup.sh --help  # Complete setup with all options
./scripts/install.sh --help         # Package management
./scripts/migrate.sh                # Migration workflow
./scripts/bootstrap.sh              # Bootstrap essentials
./scripts/setup-tools.sh            # Setup version managers
./scripts/verify.sh                 # Verify package structure
./scripts/test.sh                   # Docker testing
```

## How It Works

This setup uses GNU Stow to create symlinks from the package directories to your home directory. Each package contains the directory structure that mirrors where the files should be placed in your home directory.

For example:
- `stow-packages/zsh/.zshrc` → `~/.zshrc`
- `stow-packages/nvim/.config/nvim/` → `~/.config/nvim/`
- `stow-packages/wezterm/.wezterm.lua` → `~/.wezterm.lua`

## Modular Configuration

Several configurations are split into modular files for better organization:

### ZSH Configuration
The ZSH configuration is split into focused modules:
- `shell/config/environment.zsh` - Environment variables and PATH
- `shell/config/aliases.zsh` - Command aliases  
- `shell/config/functions.zsh` - Custom functions
- `shell/config/keybindings.zsh` - Shell options and keybindings
- `shell/config/plugins.zsh` - Plugin management
- `shell/config/prompt.zsh` - Prompt configuration
- `shell/config/fzf.zsh` - FZF fuzzy finder setup

### WezTerm Configuration  
The WezTerm configuration is modularized into:
- `wezterm/utils.lua` - Utility functions
- `wezterm/appearance.lua` - Visual configuration
- `wezterm/neovim.lua` - Neovim integration
- `wezterm/workspace.lua` - Workspace management
- `wezterm/events.lua` - Event handlers
- `wezterm/keybindings.lua` - Key bindings
- `wezterm/key_tables.lua` - Modal key tables

Both configurations are **symlink-aware** and will work correctly whether the main config files are symlinked or not.

## Adding New Packages

To add a new package:

1. Create a new directory under `stow-packages/`
2. Structure it to mirror your home directory
3. Add the package name to the appropriate array in `install.sh`
4. Test with `make dry-run` or `./scripts/install.sh --dry-run <package-name>`

## Troubleshooting

- **Conflicts**: If stow reports conflicts, you may have existing files. Back them up and try again.
- **Missing dependencies**: Some configurations may require specific tools to be installed first.
- **Broken symlinks**: Use `make uninstall PACKAGES="package"` or `./scripts/install.sh --unstow <package>` to remove and then reinstall.

## Testing

### Docker Testing Environment

Test your stow setup safely in an isolated Docker environment:

```bash
# Run automated tests
./test-stow.sh auto

# Interactive testing
./test-stow.sh interactive

# Quick setup for manual testing
./test-stow.sh setup
```

The Docker environment includes:
- ✅ Pre-configured test scenario with mock existing files
- ✅ All necessary tools (stow, zsh, nvim, etc.)
- ✅ Isolated environment that won't affect your host system
- ✅ Comprehensive test suite covering all functionality

See [TESTING.md](TESTING.md) for detailed testing instructions.

---

## Legacy Setup Information

<details>
<summary>Click to expand original manual setup instructions</summary>

This section contains the original manual setup instructions that have been superseded by the Stow-based approach above.

### To be sorted

```bash
brew install ripgrep
npm i -g write-good
npm i -g eslint_d
brew install eslint
brew install lazydocker
brew install ctop
npm i -g dockly
brew install tokei
brew install bottom
brew install navi
brew install sketchybar
brew install kindavim
brew install hammerspoon
```

### Basic Setup

Symlink a bunch of files and folders

```
ln -s ~/dotfiles/.zshrc ~
ln -s ~/dotfiles/.vimrc ~
ln -s ~/dotfiles/.exrc ~
ln -s ~/dotfiles/.inputrc ~
ln -s ~/dotfiles/.lesskey ~
ln -s ~/dotfiles/.tmux.conf ~
ln -s ~/dotfiles/.yabairc ~
ln -s ~/dotfiles/.skhdrc ~
ln -s ~/dotfiles/.wezterm.lua ~
ln -s ~/dotfiles/com.example.KeyRemapping.plist ~/Library/LaunchAgents/
ln -s ~/dotfiles/lazygit/ ~/.config/
ln -s ~/dotfiles/nvim/ ~/.config/
ln -s ~/dotfiles/nvimpager/ ~/.config/
ln -s ~/dotfiles/gitui/ ~/.config/
ln -s ~/dotfiles/alacritty/ ~/.config/
ln -s ~/dotfiles/yazi/ ~/.config/
ln -s ~/dotfiles/ubersicht/widgets/ ~/Library/Application\ Support/Übersicht/
ln -s ~/dotfiles/sketchybar ~/.config/
ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
ln -s ~/dotfiles/aerospace ~/.config/

# scripts
ln -s ~/dotfiles/scripts/tmux-sessionizer ~/.local/bin/
ln -s ~/dotfiles/scripts/tmux-windowizer ~/.local/bin/

# start the services
yabai --start-service
brew services start sketchybar
brew services start hammerspoon
```

Install Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install NeoVim

```
brew install neovim
```

Node is necessary for some plugins

```
brew install node
```

Antigen is the plugin manager for zsh

```
brew install antigen
```

Install a bunch of GUI apps using cask

```
brew install --cask alacritty
brew install --cask spacelauncher
brew install --cask topnotch
brew install --cask discord
brew install --cask github
brew install --cask ubersicht
```

Install a few commands

```
brew install fd
brew install fzf
```

Setup terminfo

```
# Clone alacritty
git clone https://github.com/alacritty/alacritty.git
cd alacritty
# setup terminfo
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
# cleanup
cd .. && rm -rf alacritty
```

Download a nerd font

```
brew tap homebrew/cask-fonts
brew install font-bitstream-vera-sans-mono-nerd-font
```

Enable font smoothing for Mac

```
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
defaults -currentHost write -globalDomain AppleFontSmoothing -int 2
```

Set or create an environment variable NVIM_HOME in the 'rc' file to the location of the nvim directory. Currently, this is only referenced for the swap file directory.

```
set NVIM_HOME="/path/to/nvim/"
```

### Java LSP Setup (configuration files are already setup)

Download [eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls#installation) to `/Library/Java/LanguageServers`

1. Install the various JDKs.
   ```
   brew install openjdk@11 # for example
   ```
2. Link them to `/Library/Java/JavaVirtualMachines`.
   ```
   sudo ln -sfn ~/Documents/zulu-OpenJDK/openjdk-11.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
   ```
3. Add `Contents/Home` to `jenv`. If an installation fails (for ARM or something), use [zulu](https://www.azul.com/downloads/?version=java-8-lts&architecture=arm-64-bit&package=jdk) instead.
   ```
   jenv add /Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home
   ```

Clone and build in `$HOME/Documents/GitHub/`:

- [java-debug](https://github.com/microsoft/java-debug)

```
./mvnw clean install
```

- [vscode-java-test](https://github.com/microsoft/vscode-java-test)

```
npm install
npm run build-plugin
```

### Plugin List

[Extended plugin list for Neovim - see original README for complete list]

</details>

---

*Managed with ❤️ using GNU Stow*
