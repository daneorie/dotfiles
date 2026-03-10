#!/bin/bash

# Simple test to validate the stow setup
echo "=== Simple Dotfiles Stow Test ==="

# Check if key scripts exist and are executable
echo "1. Testing script presence and permissions..."
if [[ -x "./install.sh" ]] && [[ -x "./migrate.sh" ]] && [[ -x "./verify.sh" ]]; then
    echo "✓ All scripts are present and executable"
else
    echo "✗ Missing or non-executable scripts"
    exit 1
fi

# Test package listing
echo "2. Testing package listing..."
if ./install.sh --list >/dev/null 2>&1; then
    echo "✓ Package listing works"
else
    echo "✗ Package listing failed"
    exit 1
fi

# Test package verification
echo "3. Testing package verification..."
if timeout 30 ./verify.sh >/dev/null 2>&1; then
    echo "✓ Package verification works"
else
    echo "✗ Package verification failed or timed out"
    exit 1
fi

# Test dry run
echo "4. Testing dry-run installation..."
if ./install.sh --dry-run --core >/dev/null 2>&1; then
    echo "✓ Dry-run installation works"
else
    echo "✗ Dry-run installation failed"
    exit 1
fi

# Test actual installation in temp directory
echo "5. Testing actual installation..."
TEST_DIR=$(mktemp -d)
ORIGINAL_DIR=$(pwd)

# Copy necessary files
cp -r stow-packages "$TEST_DIR/"
cp install.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/install.sh"

cd "$TEST_DIR"

# Test installation
if ./install.sh zsh >/dev/null 2>&1; then
    if [[ -L .zshrc ]]; then
        echo "✓ Installation creates symlinks correctly"
        # Test removal
        if ./install.sh --unstow zsh >/dev/null 2>&1; then
            if [[ ! -L .zshrc ]]; then
                echo "✓ Removal works correctly"
            else
                echo "✗ Removal failed to remove symlinks"
                cd "$ORIGINAL_DIR"
                rm -rf "$TEST_DIR"
                exit 1
            fi
        else
            echo "✗ Removal failed"
            cd "$ORIGINAL_DIR"
            rm -rf "$TEST_DIR"
            exit 1
        fi
    else
        echo "✗ Installation failed to create symlinks"
        cd "$ORIGINAL_DIR"
        rm -rf "$TEST_DIR"
        exit 1
    fi
else
    echo "✗ Installation failed"
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test conflict detection
echo "6. Testing conflict detection..."
# Create conflicting file
echo "# existing config" > .zshrc

# Try to install, should fail due to conflict
if ./install.sh zsh >/dev/null 2>&1; then
    echo "✗ Stow should have detected conflict but didn't"
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
    exit 1
else
    echo "✓ Conflict detection works correctly"
fi

# Cleanup
cd "$ORIGINAL_DIR"
rm -rf "$TEST_DIR"

echo ""
echo "=== All tests passed! ==="
echo "The stow setup is working correctly."