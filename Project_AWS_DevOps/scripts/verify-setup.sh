#!/bin/bash
# Quick verification script to test all automation scripts

set -e

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║         Script Verification - Pre-Demo Testing                    ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project Root: $PROJECT_ROOT"
echo ""

# Check 1: Verify all required scripts exist
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 1: Verifying script files exist"
echo "═══════════════════════════════════════════════════════════════════"

REQUIRED_SCRIPTS=(
    "scripts/deploy.sh"
    "scripts/cleanup.sh"
    "scripts/reset-state.sh"
    "scripts/push-app.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        echo -e "${GREEN}✓${NC} Found: $script"
    else
        echo -e "${RED}✗${NC} Missing: $script"
        exit 1
    fi
done

# Check 2: Verify scripts are executable
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 2: Verifying scripts are executable"
echo "═══════════════════════════════════════════════════════════════════"

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -x "$PROJECT_ROOT/$script" ]; then
        echo -e "${GREEN}✓${NC} Executable: $script"
    else
        echo -e "${YELLOW}⚠${NC}  Not executable: $script (fixing...)"
        chmod +x "$PROJECT_ROOT/$script"
        echo -e "${GREEN}✓${NC} Fixed: $script"
    fi
done

# Check 3: Verify credentials template exists
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 3: Verifying credentials configuration"
echo "═══════════════════════════════════════════════════════════════════"

if [ -f "$PROJECT_ROOT/config/credentials.template.sh" ]; then
    echo -e "${GREEN}✓${NC} Found: config/credentials.template.sh"
else
    echo -e "${RED}✗${NC} Missing: config/credentials.template.sh"
    exit 1
fi

if [ -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    echo -e "${GREEN}✓${NC} Found: config/credentials.sh (configured)"
    
    # Check if credentials are filled in
    source "$PROJECT_ROOT/config/credentials.sh"
    
    if [ "$AWS_ACCESS_KEY_ID" = "your-access-key-here" ]; then
        echo -e "${RED}✗${NC} Credentials not configured yet"
        echo "    Please update config/credentials.sh with your AWS credentials"
        exit 1
    else
        echo -e "${GREEN}✓${NC} Credentials appear to be configured"
    fi
else
    echo -e "${YELLOW}⚠${NC}  config/credentials.sh not found"
    echo "    Please copy config/credentials.template.sh to config/credentials.sh"
    echo "    and fill in your AWS credentials"
    exit 1
fi

# Check 4: Verify required tools
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 4: Verifying required tools are installed"
echo "═══════════════════════════════════════════════════════════════════"

REQUIRED_TOOLS=(
    "terraform"
    "aws"
    "docker"
    "git"
    "python"
)

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v $tool >/dev/null 2>&1; then
        VERSION=$($tool --version 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} $tool: $VERSION"
    else
        echo -e "${RED}✗${NC} $tool not found"
        exit 1
    fi
done

# Check 5: Verify AWS credentials work
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 5: Verifying AWS credentials"
echo "═══════════════════════════════════════════════════════════════════"

if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    echo -e "${GREEN}✓${NC} AWS credentials valid"
    echo "    Account ID: $AWS_ACCOUNT_ID"
    echo "    User: $AWS_USER"
else
    echo -e "${RED}✗${NC} AWS credentials not valid"
    echo "    Please check your credentials in config/credentials.sh"
    exit 1
fi

# Check 6: Verify Docker is running
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 6: Verifying Docker is running"
echo "═══════════════════════════════════════════════════════════════════"

if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker is running"
else
    echo -e "${RED}✗${NC} Docker is not running"
    echo "    Please start Docker Desktop"
    exit 1
fi

# Check 7: Verify Terraform directory structure
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 7: Verifying Terraform structure"
echo "═══════════════════════════════════════════════════════════════════"

if [ -f "$PROJECT_ROOT/terraform/main.tf" ]; then
    echo -e "${GREEN}✓${NC} Found: terraform/main.tf"
else
    echo -e "${RED}✗${NC} Missing: terraform/main.tf"
    exit 1
fi

if [ -d "$PROJECT_ROOT/terraform/modules" ]; then
    MODULE_COUNT=$(ls -1 "$PROJECT_ROOT/terraform/modules" | wc -l)
    echo -e "${GREEN}✓${NC} Found: terraform/modules ($MODULE_COUNT modules)"
else
    echo -e "${RED}✗${NC} Missing: terraform/modules directory"
    exit 1
fi

# Check 8: Verify no leftover Terraform state
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 8: Checking for leftover Terraform state"
echo "═══════════════════════════════════════════════════════════════════"

if [ -f "$PROJECT_ROOT/terraform/terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠${NC}  Found existing terraform.tfstate"
    echo "    This may be from a previous deployment"
    echo "    Run './scripts/reset-state.sh' if deploying to a new AWS account"
else
    echo -e "${GREEN}✓${NC} No leftover state files (clean slate)"
fi

# Check 9: Verify script syntax
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 9: Verifying script syntax"
echo "═══════════════════════════════════════════════════════════════════"

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if bash -n "$PROJECT_ROOT/$script" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Syntax OK: $script"
    else
        echo -e "${RED}✗${NC} Syntax error: $script"
        bash -n "$PROJECT_ROOT/$script"
        exit 1
    fi
done

# Check 10: Verify CodeCommit credentials
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Check 10: Verifying CodeCommit credentials"
echo "═══════════════════════════════════════════════════════════════════"

if [ -n "$CODECOMMIT_USERNAME" ] && [ "$CODECOMMIT_USERNAME" != "your-codecommit-username-here" ]; then
    echo -e "${GREEN}✓${NC} CodeCommit username configured"
else
    echo -e "${YELLOW}⚠${NC}  CodeCommit username not configured"
    echo "    You'll need this to push code after deployment"
    echo "    Generate at: https://console.aws.amazon.com/iam/home#/security_credentials"
fi

if [ -n "$CODECOMMIT_PASSWORD" ] && [ "$CODECOMMIT_PASSWORD" != "your-codecommit-password-here" ]; then
    echo -e "${GREEN}✓${NC} CodeCommit password configured"
else
    echo -e "${YELLOW}⚠${NC}  CodeCommit password not configured"
fi

# Final Summary
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "║                    Verification Summary                           ║"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ All required scripts are present and executable${NC}"
echo -e "${GREEN}✓ All required tools are installed${NC}"
echo -e "${GREEN}✓ AWS credentials are configured and valid${NC}"
echo -e "${GREEN}✓ Docker is running${NC}"
echo -e "${GREEN}✓ Terraform structure is correct${NC}"
echo -e "${GREEN}✓ Script syntax is valid${NC}"
echo ""

if [ -n "$CODECOMMIT_USERNAME" ] && [ "$CODECOMMIT_USERNAME" != "your-codecommit-username-here" ]; then
    echo -e "${GREEN}✓ Ready for full deployment and demo!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run './scripts/deploy.sh' to deploy infrastructure"
    echo "  2. Wait 15-20 minutes for deployment"
    echo "  3. Run './scripts/push-app.sh' to trigger CI/CD pipeline"
    echo "  4. Monitor progress in AWS Console"
    echo "  5. Run './scripts/cleanup.sh' when done"
else
    echo -e "${YELLOW}⚠  Almost ready!${NC}"
    echo ""
    echo "Before deploying, you need to:"
    echo "  1. Generate CodeCommit Git credentials"
    echo "  2. Update CODECOMMIT_USERNAME and CODECOMMIT_PASSWORD in config/credentials.sh"
    echo ""
    echo "Generate credentials at:"
    echo "  https://console.aws.amazon.com/iam/home#/security_credentials"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
