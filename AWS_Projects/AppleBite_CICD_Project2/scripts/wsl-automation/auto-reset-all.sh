#!/bin/bash

# Reset Script - Removes all WSL VMs and configurations created by automation

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - RESET ALL                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "⚠️  WARNING: This will remove:"
echo "  - TestServer WSL instance (if exists)"
echo "  - ProdServer WSL instance"
echo "  - WSL instance files in ~/WSL-Instances/"
echo "  - Jenkins and Ansible from Master VM"
echo "  - SSH keys and configurations"
echo ""
echo "Master VM (Ubuntu/Ubuntu-22.04) will be kept but cleaned."
echo ""
echo -n "Are you SURE you want to reset everything? (type 'yes' to confirm): "
read confirm

if [ "$confirm" != "yes" ]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Starting reset process..."
echo "═══════════════════════════════════════════════════════════"
echo ""

# Detect Master VM
MASTER_VM=""
wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')
if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
    MASTER_VM="Ubuntu-22.04"
elif echo "$wsl_list" | grep -qi "^Ubuntu$"; then
    MASTER_VM="Ubuntu"
fi

# Step 1: Unregister WSL instances
echo "Step 1: Removing WSL instances..."

# Get list of WSL instances and clean it
wsl_instances=$(wsl.exe --list --quiet | tr -d '\r' | tr -d '\0')

# Check and remove TestServer
if echo "$wsl_instances" | grep -q "TestServer"; then
    echo "  Removing TestServer..."
    wsl.exe --unregister TestServer
    if [ $? -eq 0 ]; then
        echo "  ✓ TestServer removed"
    else
        echo "  ✗ Failed to remove TestServer"
    fi
else
    echo "  TestServer not found (skipped)"
fi

# Check and remove ProdServer
if echo "$wsl_instances" | grep -q "ProdServer"; then
    echo "  Removing ProdServer..."
    wsl.exe --unregister ProdServer
    if [ $? -eq 0 ]; then
        echo "  ✓ ProdServer removed"
    else
        echo "  ✗ Failed to remove ProdServer"
    fi
else
    echo "  ProdServer not found (skipped)"
fi

echo ""

# Step 2: Remove WSL instance directories
echo "Step 2: Removing WSL instance files..."
if [ -d "$HOME/WSL-Instances" ]; then
    rm -rf "$HOME/WSL-Instances"
    echo "  ✓ Removed ~/WSL-Instances directory"
else
    echo "  WSL-Instances directory not found (skipped)"
fi

echo ""

# Step 3: Clean Master VM
if [ ! -z "$MASTER_VM" ]; then
    echo "Step 3: Cleaning Master VM ($MASTER_VM)..."

    # Remove Jenkins
    echo "  Removing Jenkins..."
    wsl.exe -d "$MASTER_VM" -u root -- bash -c "
        service jenkins stop 2>/dev/null
        apt-get remove -y jenkins 2>/dev/null
        apt-get purge -y jenkins 2>/dev/null
        rm -rf /var/lib/jenkins
        rm -rf /var/cache/jenkins
        rm -f /etc/apt/sources.list.d/jenkins.list
        rm -f /usr/share/keyrings/jenkins-keyring.asc
    " 2>/dev/null
    echo "  ✓ Jenkins removed"

    # Remove Ansible
    echo "  Removing Ansible..."
    wsl.exe -d "$MASTER_VM" -u root -- bash -c "
        apt-get remove -y ansible 2>/dev/null
        apt-get purge -y ansible 2>/dev/null
        add-apt-repository --remove ppa:ansible/ansible -y 2>/dev/null
    " 2>/dev/null
    echo "  ✓ Ansible removed"

    # Remove SSH keys and config
    echo "  Removing SSH configurations..."
    wsl.exe -d "$MASTER_VM" -- bash -c "
        rm -f ~/.ssh/id_rsa
        rm -f ~/.ssh/id_rsa.pub
        rm -f ~/.ssh/config
        rm -f ~/.ssh/known_hosts
    " 2>/dev/null
    echo "  ✓ SSH configurations removed"

    # Clean up apt
    echo "  Cleaning up packages..."
    wsl.exe -d "$MASTER_VM" -u root -- bash -c "
        apt-get autoremove -y 2>/dev/null
        apt-get clean 2>/dev/null
    " 2>/dev/null
    echo "  ✓ Package cleanup complete"
else
    echo "Step 3: Master VM not found (skipped)"
fi

echo ""

# Step 4: Restore configuration files
echo "Step 4: Restoring configuration files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Restore Ansible inventory
ANSIBLE_HOSTS="$PROJECT_ROOT/ansible/inventory/hosts"
if [ -f "$ANSIBLE_HOSTS" ]; then
    cat > "$ANSIBLE_HOSTS" << 'EOF'
# Ansible Inventory for AppleBite CI/CD Project
# Update with your server IPs and SSH details

[test_server]
testserver ansible_host=<TEST_SERVER_IP> ansible_user=<username> ansible_ssh_private_key_file=~/.ssh/id_rsa

[prod_server]
prodserver ansible_host=<PROD_SERVER_IP> ansible_user=<username> ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
    echo "  ✓ Restored ansible/inventory/hosts"
fi

# Remove backup files
rm -f "$PROJECT_ROOT/Jenkinsfile.bak" 2>/dev/null
rm -f "$PROJECT_ROOT/Jenkinsfile-with-prod.bak" 2>/dev/null
echo "  ✓ Removed backup files"

echo ""

# Step 5: Show current state
echo "═══════════════════════════════════════════════════════════"
echo "Reset Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Current WSL instances:"
wsl.exe --list --verbose
echo ""
echo "What was removed:"
echo "  ✓ TestServer WSL instance"
echo "  ✓ ProdServer WSL instance"
echo "  ✓ Jenkins from Master VM"
echo "  ✓ Ansible from Master VM"
echo "  ✓ SSH keys and configurations"
echo "  ✓ WSL instance files"
echo ""
echo "What was kept:"
echo "  ✓ Master VM ($MASTER_VM) - cleaned but not removed"
echo "  ✓ Project files and scripts"
echo ""
echo "You can now run the full automation again if needed:"
echo "  ./wsl-quickstart.sh"
echo "  Select option 1 for full auto setup"
echo ""
