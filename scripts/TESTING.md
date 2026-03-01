# Dotfiles Testing

This document describes the comprehensive testing system for validating the GNU Stow migration and package management setup.

## Quick Start

The testing environment runs automatically when you start the Docker container:

```bash
docker-compose up --build
```

This will:
1. Set up a clean testing environment
2. Copy only the stow management scripts and packages (no existing dotfiles)
3. Run the comprehensive test suite automatically
4. Show detailed results for all validation tests

## Test Suite Overview

The comprehensive test suite (`test-stow.sh`) validates 7 critical aspects:

### ✅ Test 1: Basic Functionality
- Verifies script permissions are correct
- Tests package listing functionality
- Ensures all management scripts are executable

### ✅ Test 2: Package Verification  
- Runs the package structure verification system
- Validates all 20 stow packages are properly organized
- Confirms no empty or malformed packages exist

### ✅ Test 3: Dry-Run Installation
- Tests dry-run installation of core packages
- Ensures preview mode works without side effects
- Validates command-line interface functionality

### ✅ Test 4: Package Structure
- Verifies the expected number of packages (20) exist
- Confirms stow-packages directory is properly organized
- Tests package counting and enumeration

### ✅ Test 5: Installation & Removal
- Tests complete installation workflow in clean environment
- Verifies symlinks are created correctly
- Tests package removal (unstow) functionality
- Confirms symlinks are properly cleaned up

### ✅ Test 6: Conflict Detection
- Creates conflicting files to test protection mechanisms
- Verifies stow correctly refuses to overwrite existing files
- Confirms existing user data is protected during installation

### ✅ Test 7: Migration Workflow
- Simulates existing dotfiles setup
- Tests backup creation functionality
- Validates post-migration installation process
- Ensures complete migration workflow works end-to-end

## Running Tests Manually

You can run specific tests or the full suite manually:

```bash
# Connect to running container
docker exec -it dotfiles-stow-test zsh
cd dotfiles-work

# Run the complete test suite
./test-stow.sh

# Run individual validation steps
./verify.sh              # Package structure verification
./install.sh --list      # List all packages  
./install.sh --dry-run --core  # Preview core installation
```

Alternatively, run tests directly:

```bash
docker-compose run dotfiles-test bash -c "cd dotfiles-work && ./test-stow.sh"
```

## Test Environment Details

The testing environment provides:

- **Clean baseline**: No existing dotfiles to cause conflicts
- **Ubuntu 22.04**: Standard LTS environment for testing
- **All dependencies**: Stow, git, zsh, tmux, neovim, etc.
- **Isolated execution**: Tests run in temporary directories
- **Comprehensive validation**: Every aspect of the stow system

### Environment Setup

The Docker container automatically:
1. Creates a working directory (`dotfiles-work`)
2. Copies only management scripts and stow packages
3. Sets proper permissions
4. Runs the test suite

This ensures a clean, conflict-free testing environment.

## Expected Results

All tests should pass with output like:

```
=== ALL TESTS PASSED ===
The stow system is working correctly!

Tests validated:
• Basic functionality (script permissions, package listing)
• Package structure verification (20 packages found)  
• Dry-run installation capabilities
• Package counting and structure validation
• Clean installation with proper symlink creation
• Package removal (unstow) functionality
• Conflict detection (protects existing files)
• Migration workflow with backup creation

✅ System ready for production deployment!
```

## Individual Test Commands

You can run specific aspects manually:

```bash
# Package management
./install.sh --list                 # List all packages
./install.sh --dry-run --core       # Preview core installation
./install.sh zsh git                # Install specific packages
./install.sh --unstow zsh           # Remove packages

# Migration testing
./migrate.sh                        # Test migration workflow

# Verification
./verify.sh                         # Verify package structure

# System exploration
ls -la ~/                           # Check home directory
ls -la ~/.config/                   # Check config directory
```

## Troubleshooting

If any tests fail:

1. **Check the logs**: Test output shows specific failure reasons
2. **Verify package structure**: Run `./verify.sh` for detailed validation
3. **Check permissions**: Ensure all scripts have execute permissions
4. **Review conflicts**: Failed installations may indicate existing file conflicts

### Common Issues

- **Permission Errors**: Scripts should automatically have execute permissions
- **Stow Conflicts**: Tests validate that conflicts are properly detected
- **Path Issues**: Tests run in isolated temporary directories

### Debugging Commands

```bash
# Run with verbose output
./install.sh --dry-run --core

# Check specific package structure
ls -la stow-packages/zsh/

# Test individual stow operation
cd /tmp && mkdir test && cd test
stow -n -v -t . -d /path/to/stow-packages zsh
```

## Production Confidence

This comprehensive testing system validates that:

- ✅ The migration approach is safe and protects existing files
- ✅ All package management functionality works correctly  
- ✅ The system handles edge cases and error conditions properly
- ✅ Installation, removal, and migration workflows are robust
- ✅ The setup is ready for deployment on any machine

## CI/CD Integration

The testing can be automated in CI/CD pipelines:

```bash
# Run tests in CI
docker-compose run --rm dotfiles-test bash -c "cd dotfiles-work && ./test-stow.sh"
```

Add to your `.github/workflows/test.yml`:

```yaml
name: Test Stow Setup
on: [push, pull_request]

jobs:
  test-stow:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test dotfiles stow setup
        run: |
          docker-compose run --rm dotfiles-test bash -c "cd dotfiles-work && ./test-stow.sh"
```

The testing system provides confidence that the stow migration approach is production-ready and will work reliably across different environments.

---

*Comprehensive automated testing for bulletproof dotfiles management* 🧪