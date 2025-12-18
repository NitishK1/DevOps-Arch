#!/bin/bash

################################################################################
# Cleanup Script - Remove Azure Resources
################################################################################

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if credentials file exists
if [ -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    source "$PROJECT_ROOT/config/credentials.sh"
fi

echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    CLEANUP WARNING                         ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${YELLOW}This will delete:${NC}"
echo "  - Azure Resource Group: $AZURE_RESOURCE_GROUP"
echo "  - Web Apps: $WEBAPP_NAME_STAGING, $WEBAPP_NAME_PRODUCTION"
echo "  - App Service Plans"
echo ""
echo -e "${RED}Azure DevOps project and work items will NOT be deleted.${NC}"
echo "You can delete them manually from the Azure DevOps portal if needed."
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting cleanup...${NC}"

# Login check
if ! az account show &>/dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Set subscription
if [ -n "$AZURE_SUBSCRIPTION_ID" ]; then
    az account set --subscription "$AZURE_SUBSCRIPTION_ID"
fi

# Delete resource group (this deletes all resources within it)
echo ""
echo "Deleting resource group: $AZURE_RESOURCE_GROUP"
if az group exists --name "$AZURE_RESOURCE_GROUP" | grep -q "true"; then
    az group delete \
        --name "$AZURE_RESOURCE_GROUP" \
        --yes \
        --no-wait
    echo -e "${GREEN}✓ Resource group deletion initiated (this may take a few minutes)${NC}"
else
    echo "Resource group does not exist"
fi

echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
echo ""
echo "What was deleted:"
echo "  ✓ Resource group and all Azure resources"
echo ""
echo "What remains:"
echo "  - Azure DevOps project"
echo "  - Git repository"
echo "  - Work items"
echo "  - Pipelines"
echo ""
echo "To delete Azure DevOps project:"
echo "  1. Go to: https://dev.azure.com/$AZURE_DEVOPS_ORG"
echo "  2. Project Settings > Overview"
echo "  3. Delete project: $AZURE_DEVOPS_PROJECT"
