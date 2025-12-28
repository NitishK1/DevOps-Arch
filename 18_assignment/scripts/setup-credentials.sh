#!/bin/bash
# Interactive Credentials Setup
# This script helps you set up credentials for your rotating Azure account

set -e

FORCE=false
if [ "$1" = "-Force" ] || [ "$1" = "--force" ]; then
    FORCE=true
fi

echo "====================================================="
echo -e "\033[0;36mAzure Account Credentials Setup\033[0m"
echo "====================================================="
echo ""

# Check if credentials file already exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_FILE="$SCRIPT_DIR/../config/credentials.sh"
TEMPLATE_FILE="$SCRIPT_DIR/../config/credentials.template.sh"

if [ -f "$CREDENTIALS_FILE" ] && [ "$FORCE" = false ]; then
    echo -e "\033[1;33m[WARNING] Credentials file already exists!\033[0m"
    echo -e "\033[1;33mFile: $CREDENTIALS_FILE\033[0m"
    echo ""
    read -p "Do you want to update with new credentials? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo -e "\033[1;33mKeeping existing credentials. Use --force to override without prompt.\033[0m"
        exit 0
    fi
fi

echo -e "\033[0;32mThis script will create a secure credentials file for your Azure session.\033[0m"
echo ""
echo -e "\033[1;33mIMPORTANT: Your Azure account credentials change every 6 hours.\033[0m"
echo -e "\033[1;33mYou will need to run this script again when you get new credentials.\033[0m"
echo ""

# Collect credentials
echo "====================================================="
echo -e "\033[0;36mStep 1: Azure Account Credentials\033[0m"
echo "====================================================="
echo ""

read -p "Enter your Azure account email: " AZURE_EMAIL
read -sp "Enter your Azure account password: " AZURE_PASSWORD
echo ""

echo ""
echo "====================================================="
echo -e "\033[0;36mStep 2: Azure DevOps Organization\033[0m"
echo "====================================================="
echo ""
echo -e "\033[0;32mChoose a name for your Azure DevOps organization.\033[0m"
echo -e "\033[0;32mThis can be anything (e.g., 'hooli-dev', 'myorg', 'student123')\033[0m"
echo ""

read -p "Enter Azure DevOps organization name [hooli-dev-org]: " ORG_NAME
ORG_NAME=${ORG_NAME:-hooli-dev-org}

echo ""
echo "====================================================="
echo -e "\033[0;36mStep 3: Session Information\033[0m"
echo "====================================================="
echo ""

SESSION_START=$(date +%s)
SESSION_EXPIRY=$((SESSION_START + 21600))  # 6 hours

echo "Session Start Time: $(date)"
echo -e "\033[0;31mSession Expiry Time: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)\033[0m"
echo -e "\033[1;33mTime Available: 6 hours\033[0m"

# Create credentials file
echo ""
echo -e "\033[0;32m[INFO] Creating credentials file...\033[0m"

mkdir -p "$SCRIPT_DIR/../config"

cat > "$CREDENTIALS_FILE" << EOF
#!/bin/bash
# Azure Credentials - Auto-generated
# Created: $(date)
# Expires: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)
# DO NOT COMMIT THIS FILE TO GIT

# Azure Account Details
export AZURE_EMAIL="$AZURE_EMAIL"
export AZURE_PASSWORD="$AZURE_PASSWORD"
export AZURE_DEVOPS_ORG_NAME="$ORG_NAME"

# Personal Access Token (will be set during setup)
export PERSONAL_ACCESS_TOKEN=""

# Derived Configuration
export AZURE_DEVOPS_ORG_URL="https://dev.azure.com/\$AZURE_DEVOPS_ORG_NAME"
export PROJECT_NAME="HooliMathHelper"
export REPO_NAME="HooliMathHelper"

# Session Information
export SESSION_START=$SESSION_START
export SESSION_EXPIRY=$SESSION_EXPIRY

# Function to show session info
show_session_info() {
    local current=\$(date +%s)
    local remaining=\$((SESSION_EXPIRY - current))

    if [ \$remaining -lt 0 ]; then
        echo "====================================================="
        echo -e "\033[0;31mWARNING: Azure Session Has Expired!\033[0m"
        echo "====================================================="
        echo -e "\033[1;33mPlease run setup-credentials.sh again with new credentials\033[0m"
        return 1
    fi

    local hours=\$((remaining / 3600))
    local minutes=\$(((remaining % 3600) / 60))

    echo "====================================================="
    echo -e "\033[0;32mAzure Session Active\033[0m"
    echo "====================================================="
    echo "Email: \$AZURE_EMAIL"
    echo "Organization: \$AZURE_DEVOPS_ORG_NAME"
    echo -e "\033[1;33mTime Remaining: \${hours}h \${minutes}m\033[0m"

    if [ \$remaining -lt 3600 ]; then
        echo ""
        echo -e "\033[0;31mWARNING: Less than 1 hour remaining!\033[0m"
        echo -e "\033[0;31mConsider backing up your work now!\033[0m"
    elif [ \$remaining -lt 7200 ]; then
        echo ""
        echo -e "\033[1;33mNOTE: Less than 2 hours remaining\033[0m"
    fi
    echo "====================================================="
    return 0
}

# Auto-display on load
show_session_info
EOF

chmod +x "$CREDENTIALS_FILE"

echo -e "\033[0;32m[SUCCESS] Credentials file created!\033[0m"
echo -e "\033[0;36mLocation: $CREDENTIALS_FILE\033[0m"

# Update .gitignore
echo ""
echo -e "\033[0;32m[INFO] Updating .gitignore to exclude credentials...\033[0m"

GITIGNORE_PATH="$SCRIPT_DIR/../.gitignore"

cat > "$GITIGNORE_PATH" << 'EOF'
# Credentials (NEVER COMMIT)
config/credentials.sh
config/credentials.*.sh
*.credentials.sh
.env
.env.*

# Azure/PAT
*.pat
pat.txt
token.txt

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
dist/
*.egg-info/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Testing
.coverage
.pytest_cache/

# Backups
backup/
*.bak

# Local config
*.local.*
config/*.local.*

# Logs
*.log
logs/

# Temporary
tmp/
temp/
*.tmp
EOF

echo -e "\033[0;32m[SUCCESS] .gitignore updated\033[0m"

# Display summary
echo ""
echo "====================================================="
echo -e "\033[0;32mSetup Complete!\033[0m"
echo "====================================================="
echo ""
echo -e "\033[0;32mYour credentials have been saved securely.\033[0m"
echo ""
echo -e "\033[1;33mNext steps:\033[0m"
echo "  1. Load credentials:"
echo -e "     \033[0;37msource $CREDENTIALS_FILE\033[0m"
echo ""
echo "  2. Run Azure DevOps setup:"
echo -e "     \033[0;37m./scripts/setup-azure-devops-secure.sh\033[0m"
echo ""
echo -e "\033[1;33mWhen you get NEW credentials (after 6 hours):\033[0m"
echo -e "  \033[0;37m./scripts/setup-credentials.sh --force\033[0m"
echo ""
echo -e "\033[1;33mTo check session status at any time:\033[0m"
echo -e "  \033[0;37msource $CREDENTIALS_FILE && show_session_info\033[0m"
echo ""
echo "====================================================="

# Set reminder
echo ""
echo -e "\033[0;31mREMINDER: Your session expires at: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)\033[0m"
echo -e "\033[1;33mSet an alarm for 5 hours from now to backup your work!\033[0m"
echo "====================================================="
