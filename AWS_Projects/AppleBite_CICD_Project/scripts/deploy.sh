#!/bin/bash

# Deploy Script for AppleBite Application
# Deploys application to specified environment

set -e

echo "======================================"
echo "AppleBite Application Deployment"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Parse arguments
DEPLOY_ENV=${1:-"test"}

# Validate environment
case $DEPLOY_ENV in
    test|stage|prod|production)
        ;;
    *)
        echo -e "${RED}Error: Invalid environment${NC}"
        echo "Usage: $0 [test|stage|prod]"
        exit 1
        ;;
esac

# Normalize prod/production
if [ "$DEPLOY_ENV" = "production" ]; then
    DEPLOY_ENV="prod"
fi

echo -e "${YELLOW}Deploying to: $DEPLOY_ENV${NC}"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

# Check if app directory exists
if [ ! -d "app" ]; then
    echo -e "${YELLOW}Application not found. Running setup...${NC}"
    ./scripts/setup.sh
fi

# Build the application
echo "Building application..."
./scripts/build.sh $DEPLOY_ENV

# Deploy using Docker Compose
echo ""
echo "Deploying to $DEPLOY_ENV environment..."

cd docker

case $DEPLOY_ENV in
    test)
        docker-compose -f docker-compose.test.yml down || true
        docker-compose -f docker-compose.test.yml up -d
        PORT=8080
        ;;
    stage)
        docker-compose -f docker-compose.stage.yml down || true
        docker-compose -f docker-compose.stage.yml up -d
        PORT=8081
        ;;
    prod)
        # Production requires confirmation
        echo -e "${YELLOW}WARNING: Deploying to PRODUCTION${NC}"
        read -p "Are you sure? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            echo "Deployment cancelled"
            exit 0
        fi

        docker-compose -f docker-compose.prod.yml down || true
        docker-compose -f docker-compose.prod.yml up -d
        PORT=8082
        ;;
esac

cd ..

# Wait for application to start
echo ""
echo "Waiting for application to start..."
sleep 15

# Check if application is running
echo "Checking application health..."
if curl -f http://localhost:$PORT >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Application is running"
else
    echo -e "${YELLOW}!${NC} Application may still be starting..."
fi

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
echo "Environment: $DEPLOY_ENV"
echo "URL: http://localhost:$PORT"
echo ""
echo "To view logs:"
echo "  cd docker && docker-compose -f docker-compose.$DEPLOY_ENV.yml logs -f"
echo ""
echo "To stop:"
echo "  cd docker && docker-compose -f docker-compose.$DEPLOY_ENV.yml down"
echo ""
