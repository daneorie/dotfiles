# Dotfiles Management Makefile
# Modern task runner for dotfiles management

.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ Package Management
list: ## List all available packages
	@cd $(CURDIR) && ./scripts/install.sh --list

install-core: ## Install core packages (zsh, wezterm, tmux, git, vim, nvim, yabai)
	@cd $(CURDIR) && ./scripts/install.sh --core

install-all: ## Install all packages
	@cd $(CURDIR) && ./scripts/install.sh --all

install: ## Install specific packages (usage: make install PACKAGES="zsh git tmux")
	@if [ -z "$(PACKAGES)" ]; then \
		echo -e "$(RED)Error: Please specify packages to install$(NC)"; \
		echo "Usage: make install PACKAGES=\"zsh git tmux\""; \
		exit 1; \
	fi
	@cd $(CURDIR) && ./scripts/install.sh $(PACKAGES)

uninstall: ## Remove specific packages (usage: make uninstall PACKAGES="zsh git")
	@if [ -z "$(PACKAGES)" ]; then \
		echo -e "$(RED)Error: Please specify packages to remove$(NC)"; \
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

##@ Testing
test: ## Run comprehensive test suite
	@echo -e "$(BLUE)Running comprehensive test suite...$(NC)"
	@cd scripts && ./test.sh

test-interactive: ## Start interactive testing session
	@echo -e "$(BLUE)Starting interactive testing session...$(NC)"
	@cd scripts && ./test.sh interactive

test-status: ## Check testing container status
	@cd scripts && ./test.sh status

test-logs: ## Show testing container logs
	@cd scripts && ./test.sh logs

test-clean: ## Clean up test environment
	@cd scripts && ./test.sh cleanup

##@ Development  
dev-build: ## Build Docker test environment without running tests
	@echo -e "$(BLUE)Building Docker test environment...$(NC)"
	@cd docker && docker-compose build

dev-shell: ## Get shell access to test container
	@cd scripts && ./test.sh interactive

##@ Maintenance
clean: ## Clean up temporary files and test artifacts
	@echo -e "$(YELLOW)Cleaning up temporary files...$(NC)"
	@rm -f test1.log test2.log test3.log 2>/dev/null || true
	@rm -f *.log 2>/dev/null || true
	@echo -e "$(GREEN)Cleanup completed!$(NC)"

clean-all: test-clean clean ## Full cleanup (test environment + temp files)

##@ Information
status: ## Show current dotfiles status
	@echo -e "$(BLUE)Dotfiles Status$(NC)"
	@echo -e "$(BLUE)===============$(NC)"
	@echo ""
	@echo "📁 Package count: $$(ls stow-packages/ | wc -l | tr -d ' ')"
	@echo "📋 Available packages:"
	@ls stow-packages/ | sed 's/^/  - /'
	@echo ""
	@echo "🔗 Current symlinks in home directory:"
	@find ~/ -maxdepth 1 -type l 2>/dev/null | head -10 || echo "  (none found at top level)"

health: ## Health check - verify everything is working
	@echo -e "$(BLUE)Running health check...$(NC)"
	@echo ""
	@echo "✓ Checking package structure..."
	@cd $(CURDIR) && ./scripts/verify.sh > /dev/null && echo -e "$(GREEN)✓ Package structure is valid$(NC)" || echo -e "$(RED)✗ Package structure issues found$(NC)"
	@echo "✓ Checking script permissions..."
	@[ -x scripts/install.sh ] && [ -x scripts/migrate.sh ] && [ -x scripts/verify.sh ] && echo -e "$(GREEN)✓ All scripts are executable$(NC)" || echo -e "$(RED)✗ Script permission issues$(NC)"
	@echo "✓ Checking Docker environment..."
	@command -v docker >/dev/null && echo -e "$(GREEN)✓ Docker is available$(NC)" || echo -e "$(YELLOW)⚠ Docker not found (testing will be limited)$(NC)"

help: ## Show this help message
	@echo -e "$(BLUE)Dotfiles Management$(NC)"
	@echo -e "$(BLUE)==================$(NC)"
	@echo ""
	@echo "A modern task runner for dotfiles management using GNU Stow"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make list                    # See all available packages"
	@echo "  make install-core            # Install essential packages"
	@echo "  make install PACKAGES=\"zsh git\"  # Install specific packages"
	@echo "  make test                    # Run comprehensive tests"
	@echo "  make migrate                 # Migrate existing dotfiles to stow"
	@echo ""

.PHONY: help list install-core install-all install uninstall dry-run dry-run-all verify migrate test test-interactive test-status test-logs test-clean dev-build dev-shell clean clean-all status health