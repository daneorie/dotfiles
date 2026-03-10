#!/bin/bash

# Docker Setup Verification Script
# Verifies that all Docker testing files are properly configured

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🐋 Docker Testing Setup Verification"
echo "===================================="
echo ""

# Check required files exist
echo "Checking required files..."
required_files=(
    "Dockerfile"
    "docker-compose.yml" 
    ".dockerignore"
    "test-stow.sh"
    "TESTING.md"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "✓ ${GREEN}$file${NC} exists"
    else
        echo -e "✗ ${RED}$file${NC} missing"
        exit 1
    fi
done

echo ""

# Check scripts are executable
echo "Checking script permissions..."
if [[ -x "test-stow.sh" ]]; then
    echo -e "✓ ${GREEN}test-stow.sh${NC} is executable"
else
    echo -e "✗ ${RED}test-stow.sh${NC} not executable"
    exit 1
fi

echo ""

# Validate docker-compose syntax
echo "Validating Docker configuration..."
if docker-compose config >/dev/null 2>&1; then
    echo -e "✓ ${GREEN}docker-compose.yml${NC} syntax valid"
else
    echo -e "✗ ${RED}docker-compose.yml${NC} syntax invalid"
    docker-compose config 2>&1 | head -5
    exit 1
fi

echo ""

# Check Docker availability
echo "Checking Docker availability..."
if command -v docker >/dev/null 2>&1; then
    echo -e "✓ ${GREEN}Docker${NC} command available"
    
    if docker info >/dev/null 2>&1; then
        echo -e "✓ ${GREEN}Docker daemon${NC} running"
        DOCKER_READY=true
    else
        echo -e "⚠ ${YELLOW}Docker daemon${NC} not running (start Docker to test)"
        DOCKER_READY=false
    fi
else
    echo -e "✗ ${RED}Docker${NC} not installed"
    DOCKER_READY=false
fi

echo ""

# Summary and instructions
echo "📋 Summary"
echo "========="
echo -e "✅ All Docker testing files are properly configured"
echo -e "✅ Scripts have correct permissions" 
echo -e "✅ Docker Compose configuration is valid"

if [[ "$DOCKER_READY" == "true" ]]; then
    echo -e "✅ Docker is ready for testing"
    echo ""
    echo -e "${GREEN}🚀 Ready to test!${NC} Run:"
    echo "   ./test-stow.sh auto        # Automated tests"
    echo "   ./test-stow.sh interactive # Interactive testing"
else
    echo -e "⚠ Docker needs to be started for testing"
    echo ""
    echo -e "${YELLOW}To test when Docker is ready:${NC}"
    echo "   1. Start Docker Desktop (or Docker daemon)"
    echo "   2. Run: ./test-stow.sh auto"
fi

echo ""
echo "📖 See TESTING.md for complete testing documentation"