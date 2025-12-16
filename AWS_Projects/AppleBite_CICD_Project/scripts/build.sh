#!/bin/bash

# Build Script for AppleBite Application
# Builds Docker images for all environments

set -e

echo "======================================"
echo "AppleBite Application Build"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Parse arguments
BUILD_ENV=${1:-"all"}

echo -e "${YELLOW}Build Environment: $BUILD_ENV${NC}"
echo ""

# Function to build image
build_image() {
    local env=$1
    local target=$2

    echo "Building Docker image for $env environment..."

    docker build \
        --target $target \
        -t applebite-app:$env \
        -f docker/Dockerfile \
        .

    echo -e "${GREEN}✓${NC} Image built: applebite-app:$env"
    echo ""
}

# Build based on environment
case $BUILD_ENV in
    test)
        build_image "test" "development"
        ;;
    stage)
        build_image "stage" "production"
        ;;
    prod|production)
        build_image "prod" "production"
        ;;
    all)
        build_image "test" "development"
        build_image "stage" "production"
        build_image "prod" "production"
        ;;
    *)
        echo "Usage: $0 [test|stage|prod|all]"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Build Complete!"
echo "======================================"
echo ""
echo "Available images:"
docker images | grep applebite-app || echo "No applebite images found"
echo ""
