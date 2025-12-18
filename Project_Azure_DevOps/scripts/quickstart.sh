#!/bin/bash

################################################################################
# ProjectX Quickstart Script
# This script automates the complete setup of Azure DevOps for ProjectX
# Usage: ./quickstart.sh
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║         ProjectX - Azure DevOps Quickstart                ║"
echo "║         Order Management System Setup                     ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if credentials file exists
if [ ! -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    echo -e "${YELLOW}⚠ Credentials file not found!${NC}"
    echo ""
    echo "Creating from template..."
    cp "$PROJECT_ROOT/config/credentials.template.sh" "$PROJECT_ROOT/config/credentials.sh"
    echo -e "${RED}Please edit config/credentials.sh with your Azure credentials and run this script again.${NC}"
    exit 1
fi

# Load credentials
source "$PROJECT_ROOT/config/credentials.sh"

# Validate credentials
echo -e "${BLUE}► Validating credentials...${NC}"
if [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ "$AZURE_SUBSCRIPTION_ID" == "your-subscription-id-here" ]; then
    echo -e "${RED}✗ Azure credentials not configured!${NC}"
    echo "Please edit config/credentials.sh with your actual Azure credentials."
    exit 1
fi

echo -e "${GREEN}✓ Credentials loaded${NC}"

# Check prerequisites
echo ""
echo -e "${BLUE}► Checking prerequisites...${NC}"

command -v az >/dev/null 2>&1 || {
    echo -e "${RED}✗ Azure CLI not found. Please install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
    exit 1
}
echo -e "${GREEN}✓ Azure CLI installed${NC}"

command -v node >/dev/null 2>&1 || {
    echo -e "${RED}✗ Node.js not found. Please install: https://nodejs.org/${NC}"
    exit 1
}
echo -e "${GREEN}✓ Node.js installed${NC}"

command -v git >/dev/null 2>&1 || {
    echo -e "${RED}✗ Git not found. Please install: https://git-scm.com/${NC}"
    exit 1
}
echo -e "${GREEN}✓ Git installed${NC}"

# Azure DevOps CLI extension
echo ""
echo -e "${BLUE}► Checking Azure DevOps CLI extension...${NC}"
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    echo "Installing Azure DevOps extension..."
    az extension add --name azure-devops -y
fi
echo -e "${GREEN}✓ Azure DevOps CLI ready${NC}"

# Login to Azure
echo ""
echo -e "${BLUE}► Logging into Azure...${NC}"
if ! az account show &>/dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Set subscription
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
CURRENT_SUB=$(az account show --query name -o tsv)
echo -e "${GREEN}✓ Using subscription: $CURRENT_SUB${NC}"

# Configure Azure DevOps
echo ""
echo -e "${BLUE}► Configuring Azure DevOps...${NC}"
export AZURE_DEVOPS_EXT_PAT=$AZURE_DEVOPS_PAT
az devops configure --defaults organization="https://dev.azure.com/$AZURE_DEVOPS_ORG"

# Run setup scripts
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Step 1: Setting up Azure DevOps Organization & Project   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
bash "$SCRIPT_DIR/setup-azure-devops.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Step 2: Creating Work Items (Epic, Stories, Tasks)       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
bash "$SCRIPT_DIR/create-work-items.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Step 3: Setting up Git Repository                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
bash "$SCRIPT_DIR/setup-repo.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Step 4: Creating CI/CD Pipelines                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
bash "$SCRIPT_DIR/setup-pipelines.sh"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║              ✓ Setup Completed Successfully!               ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Project URL:${NC} https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT"
echo -e "${BLUE}Boards:${NC} https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_boards"
echo -e "${BLUE}Repos:${NC} https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_git/$REPO_NAME"
echo -e "${BLUE}Pipelines:${NC} https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_build"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review work items in Azure Boards"
echo "2. Trigger the CI/CD pipeline by pushing code"
echo "3. Approve the production deployment when ready"
echo "4. Run ./scripts/demo.sh for a guided demonstration"
echo ""
