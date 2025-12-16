#!/bin/bash

# Script to build the Docker image for the company website
# Usage: ./build.sh

set -e

echo "============================================"
echo "Building Company Website Docker Image"
echo "============================================"

# Define docker as podman function (aliases don't work in scripts)
docker() {
    podman "$@"
}

# Define variables
IMAGE_NAME="company-website"
IMAGE_TAG="latest"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build --tls-verify=false -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo ""
echo "✓ Docker image built successfully!"
echo ""
echo "To run the container locally:"
echo "  docker run -d -p 80:80 -v \$(pwd)/dockerContent/Case-study\ app:/var/www/html ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Or use docker-compose:"
echo "  docker-compose up -d"
echo ""
