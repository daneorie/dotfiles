#!/bin/bash

# Test individual functions
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

test_package_structure() {
    echo "  Testing verify.sh..."
    # Test package structure verification
    if ! timeout 30 ./verify.sh >/dev/null 2>&1; then
        echo "Package structure verification failed or timed out"
        return 1
    fi
    
    echo "  Checking stow-packages directory..."
    # Check that stow packages directory exists and has packages
    if [[ ! -d "stow-packages" ]]; then
        echo "stow-packages directory does not exist"
        return 1
    fi
    
    echo "  Counting packages..."
    local package_count=$(ls stow-packages/ | wc -l)
    if [[ $package_count -lt 15 ]]; then
        echo "Expected at least 15 packages, found $package_count"
        return 1
    fi
    
    echo "  Found $package_count packages"
    return 0
}

echo "Running individual test function..."
if test_package_structure; then
    echo -e "${GREEN}✓ Package structure test passed${NC}"
else 
    echo -e "${RED}✗ Package structure test failed${NC}"
fi