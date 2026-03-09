# Dotfiles Management Makefile
# Modern task runner for dotfiles management

.DEFAULT_GOAL := help

# Colors for output
WHITE := \033[0;1m
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ Setup
bootstrap: ## Install package managers and essential tools (run this first)
	@./scripts/bootstrap.sh

install-deps: ## Install development tools and CLI utilities
	@./scripts/install-deps.sh

install-deps-core: ## Install only core CLI tools
	@./scripts/install-deps.sh --core

install-deps-gui: ## Install only GUI applications  
	@./scripts/install-deps.sh --gui

install-deps-lang: ## Install only programming language tools
	@./scripts/install-deps.sh --lang

setup-tools: ## Setup version managers (jenv, rbenv, pyenv, nvm, antigen)
	@./scripts/setup-tools.sh

setup-java: ## Setup only Java version manager (jenv)
	@./scripts/setup-tools.sh --java

setup-ruby: ## Setup only Ruby version manager (rbenv)
	@./scripts/setup-tools.sh --ruby

setup-python: ## Setup only Python version manager (pyenv)
	@./scripts/setup-tools.sh --python

setup-node: ## Setup only Node.js version manager (nvm)
	@./scripts/setup-tools.sh --node

setup-zsh: ## Setup Zsh tools (antigen, oh-my-zsh)
	@./scripts/setup-tools.sh --zsh

complete-setup: ## Complete comprehensive setup (dependencies + stow packages)
	@./scripts/complete-setup.sh

complete-setup-all: ## Complete setup with all packages  
	@./scripts/complete-setup.sh --packages all

complete-setup-core-deps: ## Complete setup with core dependencies only (faster)
	@./scripts/complete-setup.sh --deps-core

complete-setup-verbose: ## Complete setup with verbose output
	@./scripts/complete-setup.sh --verbose

complete-setup-migrate: ## Complete setup with migration (backup existing files)
	@./scripts/complete-setup.sh --migrate

complete-setup-migrate-all: ## Complete setup with migration (all packages)
	@./scripts/complete-setup.sh --migrate --packages all

full-setup: bootstrap install-deps setup-tools install-core ## Complete setup (bootstrap + deps + tools + dotfiles)

##@ Package Management
list: ## List all available packages
	@cd $(CURDIR) && ./scripts/install.sh --list

install-core: ## Install core packages (zsh, wezterm, tmux, git, vim, nvim, yabai)
	@cd $(CURDIR) && ./scripts/install.sh --core

install-all: ## Install all packages
	@cd $(CURDIR) && ./scripts/install.sh --all

install: ## Install specific packages (usage: make install PACKAGES="zsh git tmux")
	@if [ -z "$(PACKAGES)" ]; then \
		echo "$(RED)Error: Please specify packages to install$(NC)"; \
		echo "Usage: make install PACKAGES=\"zsh git tmux\""; \
		exit 1; \
	fi
	@cd $(CURDIR) && ./scripts/install.sh $(PACKAGES)

uninstall: ## Remove specific packages (usage: make uninstall PACKAGES="zsh git")
	@if [ -z "$(PACKAGES)" ]; then \
		echo "$(RED)Error: Please specify packages to remove$(NC)"; \
		echo "Usage: make uninstall PACKAGES=\"zsh git\""; \
		exit 1; \
	fi
	@cd $(CURDIR) && ./scripts/install.sh --unstow $(PACKAGES)

dry-run: ## Preview what would be installed (core packages)
	@cd $(CURDIR) && ./scripts/install.sh --dry-run --core

dry-run-all: ## Preview what would be installed (all packages)  
	@cd $(CURDIR) && ./scripts/install.sh --dry-run --all

verify: ## Verify package structure
	@cd $(CURDIR) && ./scripts/verify.sh

##@ Migration
migrate: ## Run migration workflow (backup existing files and migrate to stow)
	@cd $(CURDIR) && ./scripts/migrate.sh

migrate-core: ## Migrate core packages only
	@cd $(CURDIR) && ./scripts/migrate.sh --core

migrate-all: ## Migrate all packages
	@cd $(CURDIR) && ./scripts/migrate.sh --all

migrate-dry-run: ## Preview migration (core packages)
	@cd $(CURDIR) && ./scripts/migrate.sh --core --dry-run

migrate-backup-only: ## Backup existing files without installing packages
	@cd $(CURDIR) && ./scripts/migrate.sh --core --backup-only

##@ Testing
test: ## Run comprehensive test suite
	@echo "$(BLUE)Running comprehensive test suite...$(NC)"
	@cd scripts && ./test.sh

test-interactive: ## Start interactive testing session
	@echo "$(BLUE)Starting interactive testing session...$(NC)"
	@cd scripts && ./test.sh interactive

test-status: ## Check testing container status
	@cd scripts && ./test.sh status

test-logs: ## Show testing container logs
	@cd scripts && ./test.sh logs

test-clean: ## Clean up test environment
	@cd scripts && ./test.sh cleanup

test-complete: ## Test complete setup process in Docker
	@echo "$(BLUE)Testing complete setup process...$(NC)"
	@cd docker && docker-compose up --build dotfiles-test

test-stow-only: ## Test stow-only process in Docker  
	@echo "$(BLUE)Testing stow-only process...$(NC)"
	@cd docker && docker-compose up --build dotfiles-stow-test

##@ Development  
dev-build: ## Build Docker test environment without running tests
	@echo "$(BLUE)Building Docker test environment...$(NC)"
	@cd docker && docker-compose build

dev-shell: ## Get shell access to test container
	@cd scripts && ./test.sh interactive

##@ Maintenance
clean: ## Clean up temporary files and test artifacts
	@echo "$(YELLOW)Cleaning up temporary files...$(NC)"
	@rm -f test1.log test2.log test3.log 2>/dev/null || true
	@rm -f *.log 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-all: test-clean clean ## Full cleanup (test environment + temp files)

##@ Information
status: ## Show current dotfiles status
	@echo "$(BLUE)Dotfiles Status$(NC)"
	@echo "$(BLUE)===============$(NC)"
	@echo ""
	@echo "📁 Package count: $$(ls stow-packages/ | wc -l | tr -d ' ')"
	@echo "📋 Available packages:"
	@ls stow-packages/ | sed 's/^/  - /'
	@echo ""
	@echo "🔗 Current symlinks in home directory:"
	@find ~/ -maxdepth 1 -type l 2>/dev/null | head -10 || echo "  (none found at top level)"

health: ## Health check - verify everything is working
	@echo "$(BLUE)Running health check...$(NC)"
	@echo ""
	@echo "✓ Checking package structure..."
	@cd $(CURDIR) && ./scripts/verify.sh > /dev/null && echo "$(GREEN)✓ Package structure is valid$(NC)" || echo "$(RED)✗ Package structure issues found$(NC)"
	@echo "✓ Checking script permissions..."
	@[ -x scripts/install.sh ] && [ -x scripts/migrate.sh ] && [ -x scripts/verify.sh ] && echo "$(GREEN)✓ All scripts are executable$(NC)" || echo "$(RED)✗ Script permission issues$(NC)"
	@echo "✓ Checking essential tools..."
	@command -v git >/dev/null && echo "$(GREEN)✓ Git is available$(NC)" || echo "$(RED)✗ Git not found$(NC)"
	@command -v stow >/dev/null && echo "$(GREEN)✓ GNU Stow is available$(NC)" || echo "$(RED)✗ GNU Stow not found$(NC)"
	@echo "✓ Checking package managers..."
	@command -v brew >/dev/null && echo "$(GREEN)✓ Homebrew is available$(NC)" || echo "$(YELLOW)⚠ Homebrew not found$(NC)"
	@echo "✓ Checking development tools..."
	@command -v nvim >/dev/null && echo "$(GREEN)✓ Neovim is available$(NC)" || echo "$(YELLOW)⚠ Neovim not found$(NC)"
	@command -v fzf >/dev/null && echo "$(GREEN)✓ fzf is available$(NC)" || echo "$(YELLOW)⚠ fzf not found$(NC)"
	@command -v fd >/dev/null && echo "$(GREEN)✓ fd is available$(NC)" || echo "$(YELLOW)⚠ fd not found$(NC)"
	@echo "✓ Checking version managers..."
	@command -v jenv >/dev/null && echo "$(GREEN)✓ jenv is available$(NC)" || echo "$(YELLOW)⚠ jenv not found$(NC)"
	@command -v rbenv >/dev/null && echo "$(GREEN)✓ rbenv is available$(NC)" || echo "$(YELLOW)⚠ rbenv not found$(NC)"
	@command -v pyenv >/dev/null && echo "$(GREEN)✓ pyenv is available$(NC)" || echo "$(YELLOW)⚠ pyenv not found$(NC)"
	@[[ -s "$$HOME/.nvm/nvm.sh" ]] && echo "$(GREEN)✓ nvm is available$(NC)" || echo "$(YELLOW)⚠ nvm not found$(NC)"
	@[[ -f "$$HOME/.antigen/antigen.zsh" ]] && echo "$(GREEN)✓ antigen is available$(NC)" || echo "$(YELLOW)⚠ antigen not found$(NC)"
	@echo "✓ Checking Docker environment..."
	@command -v docker >/dev/null && echo "$(GREEN)✓ Docker is available$(NC)" || echo "$(YELLOW)⚠ Docker not found (testing will be limited)$(NC)"

help: ## Show this help message
	@echo "$(BLUE)Dotfiles Management$(NC)"
	@echo "$(BLUE)===================$(NC)"
	@echo ""
	@echo "A modern task runner for dotfiles management using GNU Stow"
	@echo ""
	@echo "Usage:"
	@echo "  make $(BLUE)<target>$(NC)"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make list                               # See all available packages"
	@echo "  make install-core                       # Install essential packages"
	@echo "  make install PACKAGES=\"zsh git tmux\"  # Install specific packages"
	@echo "  make test                               # Run comprehensive tests"
	@echo "  make migrate                            # Migrate existing dotfiles to stow"
	@echo ""

.PHONY: help list install-core install-all install uninstall dry-run dry-run-all verify migrate test test-interactive test-status test-logs test-clean dev-build dev-shell clean clean-all status health
