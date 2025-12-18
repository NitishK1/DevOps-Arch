#!/bin/bash

################################################################################
# Setup CI/CD Pipelines in Azure DevOps
################################################################################

set -e
source "$(dirname "$0")/../config/credentials.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Setting up CI/CD pipelines...${NC}"

# Set defaults
az devops configure --defaults organization="https://dev.azure.com/$AZURE_DEVOPS_ORG" project="$AZURE_DEVOPS_PROJECT"

# Create Azure Web Apps for Staging and Production
echo ""
echo -e "${BLUE}Creating Azure resources...${NC}"

# Create resource group
echo "Creating resource group: $AZURE_RESOURCE_GROUP"
az group create \
    --name "$AZURE_RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --output none || echo "Resource group already exists"

# Create App Service Plan for Staging
echo "Creating App Service Plan for staging..."
az appservice plan create \
    --name "projectx-asp-staging" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --sku B1 \
    --is-linux \
    --output none || echo "Staging plan already exists"

# Create Web App for Staging
echo "Creating Web App for staging..."
az webapp create \
    --name "$WEBAPP_NAME_STAGING" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --plan "projectx-asp-staging" \
    --runtime "NODE:18-lts" \
    --output none || echo "Staging webapp already exists"

# Create App Service Plan for Production
echo "Creating App Service Plan for production..."
az appservice plan create \
    --name "projectx-asp-prod" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --sku S1 \
    --is-linux \
    --output none || echo "Production plan already exists"

# Create Web App for Production
echo "Creating Web App for production..."
az webapp create \
    --name "$WEBAPP_NAME_PRODUCTION" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --plan "projectx-asp-prod" \
    --runtime "NODE:18-lts" \
    --output none || echo "Production webapp already exists"

echo -e "${GREEN}✓ Azure resources created${NC}"

# Get subscription details
SUB_ID=$(az account show --query id -o tsv)
SUB_NAME=$(az account show --query name -o tsv)

# Create service connection
echo ""
echo -e "${BLUE}Creating Azure service connection...${NC}"
echo -e "${YELLOW}Note: Service connections are best created via Azure DevOps UI${NC}"
echo "Manual steps:"
echo "1. Go to: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_settings/adminservices"
echo "2. Create new Azure Resource Manager service connection"
echo "3. Select subscription: $SUB_NAME"
echo "4. Name it: 'Azure-ServiceConnection'"

# Create pipeline
echo ""
echo -e "${BLUE}Creating CI/CD pipeline...${NC}"

# Check if pipeline exists
PIPELINE_EXISTS=$(az pipelines list --query "[?name=='ProjectX-CICD'].name" -o tsv)

if [ -z "$PIPELINE_EXISTS" ]; then
    echo "Creating pipeline from YAML..."

    # Create pipeline
    az pipelines create \
        --name "ProjectX-CICD" \
        --repository "$REPO_NAME" \
        --repository-type tfsgit \
        --branch main \
        --yml-path "pipelines/azure-pipelines.yml" \
        --skip-first-run \
        || echo "Pipeline creation may need to be done via UI"
else
    echo "Pipeline already exists: ProjectX-CICD"
fi

# Create environments for approvals
echo ""
echo -e "${BLUE}Creating environments...${NC}"

# Staging environment
echo "Creating staging environment..."
az devops invoke \
    --area distributedtask \
    --resource environments \
    --route-parameters project="$AZURE_DEVOPS_PROJECT" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    --http-method POST \
    --api-version "6.0-preview.1" \
    --in-file <(echo '{"name": "ProjectX-Staging", "description": "Staging environment for ProjectX"}') \
    --output none 2>/dev/null || echo "Staging environment may already exist"

# Production environment with approval
echo "Creating production environment..."
az devops invoke \
    --area distributedtask \
    --resource environments \
    --route-parameters project="$AZURE_DEVOPS_PROJECT" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    --http-method POST \
    --api-version "6.0-preview.1" \
    --in-file <(echo '{"name": "ProjectX-Production", "description": "Production environment for ProjectX - requires approval"}') \
    --output none 2>/dev/null || echo "Production environment may already exist"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Pipeline setup initiated!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Manual Configuration Required:${NC}"
echo ""
echo "1. Configure Service Connection:"
echo "   URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_settings/adminservices"
echo "   - Create Azure Resource Manager connection"
echo "   - Name: 'Azure-ServiceConnection'"
echo "   - Select subscription: $SUB_NAME"
echo ""
echo "2. Add Pipeline Variables:"
echo "   URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_build"
echo "   Variables to add:"
echo "   - azureSubscription: 'Azure-ServiceConnection'"
echo "   - resourceGroupName: '$AZURE_RESOURCE_GROUP'"
echo "   - stagingWebAppName: '$WEBAPP_NAME_STAGING'"
echo "   - productionWebAppName: '$WEBAPP_NAME_PRODUCTION'"
echo ""
echo "3. Configure Production Environment Approval:"
echo "   URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_environments"
echo "   - Select 'ProjectX-Production'"
echo "   - Add approval check"
echo "   - Add yourself as approver"
echo ""
echo "4. Trigger the pipeline:"
echo "   Push code to trigger: git push azure main"
echo ""
echo "Web App URLs:"
echo "  Staging: https://$WEBAPP_NAME_STAGING.azurewebsites.net"
echo "  Production: https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net"
