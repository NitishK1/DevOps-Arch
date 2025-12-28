#!/bin/bash
# Quick Git Repository Setup with Secure Credentials
# Uses credentials from credentials.sh file

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
echo -e "\033[0;36mGit Repository Quick Setup (Secure)\033[0m"
echo "====================================================="

# Load credentials
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$CREDENTIALS_FILE" ]; then
    CREDENTIALS_FILE="$SCRIPT_DIR/../config/credentials.sh"
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo -e "\033[0;31m[ERROR] Credentials file not found!\033[0m"
    echo -e "\033[1;33mPlease run: ./scripts/setup-credentials.sh\033[0m"
    exit 1
fi

echo -e "\033[0;32m[INFO] Loading credentials...\033[0m"
source "$CREDENTIALS_FILE"

# Check session validity
if ! show_session_info; then
    echo ""
    echo -e "\033[1;33mPlease run setup-credentials.sh with new credentials\033[0m"
    exit 1
fi

# Get repository URL
REPO_URL="https://$AZURE_DEVOPS_ORG_NAME@dev.azure.com/$AZURE_DEVOPS_ORG_NAME/$PROJECT_NAME/_git/$REPO_NAME"
CLONE_DIR="repo"

echo ""
echo -e "\033[0;32m[INFO] Repository: $REPO_NAME\033[0m"
echo -e "\033[0;32m[INFO] Repository URL: $REPO_URL\033[0m"
echo -e "\033[0;32m[INFO] Clone directory: $CLONE_DIR\033[0m"

# Clone repository
echo ""
echo -e "\033[0;32m[INFO] Cloning repository...\033[0m"

if [ -d "$CLONE_DIR" ]; then
    echo -e "\033[1;33m[WARNING] Directory '$CLONE_DIR' already exists.\033[0m"
    read -p "Delete and re-clone? (y/n): " overwrite
    if [ "$overwrite" = "y" ]; then
        rm -rf "$CLONE_DIR"
    else
        echo -e "\033[0;32m[INFO] Using existing directory\033[0m"
        cd "$CLONE_DIR"
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
        cd ..
    fi
fi

if [ ! -d "$CLONE_DIR" ]; then
    echo ""
    echo -e "\033[1;33mWhen prompted for credentials:\033[0m"
    echo -e "  \033[0;36mUsername: $AZURE_EMAIL\033[0m"
    echo -e "  \033[0;36mPassword: [Your Personal Access Token]\033[0m"
    echo ""

    if [ -n "$PERSONAL_ACCESS_TOKEN" ]; then
        echo -e "\033[0;32m[INFO] Using saved PAT from credentials...\033[0m"
        # Use PAT in URL for automatic authentication
        # Remove existing username from URL first
        CLEAN_URL="${REPO_URL/https:\/\/${AZURE_DEVOPS_ORG_NAME}@/https:\/\/}"
        # Add PAT authentication
        AUTH_URL="${CLEAN_URL/https:\/\//https:\/\/${PERSONAL_ACCESS_TOKEN}@}"
        git clone "$AUTH_URL" "$CLONE_DIR" 2>&1 | grep -v "password" || true
    else
        git clone "$REPO_URL" "$CLONE_DIR"
    fi

    if [ $? -eq 0 ] && [ -d "$CLONE_DIR" ]; then
        echo -e "\033[0;32m[SUCCESS] Repository cloned!\033[0m"
    else
        echo -e "\033[0;31m[ERROR] Failed to clone repository\033[0m"
        echo "Please check your Personal Access Token and try again."
        exit 1
    fi
fi

# Change to repo directory
if [ ! -d "$CLONE_DIR" ]; then
    echo -e "\033[0;31m[ERROR] Clone directory does not exist\033[0m"
    exit 1
fi

cd "$CLONE_DIR"

# Configure git user
echo ""
echo -e "\033[0;32m[INFO] Configuring git user...\033[0m"
git config user.name "Hooli Developer"
git config user.email "$AZURE_EMAIL"

# Copy application files
echo ""
echo -e "\033[0;32m[INFO] Copying application files...\033[0m"

SOURCE_DIR="../app"
TARGET_DIR="app"

if [ -d "$SOURCE_DIR" ]; then
    rm -rf "$TARGET_DIR"
    cp -r "$SOURCE_DIR" .
    echo -e "\033[0;32m[SUCCESS] Application files copied\033[0m"
else
    echo -e "\033[1;33m[WARNING] Source directory not found: $SOURCE_DIR\033[0m"
fi

# Copy README
if [ -f "../README.md" ]; then
    cp "../README.md" .
    echo -e "\033[0;32m[SUCCESS] README copied\033[0m"
fi

# Create .gitignore
echo -e "\033[0;32m[INFO] Creating .gitignore...\033[0m"
cat > .gitignore << 'EOF'
# Credentials
config/credentials.sh
config/credentials.*.sh
*.credentials.sh
.env
.env.*

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
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

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
htmlcov/
.pytest_cache/

# Local config
*.local.*
EOF

# Check if there are changes to commit
STATUS=$(git status --porcelain)
if [ -z "$STATUS" ]; then
    echo ""
    echo -e "\033[1;33m[INFO] No changes to commit - repository already initialized\033[0m"
else
    # Stage all files
    echo ""
    echo -e "\033[0;32m[INFO] Staging files...\033[0m"
    git add .

    # Create initial commit
    echo -e "\033[0;32m[INFO] Creating initial commit...\033[0m"
    git commit -m "Initial commit: Math Helper Library project structure

- Added core math functions (add, multiply, sin, cos, distance)
- Added extended functions for branching demo
- Added comprehensive unit tests
- Added README and documentation
- Project structure setup complete

Assignment 18 - Azure DevOps Git Integration"

    # Push to remote
    echo ""
    echo -e "\033[0;32m[INFO] Pushing to Azure DevOps...\033[0m"

    if [ -n "$PERSONAL_ACCESS_TOKEN" ]; then
        # Configure credential helper
        git config credential.helper store
        echo "https://${AZURE_EMAIL}:${PERSONAL_ACCESS_TOKEN}@dev.azure.com" | git credential approve 2>/dev/null || true
    fi

    git push origin HEAD

    if [ $? -eq 0 ]; then
        echo -e "\033[0;32m[SUCCESS] Changes pushed to Azure DevOps!\033[0m"
    else
        echo -e "\033[0;31m[ERROR] Failed to push changes\033[0m"
        echo -e "\033[1;33mYou may need to push manually using your PAT\033[0m"
    fi
fi

# Return to parent directory
cd ..

# Display completion summary
CURRENT=$(date +%s)
REMAINING=$((SESSION_EXPIRY - CURRENT))
HOURS=$((REMAINING / 3600))
MINUTES=$(((REMAINING % 3600) / 60))

echo ""
echo "====================================================="
echo -e "\033[0;32mGit Setup Complete!\033[0m"
echo "====================================================="
echo ""
echo -e "\033[0;36mRepository Location: $(pwd)/$CLONE_DIR\033[0m"
echo -e "\033[0;36mRepository URL: $REPO_URL\033[0m"
echo ""
echo -e "\033[1;33mNext Steps:\033[0m"
echo "  1. View your repository in Azure DevOps:"
echo -e "     \033[0;36m$AZURE_DEVOPS_ORG_URL/$PROJECT_NAME/_git/$REPO_NAME\033[0m"
echo ""
echo "  2. Create work items in Azure Boards:"
echo -e "     \033[0;36m$AZURE_DEVOPS_ORG_URL/$PROJECT_NAME/_boards\033[0m"
echo ""
echo "  3. Make additional commits and track changes"
echo ""
echo -e "\033[1;33mSession Info:\033[0m"
echo "  Time Remaining: ${HOURS}h ${MINUTES}m"
echo -e "  Expires: \033[0;31m$(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)\033[0m"
echo ""
echo "====================================================="
