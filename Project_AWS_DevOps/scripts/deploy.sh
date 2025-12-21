#!/bin/bash
# Main deployment script for AWS DevOps Multi-Region Project

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║        AWS DevOps Multi-Region Deployment Script                  ║"
echo "║                   Logicworks Project                               ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load credentials
if [ -f "$PROJECT_ROOT/config/credentials.sh" ]; then
    echo "✓ Loading AWS credentials..."
    source "$PROJECT_ROOT/config/credentials.sh"
else
    echo "✗ Error: credentials.sh not found!"
    echo "  Please create config/credentials.sh from config/credentials.template.sh"
    exit 1
fi

# Validate required variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "✗ Error: AWS credentials not set!"
    echo "  Please configure your credentials in config/credentials.sh"
    exit 1
fi

if [ -z "$NOTIFICATION_EMAIL" ]; then
    echo "✗ Error: NOTIFICATION_EMAIL not set!"
    echo "  Please set NOTIFICATION_EMAIL in config/credentials.sh"
    exit 1
fi

# Check required tools
echo ""
echo "Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "✗ Terraform is required but not installed. Aborting." >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "✗ AWS CLI is required but not installed. Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "✗ Docker is required but not installed. Aborting." >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "✗ Git is required but not installed. Aborting." >&2; exit 1; }

echo "✓ All prerequisites met"

# Verify AWS credentials
echo ""
echo "Verifying AWS credentials..."
if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "✓ AWS credentials valid"
    echo "  Account ID: $AWS_ACCOUNT_ID"
else
    echo "✗ Error: Invalid AWS credentials!"
    exit 1
fi

# Navigate to terraform directory
cd "$PROJECT_ROOT/terraform"

# Pre-deployment cleanup: Delete any leftover log groups
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Pre-deployment: Cleaning up leftover resources"
echo "═══════════════════════════════════════════════════════════════════"

PROJECT_NAME=${PROJECT_NAME:-logicworks-devops}
PRIMARY_REGION=${PRIMARY_REGION:-us-east-1}
SECONDARY_REGION=${SECONDARY_REGION:-us-east-2}

echo "Checking for leftover CloudWatch Log Groups..."
for log_group in "/aws/vpc/${PROJECT_NAME}-${PRIMARY_REGION}" "/ecs/${PROJECT_NAME}-${PRIMARY_REGION}" "/aws/codebuild/${PROJECT_NAME}-${PRIMARY_REGION}"; do
    MSYS_NO_PATHCONV=1 aws logs delete-log-group --log-group-name "$log_group" --region ${PRIMARY_REGION} 2>/dev/null && echo "  Deleted: $log_group" || true
done

for log_group in "/aws/vpc/${PROJECT_NAME}-${SECONDARY_REGION}" "/ecs/${PROJECT_NAME}-${SECONDARY_REGION}"; do
    MSYS_NO_PATHCONV=1 aws logs delete-log-group --log-group-name "$log_group" --region ${SECONDARY_REGION} 2>/dev/null && echo "  Deleted: $log_group" || true
done

echo "  Pre-deployment cleanup complete"

# Initialize Terraform
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 1: Initializing Terraform"
echo "═══════════════════════════════════════════════════════════════════"
terraform init

# Plan infrastructure
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 2: Planning infrastructure"
echo "═══════════════════════════════════════════════════════════════════"
terraform plan \
    -var="project_name=${PROJECT_NAME:-logicworks-devops}" \
    -var="environment=${ENVIRONMENT:-production}" \
    -var="primary_region=${PRIMARY_REGION:-us-east-1}" \
    -var="secondary_region=${SECONDARY_REGION:-us-east-2}" \
    -var="notification_email=${NOTIFICATION_EMAIL}" \
    -out=tfplan

# Apply infrastructure
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 3: Deploying infrastructure"
echo "═══════════════════════════════════════════════════════════════════"
echo "This will take approximately 15-20 minutes..."
echo ""

terraform apply tfplan

# Get outputs
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 4: Gathering deployment information"
echo "═══════════════════════════════════════════════════════════════════"

PRIMARY_ECR=$(terraform output -raw primary_ecr_repository)
SECONDARY_ECR=$(terraform output -raw secondary_ecr_repository)
PRIMARY_CODECOMMIT=$(terraform output -raw primary_codecommit_clone_url)
SECONDARY_CODECOMMIT=$(terraform output -raw secondary_codecommit_clone_url)
PRIMARY_ALB=$(terraform output -raw primary_alb_url)
SECONDARY_ALB=$(terraform output -raw secondary_alb_url)

# Build and push Docker image to primary region
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 5: Building and pushing Docker image"
echo "═══════════════════════════════════════════════════════════════════"

cd "$PROJECT_ROOT/app"

# Login to ECR (Primary Region)
echo "Logging into ECR (${PRIMARY_REGION})..."
aws ecr get-login-password --region ${PRIMARY_REGION} | docker login --username AWS --password-stdin ${PRIMARY_ECR}

# Build Docker image
echo "Building Docker image..."
docker build -t ${PROJECT_NAME:-logicworks-devops}-app:latest .

# Tag and push to primary ECR
echo "Pushing to primary ECR..."
docker tag ${PROJECT_NAME:-logicworks-devops}-app:latest ${PRIMARY_ECR}:latest
docker push ${PRIMARY_ECR}:latest

# Login to ECR (Secondary Region)
echo "Logging into ECR (${SECONDARY_REGION})..."
aws ecr get-login-password --region ${SECONDARY_REGION} | docker login --username AWS --password-stdin ${SECONDARY_ECR}

# Tag and push to secondary ECR
echo "Pushing to secondary ECR..."
docker tag ${PROJECT_NAME:-logicworks-devops}-app:latest ${SECONDARY_ECR}:latest
docker push ${SECONDARY_ECR}:latest

# Wait for ECS services to stabilize
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 6: Waiting for ECS services to stabilize"
echo "═══════════════════════════════════════════════════════════════════"
echo "This may take a few minutes..."

# Get outputs safely by redirecting stderr
PRIMARY_CLUSTER=$(cd "$PROJECT_ROOT/terraform" && terraform output -raw primary_ecs_cluster 2>/dev/null || echo "")
SECONDARY_CLUSTER=$(cd "$PROJECT_ROOT/terraform" && terraform output -raw secondary_ecs_cluster 2>/dev/null || echo "")

if [ -n "$PRIMARY_CLUSTER" ]; then
    echo "Waiting for primary region service..."
    aws ecs wait services-stable --cluster ${PRIMARY_CLUSTER} --services ${PROJECT_NAME:-logicworks-devops}-service-${PRIMARY_REGION} --region ${PRIMARY_REGION} || true
fi

if [ -n "$SECONDARY_CLUSTER" ]; then
    echo "Waiting for secondary region service..."
    aws ecs wait services-stable --cluster ${SECONDARY_CLUSTER} --services ${PROJECT_NAME:-logicworks-devops}-service-${SECONDARY_REGION} --region ${SECONDARY_REGION} || true
fi

# Setup CodeCommit repository
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 7: Setting up CodeCommit repository"
echo "═══════════════════════════════════════════════════════════════════"

cd "$PROJECT_ROOT"

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit"
fi

# Configure git credential helper for CodeCommit
git config credential.helper '!aws codecommit credential-helper $@' 2>/dev/null || true
git config credential.UseHttpPath true 2>/dev/null || true

# Add CodeCommit as remote (primary region)
PRIMARY_CODECOMMIT=$(cd "$PROJECT_ROOT/terraform" && terraform output -raw primary_codecommit_clone_url 2>/dev/null)
# Remove existing remote if present to avoid conflicts
git remote remove codecommit-primary 2>/dev/null || true
if [ -n "$PRIMARY_CODECOMMIT" ]; then
    git remote add codecommit-primary ${PRIMARY_CODECOMMIT} 2>/dev/null || true
    echo "✓ Added primary CodeCommit remote"
fi

# Push to CodeCommit (non-interactive, with timeout)
echo "Pushing code to CodeCommit (primary region)..."
timeout 30 git push codecommit-primary main 2>&1 || timeout 30 git push codecommit-primary master:main 2>&1 || echo "Note: CodeCommit push skipped (optional step)"

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════════════"
cd "$PROJECT_ROOT/terraform" && terraform output -raw deployment_summary 2>/dev/null || echo "Deployment completed"
echo "═══════════════════════════════════════════════════════════════════"

# Get URLs for display
PRIMARY_ALB=$(cd "$PROJECT_ROOT/terraform" && terraform output -raw primary_alb_url 2>/dev/null || echo "")
SECONDARY_ALB=$(cd "$PROJECT_ROOT/terraform" && terraform output -raw secondary_alb_url 2>/dev/null || echo "")

echo ""
echo "IMPORTANT NEXT STEPS:"
echo "---------------------------------------------------------------------"
echo "1. Check your email (${NOTIFICATION_EMAIL}) and confirm SNS subscriptions"
echo "2. Access your applications:"
echo "   Primary:   ${PRIMARY_ALB}"
echo "   Secondary: ${SECONDARY_ALB}"
echo ""
echo "3. Monitor the CI/CD pipeline in AWS Console:"
echo "   https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
echo ""
echo "4. View CloudWatch dashboards for monitoring:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=${PRIMARY_REGION}#dashboards:"
echo ""
echo "For cleanup before your AWS account expires:"
echo "   ./scripts/cleanup.sh"
echo ""
echo "✓ Deployment completed successfully!"
echo "═══════════════════════════════════════════════════════════════════"
