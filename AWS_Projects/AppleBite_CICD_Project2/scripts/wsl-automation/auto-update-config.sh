#!/bin/bash

# Automated Configuration File Updates with Current IPs

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - Auto Config Updater               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"
echo ""

# Get current IP addresses
echo "Getting current WSL IP addresses..."
test_ip=$(wsl.exe -d TestServer hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')
prod_ip=$(wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

if [ -z "$test_ip" ] || [ -z "$prod_ip" ]; then
    echo "Error: Could not get WSL IPs. Make sure TestServer and ProdServer are running."
    echo ""
    echo "Start them with:"
    echo "  wsl -d TestServer"
    echo "  wsl -d ProdServer"
    exit 1
fi

echo "TestServer IP: $test_ip"
echo "ProdServer IP: $prod_ip"
echo ""

# Get username
username=$(wsl.exe -d TestServer whoami | tr -d '\r\n ')
echo "Username: $username"
echo ""

# Update Ansible inventory
echo "═══════════════════════════════════════════════════════════"
echo "Updating Ansible inventory..."
echo "═══════════════════════════════════════════════════════════"

ANSIBLE_HOSTS="$PROJECT_ROOT/ansible/inventory/hosts"

if [ -f "$ANSIBLE_HOSTS" ]; then
    cat > "$ANSIBLE_HOSTS" << EOF
# Ansible Inventory for AppleBite CI/CD Project
# Auto-generated on $(date)

[test_server]
testserver ansible_host=$test_ip ansible_user=$username ansible_ssh_private_key_file=~/.ssh/id_rsa

[prod_server]
prodserver ansible_host=$prod_ip ansible_user=$username ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
    echo "✓ Updated: $ANSIBLE_HOSTS"
else
    echo "✗ File not found: $ANSIBLE_HOSTS"
fi

echo ""

# Update Jenkinsfile-with-prod
echo "═══════════════════════════════════════════════════════════"
echo "Updating Jenkinsfile-with-prod..."
echo "═══════════════════════════════════════════════════════════"

JENKINSFILE="$PROJECT_ROOT/Jenkinsfile-with-prod"

if [ -f "$JENKINSFILE" ]; then
    # Create backup
    cp "$JENKINSFILE" "$JENKINSFILE.bak"

    # Update IPs
    sed -i "s/TEST_SERVER = '[^']*'/TEST_SERVER = '$test_ip'/" "$JENKINSFILE"
    sed -i "s/PROD_SERVER = '[^']*'/PROD_SERVER = '$prod_ip'/" "$JENKINSFILE"
    sed -i "s/SSH_USER = '[^']*'/SSH_USER = '$username'/" "$JENKINSFILE"

    echo "✓ Updated: $JENKINSFILE"
    echo "  (Backup saved as Jenkinsfile-with-prod.bak)"
else
    echo "✗ File not found: $JENKINSFILE"
fi

echo ""

# Update Jenkinsfile (test only)
echo "═══════════════════════════════════════════════════════════"
echo "Updating Jenkinsfile..."
echo "═══════════════════════════════════════════════════════════"

JENKINSFILE_TEST="$PROJECT_ROOT/Jenkinsfile"

if [ -f "$JENKINSFILE_TEST" ]; then
    # Create backup
    cp "$JENKINSFILE_TEST" "$JENKINSFILE_TEST.bak"

    # Update IP
    sed -i "s/TEST_SERVER = '[^']*'/TEST_SERVER = '$test_ip'/" "$JENKINSFILE_TEST"
    sed -i "s/SSH_USER = '[^']*'/SSH_USER = '$username'/" "$JENKINSFILE_TEST"

    echo "✓ Updated: $JENKINSFILE_TEST"
    echo "  (Backup saved as Jenkinsfile.bak)"
else
    echo "✗ File not found: $JENKINSFILE_TEST"
fi

echo ""

# Summary
echo "═══════════════════════════════════════════════════════════"
echo "Configuration Update Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Updated files with:"
echo "  TestServer IP: $test_ip"
echo "  ProdServer IP: $prod_ip"
echo "  Username: $username"
echo ""
echo "Updated files:"
echo "  ✓ ansible/inventory/hosts"
echo "  ✓ Jenkinsfile"
echo "  ✓ Jenkinsfile-with-prod"
echo ""
echo "Next steps:"
echo "  1. Test Ansible connectivity:"
echo "     wsl -d Ubuntu-22.04 (or your Master VM)"
echo "     cd /mnt/c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/AWS_Projects/AppleBite_CICD_Project2"
echo "     ansible all -i ansible/inventory/hosts -m ping"
echo ""
echo "  2. Access Jenkins and create a new pipeline job"
echo "     http://\$(wsl hostname -I | tr -d ' '):8080"
echo ""
