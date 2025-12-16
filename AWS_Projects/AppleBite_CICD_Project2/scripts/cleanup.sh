#!/bin/bash

# Cleanup Script - Removes failed or old containers and images
# Usage: ./cleanup.sh [container_name] [image_name]

CONTAINER_NAME=${1:-applebite-container}
IMAGE_NAME=${2:-applebite-php-app}

echo "=========================================="
echo "Starting Cleanup Process"
echo "=========================================="

# Stop running container
echo "Stopping container: $CONTAINER_NAME"
docker stop $CONTAINER_NAME 2>/dev/null || echo "Container not running or doesn't exist"

# Remove container
echo "Removing container: $CONTAINER_NAME"
docker rm $CONTAINER_NAME 2>/dev/null || echo "Container doesn't exist"

# Remove images (optional - uncomment if you want to remove images too)
# echo "Removing images: $IMAGE_NAME"
# docker rmi $(docker images $IMAGE_NAME -q) 2>/dev/null || echo "No images found"

# Clean up dangling images
echo "Cleaning up dangling images..."
docker image prune -f

# Display remaining containers and images
echo ""
echo "Current running containers:"
docker ps

echo ""
echo "Available images:"
docker images | grep $IMAGE_NAME || echo "No $IMAGE_NAME images found"

echo ""
echo "=========================================="
echo "Cleanup completed!"
echo "=========================================="
