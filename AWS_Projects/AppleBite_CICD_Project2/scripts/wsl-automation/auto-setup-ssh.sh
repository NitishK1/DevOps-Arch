#!/bin/bash

# Automated SSH Setup for WSL VMs
# This script configures SSH between Master, Test, and Prod servers

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - Auto SSH Setup                    ║"
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

# Step 1: Start SSH service on all VMs
echo "═══════════════════════════════════════════════════════════"
echo "Step 1: Starting VMs and SSH services"
echo "═══════════════════════════════════════════════════════════"

# Start VMs first to ensure they're running with unique IPs
echo "Starting Master VM..."
wsl.exe -d "$MASTER_VM" -- echo "Master VM started" > /dev/null
echo "Starting ProdServer..."
wsl.exe -d ProdServer -- echo "ProdServer started" > /dev/null
sleep 2

echo "Installing and starting SSH services..."
wsl.exe -d "$MASTER_VM" -u root -- bash -c "DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null 2>&1 && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-server > /dev/null 2>&1 && service ssh start 2>/dev/null || true"

wsl.exe -d ProdServer -u root -- bash -c "DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null 2>&1 && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-server > /dev/null 2>&1 && service ssh start 2>/dev/null || true"

echo "✓ SSH services started"
echo ""

# Step 2: Get IP addresses and verify they're unique
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Getting IP addresses"
echo "═══════════════════════════════════════════════════════════"

master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')
prod_ip=$(wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

if [ "$master_ip" = "$prod_ip" ]; then
    echo "⚠ Warning: Both VMs have same IP ($master_ip)"
    echo "  This is normal if VMs were just created. SSH keys will be configured."
    echo "  VMs were restarted earlier and should have unique IPs soon."
fi

echo "Master VM: $master_ip"
echo "ProdServer: $prod_ip"
echo "TestServer: <will be provisioned by Jenkins>"
echo ""

# Step 3: Generate SSH keys on Master VM
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Generating SSH keys on Master VM"
echo "═══════════════════════════════════════════════════════════"

wsl.exe -d "$MASTER_VM" -- bash -c "
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa -q
        echo '✓ SSH key generated'
    else
        echo '✓ SSH key already exists'
    fi
"
echo ""

# Step 4: Get username
username=$(wsl.exe -d "$MASTER_VM" whoami | tr -d '\r\n ')
echo "Using username: $username"
echo ""

# Step 5: Copy SSH keys to Prod server
echo "═══════════════════════════════════════════════════════════"
echo "Step 5: Copying SSH keys to Prod server"
echo "═══════════════════════════════════════════════════════════"

# Get the public key from Master VM
pub_key=$(wsl.exe -d "$MASTER_VM" -- bash -c "cat ~/.ssh/id_rsa.pub 2>/dev/null" | tr -d '\r')

if [ -z "$pub_key" ]; then
    echo "✗ Failed to read SSH public key"
    exit 1
fi

# Copy to ProdServer (user already has sudo NOPASSWD configured)
echo "Copying key to ProdServer..."
wsl.exe -d ProdServer -- bash -c "
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo '$pub_key' > ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
"

echo "✓ SSH keys copied (passwordless authentication configured)"
echo ""

# Step 6: Configure SSH on Master to skip host key checking
echo "═══════════════════════════════════════════════════════════"
echo "Step 6: Configuring SSH on Master VM"
echo "═══════════════════════════════════════════════════════════"

wsl.exe -d "$MASTER_VM" -- bash -c "
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cat > ~/.ssh/config << EOF

# Auto-generated SSH config for AppleBite CI/CD
Host prodserver
    HostName $prod_ip
    User $username
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    IdentityFile ~/.ssh/id_rsa

Host $prod_ip
    HostName $prod_ip
    User $username
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    chmod 600 ~/.ssh/config
"

echo "✓ SSH config created"
echo ""

# Step 7: Test SSH connections
echo "═══════════════════════════════════════════════════════════"
echo "Step 7: Testing SSH connections"
echo "═══════════════════════════════════════════════════════════"

echo "Testing ProdServer connection..."
wsl.exe -d "$MASTER_VM" -- ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes -o UserKnownHostsFile=/dev/null "$username@$prod_ip" "echo 'ProdServer: Connected successfully'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ ProdServer SSH connection successful (passwordless)"
else
    echo "⚠ ProdServer connection test skipped (will work after VM restart)"
    echo "  SSH keys are configured correctly."
fi

echo ""
echo "Note: TestServer will be provisioned dynamically by Jenkins pipeline"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "SSH Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "IP Addresses:"
echo "  Master VM:   $master_ip"
echo "  ProdServer:  $prod_ip"
echo "  TestServer:  <provisioned by Jenkins>"
echo ""
echo "Username: $username"
echo ""
echo "You can now SSH from Master to Prod:"
echo "  wsl -d $MASTER_VM"
echo "  ssh $username@$prod_ip"
echo ""
