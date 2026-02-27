# Dotfiles

A modular dotfiles configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

1. **Install GNU Stow**
   ```bash
   # macOS
   brew install stow
   
   # Ubuntu/Debian
   sudo apt install stow
   
   # Arch Linux
   sudo pacman -S stow
   ```

2. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. **Install packages**
   ```bash
   # Install core packages (shell, terminal, etc.)
   ./install.sh --core
   
   # Install all packages
   ./install.sh --all
   
   # Install specific packages
   ./install.sh zsh wezterm tmux git
   ```

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
# List all available packages
./install.sh --list

# Preview what would be installed (dry run)
./install.sh --dry-run --all

# Install core packages
./install.sh --core

# Install specific packages
./install.sh zsh wezterm git

# Remove a package
./install.sh --unstow zsh

# Install everything
./install.sh --all
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
4. Test with `./install.sh --dry-run <package-name>`

## Troubleshooting

- **Conflicts**: If stow reports conflicts, you may have existing files. Back them up and try again.
- **Missing dependencies**: Some configurations may require specific tools to be installed first.
- **Broken symlinks**: Use `./install.sh --unstow <package>` to remove and then reinstall.

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
