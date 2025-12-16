#!/bin/bash

# Auto-create all 3 WSL instances without interactive prompts
# This script will:
# 1. Check if Ubuntu (Master) exists
# 2. Create TestServer from Ubuntu
# 3. Create ProdServer from Ubuntu

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - ProdServer Creator                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Note: TestServer is provisioned by Jenkins pipeline (ephemeral)"
echo ""

# Check current WSL instances
echo "Current WSL instances:"
wsl.exe --list --verbose
echo ""

# Set installation directory early
INSTALL_DIR="$HOME/WSL-Instances"
mkdir -p "$INSTALL_DIR"

# Detect which Ubuntu distribution is available
MASTER_VM=""
wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')

if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
    MASTER_VM="Ubuntu-22.04"
    echo "Master VM (Ubuntu-22.04) found!"
elif echo "$wsl_list" | grep -i "Ubuntu" | grep -qv "Ubuntu-22.04"; then
    echo "Ubuntu found. Creating Master VM (Ubuntu-22.04) from Ubuntu base..."

    # Create Ubuntu-22.04 from Ubuntu
    mkdir -p "$INSTALL_DIR/Ubuntu-22.04"
    echo "Exporting Ubuntu as base..."
    wsl.exe --export Ubuntu "$INSTALL_DIR/ubuntu-base-temp.tar"

    if [ $? -eq 0 ]; then
        echo "Creating Ubuntu-22.04 (Master VM)..."
        wsl.exe --import Ubuntu-22.04 "$INSTALL_DIR/Ubuntu-22.04" "$INSTALL_DIR/ubuntu-base-temp.tar"

        if [ $? -eq 0 ]; then
            echo "✓ Master VM (Ubuntu-22.04) created successfully"
            rm -f "$INSTALL_DIR/ubuntu-base-temp.tar"
            MASTER_VM="Ubuntu-22.04"
        else
            echo "✗ Failed to create Ubuntu-22.04"
            rm -f "$INSTALL_DIR/ubuntu-base-temp.tar"
            exit 1
        fi
    else
        echo "✗ Failed to export Ubuntu"
        exit 1
    fi
else
    echo "Error: No Ubuntu WSL instance found!"
    echo "Available instances:"
    echo "$wsl_list"
    echo ""
    echo "Please install Ubuntu from Microsoft Store first."
    exit 1
fi

echo ""

# Create directory for ProdServer
mkdir -p "$INSTALL_DIR/ProdServer"

echo "Installation directory created at: $INSTALL_DIR/ProdServer"
echo ""

# Export Ubuntu as base image
EXPORT_FILE="$INSTALL_DIR/ubuntu-base.tar"

# Check if ProdServer already exists
if wsl.exe --list | grep -q "ProdServer"; then
    echo "ProdServer already exists. Skipping..."
else
    echo "Step 1: Exporting $MASTER_VM as base image..."
    wsl.exe --export "$MASTER_VM" "$EXPORT_FILE"

    if [ $? -eq 0 ]; then
        echo "✓ $MASTER_VM exported successfully"
        echo ""

        echo "Step 2: Creating ProdServer..."
        wsl.exe --import ProdServer "$INSTALL_DIR/ProdServer" "$EXPORT_FILE"

        if [ $? -eq 0 ]; then
            echo "✓ ProdServer created successfully"
        else
            echo "✗ Failed to create ProdServer"
            exit 1
        fi
    else
        echo "✗ Failed to export $MASTER_VM"
        exit 1
    fi
fi

echo ""
echo "Cleaning up temporary export file..."
rm -f "$EXPORT_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "ProdServer Creation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "TestServer will be created dynamically by Jenkins pipeline."
echo ""

# List all instances
echo "All WSL instances:"
wsl.exe --list --verbose
echo ""

# Get and display IPs
echo "═══════════════════════════════════════════════════════════"
echo "WSL IP Addresses:"
echo "═══════════════════════════════════════════════════════════"

master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ')
prod_ip=$(wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n ')

echo "Master VM ($MASTER_VM):  $master_ip"
echo "Prod Server:             $prod_ip"
echo "Test Server:             <provisioned by Jenkins pipeline>"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "Next Steps:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Configure SSH on VMs:"
echo "   wsl -d $MASTER_VM sudo service ssh start"
echo "   wsl -d ProdServer sudo service ssh start"
echo ""
echo "2. Set up SSH keys on Master VM:"
echo "   wsl -d $MASTER_VM ssh-keygen -t rsa -b 4096 -N ''"
echo ""
echo "3. Install Jenkins and Ansible on Master VM:"
echo "   See WSL_SETUP_GUIDE.md for detailed instructions"
echo ""
echo "4. Update configuration files with these IP addresses:"
echo "   - ansible/inventory/hosts"
echo "   - Jenkinsfile-with-prod"
echo ""
echo "Done!"
