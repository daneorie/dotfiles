# Docker Testing Environment

This directory contains Docker configuration files for testing the dotfiles stow setup in an isolated environment.

## Files

- **`Dockerfile`** - Ubuntu 22.04 based testing environment with all required tools
- **`docker-compose.yml`** - Service configuration for the test environment
- **`.dockerignore`** - Files to exclude from Docker build context

## Quick Start

### From the scripts directory:
```bash
cd ../scripts
./test.sh                    # Run full test suite
./test.sh interactive        # Interactive testing session
./test.sh cleanup           # Clean up containers
```

### From the root directory with task runners:
```bash
make test                    # Run tests (Makefile)
just test                    # Run tests (Just)
```

### Direct Docker usage:
```bash
cd docker/
docker-compose up --build   # Build and run tests
docker-compose run --rm dotfiles-test  # Interactive session
docker-compose down         # Stop and remove containers
```

## Environment Details

The Docker environment provides:
- **Base**: Ubuntu 22.04 LTS
- **User**: `testuser` (non-root for realistic testing)
- **Tools**: stow, git, zsh, tmux, neovim, vim, fd-find, fzf, ripgrep
- **Working Directory**: `/home/testuser/dotfiles-work`
- **Mount**: Parent directory mounted read-only as `/home/testuser/dotfiles`

## Test Process

1. **Setup**: Creates clean working directory in container
2. **Copy**: Copies management scripts and stow packages from host
3. **Test**: Runs comprehensive test suite automatically
4. **Interactive**: Drops to shell for manual testing

## Configuration

The `docker-compose.yml` is configured to:
- Build from the parent directory context
- Mount the entire dotfiles directory as read-only
- Automatically run the test suite on startup
- Provide an interactive shell after testing

## Troubleshooting

### Build Issues
```bash
docker-compose build --no-cache  # Force rebuild
docker system prune              # Clean up Docker cache
```

### Permission Issues
The container runs as `testuser` (non-root) to simulate real usage conditions.

### Path Issues
Make sure you're running commands from the correct directory:
- Scripts should run from `scripts/` directory
- Docker commands should run from `docker/` directory  
- Task runners (make/just) should run from root directory