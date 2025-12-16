#!/bin/bash

# Cleanup Podman Pod Deployment
# Usage: ./cleanup-podman-pod.sh

set -e

POD_NAME="company-website-prod"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Cleaning Up Podman Pod Deployment                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if pod exists
if podman pod exists ${POD_NAME}; then
    echo "Found pod: ${POD_NAME}"
    echo ""

    # Show current status
    echo "Current pod status:"
    podman pod ps --filter name=${POD_NAME}
    echo ""

    echo "Containers in pod:"
    podman ps -a --filter pod=${POD_NAME}
    echo ""

    read -p "Do you want to remove this pod and all its containers? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Stopping pod..."
        podman pod stop ${POD_NAME} 2>/dev/null || true

        echo "Removing pod and containers..."
        podman pod rm -f ${POD_NAME}

        echo ""
        echo "✓ Pod '${POD_NAME}' removed successfully!"
    else
        echo "Cleanup cancelled."
        exit 0
    fi
else
    echo "Pod '${POD_NAME}' not found. Nothing to clean up."
fi

echo ""
echo "Current pods:"
podman pod ps

echo ""
echo "Cleanup complete!"
echo ""
