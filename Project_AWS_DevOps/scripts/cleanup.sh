#!/bin/bash
# Cleanup script to destroy all AWS resources

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║             AWS DevOps Multi-Region Cleanup Script                ║"
echo "║                                                                    ║"
echo "║  WARNING: This will destroy ALL resources created by Terraform    ║"
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
    exit 1
fi

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

# Confirmation prompt
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "This will delete all resources in both regions:"
echo "  - Primary Region: ${PRIMARY_REGION:-us-east-1}"
echo "  - Secondary Region: ${SECONDARY_REGION:-us-west-2}"
echo ""
echo "Including:"
echo "  - ECS Clusters and Services"
echo "  - Application Load Balancers"
echo "  - VPCs and Networking"
echo "  - ECR Repositories and Images"
echo "  - CodePipeline, CodeBuild, CodeCommit"
echo "  - CloudWatch Dashboards and Alarms"
echo "  - S3 Buckets (artifacts)"
echo "  - All associated IAM Roles and Policies"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Navigate to terraform directory
cd "$PROJECT_ROOT/terraform"

# Pre-cleanup: Delete images from ECR to avoid issues
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 1: Cleaning up ECR repositories"
echo "═══════════════════════════════════════════════════════════════════"

PROJECT_NAME=${PROJECT_NAME:-logicworks-devops}
PRIMARY_REGION=${PRIMARY_REGION:-us-east-1}
SECONDARY_REGION=${SECONDARY_REGION:-us-west-2}

# Delete ECR images in primary region
echo "Cleaning ECR in ${PRIMARY_REGION}..."
IMAGE_IDS=$(aws ecr list-images --repository-name ${PROJECT_NAME}-app --region ${PRIMARY_REGION} --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
if [ "$IMAGE_IDS" != "[]" ] && [ "$IMAGE_IDS" != "" ]; then
    aws ecr batch-delete-image \
        --repository-name ${PROJECT_NAME}-app \
        --image-ids "$IMAGE_IDS" \
        --region ${PRIMARY_REGION} 2>/dev/null || echo "  No images to delete"
else
    echo "  No images found"
fi

# Delete ECR images in secondary region
echo "Cleaning ECR in ${SECONDARY_REGION}..."
IMAGE_IDS=$(aws ecr list-images --repository-name ${PROJECT_NAME}-app --region ${SECONDARY_REGION} --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
if [ "$IMAGE_IDS" != "[]" ] && [ "$IMAGE_IDS" != "" ]; then
    aws ecr batch-delete-image \
        --repository-name ${PROJECT_NAME}-app \
        --image-ids "$IMAGE_IDS" \
        --region ${SECONDARY_REGION} 2>/dev/null || echo "  No images to delete"
else
    echo "  No images found"
fi

# Pre-cleanup: Empty S3 buckets
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 2: Emptying S3 buckets"
echo "═══════════════════════════════════════════════════════════════════"

BUCKET_NAME="${PROJECT_NAME}-pipeline-artifacts-${PRIMARY_REGION}-${AWS_ACCOUNT_ID}"
echo "Emptying bucket: ${BUCKET_NAME}"

# Delete all versions and delete markers
aws s3api list-object-versions --bucket ${BUCKET_NAME} --region ${PRIMARY_REGION} 2>/dev/null | \
grep -E '"VersionId"|"Key"' | \
awk '{gsub(/"/, "", $2); gsub(/,/, "", $2); print $2}' | \
paste - - | \
while read key version; do
    aws s3api delete-object --bucket ${BUCKET_NAME} --key "$key" --version-id "$version" --region ${PRIMARY_REGION} 2>/dev/null || true
done

echo "  Bucket emptied"

# Force delete ECS services to speed up cleanup
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 3: Scaling down ECS services"
echo "═══════════════════════════════════════════════════════════════════"

# Primary region
CLUSTER_PRIMARY="${PROJECT_NAME}-cluster-${PRIMARY_REGION}"
SERVICE_PRIMARY="${PROJECT_NAME}-service-${PRIMARY_REGION}"

echo "Scaling down primary service..."
aws ecs update-service \
    --cluster ${CLUSTER_PRIMARY} \
    --service ${SERVICE_PRIMARY} \
    --desired-count 0 \
    --region ${PRIMARY_REGION} 2>/dev/null || echo "  Service not found"

# Secondary region
CLUSTER_SECONDARY="${PROJECT_NAME}-cluster-${SECONDARY_REGION}"
SERVICE_SECONDARY="${PROJECT_NAME}-service-${SECONDARY_REGION}"

echo "Scaling down secondary service..."
aws ecs update-service \
    --cluster ${CLUSTER_SECONDARY} \
    --service ${SERVICE_SECONDARY} \
    --desired-count 0 \
    --region ${SECONDARY_REGION} 2>/dev/null || echo "  Service not found"

echo "Waiting for tasks to drain (30 seconds)..."
sleep 30

# Delete CloudWatch Log Groups
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 4: Deleting CloudWatch Log Groups"
echo "═══════════════════════════════════════════════════════════════════"

# Delete log groups in primary region
echo "Cleaning log groups in ${PRIMARY_REGION}..."
for log_group in "/aws/vpc/${PROJECT_NAME}-${PRIMARY_REGION}" "/ecs/${PROJECT_NAME}-${PRIMARY_REGION}" "/aws/codebuild/${PROJECT_NAME}-${PRIMARY_REGION}"; do
    MSYS_NO_PATHCONV=1 aws logs delete-log-group --log-group-name "$log_group" --region ${PRIMARY_REGION} 2>/dev/null && echo "  Deleted: $log_group" || true
done

# Delete log groups in secondary region
echo "Cleaning log groups in ${SECONDARY_REGION}..."
for log_group in "/aws/vpc/${PROJECT_NAME}-${SECONDARY_REGION}" "/ecs/${PROJECT_NAME}-${SECONDARY_REGION}"; do
    MSYS_NO_PATHCONV=1 aws logs delete-log-group --log-group-name "$log_group" --region ${SECONDARY_REGION} 2>/dev/null && echo "  Deleted: $log_group" || true
done

# Destroy infrastructure with Terraform
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 5: Destroying infrastructure with Terraform"
echo "═══════════════════════════════════════════════════════════════════"
echo "This may take 10-15 minutes..."
echo ""

terraform destroy \
    -var="project_name=${PROJECT_NAME}" \
    -var="environment=${ENVIRONMENT:-production}" \
    -var="primary_region=${PRIMARY_REGION}" \
    -var="secondary_region=${SECONDARY_REGION}" \
    -var="notification_email=${NOTIFICATION_EMAIL}" \
    -auto-approve

# Clean up local state
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "Phase 6: Cleaning up local files"
echo "═══════════════════════════════════════════════════════════════════"

rm -f tfplan
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
echo "✓ Local cleanup complete"
echo ""
echo "Note: All Terraform state files have been removed."
echo "This is important when switching AWS accounts (e.g., after 6-hour rotation)."

# Final summary
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "║                    Cleanup Completed Successfully                 ║"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "All AWS resources have been destroyed."
echo ""
echo "To redeploy with a new AWS account:"
echo "  1. Update config/credentials.sh with new credentials"
echo "  2. Run ./scripts/deploy.sh"
echo ""
echo "Your code is safe in this repository and can be redeployed anytime!"
echo "═══════════════════════════════════════════════════════════════════"
