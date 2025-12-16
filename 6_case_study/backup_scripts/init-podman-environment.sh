#!/bin/bash

# Complete Podman initialization and alias setup
# Run: source ./init-podman-environment.sh

echo "Initializing Podman environment..."
echo ""

# Check if Podman machine exists
if ! podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
    echo "Creating Podman machine..."
    podman machine init
fi

# Check if machine is running
if ! podman machine list 2>/dev/null | grep -q "Currently running"; then
    echo "Starting Podman machine..."
    podman machine start
fi

# Set up aliases
alias docker='podman'
alias docker-compose='podman-compose'
export DOCKER_CMD='podman'

echo ""
echo "✅ Podman environment ready!"
echo ""
echo "Aliases set:"
echo "  docker → podman"
echo "  docker-compose → podman-compose"
echo ""
echo "Verification:"
docker --version
echo ""
echo "You can now run:"
echo "  podman build -t company-website:latest ."
echo "  ./deploy-podman-pod.sh"
echo ""
