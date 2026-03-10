# Docker Testing Environment

This directory contains Docker configuration for testing both the complete dotfiles setup and stow-only functionality in isolated environments.

## Files

- **`Dockerfile`** - Ubuntu 22.04 based testing environment with comprehensive toolset
- **`docker-compose.yml`** - Service configurations for different test scenarios
- **`.dockerignore`** - Files to exclude from Docker build context

## Available Test Environments

### 1. Complete Setup Testing (`dotfiles-test`)
Tests the full installation process including dependencies, version managers, and stow packages.

### 2. Stow-Only Testing (`dotfiles-stow-test`)  
Tests only the stow package management functionality.

## Quick Start

### Using Task Runners (Recommended)
```bash
# Test complete setup process
make test-complete           # Full dependency + stow testing
just test-complete

# Test stow-only functionality  
make test-stow-only          # Stow package management only
just test-stow-only

# Traditional comprehensive tests
make test                    # Run existing test suite
just test
```

### From the scripts directory:
```bash
cd ../scripts
./test.sh                    # Run full test suite
./test.sh interactive        # Interactive testing session
./test.sh cleanup           # Clean up containers
```

### Direct Docker usage:
```bash
cd docker/

# Test complete setup process
docker-compose up --build dotfiles-test

# Test stow-only process  
docker-compose up --build dotfiles-stow-test

# Interactive sessions
docker-compose run --rm dotfiles-test        # Complete setup environment
docker-compose run --rm dotfiles-stow-test   # Stow-only environment

# Cleanup
docker-compose down         # Stop and remove containers
```

## Environment Details

### Complete Setup Environment (`dotfiles-test`)
- **Base**: Ubuntu 22.04 LTS with comprehensive development tools
- **User**: `testuser` (non-root for realistic testing)
- **Tools**: Homebrew, git, stow, zsh, tmux, neovim, build tools, etc.
- **Working Directory**: `/home/testuser/dotfiles-work`
- **Mount**: Parent directory mounted read-only as `/home/testuser/dotfiles`
- **Tests**: Full dependency installation + stow packages

### Stow-Only Environment (`dotfiles-stow-test`)
- **Base**: Ubuntu 22.04 LTS with minimal required tools
- **User**: `testuser` (non-root)
- **Tools**: Essential tools for stow testing only
- **Working Directory**: `/home/testuser/dotfiles-work`  
- **Mount**: Parent directory mounted read-only as `/home/testuser/dotfiles`
- **Tests**: Package management and stow functionality only

## Test Scenarios

### Complete Setup Testing
1. **Bootstrap**: Tests package manager installation
2. **Dependencies**: Tests development tool installation
3. **Version Managers**: Tests jenv, rbenv, pyenv, nvm, antigen setup
4. **Stow Packages**: Tests dotfiles configuration installation
5. **Health Check**: Verifies complete system functionality

### Stow-Only Testing  
1. **Setup**: Creates clean working directory in container
2. **Copy**: Copies management scripts and stow packages from host
3. **Test**: Runs comprehensive stow test suite automatically
4. **Interactive**: Drops to shell for manual testing

## Available Commands in Containers

### Complete Setup Container
```bash
cd dotfiles-work

# Test complete setup
make complete-setup              # Complete setup with core packages
make complete-setup-all          # Complete setup with all packages
make complete-setup-verbose      # Detailed output

# Test individual components  
make bootstrap                   # Test package manager setup
make install-deps               # Test dependency installation
make setup-tools                # Test version manager setup
make install-core               # Test dotfiles installation

# Verification
make health                      # Health check
make status                      # Show status
```

### Stow-Only Container
```bash
cd dotfiles-work

# Test stow functionality
./scripts/install.sh --list              # List packages
./scripts/install.sh --dry-run --core    # Test core installation
./scripts/migrate.sh                     # Test migration
./scripts/verify.sh                      # Verify packages
./scripts/test-stow.sh                   # Run comprehensive test suite
```

## Configuration

The `docker-compose.yml` provides two services:
- **dotfiles-test**: Complete setup testing with all dependencies
- **dotfiles-stow-test**: Stow-only testing for package management

Both environments:
- Build from the parent directory context
- Mount the entire dotfiles directory as read-only
- Run as non-root user for realistic testing
- Provide interactive shells after automated testing

## Troubleshooting

### Build Issues
```bash
docker-compose build --no-cache dotfiles-test      # Force rebuild complete env
docker-compose build --no-cache dotfiles-stow-test # Force rebuild stow env
docker system prune                                # Clean up Docker cache
```

### Permission Issues
Containers run as `testuser` (non-root) to simulate real usage conditions.

### Path Issues
Make sure you're running commands from the correct directory:
- Scripts should run from `scripts/` directory
- Docker commands should run from `docker/` directory  
- Task runners (make/just) should run from root directory

### Service Selection
When using docker-compose, specify the service name:
- `docker-compose up dotfiles-test` - Complete setup testing
- `docker-compose up dotfiles-stow-test` - Stow-only testing