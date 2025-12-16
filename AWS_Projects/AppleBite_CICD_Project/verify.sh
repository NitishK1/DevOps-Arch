#!/bin/bash

# Verification Script for AppleBite CI/CD Project
# This script checks if all components are properly set up

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "======================================"
echo "  AppleBite CI/CD - Verification"
echo "======================================"
echo -e "${NC}"
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to check
check_item() {
    local item=$1
    local check_command=$2

    echo -n "Checking $item... "

    if eval $check_command >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Check files exist
check_file() {
    local file=$1
    echo -n "Checking file: $file... "

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ EXISTS${NC}"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ MISSING${NC}"
        ((CHECKS_FAILED++))
    fi
}

# Check directory exists
check_dir() {
    local dir=$1
    echo -n "Checking directory: $dir... "

    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ EXISTS${NC}"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ MISSING${NC}"
        ((CHECKS_FAILED++))
    fi
}

echo -e "${YELLOW}System Prerequisites:${NC}"
echo ""
check_item "Git" "command -v git"
check_item "Docker" "command -v docker"
check_item "Docker daemon" "docker info"
check_item "Docker Compose" "command -v docker-compose"

echo ""
echo -e "${YELLOW}Project Structure:${NC}"
echo ""

# Check main documentation
check_file "README.md"
check_file "SETUP_GUIDE.md"
check_file "DEPLOYMENT_GUIDE.md"
check_file "ARCHITECTURE.md"
check_file "QUICK_REFERENCE.md"
check_file "ASSIGNMENT_COMPLETION.md"
check_file ".gitignore"
check_file "quickstart.sh"

echo ""
echo -e "${YELLOW}Docker Configuration:${NC}"
echo ""
check_dir "docker"
check_file "docker/Dockerfile"
check_file "docker/docker-compose.test.yml"
check_file "docker/docker-compose.stage.yml"
check_file "docker/docker-compose.prod.yml"
check_file "docker/.env.example"

echo ""
echo -e "${YELLOW}Jenkins Configuration:${NC}"
echo ""
check_dir "jenkins"
check_file "jenkins/Jenkinsfile"
check_file "jenkins/jenkins-setup.sh"

echo ""
echo -e "${YELLOW}Ansible Configuration:${NC}"
echo ""
check_dir "ansible"
check_dir "ansible/inventory"
check_dir "ansible/playbooks"
check_file "ansible/inventory/test.ini"
check_file "ansible/inventory/stage.ini"
check_file "ansible/inventory/prod.ini"
check_file "ansible/playbooks/provision-server.yml"
check_file "ansible/playbooks/deploy-app.yml"
check_file "ansible/playbooks/rollback.yml"

echo ""
echo -e "${YELLOW}Automation Scripts:${NC}"
echo ""
check_dir "scripts"
check_file "scripts/setup.sh"
check_file "scripts/build.sh"
check_file "scripts/deploy.sh"
check_file "scripts/test.sh"
check_file "scripts/cleanup.sh"

echo ""
echo -e "${YELLOW}Script Permissions:${NC}"
echo ""
check_item "setup.sh executable" "[ -x scripts/setup.sh ]"
check_item "build.sh executable" "[ -x scripts/build.sh ]"
check_item "deploy.sh executable" "[ -x scripts/deploy.sh ]"
check_item "test.sh executable" "[ -x scripts/test.sh ]"
check_item "cleanup.sh executable" "[ -x scripts/cleanup.sh ]"
check_item "jenkins-setup.sh executable" "[ -x jenkins/jenkins-setup.sh ]"
check_item "quickstart.sh executable" "[ -x quickstart.sh ]"

echo ""
echo "======================================"
echo "         Verification Summary"
echo "======================================"
echo ""
echo -e "${GREEN}Checks Passed: $CHECKS_PASSED${NC}"
echo -e "${RED}Checks Failed: $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Project is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run ./quickstart.sh for interactive menu"
    echo "2. Or run ./scripts/setup.sh to begin"
    echo "3. Read SETUP_GUIDE.md for detailed instructions"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the issues above.${NC}"
    echo ""
    echo "To fix missing files, ensure you're in the correct directory:"
    echo "cd c:/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/AWS_Projects/AppleBite_CICD_Project"
    echo ""
    exit 1
fi
