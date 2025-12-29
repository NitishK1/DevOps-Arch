#!/bin/bash

################################################################################
# Setup Git Repository in Azure Repos
################################################################################

set -e
source "$(dirname "$0")/../config/credentials.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Setting up Git repository...${NC}"

# Set defaults and verify project
az devops configure --defaults organization=https://dev.azure.com/$AZURE_DEVOPS_ORG project=$AZURE_DEVOPS_PROJECT

# Verify project exists and get current project ID
PROJECT_ID=$(az devops project show --project "$AZURE_DEVOPS_PROJECT" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --query "id" -o tsv)
echo "Using project ID: $PROJECT_ID"

# Check if repo exists
REPO_EXISTS=$(az repos list --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --project "$AZURE_DEVOPS_PROJECT" --query "[?name=='$REPO_NAME'].name" -o tsv)

if [ -z "$REPO_EXISTS" ]; then
    echo "Creating repository: $REPO_NAME"
    az repos create --name "$REPO_NAME" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --project "$AZURE_DEVOPS_PROJECT" >/dev/null
    sleep 5
else
    echo "Repository already exists: $REPO_NAME"
fi

# Get repository URL
REPO_URL=$(az repos show --repository "$REPO_NAME" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --project "$AZURE_DEVOPS_PROJECT" --query "remoteUrl" -o tsv)
echo "Repository URL: $REPO_URL"

# Initialize local git if not already initialized
cd "$PROJECT_ROOT"
if [ ! -d ".git" ]; then
    echo "Initializing local git repository..."
    git init
    git checkout -b main 2>/dev/null || git checkout main
fi

# Create .gitignore
cat > .gitignore <<EOF
# Dependencies
node_modules/
npm-debug.log*

# Environment variables
.env
config/credentials.sh

# Build outputs
dist/
build/
*.zip

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Test coverage
coverage/

# Azure
.azure/
EOF

# Add all files
echo "Adding files to git..."
git add .

# Commit
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "No changes to commit"
else
    git commit -m "Initial commit - ProjectX Order Management System

- Added application code with Node.js/Express server
- Created CI/CD pipeline configuration
- Added work item templates for Azure Boards
- Included automation scripts for setup
- Added comprehensive documentation

This commit sets up the complete ProjectX infrastructure as code."
fi

# Add or update Azure DevOps remote with embedded PAT
REPO_URL_WITH_PAT="https://:${AZURE_DEVOPS_PAT}@dev.azure.com/${AZURE_DEVOPS_ORG}/${AZURE_DEVOPS_PROJECT}/_git/${REPO_NAME}"

if git remote | grep -q "azure"; then
    CURRENT_REMOTE=$(git remote get-url azure)
    # Check if remote needs updating (compare without PAT for display)
    if [[ "$CURRENT_REMOTE" != *"dev.azure.com/$AZURE_DEVOPS_ORG"* ]]; then
        echo "Updating Azure DevOps remote URL..."
        git remote remove azure
        git remote add azure "$REPO_URL_WITH_PAT"
        echo "Remote updated from old organization to: $AZURE_DEVOPS_ORG"
    else
        echo "Updating remote with current credentials..."
        git remote set-url azure "$REPO_URL_WITH_PAT"
        echo "Azure remote configured with PAT authentication"
    fi
else
    echo "Adding Azure DevOps remote..."
    git remote add azure "$REPO_URL_WITH_PAT"
fi

# Push to Azure Repos
echo "Pushing to Azure Repos..."
echo "Using PAT from credentials.sh for authentication..."
echo ""

# Push with credentials already embedded in URL
git push azure main -u 2>&1 || {
    echo ""
    echo -e "${YELLOW}Push failed. Trying interactive authentication...${NC}"
    echo "When prompted:"
    echo "  Username: (just press Enter or use your email)"
    echo "  Password: $AZURE_DEVOPS_PAT"
    git push azure main -u
}

# Set branch policies (optional - requires API)
echo ""
echo -e "${BLUE}Setting up branch policies...${NC}"
echo "(Branch policies are best configured via Azure DevOps web UI)"
echo "Recommended policies for 'main' branch:"
echo "  - Require pull request reviews"
echo "  - Require successful build"
echo "  - Require linked work items"

echo ""
echo -e "${GREEN}✓ Repository setup complete${NC}"
echo ""
echo "Repository URL: $REPO_URL"
echo "Local branch: main"
echo "Remote: azure"
