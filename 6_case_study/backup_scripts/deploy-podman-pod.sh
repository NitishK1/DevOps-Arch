#!/bin/bash

# Podman Pod Deployment Script
# Alternative to Docker Swarm using Podman Pods
# Usage: ./deploy-podman-pod.sh [dockerhub-username]

set -e

DOCKERHUB_USERNAME=${1:-""}
IMAGE_NAME="company-website"
POD_NAME="company-website-pod"
NUM_REPLICAS=3

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║    Deploying Company Website using Podman Pods                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Use local image if no username provided
if [ -z "$DOCKERHUB_USERNAME" ]; then
    FULL_IMAGE_NAME="${IMAGE_NAME}:latest"
    echo "Using local image: ${FULL_IMAGE_NAME}"
else
    FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
    echo "Using Docker Hub image: ${FULL_IMAGE_NAME}"
fi

echo ""

# Check if pod already exists
if podman pod exists ${POD_NAME}; then
    echo "⚠️  Pod '${POD_NAME}' already exists"
    read -p "Do you want to remove it and create a new one? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing pod..."
        podman pod rm -f ${POD_NAME}
    else
        echo "Keeping existing pod. Exiting."
        exit 0
    fi
fi

# Create the pod with port mapping
echo "Creating pod: ${POD_NAME}"
podman pod create \
    --name ${POD_NAME} \
    --publish 80:80 \
    --share net

echo "✓ Pod created"
echo ""

# Get the absolute path for volume mounting
WEBSITE_DIR="$(pwd)/dockerContent/Case-study app"

# Deploy multiple container replicas in the pod
echo "Deploying ${NUM_REPLICAS} container replicas..."
for i in $(seq 1 ${NUM_REPLICAS}); do
    CONTAINER_NAME="web${i}"
    echo "  - Starting container: ${CONTAINER_NAME}"

    podman run -d \
        --pod ${POD_NAME} \
        --name ${CONTAINER_NAME} \
        -v "${WEBSITE_DIR}:/var/www/html:Z" \
        ${FULL_IMAGE_NAME}

    sleep 1
done

echo ""
echo "✓ All containers deployed"
echo ""

# Wait a moment for containers to start
echo "Waiting for containers to be ready..."
sleep 5

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Deployment Information"
echo "════════════════════════════════════════════════════════════════"
echo "Pod Name: ${POD_NAME}"
echo "Replicas: ${NUM_REPLICAS}"
echo "Image: ${FULL_IMAGE_NAME}"
echo "Port: 80"
echo "Volume: ${WEBSITE_DIR}"
echo ""

# Show pod status
echo "Pod Status:"
podman pod ps

echo ""
echo "Container Status:"
podman ps --pod --filter pod=${POD_NAME}

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Useful Commands"
echo "════════════════════════════════════════════════════════════════"
echo "View pod details:    podman pod inspect ${POD_NAME}"
echo "View containers:     podman ps --pod"
echo "View logs:           podman logs web1"
echo "Stop pod:            podman pod stop ${POD_NAME}"
echo "Start pod:           podman pod start ${POD_NAME}"
echo "Remove pod:          podman pod rm -f ${POD_NAME}"
echo "Generate K8s YAML:   podman generate kube ${POD_NAME} > deployment.yaml"
echo ""
echo "Access your website at: http://localhost"
echo ""
echo "✓ Deployment complete!"
echo ""
