#!/bin/bash

# Reset Script for AppleBite CI/CD Project
# This script completely removes all resources created by this solution
# USE WITH CAUTION - This will delete containers, images, volumes, and app files

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${RED}"
cat << "EOF"
 ██████╗ ███████╗███████╗███████╗████████╗
 ██╔══██╗██╔════╝██╔════╝██╔════╝╚══██╔══╝
 ██████╔╝█████╗  ███████╗█████╗     ██║
 ██╔══██╗██╔══╝  ╚════██║██╔══╝     ██║
 ██║  ██║███████╗███████║███████╗   ██║
 ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝

 AppleBite CI/CD Project - Complete Reset
EOF
echo -e "${NC}"

echo -e "${YELLOW}WARNING: This script will DELETE:${NC}"
echo ""
echo "  • All Docker containers (test, stage, prod)"
echo "  • All Docker images (applebite-app)"
echo "  • All Docker volumes (including databases)"
echo "  • All Docker networks"
echo "  • Jenkins container and data"
echo "  • Application files (app/ directory)"
echo "  • Log files"
echo ""
echo -e "${RED}THIS ACTION CANNOT BE UNDONE!${NC}"
echo ""

# Confirmation
read -p "Are you ABSOLUTELY sure you want to reset everything? Type 'yes' to continue: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo -e "${GREEN}Reset cancelled. No changes made.${NC}"
    exit 0
fi

echo ""
read -p "Type 'DELETE' to confirm (case-sensitive): " CONFIRM2

if [ "$CONFIRM2" != "DELETE" ]; then
    echo ""
    echo -e "${GREEN}Reset cancelled. No changes made.${NC}"
    exit 0
fi

echo ""
echo -e "${MAGENTA}======================================"
echo "  Starting Complete Reset Process"
echo -e "======================================${NC}"
echo ""

ITEMS_DELETED=0

# Function to display status
show_status() {
    local message=$1
    echo -e "${BLUE}▶${NC} $message"
}

show_success() {
    local message=$1
    echo -e "${GREEN}✓${NC} $message"
    ((ITEMS_DELETED++))
}

show_info() {
    local message=$1
    echo -e "${YELLOW}ℹ${NC} $message"
}

# 1. Stop and remove all AppleBite containers
show_status "Stopping and removing AppleBite containers..."

cd docker 2>/dev/null || cd .

if [ -f "docker-compose.test.yml" ]; then
    if docker-compose -f docker-compose.test.yml down -v 2>/dev/null; then
        show_success "Test environment stopped"
    else
        show_info "Test environment not running"
    fi
fi

if [ -f "docker-compose.stage.yml" ]; then
    if docker-compose -f docker-compose.stage.yml down -v 2>/dev/null; then
        show_success "Stage environment stopped"
    else
        show_info "Stage environment not running"
    fi
fi

if [ -f "docker-compose.prod.yml" ]; then
    if docker-compose -f docker-compose.prod.yml down -v 2>/dev/null; then
        show_success "Production environment stopped"
    else
        show_info "Production environment not running"
    fi
fi

cd "$SCRIPT_DIR"

# Remove any remaining AppleBite containers
CONTAINERS=$(docker ps -a -q --filter "name=applebite" 2>/dev/null || true)
if [ -n "$CONTAINERS" ]; then
    docker rm -f $CONTAINERS 2>/dev/null || true
    show_success "Removed remaining AppleBite containers"
else
    show_info "No additional AppleBite containers found"
fi

echo ""

# 2. Remove Docker images
show_status "Removing Docker images..."

IMAGES=$(docker images -q "applebite-app" 2>/dev/null || true)
if [ -n "$IMAGES" ]; then
    docker rmi -f $IMAGES 2>/dev/null || true
    show_success "Removed AppleBite images"
else
    show_info "No AppleBite images found"
fi

echo ""

# 3. Remove Docker volumes
show_status "Removing Docker volumes..."

VOLUMES=$(docker volume ls -q 2>/dev/null | grep -E "(applebite|test-db-data|stage-db-data|prod-db-data)" 2>/dev/null || true)
if [ -n "$VOLUMES" ]; then
    echo "$VOLUMES" | xargs docker volume rm 2>/dev/null || true
    show_success "Removed AppleBite volumes"
else
    show_info "No AppleBite volumes found"
fi

echo ""

# 4. Remove Docker networks
show_status "Removing Docker networks..."

NETWORKS=$(docker network ls -q --filter "name=applebite" 2>/dev/null || true)
if [ -n "$NETWORKS" ]; then
    echo "$NETWORKS" | xargs docker network rm 2>/dev/null || true
    show_success "Removed AppleBite networks"
else
    show_info "No AppleBite networks found"
fi

echo ""

# 5. Stop and remove Jenkins container
show_status "Removing Jenkins container..."

if docker ps -a 2>/dev/null | grep -q "jenkins-applebite"; then
    docker stop jenkins-applebite 2>/dev/null || true
    docker rm -f jenkins-applebite 2>/dev/null || true
    show_success "Removed Jenkins container"
else
    show_info "Jenkins container not found"
fi

echo ""

# 6. Remove Jenkins data directory
show_status "Removing Jenkins data..."

if [ -d "jenkins_home" ]; then
    rm -rf jenkins_home 2>/dev/null || true
    show_success "Removed Jenkins data directory"
else
    show_info "Jenkins data directory not found"
fi

echo ""

# 7. Remove application directory
show_status "Removing application files..."

if [ -d "app" ]; then
    read -p "Remove app/ directory? This contains the cloned application. (yes/no): " REMOVE_APP
    if [ "$REMOVE_APP" = "yes" ]; then
        rm -rf app 2>/dev/null || true
        show_success "Removed app/ directory"
    else
        show_info "Keeping app/ directory"
    fi
else
    show_info "App directory not found"
fi

echo ""

# 8. Remove log files
show_status "Removing log files..."

if [ -d "logs" ]; then
    rm -rf logs/*.log 2>/dev/null || true
    show_success "Removed log files"
else
    show_info "No log directory found"
fi

if [ -d "docker/logs" ]; then
    rm -rf docker/logs 2>/dev/null || true
    show_success "Removed Docker log files"
fi

echo ""

# 9. Clean up Docker system (optional)
show_status "Docker system cleanup..."

read -p "Run Docker system prune (removes unused Docker resources)? (yes/no): " PRUNE_DOCKER

if [ "$PRUNE_DOCKER" = "yes" ]; then
    docker system prune -f 2>/dev/null || true
    show_success "Docker system cleaned"
else
    show_info "Skipped Docker system prune"
fi

echo ""

# 10. Remove .env file if exists
show_status "Removing environment files..."

if [ -f "docker/.env" ]; then
    rm -f docker/.env 2>/dev/null || true
    show_success "Removed docker/.env file"
else
    show_info "No .env file found"
fi

echo ""

# 11. Display remaining files
echo -e "${BLUE}======================================"
echo "  Remaining Project Files"
echo -e "======================================${NC}"
echo ""
echo "The following files are kept (project structure and documentation):"
echo ""
find . -maxdepth 2 -type f \( -name "*.md" -o -name "*.sh" -o -name "Dockerfile" -o -name "*.yml" -o -name "*.ini" \) 2>/dev/null | grep -v ".git" | sort || echo "Project files present"
echo ""

# 12. Verification
echo -e "${BLUE}======================================"
echo "  Verification"
echo -e "======================================${NC}"
echo ""

show_status "Checking for remaining resources..."
echo ""

echo "Docker Containers:"
REMAINING_CONTAINERS=$(docker ps -a 2>/dev/null | grep applebite | wc -l || echo "0")
if [ "$REMAINING_CONTAINERS" -eq 0 ]; then
    echo -e "${GREEN}✓ No AppleBite containers${NC}"
else
    echo -e "${YELLOW}! Found $REMAINING_CONTAINERS containers${NC}"
    docker ps -a | grep applebite || true
fi

echo ""
echo "Docker Images:"
REMAINING_IMAGES=$(docker images 2>/dev/null | grep applebite | wc -l || echo "0")
if [ "$REMAINING_IMAGES" -eq 0 ]; then
    echo -e "${GREEN}✓ No AppleBite images${NC}"
else
    echo -e "${YELLOW}! Found $REMAINING_IMAGES images${NC}"
    docker images | grep applebite || true
fi

echo ""
echo "Docker Volumes:"
REMAINING_VOLUMES=$(docker volume ls 2>/dev/null | grep -E "(applebite|test-db-data|stage-db-data|prod-db-data)" | wc -l || echo "0")
if [ "$REMAINING_VOLUMES" -eq 0 ]; then
    echo -e "${GREEN}✓ No AppleBite volumes${NC}"
else
    echo -e "${YELLOW}! Found $REMAINING_VOLUMES volumes${NC}"
    docker volume ls | grep -E "(applebite|test-db-data|stage-db-data|prod-db-data)" || true
fi

echo ""
echo "Jenkins:"
JENKINS_EXISTS=$(docker ps -a 2>/dev/null | grep jenkins-applebite | wc -l || echo "0")
if [ "$JENKINS_EXISTS" -eq 0 ]; then
    echo -e "${GREEN}✓ No Jenkins container${NC}"
else
    echo -e "${YELLOW}! Jenkins container still exists${NC}"
fi

echo ""

# 13. Summary
echo -e "${MAGENTA}======================================"
echo "  Reset Complete!"
echo -e "======================================${NC}"
echo ""
echo -e "${GREEN}Items Removed: $ITEMS_DELETED${NC}"
echo ""
echo "What's been reset:"
echo "  ✓ All Docker containers stopped and removed"
echo "  ✓ All Docker images deleted"
echo "  ✓ All Docker volumes removed (including databases)"
echo "  ✓ All Docker networks cleaned up"
echo "  ✓ Jenkins container and data removed"
echo "  ✓ Log files cleaned"
echo ""
echo "What's been kept:"
echo "  • Project structure and directories"
echo "  • Documentation files"
echo "  • Scripts"
echo "  • Docker and Ansible configurations"
echo "  • Jenkinsfile"
echo ""
echo -e "${BLUE}The project is now reset to its initial state.${NC}"
echo ""
echo "To start fresh, run:"
echo "  ./scripts/setup.sh"
echo ""
echo "Or use the interactive menu:"
echo "  ./quickstart.sh"
echo ""
echo -e "${GREEN}Reset completed successfully! ✓${NC}"
