#!/bin/bash

# Script to deploy the company website on Docker Swarm
# Usage: ./deploy-swarm.sh <your-dockerhub-username>

set -e

# Define docker as podman function
docker() {
    podman "$@"
}

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: ./deploy-swarm.sh <your-dockerhub-username>"
    echo "Example: ./deploy-swarm.sh johndoe"
    echo ""
    echo "Note: Make sure you have:"
    echo "  1. Built the image (./build.sh)"
    echo "  2. Pushed to Docker Hub (./push-to-dockerhub.sh)"
    echo "  3. Initialized swarm (./init-swarm.sh)"
    exit 1
fi

DOCKERHUB_USERNAME=$1
STACK_NAME="company-website-stack"

echo "============================================"
echo "Deploying Website to Docker Swarm"
echo "============================================"

# Check if swarm is initialized
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not initialized!"
    echo "Please run ./init-swarm.sh first"
    exit 1
fi

# Export the Docker Hub username for docker-compose-swarm.yml
export DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}

# Deploy the stack
echo ""
echo "Deploying stack: ${STACK_NAME}"
docker stack deploy -c docker-compose-swarm.yml ${STACK_NAME}

echo ""
echo "✓ Stack deployed successfully!"
echo ""
echo "Checking service status..."
sleep 3
docker service ls

echo ""
echo "Service details:"
docker service ps ${STACK_NAME}_web

echo ""
echo "============================================"
echo "Deployment Information"
echo "============================================"
echo "Stack Name: ${STACK_NAME}"
echo "Service Name: ${STACK_NAME}_web"
echo "Exposed Port: 80"
echo ""
echo "Useful commands:"
echo "  - View service logs: docker service logs -f ${STACK_NAME}_web"
echo "  - Scale service: docker service scale ${STACK_NAME}_web=5"
echo "  - Update service: docker service update ${STACK_NAME}_web"
echo "  - Remove stack: docker stack rm ${STACK_NAME}"
echo "  - List services: docker service ls"
echo "  - Inspect service: docker service inspect ${STACK_NAME}_web"
echo ""
echo "Access your website at: http://localhost or http://<node-ip>"
echo ""
