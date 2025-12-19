#!/bin/bash
# Reset Terraform state for new AWS account deployment
# Use this when your AWS account changes (e.g., 6-hour rotation)

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║          Reset Terraform State for New AWS Account                ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "This script will remove local Terraform state files."
echo "Use this when switching to a new AWS account."
echo ""
echo "This will NOT destroy any AWS resources."
echo "It only cleans up local state files so you can deploy to a new account."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

read -p "Continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

cd "$PROJECT_ROOT/terraform"

echo ""
echo "Removing Terraform state files..."
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f tfplan
rm -f .terraform.lock.hcl

echo "✓ State files removed"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Next steps:"
echo "  1. Update config/credentials.sh with your new AWS credentials"
echo "  2. Run ./scripts/deploy.sh to deploy to the new account"
echo "═══════════════════════════════════════════════════════════════════"
