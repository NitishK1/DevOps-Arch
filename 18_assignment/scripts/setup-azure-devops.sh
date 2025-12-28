#!/bin/bash
# Setup Azure DevOps Project and Repository
# This script automates the creation of Azure DevOps project and initial setup

set -e  # Exit on error

echo "=================================================="
echo "Azure DevOps Project Setup"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_info "Checking prerequisites..."

# Check if az CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install it first."
    exit 1
fi

print_info "All prerequisites are installed."

# Login to Azure
print_info "Logging in to Azure..."
az login

# Install Azure DevOps extension
print_info "Installing Azure DevOps CLI extension..."
az extension add --name azure-devops --yes 2>/dev/null || print_warning "Extension already installed"

# Get organization name
echo ""
read -p "Enter your Azure DevOps organization name (e.g., myorg): " ORG_NAME
ORG_URL="https://dev.azure.com/$ORG_NAME"

# Project details
PROJECT_NAME="HooliMathHelper"
PROJECT_DESCRIPTION="Math Helper Library for distributed development team"
REPO_NAME="HooliMathHelper"

# Configure default organization
print_info "Setting default organization..."
az devops configure --defaults organization="$ORG_URL"

# Create project
print_info "Creating project: $PROJECT_NAME..."
az devops project create \
    --name "$PROJECT_NAME" \
    --description "$PROJECT_DESCRIPTION" \
    --source-control git \
    --visibility private \
    --process Agile 2>/dev/null || print_warning "Project may already exist"

# Set default project
az devops configure --defaults project="$PROJECT_NAME"

print_info "Project created successfully!"

# Get repository details
print_info "Getting repository information..."
REPO_ID=$(az repos list --query "[?name=='$REPO_NAME'].id" -o tsv)

if [ -z "$REPO_ID" ]; then
    print_error "Repository not found. It should be created automatically with the project."
    exit 1
fi

REPO_URL=$(az repos show --repository "$REPO_NAME" --query "remoteUrl" -o tsv)
print_info "Repository URL: $REPO_URL"

# Create sprint
print_info "Creating Sprint 1..."
SPRINT_ID=$(az boards iteration project create \
    --name "Sprint 1" \
    --project "$PROJECT_NAME" \
    --start-date "$(date -d '+1 day' +'%Y-%m-%d')" \
    --finish-date "$(date -d '+15 days' +'%Y-%m-%d')" \
    --query "id" -o tsv 2>/dev/null || echo "")

if [ ! -z "$SPRINT_ID" ]; then
    print_info "Sprint 1 created successfully!"
else
    print_warning "Sprint creation skipped (may already exist)"
fi

# Save configuration
CONFIG_FILE="../config/azure-devops-config.sh"
mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" << EOF
# Azure DevOps Configuration
export AZURE_DEVOPS_ORG_URL="$ORG_URL"
export AZURE_DEVOPS_PROJECT="$PROJECT_NAME"
export AZURE_DEVOPS_REPO_NAME="$REPO_NAME"
export AZURE_DEVOPS_REPO_URL="$REPO_URL"
EOF

print_info "Configuration saved to: $CONFIG_FILE"

echo ""
echo "=================================================="
print_info "Setup completed successfully!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Source the configuration: source $CONFIG_FILE"
echo "2. Clone the repository: git clone $REPO_URL"
echo "3. Create work items using Azure DevOps web interface or CLI"
echo "4. Start developing!"
echo ""
echo "Access your project at: $ORG_URL/$PROJECT_NAME"
echo "=================================================="
