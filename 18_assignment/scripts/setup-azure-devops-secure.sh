#!/bin/bash
# Setup Azure DevOps with Secure Credentials
# This version uses credentials from the credentials file

set -e

CREDENTIALS_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --credentials-file)
            CREDENTIALS_FILE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo "====================================================="
echo -e "\033[0;36mAzure DevOps Secure Setup\033[0m"
echo "====================================================="

# Color functions
print_info() {
    echo -e "\033[0;32m[INFO] $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m[WARNING] $1\033[0m"
}

print_error() {
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

# Load credentials
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$CREDENTIALS_FILE" ]; then
    CREDENTIALS_FILE="$SCRIPT_DIR/../config/credentials.sh"
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    print_error "Credentials file not found: $CREDENTIALS_FILE"
    echo ""
    echo -e "\033[1;33mPlease run setup-credentials.sh first:\033[0m"
    echo "  ./scripts/setup-credentials.sh"
    exit 1
fi

print_info "Loading credentials from: $CREDENTIALS_FILE"
source "$CREDENTIALS_FILE"

# Verify credentials are loaded
if [ -z "$AZURE_EMAIL" ] || [ -z "$AZURE_DEVOPS_ORG_NAME" ]; then
    print_error "Credentials not properly loaded. Please check your credentials file."
    exit 1
fi

# Check session expiry
CURRENT=$(date +%s)
TIME_REMAINING=$((SESSION_EXPIRY - CURRENT))

if [ $TIME_REMAINING -lt 0 ]; then
    print_error "Your Azure session has expired!"
    echo "Session expired at: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)"
    echo ""
    echo -e "\033[1;33mPlease run setup-credentials.sh with your NEW credentials:\033[0m"
    echo "  ./scripts/setup-credentials.sh --force"
    exit 1
fi

HOURS=$((TIME_REMAINING / 3600))
MINUTES=$(((TIME_REMAINING % 3600) / 60))
print_info "Session valid - ${HOURS}h ${MINUTES}m remaining"

if [ $TIME_REMAINING -lt 3600 ]; then
    print_warning "Less than 1 hour remaining in session!"
    echo -e "\033[0;31mConsider backing up your work now!\033[0m"
    read -p "Continue anyway? (y/n): " continue_choice
    if [ "$continue_choice" != "y" ]; then
        exit 0
    fi
fi

# Check prerequisites
print_info "Checking prerequisites..."

if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
print_info "Azure CLI is installed"

if ! command -v git &> /dev/null; then
    print_error "Git is not installed."
    exit 1
fi
print_info "Git is installed"

# Login to Azure
echo ""
print_info "Logging in to Azure..."
echo "Email: $AZURE_EMAIL"

echo ""
echo -e "\033[1;33m========================================\033[0m"
echo -e "\033[1;33mDevice Code Authentication\033[0m"
echo -e "\033[1;33m========================================\033[0m"
echo ""
echo -e "\033[0;32mA code will be displayed below.\033[0m"
echo -e "\033[0;32mFollow these steps:\033[0m"
echo "  1. Open your browser"
echo "  2. Go to: https://microsoft.com/devicelogin"
echo "  3. Enter the code shown below"
echo "  4. Sign in with: $AZURE_EMAIL"
echo ""
echo -e "\033[1;33mStarting authentication...\033[0m"
echo ""

az login --use-device-code

if [ $? -eq 0 ]; then
    print_info "Successfully logged in to Azure"
else
    print_error "Failed to authenticate. Please try again."
    exit 1
fi

# Verify login
ACCOUNT=$(az account show --query "user.name" -o tsv 2>/dev/null || echo "")
if [ "$ACCOUNT" != "$AZURE_EMAIL" ]; then
    print_warning "Logged in as: $ACCOUNT (expected: $AZURE_EMAIL)"
    echo "If this is a different account, credentials may not match."
else
    print_info "Confirmed: Logged in as $ACCOUNT"
fi

# Install Azure DevOps extension
print_info "Installing Azure DevOps CLI extension..."
az extension add --name azure-devops --yes --only-show-errors 2>/dev/null || print_warning "Extension may already be installed"
print_info "Azure DevOps extension ready"

# Configure defaults
print_info "Configuring Azure DevOps defaults..."
az devops configure --defaults organization="$AZURE_DEVOPS_ORG_URL"

# Create project
print_info "Creating project: $PROJECT_NAME..."
az devops project create \
    --name "$PROJECT_NAME" \
    --description "Math Helper Library for distributed development team - Assignment 18" \
    --source-control git \
    --visibility private \
    --process Agile \
    --only-show-errors 2>/dev/null && print_info "Project created successfully!" || print_warning "Project may already exist - continuing..."

# Set default project
az devops configure --defaults project="$PROJECT_NAME"

# Get repository details
print_info "Getting repository information..."
REPO_URL=$(az repos show --repository "$REPO_NAME" --query "remoteUrl" -o tsv 2>/dev/null || echo "")

if [ -z "$REPO_URL" ]; then
    print_error "Failed to get repository information"
    echo "The project may not have been created successfully."
    exit 1
fi

print_info "Repository URL: $REPO_URL"

# Create sprint
print_info "Creating Sprint 1..."
START_DATE=$(date -d '+1 day' '+%Y-%m-%d' 2>/dev/null || date -v+1d '+%Y-%m-%d')
END_DATE=$(date -d '+15 days' '+%Y-%m-%d' 2>/dev/null || date -v+15d '+%Y-%m-%d')

az boards iteration project create \
    --name "Sprint 1" \
    --project "$PROJECT_NAME" \
    --start-date "$START_DATE" \
    --finish-date "$END_DATE" \
    --only-show-errors 2>/dev/null && print_info "Sprint 1 created successfully!" || print_warning "Sprint may already exist"

# Create Personal Access Token instructions
echo ""
echo "====================================================="
echo -e "\033[1;33mPersonal Access Token (PAT) Required\033[0m"
echo "====================================================="
echo ""
echo -e "\033[1;33mYou need to create a PAT for Git operations:\033[0m"
echo ""
echo "1. Go to: $AZURE_DEVOPS_ORG_URL"
echo "2. Click User Settings (top right) -> Personal Access Tokens"
echo "3. Click 'New Token'"
echo "4. Configure:"
echo "   - Name: HooliMathHelper-PAT"
echo "   - Organization: $AZURE_DEVOPS_ORG_NAME"
echo "   - Expiration: Custom (6 hours from now)"
echo "   - Scopes: Code (Read & Write)"
echo "5. Click 'Create'"
echo -e "\033[0;31m6. COPY THE TOKEN IMMEDIATELY!\033[0m"
echo ""
read -p "Press Enter after creating your PAT..."

echo ""
read -sp "Paste your Personal Access Token here: " PAT_TOKEN
echo ""

# Update credentials file with PAT
print_info "Saving PAT to credentials file..."
sed -i.bak "s|^export PERSONAL_ACCESS_TOKEN=.*|export PERSONAL_ACCESS_TOKEN=\"$PAT_TOKEN\"|" "$CREDENTIALS_FILE"
rm -f "${CREDENTIALS_FILE}.bak"

# Update configuration file
CONFIG_DIR="$SCRIPT_DIR/../config"
CONFIG_FILE="$CONFIG_DIR/azure-devops-config.sh"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" << EOF
#!/bin/bash
# Azure DevOps Configuration
# Auto-generated by setup-azure-devops-secure.sh
# Created: $(date)

export AZURE_DEVOPS_ORG_URL="$AZURE_DEVOPS_ORG_URL"
export AZURE_DEVOPS_PROJECT="$PROJECT_NAME"
export AZURE_DEVOPS_REPO_NAME="$REPO_NAME"
export AZURE_DEVOPS_REPO_URL="$REPO_URL"

echo -e "\033[0;32mAzure DevOps configuration loaded\033[0m"
echo -e "\033[0;36mOrganization: $AZURE_DEVOPS_ORG_URL\033[0m"
echo -e "\033[0;36mProject: $PROJECT_NAME\033[0m"
echo -e "\033[0;36mRepository: $REPO_URL\033[0m"
EOF

chmod +x "$CONFIG_FILE"
print_info "Configuration saved to: $CONFIG_FILE"

# Display summary
echo ""
echo "====================================================="
echo -e "\033[0;32mSetup Complete!\033[0m"
echo "====================================================="
echo ""
echo -e "\033[1;33mConfiguration Summary:\033[0m"
echo "  Organization: $AZURE_DEVOPS_ORG_URL"
echo "  Project: $PROJECT_NAME"
echo "  Repository: $REPO_URL"
echo -e "  \033[0;31mSession Expires: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)\033[0m"
echo -e "  \033[1;33mTime Remaining: ${HOURS}h ${MINUTES}m\033[0m"
echo ""
echo -e "\033[1;33mNext Steps:\033[0m"
echo "  1. Clone repository:"
echo -e "     \033[0;37m./scripts/quick-setup-secure.sh\033[0m"
echo ""
echo "  2. Access your project:"
echo -e "     \033[0;36m$AZURE_DEVOPS_ORG_URL/$PROJECT_NAME\033[0m"
echo ""
echo "====================================================="
