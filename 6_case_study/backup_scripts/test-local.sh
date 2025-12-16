#!/bin/bash

# Quick test script to verify the Docker setup locally
# Usage: ./test-local.sh

set -e

# Define docker as podman function
docker() {
    podman "$@"
}

IMAGE_NAME="company-website"
CONTAINER_NAME="company-website-test"

echo "============================================"
echo "Testing Docker Image Locally"
echo "============================================"

# Stop and remove existing test container if it exists
if docker ps -a | grep -q ${CONTAINER_NAME}; then
    echo "Removing existing test container..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# Run container with volume mount
echo ""
echo "Starting container with volume mount..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p 8080:80 \
    -v "$(pwd)/dockerContent/Case-study app:/var/www/html" \
    ${IMAGE_NAME}:latest

echo ""
echo "Waiting for container to be ready..."
sleep 5

# Check container status
echo ""
echo "Container Status:"
docker ps | grep ${CONTAINER_NAME}

# Test the website
echo ""
echo "Testing website accessibility..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
    echo "✓ Website is accessible!"
    echo ""
    echo "Visit: http://localhost:8080"
    echo ""
    echo "To view logs: docker logs -f ${CONTAINER_NAME}"
    echo "To stop: docker stop ${CONTAINER_NAME}"
    echo "To remove: docker rm ${CONTAINER_NAME}"
else
    echo "❌ Website is not responding correctly"
    echo "Check logs with: docker logs ${CONTAINER_NAME}"
fi

echo ""
