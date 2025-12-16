#!/bin/bash

# Quick Podman Setup and Test
# This script ensures you're using Podman for the assignment

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          Podman Quick Setup & Test                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check installations
echo "Checking installed tools..."
echo ""
echo "Docker: $(which docker 2>/dev/null || echo 'not found')"
echo "Podman: $(which podman 2>/dev/null || echo 'not found')"
echo ""

# Set up shell functions instead of aliases (works in scripts too)
echo "Setting up Podman as docker command..."
echo ""

# Create wrapper function
docker() {
    podman "$@"
}

docker-compose() {
    if command -v podman-compose &> /dev/null; then
        podman-compose "$@"
    else
        echo "⚠️  podman-compose not found. Install with: pip3 install podman-compose"
        return 1
    fi
}

# Export functions
export -f docker
export -f docker-compose

echo "✓ Functions exported"
echo ""

# Verify
echo "Verification:"
echo "  docker --version: $(podman --version)"
echo ""

# Check Podman machine status (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Checking Podman machine status..."
    if ! podman machine list 2>/dev/null | grep -q "Currently running"; then
        echo ""
        echo "⚠️  Podman machine is not running!"
        echo ""
        read -p "Would you like to start it now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Starting Podman machine..."
            
            # Check if machine exists
            if ! podman machine list 2>/dev/null | grep -q "podman-machine"; then
                echo "Initializing Podman machine..."
                podman machine init
            fi
            
            podman machine start
            echo "✓ Podman machine started"
        fi
    else
        echo "✓ Podman machine is running"
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Setup Complete! You can now use docker commands with Podman."
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Build the image:     podman build -t company-website:latest ."
echo "  2. Test locally:        ./test-local.sh (after setting alias)"
echo "  3. Deploy with pod:     ./deploy-podman-pod.sh"
echo ""
echo "Note: To make aliases permanent, add to ~/.bashrc or ~/.zshrc:"
echo "  alias docker='podman'"
echo "  alias docker-compose='podman-compose'"
echo ""
