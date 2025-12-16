#!/bin/bash

# Script to remove the swarm deployment
# Usage: ./cleanup-swarm.sh

set -e

# Define docker as podman function
docker() {
    podman "$@"
}

STACK_NAME="company-website-stack"

echo "============================================"
echo "Cleaning Up Docker Swarm Deployment"
echo "============================================"

# Check if swarm is active
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "Docker Swarm is not active. Nothing to clean up."
    exit 0
fi

# Check if stack exists
if docker stack ls | grep -q ${STACK_NAME}; then
    echo "Removing stack: ${STACK_NAME}"
    docker stack rm ${STACK_NAME}
    
    echo ""
    echo "Waiting for stack to be removed..."
    sleep 10
    
    echo "✓ Stack removed successfully!"
else
    echo "Stack '${STACK_NAME}' not found."
fi

echo ""
read -p "Do you want to leave the swarm cluster? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker swarm leave --force
    echo "✓ Left swarm cluster"
fi

echo ""
echo "Cleanup complete!"
echo ""
