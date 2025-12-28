#!/bin/bash

# create-work-items.sh
# Automatically creates all work items (Epic, User Stories, Tasks) in Azure DevOps

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Azure DevOps Work Items Creator${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Source credentials
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CREDS_FILE="$PROJECT_ROOT/config/credentials.sh"

if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${RED}[ERROR] Credentials file not found!${NC}"
    echo "Please run: ./scripts/setup-credentials.sh"
    exit 1
fi

source "$CREDS_FILE"

# Verify we're logged in
echo -e "${YELLOW}[INFO] Checking Azure CLI login status...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}[INFO] Not logged in. Initiating device code login...${NC}"
    az login --use-device-code
fi

# Set Azure DevOps defaults
AZURE_DEVOPS_ORG_URL="https://dev.azure.com/${AZURE_DEVOPS_ORG_NAME}"
PROJECT_NAME="HooliMathHelper"

az devops configure --defaults organization="$AZURE_DEVOPS_ORG_URL" project="$PROJECT_NAME"

echo -e "${GREEN}[SUCCESS] Connected to Azure DevOps${NC}"
echo ""

# Create Epic
echo -e "${BLUE}Creating Epic...${NC}"
EPIC_ID=$(az boards work-item create \
    --title "Math Helper Library Development" \
    --type "Epic" \
    --description "Develop a comprehensive math helper library with basic and advanced mathematical operations for the Hooli development team. This library will support distributed development with proper Git workflows and Azure DevOps integration." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

echo -e "${GREEN}[SUCCESS] Epic created with ID: $EPIC_ID${NC}"
echo ""

# Create User Stories
echo -e "${BLUE}Creating User Stories...${NC}"

# User Story 1: Basic Arithmetic
US1_ID=$(az boards work-item create \
    --title "Implement Basic Arithmetic Operations" \
    --type "User Story" \
    --description "As a developer, I want basic arithmetic functions (addition and multiplication) so that I can perform simple calculations in my applications." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

az boards work-item relation add \
    --id "$US1_ID" \
    --relation-type "parent" \
    --target-id "$EPIC_ID" \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --output none

echo -e "${GREEN}  ✓ User Story 1 created (ID: $US1_ID)${NC}"

# User Story 2: Trigonometric
US2_ID=$(az boards work-item create \
    --title "Implement Trigonometric Functions" \
    --type "User Story" \
    --description "As a developer, I want trigonometric functions (sine and cosine) so that I can perform geometric and scientific calculations." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

az boards work-item relation add \
    --id "$US2_ID" \
    --relation-type "parent" \
    --target-id "$EPIC_ID" \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --output none

echo -e "${GREEN}  ✓ User Story 2 created (ID: $US2_ID)${NC}"

# User Story 3: Distance Calculation
US3_ID=$(az boards work-item create \
    --title "Implement Distance Calculation" \
    --type "User Story" \
    --description "As a developer, I want a distance calculation function so that I can compute distances between 2D points for mapping and graphics applications." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

az boards work-item relation add \
    --id "$US3_ID" \
    --relation-type "parent" \
    --target-id "$EPIC_ID" \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --output none

echo -e "${GREEN}  ✓ User Story 3 created (ID: $US3_ID)${NC}"

# User Story 4: Testing
US4_ID=$(az boards work-item create \
    --title "Implement Comprehensive Unit Tests" \
    --type "User Story" \
    --description "As a quality engineer, I want comprehensive unit tests for all math functions so that I can ensure code reliability and prevent regressions." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

az boards work-item relation add \
    --id "$US4_ID" \
    --relation-type "parent" \
    --target-id "$EPIC_ID" \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --output none

echo -e "${GREEN}  ✓ User Story 4 created (ID: $US4_ID)${NC}"

# User Story 5: Documentation
US5_ID=$(az boards work-item create \
    --title "Create Project Documentation" \
    --type "User Story" \
    --description "As a team member, I want clear project documentation so that I can understand how to use the library and contribute to the project." \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --project "$PROJECT_NAME" \
    --query "id" \
    --output tsv)

az boards work-item relation add \
    --id "$US5_ID" \
    --relation-type "parent" \
    --target-id "$EPIC_ID" \
    --org "$AZURE_DEVOPS_ORG_URL" \
    --output none

echo -e "${GREEN}  ✓ User Story 5 created (ID: $US5_ID)${NC}"
echo ""

# Create Tasks
echo -e "${BLUE}Creating Tasks...${NC}"

# Tasks for User Story 1
az boards work-item create --title "Create math_helper.py file" --type "Task" \
    --description "Create the main Python file for the math helper library" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US1_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Create math_helper.py file${NC}"

az boards work-item create --title "Implement add() function" --type "Task" \
    --description "Implement addition function that takes two numbers and returns their sum" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US1_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Implement add() function${NC}"

az boards work-item create --title "Implement multiply() function" --type "Task" \
    --description "Implement multiplication function that takes two numbers and returns their product" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US1_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Implement multiply() function${NC}"

az boards work-item create --title "Add input validation for arithmetic operations" --type "Task" \
    --description "Add type checking and error handling for add and multiply functions" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US1_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Add input validation${NC}"

# Tasks for User Story 2
az boards work-item create --title "Implement calculate_sin() function" --type "Task" \
    --description "Implement sine function using math library, accept angle in degrees" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US2_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Implement calculate_sin()${NC}"

az boards work-item create --title "Implement calculate_cos() function" --type "Task" \
    --description "Implement cosine function using math library, accept angle in degrees" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US2_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Implement calculate_cos()${NC}"

az boards work-item create --title "Add degree to radian conversion" --type "Task" \
    --description "Ensure proper conversion from degrees to radians for trig functions" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US2_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Add degree to radian conversion${NC}"

az boards work-item create --title "Handle edge cases for trig functions" --type "Task" \
    --description "Test and handle edge cases (0, 90, 180, 270, 360 degrees)" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US2_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Handle edge cases${NC}"

# Tasks for User Story 3
az boards work-item create --title "Implement calculate_distance() function" --type "Task" \
    --description "Implement distance calculation using Euclidean distance formula" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US3_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Implement calculate_distance()${NC}"

az boards work-item create --title "Validate coordinate inputs" --type "Task" \
    --description "Add validation to ensure coordinates are numeric values" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US3_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Validate coordinate inputs${NC}"

az boards work-item create --title "Test with various coordinate pairs" --type "Task" \
    --description "Test distance calculation with positive, negative, and zero coordinates" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US3_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Test coordinate pairs${NC}"

az boards work-item create --title "Optimize distance calculation performance" --type "Task" \
    --description "Review and optimize the distance calculation for performance" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US3_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Optimize performance${NC}"

# Tasks for User Story 4
az boards work-item create --title "Create test_math_helper.py file" --type "Task" \
    --description "Set up pytest test file structure" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US4_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Create test file${NC}"

az boards work-item create --title "Write tests for arithmetic operations" --type "Task" \
    --description "Create unit tests for add() and multiply() functions" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US4_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Test arithmetic operations${NC}"

az boards work-item create --title "Write tests for trigonometric functions" --type "Task" \
    --description "Create unit tests for calculate_sin() and calculate_cos()" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US4_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Test trig functions${NC}"

az boards work-item create --title "Write tests for distance calculation" --type "Task" \
    --description "Create unit tests for calculate_distance() function" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US4_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Test distance calculation${NC}"

az boards work-item create --title "Achieve 90%+ code coverage" --type "Task" \
    --description "Ensure comprehensive test coverage for all functions" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US4_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Achieve code coverage${NC}"

# Tasks for User Story 5
az boards work-item create --title "Create README.md" --type "Task" \
    --description "Write comprehensive README with installation and usage instructions" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US5_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Create README${NC}"

az boards work-item create --title "Add function docstrings" --type "Task" \
    --description "Document all functions with proper docstrings (parameters, returns, examples)" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US5_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Add docstrings${NC}"

az boards work-item create --title "Create usage examples" --type "Task" \
    --description "Provide code examples for each function in documentation" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US5_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Create examples${NC}"

az boards work-item create --title "Document Git workflow and branching strategy" --type "Task" \
    --description "Document the team's Git workflow and contribution guidelines" \
    --org "$AZURE_DEVOPS_ORG_URL" --project "$PROJECT_NAME" --query "id" --output tsv | \
    xargs -I {} az boards work-item relation add --id {} --relation-type "parent" --target-id "$US5_ID" --org "$AZURE_DEVOPS_ORG_URL" --output none
echo -e "${GREEN}  ✓ Task: Document Git workflow${NC}"

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}[SUCCESS] All work items created!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Work Items Summary:${NC}"
echo -e "  Epic: 1 (ID: $EPIC_ID)"
echo -e "  User Stories: 5"
echo -e "  Tasks: 20"
echo ""
echo -e "${BLUE}View your work items at:${NC}"
echo -e "${YELLOW}$AZURE_DEVOPS_ORG_URL/$PROJECT_NAME/_boards${NC}"
echo ""
