#!/bin/bash

# Cleanup Script for AppleBite Application
# Cleans up Docker containers, images, and volumes

set -e

echo "======================================"
echo "AppleBite Application Cleanup"
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
CLEANUP_TYPE=${1:-"containers"}

echo -e "${YELLOW}Cleanup Type: $CLEANUP_TYPE${NC}"
echo ""

# Function to confirm action
confirm() {
    read -p "$1 (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Cancelled"
        return 1
    fi
    return 0
}

case $CLEANUP_TYPE in
    containers)
        echo "Stopping all AppleBite containers..."

        cd docker

        docker-compose -f docker-compose.test.yml down || true
        docker-compose -f docker-compose.stage.yml down || true
        docker-compose -f docker-compose.prod.yml down || true

        echo -e "${GREEN}✓${NC} All containers stopped"
        ;;

    images)
        if confirm "Remove all AppleBite Docker images?"; then
            echo "Removing AppleBite images..."

            docker images | grep applebite-app | awk '{print $3}' | xargs -r docker rmi -f || true

            echo -e "${GREEN}✓${NC} Images removed"
        fi
        ;;

    volumes)
        if confirm "Remove all AppleBite Docker volumes? This will delete all data!"; then
            echo "Removing volumes..."

            docker volume ls | grep applebite | awk '{print $2}' | xargs -r docker volume rm || true

            echo -e "${GREEN}✓${NC} Volumes removed"
        fi
        ;;

    all)
        if confirm "Remove ALL AppleBite resources (containers, images, volumes)?"; then
            echo "Performing complete cleanup..."

            # Stop containers
            cd docker
            docker-compose -f docker-compose.test.yml down -v || true
            docker-compose -f docker-compose.stage.yml down -v || true
            docker-compose -f docker-compose.prod.yml down -v || true
            cd ..

            # Remove images
            docker images | grep applebite | awk '{print $3}' | xargs -r docker rmi -f || true

            # Remove volumes
            docker volume ls | grep applebite | awk '{print $2}' | xargs -r docker volume rm || true

            # Clean up logs
            rm -rf logs/*.log

            echo -e "${GREEN}✓${NC} Complete cleanup done"
        fi
        ;;

    logs)
        echo "Cleaning up log files..."
        rm -rf logs/*.log
        echo -e "${GREEN}✓${NC} Logs cleaned"
        ;;

    *)
        echo "Usage: $0 [containers|images|volumes|all|logs]"
        echo ""
        echo "Options:"
        echo "  containers  - Stop and remove all containers"
        echo "  images      - Remove all Docker images"
        echo "  volumes     - Remove all Docker volumes (data will be lost)"
        echo "  all         - Remove everything"
        echo "  logs        - Clean up log files"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Cleanup Complete!"
echo "======================================"
echo ""

# Show remaining resources
echo "Remaining AppleBite resources:"
echo ""
echo "Containers:"
docker ps -a | grep applebite || echo "  None"
echo ""
echo "Images:"
docker images | grep applebite || echo "  None"
echo ""
echo "Volumes:"
docker volume ls | grep applebite || echo "  None"
echo ""
