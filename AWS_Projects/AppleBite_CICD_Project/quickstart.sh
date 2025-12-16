#!/bin/bash

# Quick Start Script for AppleBite CI/CD Project
# This script provides an interactive menu for common operations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
cat << "EOF"
   _____                __     ____  _ __
  /  _  \ ______ ____  |  |   |    \ |  | ___
 /  /_\  \\____ \\__  \ |  |   |  |  \|  |/ _ \
/    |    \  ___/ / __ \|  |__ |  _   |  |  __/
\____|____/ /_____/ ____/______/|_| |__|__|\___|
                 \/
AppleBite CI/CD Project - Quick Start
EOF
echo -e "${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Function to display menu
show_menu() {
    echo ""
    echo -e "${YELLOW}======================================"
    echo "        AppleBite Quick Start Menu"
    echo -e "======================================${NC}"
    echo ""
    echo -e "${GREEN}Setup & Installation:${NC}"
    echo "  1) Initial Setup (First Time)"
    echo "  2) Install Jenkins"
    echo "  3) Configure Jenkins (After Installation)"
    echo ""
    echo -e "${GREEN}Build & Deploy:${NC}"
    echo "  4) Build All Environments"
    echo "  5) Deploy to Test"
    echo "  6) Deploy to Stage"
    echo "  7) Deploy to Production"
    echo ""
    echo -e "${GREEN}Testing:${NC}"
    echo "  8) Run Tests on Test Environment"
    echo "  9) Run Tests on Stage Environment"
    echo "  10) Run Tests on Production Environment"
    echo ""
    echo -e "${GREEN}Management:${NC}"
    echo "  11) View Container Status"
    echo "  12) View Logs (Test)"
    echo "  13) View Logs (Stage)"
    echo "  14) View Logs (Production)"
    echo ""
    echo -e "${GREEN}Cleanup:${NC}"
    echo "  15) Stop All Containers"
    echo "  16) Clean Up Everything"
    echo ""
    echo -e "${GREEN}Information:${NC}"
    echo "  17) Show Application URLs"
    echo "  18) Show Documentation"
    echo ""
    echo -e "${RED}Advanced:${NC}"
    echo "  19) Complete Reset (Delete Everything)"
    echo ""
    echo -e "${RED}  0) Exit${NC}"
    echo ""
    echo -e "${YELLOW}======================================${NC}"
}

# Function to pause
pause() {
    echo ""
    read -p "Press Enter to continue..."
}

# Function to show URLs
show_urls() {
    echo ""
    echo -e "${CYAN}======================================"
    echo "    Application Access URLs"
    echo -e "======================================${NC}"
    echo ""
    echo -e "${GREEN}Test Environment:${NC}"
    echo "  http://127.0.0.1:8080"
    echo ""
    echo -e "${GREEN}Stage Environment:${NC}"
    echo "  http://127.0.0.1:8081"
    echo ""
    echo -e "${GREEN}Production Environment:${NC}"
    echo "  http://127.0.0.1:8082"
    echo ""
    echo -e "${GREEN}Jenkins:${NC}"
    echo "  http://127.0.0.1:8090"
    echo ""
    echo -e "${CYAN}======================================${NC}"
}

# Function to show documentation
show_docs() {
    echo ""
    echo -e "${CYAN}======================================"
    echo "       Documentation Files"
    echo -e "======================================${NC}"
    echo ""
    echo -e "${GREEN}Available Documentation:${NC}"
    echo ""
    echo "  • README.md           - Project overview"
    echo "  • SETUP_GUIDE.md      - Complete setup instructions"
    echo "  • DEPLOYMENT_GUIDE.md - Deployment procedures"
    echo "  • ARCHITECTURE.md     - System architecture"
    echo ""
    echo -e "${YELLOW}To view a document, use:${NC}"
    echo "  cat README.md"
    echo "  cat SETUP_GUIDE.md"
    echo ""
    echo -e "${CYAN}======================================${NC}"
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-19]: " choice

    case $choice in
        1)
            echo ""
            echo -e "${CYAN}Running initial setup...${NC}"
            ./scripts/setup.sh
            pause
            ;;
        2)
            echo ""
            echo -e "${CYAN}Installing Jenkins...${NC}"
            ./jenkins/jenkins-setup.sh
            pause
            ;;
        3)
            echo ""
            echo -e "${CYAN}Configuring Jenkins...${NC}"
            ./configure-jenkins.sh
            pause
            ;;
        4)
            echo ""
            echo -e "${CYAN}Building all environments...${NC}"
            ./scripts/build.sh all
            pause
            ;;
        5)
            echo ""
            echo -e "${CYAN}Deploying to Test environment...${NC}"
            ./scripts/deploy.sh test
            pause
            ;;
        6)
            echo ""
            echo -e "${CYAN}Deploying to Stage environment...${NC}"
            ./scripts/deploy.sh stage
            pause
            ;;
        7)
            echo ""
            echo -e "${CYAN}Deploying to Production environment...${NC}"
            ./scripts/deploy.sh prod
            pause
            ;;
        8)
            echo ""
            echo -e "${CYAN}Running tests on Test environment...${NC}"
            ./scripts/test.sh test
            pause
            ;;
        9)
            echo ""
            echo -e "${CYAN}Running tests on Stage environment...${NC}"
            ./scripts/test.sh stage
            pause
            ;;
        10)
            echo ""
            echo -e "${CYAN}Running tests on Production environment...${NC}"
            ./scripts/test.sh prod
            pause
            ;;
        11)
            echo ""
            echo -e "${CYAN}Container Status:${NC}"
            echo ""
            docker ps -a | grep applebite || echo "No AppleBite containers found"
            pause
            ;;
        12)
            echo ""
            echo -e "${CYAN}Test Environment Logs:${NC}"
            echo ""
            cd docker
            docker-compose -f docker-compose.test.yml logs --tail=50 2>/dev/null || echo "No containers running or logs unavailable"
            cd ..
            pause
            ;;
        13)
            echo ""
            echo -e "${CYAN}Stage Environment Logs:${NC}"
            echo ""
            cd docker
            docker-compose -f docker-compose.stage.yml logs --tail=50 2>/dev/null || echo "No containers running or logs unavailable"
            cd ..
            pause
            ;;
        14)
            echo ""
            echo -e "${CYAN}Production Environment Logs:${NC}"
            echo ""
            cd docker
            docker-compose -f docker-compose.prod.yml logs --tail=50 2>/dev/null || echo "No containers running or logs unavailable"
            cd ..
            pause
            ;;
        15)
            echo ""
            echo -e "${CYAN}Stopping all containers...${NC}"
            ./scripts/cleanup.sh containers
            pause
            ;;
        16)
            echo ""
            echo -e "${RED}WARNING: This will remove all containers, images, and volumes!${NC}"
            ./scripts/cleanup.sh all
            pause
            ;;
        17)
            show_urls
            pause
            ;;
        18)
            show_docs
            pause
            ;;
        19)
            echo ""
            echo -e "${RED}WARNING: This will completely reset the project!${NC}"
            echo ""
            read -p "Are you sure you want to continue? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                chmod +x reset.sh
                ./reset.sh
            else
                echo "Reset cancelled."
            fi
            pause
            ;;
        0)
            echo ""
            echo -e "${GREEN}Thank you for using AppleBite CI/CD!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid option. Please try again.${NC}"
            pause
            ;;
    esac
done
