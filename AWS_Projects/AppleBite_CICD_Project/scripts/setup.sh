#!/bin/bash

# Setup Script for AppleBite CI/CD Project
# This script initializes the project and clones the PHP application

set -e

echo "======================================"
echo "AppleBite CI/CD Project Setup"
echo "======================================"
echo ""

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}Project Root: $PROJECT_ROOT${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Git
if command_exists git; then
    echo -e "${GREEN}✓${NC} Git is installed"
else
    echo -e "${RED}✗${NC} Git is not installed. Please install Git first."
    exit 1
fi

# Check Docker
if command_exists docker; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    docker --version
else
    echo -e "${RED}✗${NC} Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# Check if Docker daemon is running
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is not running. Please start Docker Desktop."
    exit 1
fi

# Check Ansible (optional, will install if not present)
if command_exists ansible; then
    echo -e "${GREEN}✓${NC} Ansible is installed"
    ansible --version | head -n 1
else
    echo -e "${YELLOW}!${NC} Ansible is not installed. Will install it..."

    # Install Ansible based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y ansible
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ansible
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo -e "${YELLOW}For Windows, please install Ansible via WSL or use Docker.${NC}"
        echo "Continuing without Ansible for now..."
    fi
fi

echo ""
echo "======================================"
echo "Initializing App Submodule"
echo "======================================"
echo ""

# Initialize git submodule for the app
APP_DIR="$PROJECT_ROOT/app"

# Check if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Setting up app as git submodule..."

    # Check if submodule already exists in .gitmodules
    if git config -f "$(git rev-parse --show-toplevel)/.gitmodules" --get-regexp "submodule.AWS_Projects/AppleBite_CICD_Project/app.path" > /dev/null 2>&1; then
        echo -e "${YELLOW}Submodule already configured. Initializing and updating...${NC}"
        git submodule update --init --recursive AWS_Projects/AppleBite_CICD_Project/app || true
    else
        if [ -d "$APP_DIR" ] && [ ! -d "$APP_DIR/.git" ]; then
            echo -e "${YELLOW}Removing existing app directory to add as submodule...${NC}"
            rm -rf "$APP_DIR"
        fi

        if [ ! -d "$APP_DIR" ]; then
            echo "Adding projCert as git submodule..."
            cd "$(git rev-parse --show-toplevel)"
            git submodule add https://github.com/edureka-devops/projCert.git AWS_Projects/AppleBite_CICD_Project/app 2>/dev/null || \
            git submodule update --init --recursive AWS_Projects/AppleBite_CICD_Project/app
            cd "$PROJECT_ROOT"
            echo -e "${GREEN}✓${NC} Application added as submodule"
        else
            echo -e "${GREEN}✓${NC} Application submodule already exists"
        fi
    fi
else
    echo -e "${YELLOW}Not in a git repository. Cloning app directly...${NC}"
    if [ -d "$APP_DIR" ]; then
        echo -e "${YELLOW}App directory already exists. Pulling latest changes...${NC}"
        cd "$APP_DIR"
        git pull origin master || echo "Could not pull latest changes"
        cd "$PROJECT_ROOT"
    else
        echo "Cloning projCert repository..."
        git clone https://github.com/edureka-devops/projCert.git "$APP_DIR"
        echo -e "${GREEN}✓${NC} Application cloned successfully"
    fi
fi

echo ""
echo "======================================"
echo "Creating Directory Structure"
echo "======================================"
echo ""

# Create necessary directories
mkdir -p "$PROJECT_ROOT/docker"
mkdir -p "$PROJECT_ROOT/ansible/inventory"
mkdir -p "$PROJECT_ROOT/ansible/playbooks"
mkdir -p "$PROJECT_ROOT/ansible/roles/common/tasks"
mkdir -p "$PROJECT_ROOT/ansible/roles/docker/tasks"
mkdir -p "$PROJECT_ROOT/ansible/roles/app/tasks"
mkdir -p "$PROJECT_ROOT/jenkins"
mkdir -p "$PROJECT_ROOT/scripts"
mkdir -p "$PROJECT_ROOT/tests/unit"
mkdir -p "$PROJECT_ROOT/tests/integration"
mkdir -p "$PROJECT_ROOT/logs"

echo -e "${GREEN}✓${NC} Directory structure created"

echo ""
echo "======================================"
echo "Setting up Git hooks (optional)"
echo "======================================"
echo ""

# Create a simple git hook for local development
if [ -d "$APP_DIR/.git" ]; then
    HOOK_FILE="$APP_DIR/.git/hooks/pre-push"
    cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
echo "Running pre-push checks..."
echo "You can add tests here before pushing to remote"
exit 0
EOF
    chmod +x "$HOOK_FILE"
    echo -e "${GREEN}✓${NC} Git hooks configured"
fi

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Review the README.md file"
echo "2. Build Docker images: cd docker && docker-compose build"
echo "3. Set up Jenkins: ./jenkins/jenkins-setup.sh"
echo "4. Configure Ansible inventory files"
echo "5. Run the pipeline!"
echo ""
echo "For detailed instructions, see:"
echo "- SETUP_GUIDE.md"
echo "- DEPLOYMENT_GUIDE.md"
echo ""
echo -e "${GREEN}Happy DevOps! 🚀${NC}"
