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

# Configure git for CodeCommit
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

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
git push codecommit-primary main

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
