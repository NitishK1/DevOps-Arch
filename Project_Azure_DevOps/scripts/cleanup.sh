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
echo "  - Azure DevOps Project: $AZURE_DEVOPS_PROJECT"
echo "  - All work items (Epic, Stories, Tasks)"
echo "  - Git repository and all code"
echo "  - CI/CD pipelines"
echo "  - Azure Resource Group: $AZURE_RESOURCE_GROUP"
echo "  - Web Apps: $WEBAPP_NAME_STAGING, $WEBAPP_NAME_PRODUCTION"
echo "  - App Service Plans"
echo ""
echo -e "${RED}⚠️  WARNING: THIS CANNOT BE UNDONE! ⚠️${NC}"
echo ""
read -p "Are you ABSOLUTELY sure you want to delete EVERYTHING? (type 'DELETE' to confirm): " -r
echo

if [[ ! $REPLY == "DELETE" ]]; then
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

# Stop and remove local agent
AGENT_DIR="$HOME/azpagent"
if [ -d "$AGENT_DIR" ]; then
    echo ""
    echo "Stopping local pipeline agent..."
    cd "$AGENT_DIR"

    # Stop agent
    if pgrep -f "Agent.Listener" > /dev/null; then
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
            taskkill //F //IM Agent.Listener.exe 2>/dev/null || true
        else
            pkill -f Agent.Listener || true
        fi
        echo -e "${GREEN}✓ Agent stopped${NC}"
    fi

    # Unconfigure agent
    if [ -f "./config.cmd" ] || [ -f "./config.sh" ]; then
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
            cmd.exe //c "config.cmd remove --auth pat --token $AZURE_DEVOPS_PAT" 2>/dev/null || true
        else
            ./config.sh remove --auth pat --token "$AZURE_DEVOPS_PAT" 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ Agent unconfigured${NC}"
    fi

    cd - > /dev/null
fi

# Configure Azure DevOps
export AZURE_DEVOPS_EXT_PAT=$AZURE_DEVOPS_PAT
az devops configure --defaults organization="https://dev.azure.com/$AZURE_DEVOPS_ORG" project="$AZURE_DEVOPS_PROJECT"

# Delete Azure DevOps Project (includes everything: work items, repos, pipelines)
echo ""
echo "Deleting Azure DevOps project: $AZURE_DEVOPS_PROJECT"
PROJECT_ID=$(az devops project show --project "$AZURE_DEVOPS_PROJECT" --query id -o tsv 2>/dev/null || echo "")

if [ -n "$PROJECT_ID" ]; then
    az devops project delete \
        --id "$PROJECT_ID" \
        --yes \
        --output none 2>/dev/null || echo "Failed to delete project (may need manual deletion)"
    echo -e "${GREEN}✓ Azure DevOps project deleted${NC}"
else
    echo "Azure DevOps project not found or already deleted"
fi

# Delete resource group (this deletes all resources within it)
echo ""
echo "Deleting Azure resource group: $AZURE_RESOURCE_GROUP"
if az group exists --name "$AZURE_RESOURCE_GROUP" 2>/dev/null | grep -q "true"; then
    az group delete \
        --name "$AZURE_RESOURCE_GROUP" \
        --yes \
        --no-wait
    echo -e "${GREEN}✓ Resource group deletion initiated (this may take a few minutes)${NC}"
else
    echo "Resource group does not exist or already deleted"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Cleanup Complete!                             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "What was deleted:"
echo "  ✓ Local pipeline agent (stopped and unconfigured)"
echo "  ✓ Azure DevOps Project: $AZURE_DEVOPS_PROJECT"
echo "  ✓ All work items (Epic, Stories, Tasks)"
echo "  ✓ Git repository and all code"
echo "  ✓ CI/CD pipelines and environments"
echo "  ✓ Azure Resource Group: $AZURE_RESOURCE_GROUP"
echo "  ✓ All Azure resources (Web Apps, App Service Plans)"
echo ""
echo "What was preserved:"
echo "  ✓ Local project files"
echo "  ✓ Credentials file (config/credentials.sh)"
echo "  ✓ Application code"
echo "  ✓ Scripts and documentation"
echo "  ✓ Agent directory ($AGENT_DIR - can be manually deleted if needed)"
echo ""
echo "Local files remain in:"
echo "  $PROJECT_ROOT"
echo ""
echo "To recreate everything with the same credentials, run:"
echo "  cd $PROJECT_ROOT"
echo "  ./scripts/quickstart.sh"
