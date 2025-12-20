#!/bin/bash
# Script to push application updates to CodeCommit

set -e

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║         Push Application Updates to CodeCommit                    ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load credentials
if [ -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    source "$PROJECT_ROOT/config/credentials.sh"
else
    echo "✗ Error: credentials.sh not found!"
    exit 1
fi

cd "$PROJECT_ROOT"

# Verify AWS credentials are loaded
echo "Verifying AWS credentials..."
aws sts get-caller-identity > /dev/null 2>&1 || {
    echo "✗ AWS credentials not configured properly!"
    echo "  Please run: source config/credentials.sh"
    exit 1
}
echo "✓ AWS credentials valid"
echo ""

# Check if CodeCommit credentials are set
if [ -z "$CODECOMMIT_USERNAME" ] || [ -z "$CODECOMMIT_PASSWORD" ]; then
    echo "✗ CodeCommit credentials not found in environment!"
    echo ""
    echo "Please generate CodeCommit Git credentials:"
    echo "1. Go to IAM Console: https://console.aws.amazon.com/iam/home#/security_credentials"
    echo "2. Scroll to 'HTTPS Git credentials for AWS CodeCommit'"
    echo "3. Click 'Generate credentials' and save the username and password"
    echo "4. Update config/credentials.sh with:"
    echo "   export CODECOMMIT_USERNAME=\"your-username\""
    echo "   export CODECOMMIT_PASSWORD=\"your-password\""
    echo ""
    exit 1
fi

echo "✓ CodeCommit credentials found"
echo ""

# Configure CodeCommit remote URL with credentials
REGION="us-east-1"
REPO_NAME="logicworks-devops-repo"

# Verify repository exists
echo "Verifying CodeCommit repository..."
aws codecommit get-repository --repository-name "$REPO_NAME" --region "$REGION" > /dev/null 2>&1 || {
    echo "✗ Cannot access CodeCommit repository!"
    exit 1
}
echo "✓ Repository verified"
echo ""

# Update remote URL to use HTTPS with embedded credentials
CODECOMMIT_URL="https://${CODECOMMIT_USERNAME}:${CODECOMMIT_PASSWORD}@git-codecommit.${REGION}.amazonaws.com/v1/repos/${REPO_NAME}"
CURRENT_URL=$(git remote get-url codecommit-primary 2>/dev/null || echo "")

if [ "$CURRENT_URL" != "$CODECOMMIT_URL" ]; then
    echo "Updating CodeCommit remote URL..."
    git remote set-url codecommit-primary "$CODECOMMIT_URL"
    echo "✓ Remote URL configured with credentials"
    echo ""
fi

# Check if changes exist
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit."
    exit 0
fi

# Get commit message
if [ -z "$1" ]; then
    echo "Enter commit message:"
    read COMMIT_MSG
else
    COMMIT_MSG="$1"
fi

# Commit and push
echo ""
echo "Committing changes..."
git add .
git commit -m "$COMMIT_MSG"

echo ""
echo "Pushing to CodeCommit..."
echo ""

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "master")

# Push to CodeCommit - try main first, then master
if git push codecommit-primary "HEAD:main" 2>&1; then
    echo ""
    echo "✓ Pushed successfully to main branch"
elif git push codecommit-primary "HEAD:master" 2>&1; then
    echo ""
    echo "✓ Pushed successfully to master branch"
else
    echo ""
    echo "✗ Push failed!"
    echo ""
    echo "Please verify your CodeCommit Git credentials are correct."
    echo "You can regenerate them at:"
    echo "https://console.aws.amazon.com/iam/home#/security_credentials"
    exit 1
fi

echo ""
echo "✓ Changes pushed successfully!"
echo ""
echo "The CI/CD pipeline will automatically:"
echo "  1. Build Docker image"
echo "  2. Push to ECR"
echo "  3. Deploy to staging"
echo "  4. Wait for manual approval"
echo "  5. Deploy to production"
echo ""
echo "Monitor the pipeline at:"
echo "https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
