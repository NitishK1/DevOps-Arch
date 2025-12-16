#!/bin/bash

# Auto-setup users on WSL VMs with pre-configured credentials
# This script creates the user 'nitish' with password 'nitish' on both VMs

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - Auto User Setup                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Detect Master VM
MASTER_VM=""
wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')

if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
    MASTER_VM="Ubuntu-22.04"
elif echo "$wsl_list" | grep -qi "^Ubuntu$"; then
    MASTER_VM="Ubuntu"
else
    echo "Error: No Ubuntu WSL instance found!"
    exit 1
fi

echo "Using Master VM: $MASTER_VM"
echo ""

# User credentials
USERNAME="nitish"
PASSWORD="nitish"

echo "═══════════════════════════════════════════════════════════"
echo "Step 1: Setting up user on Master VM"
echo "═══════════════════════════════════════════════════════════"

# Setup user on Master VM (run as root for non-interactive setup)
wsl.exe -d "$MASTER_VM" -u root -- bash -c "
    # Check if user exists
    if id -u $USERNAME >/dev/null 2>&1; then
        echo 'User $USERNAME already exists on Master VM'
    else
        # Create user with home directory
        useradd -m -s /bin/bash $USERNAME 2>/dev/null
        echo '$USERNAME:$PASSWORD' | chpasswd

        # Add user to sudo group
        usermod -aG sudo $USERNAME

        # Allow sudo without password for automation
        echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME
        chmod 0440 /etc/sudoers.d/$USERNAME

        echo '✓ User $USERNAME created on Master VM'
    fi

    # Set default user for WSL
    echo '[user]' > /etc/wsl.conf
    echo 'default=$USERNAME' >> /etc/wsl.conf
"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Setting up user on ProdServer"
echo "═══════════════════════════════════════════════════════════"

# Setup user on ProdServer (run as root for non-interactive setup)
wsl.exe -d ProdServer -u root -- bash -c "
    # Check if user exists
    if id -u $USERNAME >/dev/null 2>&1; then
        echo 'User $USERNAME already exists on ProdServer'
    else
        # Create user with home directory
        useradd -m -s /bin/bash $USERNAME 2>/dev/null
        echo '$USERNAME:$PASSWORD' | chpasswd

        # Add user to sudo group
        usermod -aG sudo $USERNAME

        # Allow sudo without password for automation
        echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME
        chmod 0440 /etc/sudoers.d/$USERNAME

        echo '✓ User $USERNAME created on ProdServer'
    fi

    # Set default user for WSL
    echo '[user]' > /etc/wsl.conf
    echo 'default=$USERNAME' >> /etc/wsl.conf
"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Restarting WSL VMs to apply user changes"
echo "═══════════════════════════════════════════════════════════"

# Terminate VMs to apply wsl.conf changes
wsl.exe --terminate "$MASTER_VM"
wsl.exe --terminate ProdServer

sleep 2

# Start VMs with new default user
echo "Starting Master VM..."
wsl.exe -d "$MASTER_VM" -- whoami

echo "Starting ProdServer..."
wsl.exe -d ProdServer -- whoami

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "User Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "User credentials:"
echo "  Username: $USERNAME"
echo "  Password: $PASSWORD"
echo ""
echo "Default user set for both VMs:"
echo "  Master VM ($MASTER_VM): $(wsl.exe -d "$MASTER_VM" -- whoami | tr -d '\r')"
echo "  ProdServer: $(wsl.exe -d ProdServer -- whoami | tr -d '\r')"
echo ""
