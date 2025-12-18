#!/bin/bash

################################################################################
# Demo Script - Guided demonstration of ProjectX
################################################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load credentials
if [ -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    source "$PROJECT_ROOT/config/credentials.sh"
fi

# Function to wait for user
wait_for_user() {
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

clear

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║            ProjectX - Demo Walkthrough                    ║"
echo "║         Order Management System on Azure DevOps           ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "This script will guide you through demonstrating all aspects"
echo "of the ProjectX implementation."
echo ""
wait_for_user

# Step 1: Azure Boards
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 1: Azure Boards - Work Item Management${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Epic: ProjectX - Order Management System"
echo "  ✓ 5 User Stories with acceptance criteria"
echo "  ✓ Multiple Tasks under each User Story"
echo "  ✓ Sprint planning and backlog management"
echo ""
echo "What to show:"
echo "  1. Backlog view with Epic and User Stories"
echo "  2. User Story details with acceptance criteria"
echo "  3. Tasks breakdown for implementation"
echo "  4. Board view showing workflow"
echo ""
echo -e "${YELLOW}Opening Azure Boards...${NC}"
echo "URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_boards"
echo ""
wait_for_user

# Step 2: Azure Repos
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 2: Azure Repos - Source Code Management${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Git repository with complete application code"
echo "  ✓ Branch strategy (main branch)"
echo "  ✓ Organized folder structure"
echo "  ✓ Application code (Node.js/Express)"
echo "  ✓ Pipeline YAML files"
echo "  ✓ Documentation"
echo ""
echo "What to show:"
echo "  1. Repository structure and files"
echo "  2. Application code in app/ folder"
echo "  3. CI/CD pipeline configuration"
echo "  4. Commit history"
echo "  5. Branch policies (if configured)"
echo ""
echo -e "${YELLOW}Opening Azure Repos...${NC}"
echo "URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_git/$REPO_NAME"
echo ""
wait_for_user

# Step 3: CI Pipeline
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 3: CI Pipeline - Continuous Integration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Automatic build on code push"
echo "  ✓ Node.js dependency installation"
echo "  ✓ Automated testing"
echo "  ✓ Code quality checks"
echo "  ✓ Artifact generation"
echo ""
echo "What to show:"
echo "  1. Pipeline configuration (YAML)"
echo "  2. Pipeline run history"
echo "  3. Build stages and steps"
echo "  4. Test results"
echo "  5. Published artifacts"
echo ""
echo "To trigger a build:"
echo "  - Make a code change and push to main branch"
echo "  - Or manually queue a build"
echo ""
echo -e "${YELLOW}Opening Pipelines...${NC}"
echo "URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_build"
echo ""
wait_for_user

# Step 4: CD Pipeline - Staging
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 4: CD Pipeline - Deployment to Staging${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Automatic deployment after successful build"
echo "  ✓ Deployment to staging environment"
echo "  ✓ Environment-specific configuration"
echo "  ✓ Smoke tests after deployment"
echo ""
echo "What to show:"
echo "  1. Deployment stage in pipeline"
echo "  2. Artifact download"
echo "  3. Azure Web App deployment"
echo "  4. Deployment logs"
echo "  5. Smoke test results"
echo ""
echo "Staging Environment:"
echo "  URL: https://$WEBAPP_NAME_STAGING.azurewebsites.net"
echo "  Health Check: https://$WEBAPP_NAME_STAGING.azurewebsites.net/api/health"
echo ""
echo -e "${YELLOW}Testing staging deployment...${NC}"
if command -v curl >/dev/null 2>&1; then
    curl -s "https://$WEBAPP_NAME_STAGING.azurewebsites.net/api/health" | head -20 || echo "Staging not yet deployed"
fi
echo ""
wait_for_user

# Step 5: Manual Approval
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 5: Manual Approval Gate${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Pipeline waits for manual approval"
echo "  ✓ Production environment protection"
echo "  ✓ Approval request notification"
echo "  ✓ Review and approve deployment"
echo ""
echo "What to show:"
echo "  1. Pipeline paused at production stage"
echo "  2. Approval request in environments"
echo "  3. Review staging deployment"
echo "  4. Approve or reject deployment"
echo "  5. Comments and audit trail"
echo ""
echo "To configure approval:"
echo "  1. Go to Environments"
echo "  2. Select 'ProjectX-Production'"
echo "  3. Add Approvals and checks"
echo "  4. Add yourself as approver"
echo ""
echo -e "${YELLOW}Opening Environments...${NC}"
echo "URL: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_environments"
echo ""
wait_for_user

# Step 6: Production Deployment
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 6: Production Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate:"
echo "  ✓ Deployment after approval"
echo "  ✓ Production environment deployment"
echo "  ✓ Health checks"
echo "  ✓ Live application"
echo ""
echo "What to show:"
echo "  1. Production deployment stage"
echo "  2. Deployment progress"
echo "  3. Production configuration"
echo "  4. Smoke tests in production"
echo "  5. Deployment completion notification"
echo ""
echo "Production Environment:"
echo "  URL: https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net"
echo "  Health Check: https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net/api/health"
echo ""
echo -e "${YELLOW}Testing production deployment...${NC}"
if command -v curl >/dev/null 2>&1; then
    curl -s "https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net/api/health" | head -20 || echo "Production not yet deployed"
fi
echo ""
wait_for_user

# Step 7: Live Application
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 7: Live Application Demo${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Demonstrate the working application:"
echo ""
echo "API Endpoints to test:"
echo "  Health: /api/health"
echo "  Products: /api/products"
echo "  Dashboard: /api/admin/dashboard"
echo ""
echo "Example curl commands:"
echo ""
echo "# Get health status"
echo "curl https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net/api/health"
echo ""
echo "# Get products"
echo "curl https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net/api/products"
echo ""
echo "# Create an order"
echo "curl -X POST https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net/api/orders \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"userId\": 1, \"items\": [{\"productId\": 1, \"quantity\": 2}]}'"
echo ""
wait_for_user

# Summary
clear
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                   Demo Complete! ✓                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}Key Points Demonstrated:${NC}"
echo ""
echo "1. ✓ Azure Boards - Epic, User Stories, Tasks organized"
echo "2. ✓ Azure Repos - Complete source code in Git repository"
echo "3. ✓ CI Pipeline - Automated build and testing"
echo "4. ✓ CD Pipeline - Automated deployment to staging"
echo "5. ✓ Manual Approval - Protection for production"
echo "6. ✓ Production Deployment - Live application running"
echo "7. ✓ Infrastructure as Code - Repeatable setup"
echo ""
echo -e "${BLUE}Quick Links:${NC}"
echo "  Project: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT"
echo "  Boards: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_boards"
echo "  Repos: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_git/$REPO_NAME"
echo "  Pipelines: https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_build"
echo "  Staging: https://$WEBAPP_NAME_STAGING.azurewebsites.net"
echo "  Production: https://$WEBAPP_NAME_PRODUCTION.azurewebsites.net"
echo ""
