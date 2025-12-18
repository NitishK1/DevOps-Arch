# Azure DevOps Credentials Configuration
# WARNING: This file contains sensitive information. Never commit to Git!

# Azure Subscription Details
export AZURE_SUBSCRIPTION_ID="your-subscription-id-here"
export AZURE_TENANT_ID="your-tenant-id-here"
export AZURE_RESOURCE_GROUP="projectx-rg"
export AZURE_LOCATION="eastus"

# Azure DevOps Details
export AZURE_DEVOPS_ORG="your-org-name"  # e.g., "techco-demo"
export AZURE_DEVOPS_PROJECT="ProjectX"
export AZURE_DEVOPS_PAT="your-personal-access-token-here"

# Web App Names
export WEBAPP_NAME_STAGING="projectx-staging"
export WEBAPP_NAME_PRODUCTION="projectx-production"

# Repository Details
export REPO_NAME="ProjectX"
export DEFAULT_BRANCH="main"

# How to get these values:
# 1. AZURE_SUBSCRIPTION_ID: az account show --query id -o tsv
# 2. AZURE_TENANT_ID: az account show --query tenantId -o tsv
# 3. AZURE_DEVOPS_ORG: Your Azure DevOps organization name (https://dev.azure.com/YOUR_ORG)
# 4. AZURE_DEVOPS_PAT: Generate at https://dev.azure.com/YOUR_ORG/_usersSettings/tokens
#    Required scopes: Code (Read, Write), Build (Read, Execute), Release (Read, Write, Execute), Work Items (Read, Write)
