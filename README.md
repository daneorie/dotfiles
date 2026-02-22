# Computer Setup

## To be sorted

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
```

## Basic Setup

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
ln -s ~/dotfiles/ubersicht/widgets/ ~/Library/Application Support/Übersicht/

# scripts
ln -s ~/dotfiles/scripts/tmux-sessionizer ~/.local/bin/
ln -s ~/dotfiles/scripts/tmux-windowizer ~/.local/bin/
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

## Java LSP Setup (configuration files are already setup)

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

## Plugin List

- [packer.nvim](https://github.com/wbthomason/packer.nvim)

-- Lua Development

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [popup.nvim](https://github.com/nvim-lua/popup.nvim)
- [lua-dev.nvim](https://github.com/folke/lua-dev.nvim)

-- LSP

- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [mason.nvim](https://github.com/williamboman/mason.nvim)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)
- [lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim)
- [nvim-navic](https://github.com/SmiteshP/nvim-navic)
- [symbols-outline.nvim](https://github.com/simart39/symbols-outline.nvim)
- [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
- [vim-illuminate](https://github.com/RRethy/vim-illuminate)
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)
- [lsp-inlayhints.nvim](https://github.com/lvimuser/lsp-inlayhints.nvim)
- [lsp_line.nvim](https://git.sr.ht/~whynothugo/lsp_lines.nvim)
- [folding-nvim](https://github.com/pierreglaser/folding-nvim)

-- Completion

- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [cmp-path](https://github.com/hrsh7th/cmp-path)
- [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)

-- Snippets

- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

-- Syntax/Treesitter

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
- ~~[nvim-surround](https://github.com/kylechui/nvim-surround)~~

-- Marks

- [harpoon](https://github.com/christianchiarulli/harpoon)
- [vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks)
- [sessions.nvim](https://github.com/natecraddock/sessions.nvim)
- [workspaces.nvim](https://github.com/natecraddock/workspaces.nvim)

-- Fuzzy Finder/Telescope

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim)
- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
- [telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim)
- [telescope-vim-bookmark.nvim](https://github.com/tom-anders/telescope-vim-bookmark.nvim)

-- Note Taking

- [orgmode](https://github.com/nvim-orgmode/orgmode)

-- Colorschemes

- [nightfox.nvim](https://github.com/EdenEast/nightfox.nvim)

-- Utility

- [impatient.nvim](https://github.com/lewis6991/impatient.nvim)
- ~~[coc.nvim](https://github.com/neoclide/coc.nvim)~~
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi)

-- Icon

- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons)
- ~~[vim-devicons](https://github.com/ryanoasis/vim-devicons)~~

-- Debugging

- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- ~~[DAPInstall.nvim](https://github.com/ravenxrz/DAPInstall.nvim)~~

-- Tabline

- [vim-buffet](https://github.com/bagrat/vim-buffet)

-- Statusline

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)

-- Startup

- [vim-startify](https://github.com/mhinz/vim-startify)

-- Indent

- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

-- File Explorer

- [nvim-tree](https://github.com/kyazdani42/nvim-tree.lua)
- ~~[nerdtree](https://github.com/preservim/nerdtree)~~

-- Comment

- [nerdcommenter](https://github.com/preservim/nerdcommenter)

-- Terminal

- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

-- Git

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- ~~[nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)~~

-- Editing support

- [nvim-autopairs](https://github.com/windwp/nvim-autopairs)

-- Keybinding

- [whick-key.nvim](https://github.com/folke/which-key.nvim)

-- Java

- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

-- Markdown

- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)


## LSP Servers
npm install -g @mistweaverco/kulala-ls


## Formatters
npm install -g @mistweaverco/kulala-fmt
