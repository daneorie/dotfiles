#!/bin/bash

# Dotfiles Stow Testing Runner
# Simple wrapper for Docker-based testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="dotfiles-stow-test"

show_help() {
    echo -e "${BLUE}Dotfiles Stow Testing Runner${NC}"
    echo ""
    echo "Usage: ./test.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  (no args)     Run full test suite automatically"
    echo "  interactive   Start interactive testing session"
    echo "  cleanup       Clean up test containers and images"
    echo "  status        Check if test container is running"
    echo "  logs          Show container logs"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./test.sh                 # Run all tests"
    echo "  ./test.sh interactive     # Start interactive session"
    echo "  ./test.sh cleanup         # Clean up after testing"
    echo ""
}

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
        echo "Please install Docker first: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Please start Docker first"
        exit 1
    fi

    if ! command -v docker-compose >/dev/null 2>&1; then
        echo -e "${RED}Error: docker-compose is not installed or not in PATH${NC}"
        echo "Please install docker-compose first"
        exit 1
    fi
}

check_files() {
    if [[ ! -f "../docker/docker-compose.yml" ]] || [[ ! -f "../docker/Dockerfile" ]]; then
        echo -e "${RED}Error: Docker configuration files not found${NC}"
        echo "Please run this script from the dotfiles directory containing:"
        echo "  - docker/docker-compose.yml"
        echo "  - docker/Dockerfile"
        exit 1
    fi
}

run_tests() {
    echo -e "${BLUE}Running Dotfiles Stow Test Suite${NC}"
    echo -e "${BLUE}==================================${NC}"
    echo ""
    
    echo "Building and starting test environment..."
    cd ../docker && docker-compose up --build && cd ../scripts
    
    echo ""
    echo -e "${GREEN}Test run completed!${NC}"
    echo ""
    echo "To run tests again: ./test.sh"
    echo "For interactive testing: ./test.sh interactive"
    echo "To clean up: ./test.sh cleanup"
}

run_interactive() {
    echo -e "${BLUE}Starting Interactive Testing Session${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo ""
    
    # Check if container is already running
    if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"; then
        echo "Container already running. Connecting..."
        docker exec -it "$CONTAINER_NAME" zsh -c "cd dotfiles-work && zsh"
    else
        echo "Starting new test environment..."
        echo "After setup completes, you'll be in an interactive shell."
        echo ""
        echo "Available commands in the container:"
        echo "  ./test-stow.sh            # Run full test suite"
        echo "  ./install.sh --list       # List packages"
        echo "  ./install.sh --dry-run --core  # Preview installation"
        echo "  ./verify.sh               # Verify package structure"
        echo "  ./migrate.sh              # Test migration workflow"
        echo ""
        cd ../docker && docker-compose run --rm dotfiles-test && cd ../scripts
    fi
}

cleanup() {
    echo -e "${YELLOW}Cleaning up test environment...${NC}"
    
    # Stop and remove containers
    cd ../docker && docker-compose down --remove-orphans 2>/dev/null && cd ../scripts || true
    
    # Remove any orphaned containers
    if docker ps -a --filter "name=$CONTAINER_NAME" | grep -q "$CONTAINER_NAME"; then
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    fi
    
    # Clean up Docker images (optional)
    if docker images | grep -q "dotfiles.*dotfiles-test"; then
        echo "Removing test Docker image..."
        docker rmi $(docker images --filter "reference=dotfiles*dotfiles-test*" -q) 2>/dev/null || true
    fi
    
    # Clean up any test log files
    rm -f test1.log test2.log test3.log 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup completed!${NC}"
}

show_status() {
    echo -e "${BLUE}Test Environment Status${NC}"
    echo -e "${BLUE}======================${NC}"
    echo ""
    
    if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ Container is running${NC}"
        echo ""
        echo "To connect: ./test.sh interactive"
        echo "To view logs: ./test.sh logs"
        echo "To stop: ./test.sh cleanup"
    else
        echo -e "${YELLOW}Container is not running${NC}"
        echo ""
        echo "To start tests: ./test.sh"
        echo "For interactive mode: ./test.sh interactive"
    fi
}

show_logs() {
    if docker ps -a --filter "name=$CONTAINER_NAME" | grep -q "$CONTAINER_NAME"; then
        echo -e "${BLUE}Container Logs${NC}"
        echo -e "${BLUE}==============${NC}"
        docker logs "$CONTAINER_NAME"
    else
        echo -e "${YELLOW}No container found${NC}"
        echo "Run ./test.sh to start testing"
    fi
}

main() {
    # Check prerequisites
    check_docker
    check_files
    
    case "${1:-}" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "interactive"|"i")
            run_interactive
            ;;
        "cleanup"|"clean")
            cleanup
            ;;
        "status"|"s")
            show_status
            ;;
        "logs"|"log")
            show_logs
            ;;
        "")
            run_tests
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$1'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"