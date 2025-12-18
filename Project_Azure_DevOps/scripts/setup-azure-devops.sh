#!/bin/bash

################################################################################
# Setup Azure DevOps Organization and Project
################################################################################

set -e
source "$(dirname "$0")/../config/credentials.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Setting up Azure DevOps project...${NC}"

# Check if project exists
PROJECT_EXISTS=$(az devops project show --project "$AZURE_DEVOPS_PROJECT" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" 2>/dev/null || echo "")

if [ -z "$PROJECT_EXISTS" ]; then
    echo "Creating project: $AZURE_DEVOPS_PROJECT"
    az devops project create \
        --name "$AZURE_DEVOPS_PROJECT" \
        --description "Order Management System for TechCo" \
        --visibility private \
        --process Agile \
        --org "https://dev.azure.com/$AZURE_DEVOPS_ORG"

    echo "Waiting for project creation..."
    sleep 10
else
    echo "Project already exists: $AZURE_DEVOPS_PROJECT"
fi

# Set default project
az devops configure --defaults project="$AZURE_DEVOPS_PROJECT"

echo -e "${GREEN}✓ Azure DevOps project ready${NC}"
