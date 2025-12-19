#!/bin/bash
# Quick status check script

set -e

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                  AWS DevOps Status Check                          ║"
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

PROJECT_NAME=${PROJECT_NAME:-logicworks-devops}
PRIMARY_REGION=${PRIMARY_REGION:-us-east-1}
SECONDARY_REGION=${SECONDARY_REGION:-us-west-2}

echo "Checking Primary Region (${PRIMARY_REGION})..."
echo "───────────────────────────────────────────────────────────────────"

# Check ECS service
CLUSTER_PRIMARY="${PROJECT_NAME}-cluster-${PRIMARY_REGION}"
SERVICE_PRIMARY="${PROJECT_NAME}-service-${PRIMARY_REGION}"

ECS_STATUS=$(aws ecs describe-services \
    --cluster ${CLUSTER_PRIMARY} \
    --services ${SERVICE_PRIMARY} \
    --region ${PRIMARY_REGION} \
    --query 'services[0].status' \
    --output text 2>/dev/null || echo "NOT_FOUND")

RUNNING_COUNT=$(aws ecs describe-services \
    --cluster ${CLUSTER_PRIMARY} \
    --services ${SERVICE_PRIMARY} \
    --region ${PRIMARY_REGION} \
    --query 'services[0].runningCount' \
    --output text 2>/dev/null || echo "0")

DESIRED_COUNT=$(aws ecs describe-services \
    --cluster ${CLUSTER_PRIMARY} \
    --services ${SERVICE_PRIMARY} \
    --region ${PRIMARY_REGION} \
    --query 'services[0].desiredCount' \
    --output text 2>/dev/null || echo "0")

echo "ECS Service: ${ECS_STATUS}"
echo "Tasks: ${RUNNING_COUNT}/${DESIRED_COUNT} running"

# Check ALB
ALB_NAME="${PROJECT_NAME}-alb-${PRIMARY_REGION}"
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names ${ALB_NAME} \
    --region ${PRIMARY_REGION} \
    --query 'LoadBalancers[0].DNSName' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$ALB_DNS" != "NOT_FOUND" ]; then
    echo "Application URL: http://${ALB_DNS}"
fi

echo ""
echo "Checking Secondary Region (${SECONDARY_REGION})..."
echo "───────────────────────────────────────────────────────────────────"

# Check ECS service (secondary)
CLUSTER_SECONDARY="${PROJECT_NAME}-cluster-${SECONDARY_REGION}"
SERVICE_SECONDARY="${PROJECT_NAME}-service-${SECONDARY_REGION}"

ECS_STATUS_SEC=$(aws ecs describe-services \
    --cluster ${CLUSTER_SECONDARY} \
    --services ${SERVICE_SECONDARY} \
    --region ${SECONDARY_REGION} \
    --query 'services[0].status' \
    --output text 2>/dev/null || echo "NOT_FOUND")

RUNNING_COUNT_SEC=$(aws ecs describe-services \
    --cluster ${CLUSTER_SECONDARY} \
    --services ${SERVICE_SECONDARY} \
    --region ${SECONDARY_REGION} \
    --query 'services[0].runningCount' \
    --output text 2>/dev/null || echo "0")

DESIRED_COUNT_SEC=$(aws ecs describe-services \
    --cluster ${CLUSTER_SECONDARY} \
    --services ${SERVICE_SECONDARY} \
    --region ${SECONDARY_REGION} \
    --query 'services[0].desiredCount' \
    --output text 2>/dev/null || echo "0")

echo "ECS Service: ${ECS_STATUS_SEC}"
echo "Tasks: ${RUNNING_COUNT_SEC}/${DESIRED_COUNT_SEC} running"

# Check ALB (secondary)
ALB_NAME_SEC="${PROJECT_NAME}-alb-${SECONDARY_REGION}"
ALB_DNS_SEC=$(aws elbv2 describe-load-balancers \
    --names ${ALB_NAME_SEC} \
    --region ${SECONDARY_REGION} \
    --query 'LoadBalancers[0].DNSName' \
    --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$ALB_DNS_SEC" != "NOT_FOUND" ]; then
    echo "Application URL: http://${ALB_DNS_SEC}"
fi

echo ""
echo "───────────────────────────────────────────────────────────────────"
echo "Status check complete!"
