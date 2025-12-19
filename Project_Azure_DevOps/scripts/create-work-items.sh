#!/bin/bash

################################################################################
# Create Work Items (Epic, User Stories, Tasks) in Azure DevOps Boards
################################################################################

set -e
source "$(dirname "$0")/../config/credentials.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Creating work items in Azure Boards...${NC}"

# Wait for project to be fully ready
echo "Waiting for project to be fully initialized..."
sleep 5

# Set organization and project context
export AZURE_DEVOPS_EXT_PAT="$AZURE_DEVOPS_PAT"
az devops configure --defaults organization=https://dev.azure.com/$AZURE_DEVOPS_ORG project=$AZURE_DEVOPS_PROJECT

# Verify project exists and get current project details
PROJECT_ID=$(az devops project show --project "$AZURE_DEVOPS_PROJECT" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --query "id" -o tsv)
echo "Using project ID: $PROJECT_ID"

# Always use Agile template types (Epic and User Story)
# Note: Project is created with Agile template by default
EPIC_TYPE="Epic"
STORY_TYPE="User Story"
echo "Using Agile process template"

# Create main Epic
echo "Creating Epic..."
EPIC_ID=$(az boards work-item create \
    --title "ProjectX - Order Management System" \
    --type "$EPIC_TYPE" \
    --description "Develop a comprehensive web application for managing customer orders. This is the main epic for the entire project." \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)

echo -e "${GREEN}✓ Epic created (ID: $EPIC_ID)${NC}"

# Create User Stories
echo ""
echo "Creating User Stories..."

# User Story 1
US1_ID=$(az boards work-item create \
    --title "User Authentication and Authorization" \
    --type "$STORY_TYPE" \
    --description "As a user, I want to securely log in to the system so that I can access my orders and account information" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$US1_ID" --relation-type "Parent" --target-id "$EPIC_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ User Story 1 created (ID: $US1_ID)${NC}"

# User Story 2
US2_ID=$(az boards work-item create \
    --title "Create and Submit Orders" \
    --type "$STORY_TYPE" \
    --description "As a customer, I want to create and submit orders for products so that I can purchase items" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$US2_ID" --relation-type "Parent" --target-id "$EPIC_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ User Story 2 created (ID: $US2_ID)${NC}"

# User Story 3
US3_ID=$(az boards work-item create \
    --title "View and Track Orders" \
    --type "$STORY_TYPE" \
    --description "As a customer, I want to view my order history and track current orders so that I know the status of my purchases" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$US3_ID" --relation-type "Parent" --target-id "$EPIC_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ User Story 3 created (ID: $US3_ID)${NC}"

# User Story 4
US4_ID=$(az boards work-item create \
    --title "Order Management for Administrators" \
    --type "$STORY_TYPE" \
    --description "As an administrator, I want to manage all orders in the system so that I can fulfill customer requests" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$US4_ID" --relation-type "Parent" --target-id "$EPIC_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ User Story 4 created (ID: $US4_ID)${NC}"

# User Story 5
US5_ID=$(az boards work-item create \
    --title "Product Catalog Management" \
    --type "$STORY_TYPE" \
    --description "As an administrator, I want to manage the product catalog so that customers can order the correct items" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$US5_ID" --relation-type "Parent" --target-id "$EPIC_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ User Story 5 created (ID: $US5_ID)${NC}"

# Create sample tasks for first user story
echo ""
echo "Creating sample tasks..."

TASK1_ID=$(az boards work-item create \
    --title "Design database schema for users and roles" \
    --type "Task" \
    --description "Create database tables for users, roles, and permissions" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$TASK1_ID" --relation-type "Parent" --target-id "$US1_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null

TASK2_ID=$(az boards work-item create \
    --title "Implement user registration API endpoint" \
    --type "Task" \
    --description "Create POST /api/auth/register endpoint with validation" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$TASK2_ID" --relation-type "Parent" --target-id "$US1_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null

TASK3_ID=$(az boards work-item create \
    --title "Implement login API endpoint" \
    --type "Task" \
    --description "Create POST /api/auth/login endpoint with JWT token generation" \
    --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" \
    -p "$AZURE_DEVOPS_PROJECT" \
    --query "id" -o tsv)
az boards work-item relation add --id "$TASK3_ID" --relation-type "Parent" --target-id "$US1_ID" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" >/dev/null

echo -e "${GREEN}✓ Sample tasks created${NC}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Work items created successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Epic ID: $EPIC_ID"
echo "User Story IDs: $US1_ID, $US2_ID, $US3_ID, $US4_ID, $US5_ID"
echo ""
echo -e "${YELLOW}View in Azure Boards:${NC}"
echo "https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_boards/board/t/Backlog%20items/"
