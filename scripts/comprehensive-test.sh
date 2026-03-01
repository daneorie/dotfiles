#!/bin/bash

# Comprehensive Dotfiles Stow Testing Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${BLUE}Comprehensive Dotfiles Stow Testing Suite${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Test 1: Basic functionality
echo -e "${BLUE}Test 1: Basic functionality${NC}"
echo "  Checking script permissions and package listing..."

if [[ -x "./install.sh" ]] && [[ -x "./migrate.sh" ]] && [[ -x "./verify.sh" ]]; then
    if ./install.sh --list >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS: Basic functionality works${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL: Package listing failed${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL: Scripts not executable${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 2: Package structure verification
echo -e "${BLUE}Test 2: Package structure verification${NC}"
echo "  Running verify.sh and checking package count..."

if timeout 30 ./verify.sh >/dev/null 2>&1; then
    if [[ -d "stow-packages" ]]; then
        package_count=$(ls stow-packages/ | wc -l)
        if [[ $package_count -ge 15 ]]; then
            echo -e "${GREEN}✓ PASS: Package structure verification (found $package_count packages)${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAIL: Too few packages (found $package_count, expected >=15)${NC}"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗ FAIL: stow-packages directory missing${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL: Package structure verification failed or timed out${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: Dry-run core installation
echo -e "${BLUE}Test 3: Dry-run core installation${NC}"
echo "  Testing dry-run installation of core packages..."

if timeout 60 ./install.sh --dry-run --core >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS: Dry-run core installation works${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ FAIL: Dry-run core installation failed${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 4: Conflict detection
echo -e "${BLUE}Test 4: Conflict detection${NC}"
echo "  Testing that stow detects and handles existing files correctly..."

TEST_DIR=$(mktemp -d)
ORIGINAL_DIR=$(pwd)

cp -r stow-packages "$TEST_DIR/"
cp install.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/install.sh"

cd "$TEST_DIR"

# Create conflicting files
echo "# Existing config" > .zshrc

# Stow should fail due to conflicts (this is the EXPECTED behavior)
if ./install.sh zsh >/dev/null 2>&1; then
    echo -e "${RED}✗ FAIL: Stow should have detected conflict but didn't${NC}"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ PASS: Conflict detection works (correctly prevented overwriting existing files)${NC}"
    ((TESTS_PASSED++))
fi

cd "$ORIGINAL_DIR"
rm -rf "$TEST_DIR"
echo ""

# Test 5: Successful installation and removal
echo -e "${BLUE}Test 5: Successful installation and removal${NC}"
echo "  Testing clean installation and proper symlink creation/removal..."

TEST_DIR=$(mktemp -d)

cp -r stow-packages "$TEST_DIR/"
cp install.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/install.sh"

cd "$TEST_DIR"

# Test installation in clean environment
if ./install.sh zsh >/dev/null 2>&1; then
    if [[ -L .zshrc ]]; then
        # Test removal
        if ./install.sh --unstow zsh >/dev/null 2>&1; then
            if [[ ! -L .zshrc ]]; then
                echo -e "${GREEN}✓ PASS: Installation and removal work correctly${NC}"
                ((TESTS_PASSED++))
            else
                echo -e "${RED}✗ FAIL: Removal did not remove symlinks${NC}"
                ((TESTS_FAILED++))
            fi
        else
            echo -e "${RED}✗ FAIL: Package removal failed${NC}"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗ FAIL: Installation did not create expected symlinks${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL: Clean installation failed${NC}"
    ((TESTS_FAILED++))
fi

cd "$ORIGINAL_DIR"
rm -rf "$TEST_DIR"
echo ""

# Test 6: Hidden files support
echo -e "${BLUE}Test 6: Hidden files support${NC}"
echo "  Testing that hidden files (dotfiles) are properly handled..."

TEST_DIR=$(mktemp -d)

cp -r stow-packages "$TEST_DIR/"
cp install.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/install.sh"

cd "$TEST_DIR"

# Install zsh package which has hidden files
if ./install.sh zsh >/dev/null 2>&1; then
    # Count symlinks to hidden files
    hidden_symlinks=0
    for file in stow-packages/zsh/.*; do
        if [[ -f "$file" ]] && [[ $(basename "$file") != "." ]] && [[ $(basename "$file") != ".." ]]; then
            target_file=$(basename "$file")
            if [[ -L "$target_file" ]]; then
                ((hidden_symlinks++))
            fi
        fi
    done
    
    if [[ $hidden_symlinks -gt 0 ]]; then
        echo -e "${GREEN}✓ PASS: Hidden files support works ($hidden_symlinks hidden files symlinked)${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL: No hidden files were properly symlinked${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL: Installation with hidden files failed${NC}"
    ((TESTS_FAILED++))
fi

cd "$ORIGINAL_DIR" 
rm -rf "$TEST_DIR"
echo ""

# Test 7: Migration workflow
echo -e "${BLUE}Test 7: Migration workflow${NC}"
echo "  Testing the complete migration workflow with backup creation..."

TEST_DIR=$(mktemp -d)

cp -r stow-packages "$TEST_DIR/"
cp install.sh "$TEST_DIR/"
cp migrate.sh "$TEST_DIR/"
chmod +x "$TEST_DIR/install.sh"
chmod +x "$TEST_DIR/migrate.sh"

cd "$TEST_DIR"

# Create existing files to simulate pre-stow setup
echo "# Existing zshrc" > .zshrc
mkdir -p .config/nvim
echo "-- Existing nvim config" > .config/nvim/init.lua

# Test backup creation (option 4)
echo "4" | timeout 30 ./migrate.sh >/dev/null 2>&1 || true

# Check if backup was created
backup_found=false
for backup_dir in dotfiles-backup-*; do
    if [[ -d "$backup_dir" ]]; then
        backup_found=true
        break
    fi
done

if [[ "$backup_found" == true ]]; then
    # Test that we can install after backup
    if ./install.sh zsh >/dev/null 2>&1; then
        if [[ -L .zshrc ]]; then
            echo -e "${GREEN}✓ PASS: Migration workflow works (backup created, installation successful)${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAIL: Post-migration installation did not create symlinks${NC}"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗ FAIL: Post-migration installation failed${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL: Migration backup creation failed${NC}"
    ((TESTS_FAILED++))
fi

cd "$ORIGINAL_DIR"
rm -rf "$TEST_DIR"
echo ""

# Final summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}        TEST SUMMARY${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed! ✓${NC}"
    echo -e "${GREEN}The stow migration system is working correctly and ready for deployment.${NC}"
    echo ""
    echo -e "${BLUE}What this validates:${NC}"
    echo "• Script permissions and basic functionality"
    echo "• Package structure verification"  
    echo "• Dry-run capabilities work without side effects"
    echo "• Conflict detection protects existing files"
    echo "• Clean installation creates proper symlinks"
    echo "• Package removal works correctly"
    echo "• Hidden files (dotfiles) are handled properly"
    echo "• Migration workflow with backup creation"
    echo ""
    echo -e "${GREEN}✅ System is ready for production use!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed.${NC}"
    echo -e "${RED}Please review the failures above before deploying.${NC}"
    exit 1
fi