#!/bin/bash

# Podman Configuration Script
# This script sets up Podman to work seamlessly with Docker commands
# Run: source ./setup-podman.sh

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          Configuring Podman for Docker Compatibility          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    echo "❌ Podman is not installed!"
    echo "Please install Podman first: brew install podman"
    return 1
fi

echo "✓ Podman found: $(podman --version)"
echo ""

# Set up aliases for the current session
echo "Setting up Docker command aliases..."
alias docker='podman'
alias docker-compose='podman-compose'

# Export for subshells
export DOCKER_CMD='podman'

echo "✓ Aliases configured for this session"
echo ""

# Add to shell configuration file
SHELL_RC=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [ -n "$SHELL_RC" ]; then
    echo "Adding permanent aliases to $SHELL_RC..."
    
    # Check if aliases already exist
    if grep -q "alias docker='podman'" "$SHELL_RC" 2>/dev/null; then
        echo "⚠️  Aliases already exist in $SHELL_RC"
    else
        cat >> "$SHELL_RC" << 'EOF'

# Podman aliases for Docker compatibility
alias docker='podman'
alias docker-compose='podman-compose'
export DOCKER_CMD='podman'
EOF
        echo "✓ Aliases added to $SHELL_RC"
        echo "  Run 'source $SHELL_RC' to apply in new terminals"
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Configuration Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Aliases set:"
echo "  docker → podman"
echo "  docker-compose → podman-compose"
echo ""
echo "Verification:"
docker --version
echo ""

# Check if podman-compose is installed
if ! command -v podman-compose &> /dev/null; then
    echo "⚠️  Note: podman-compose is not installed"
    echo "Install it with: pip3 install podman-compose"
    echo "Or use: brew install podman-compose"
    echo ""
fi

echo "You can now use all docker commands normally!"
echo "Example: docker build -t myimage ."
echo ""
