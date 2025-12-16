#!/bin/bash

# Deployment Script - Builds and deploys the Docker container
# Usage: ./deploy.sh [version]

VERSION=${1:-latest}
CONTAINER_NAME="applebite-container"
IMAGE_NAME="applebite-php-app"
PORT=80

echo "=========================================="
echo "Starting Deployment Process"
echo "Version: $VERSION"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "Dockerfile not found in current directory"
    exit 1
fi

# Stop and remove old container if exists
echo "Stopping and removing old container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Build Docker image
echo "Building Docker image: $IMAGE_NAME:$VERSION"
docker build -t $IMAGE_NAME:$VERSION .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

# Tag as latest
docker tag $IMAGE_NAME:$VERSION $IMAGE_NAME:latest

# Run container
echo "Running Docker container: $CONTAINER_NAME"
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -e APP_VERSION=$VERSION \
    --restart unless-stopped \
    $IMAGE_NAME:latest

if [ $? -ne 0 ]; then
    echo "Failed to start container!"
    exit 1
fi

# Wait for container to be ready
echo "Waiting for container to be ready..."
sleep 5

# Verify container is running
if docker ps | grep -q $CONTAINER_NAME; then
    echo ""
    echo "=========================================="
    echo "Deployment Successful!"
    echo "Container: $CONTAINER_NAME"
    echo "Image: $IMAGE_NAME:$VERSION"
    echo "Port: $PORT"
    echo "=========================================="
    echo ""
    echo "Container logs:"
    docker logs $CONTAINER_NAME
    echo ""
    echo "Test the application:"
    echo "curl http://localhost:$PORT"
else
    echo "Container failed to start!"
    docker logs $CONTAINER_NAME
    exit 1
fi
