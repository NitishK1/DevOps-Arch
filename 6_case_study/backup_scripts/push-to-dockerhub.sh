#!/bin/bash

# Script to push Docker image to Docker Hub
# Usage: ./push-to-dockerhub.sh <your-dockerhub-username>

set -e

# Define docker as podman function
docker() {
    podman "$@"
}

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: ./push-to-dockerhub.sh <your-dockerhub-username>"
    echo "Example: ./push-to-dockerhub.sh johndoe"
    exit 1
fi

DOCKERHUB_USERNAME=$1
IMAGE_NAME="company-website"
LOCAL_TAG="latest"

echo "============================================"
echo "Pushing Image to Docker Hub"
echo "============================================"

# Login to Docker Hub (you'll be prompted for credentials)
echo "Please login to Docker Hub:"
docker login docker.io

# Tag the image with your Docker Hub username
echo ""
echo "Tagging image for Docker Hub..."
docker tag ${IMAGE_NAME}:${LOCAL_TAG} docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${LOCAL_TAG}
docker tag ${IMAGE_NAME}:${LOCAL_TAG} docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0

# Push the image to Docker Hub
echo ""
echo "Pushing image to Docker Hub..."
docker push --tls-verify=false docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${LOCAL_TAG}
docker push --tls-verify=false docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0

echo ""
echo "✓ Image successfully pushed to Docker Hub!"
echo ""
echo "Your image is now available at:"
echo "  - docker pull docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
echo "  - docker pull docker.io/${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0"
echo ""
echo "Next steps:"
echo "  - Set up Docker Swarm cluster"
echo "  - Deploy the service using deploy-swarm.sh"
echo ""
