#!/bin/bash

# Script to initialize Docker Swarm cluster
# Usage: ./init-swarm.sh

set -e

# Define docker as podman function
docker() {
    podman "$@"
}

echo "============================================"
echo "Initializing Docker Swarm Cluster"
echo "============================================"

# Check if already in swarm mode
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "⚠️  Docker is already running in Swarm mode"
    echo ""
    docker node ls
    echo ""
    read -p "Do you want to leave the current swarm and create a new one? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Leaving current swarm..."
        docker swarm leave --force
    else
        echo "Keeping current swarm configuration"
        exit 0
    fi
fi

# Initialize Swarm
echo ""
echo "Initializing Docker Swarm..."
docker swarm init

echo ""
echo "✓ Docker Swarm initialized successfully!"
echo ""
echo "Swarm Status:"
docker node ls

echo ""
echo "To add worker nodes to this swarm, run the following command on other machines:"
docker swarm join-token worker

echo ""
echo "To add manager nodes to this swarm, run the following command on other machines:"
docker swarm join-token manager

echo ""
echo "Next step: Deploy your service using ./deploy-swarm.sh"
echo ""
