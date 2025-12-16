#!/bin/bash

# Automated Jenkins and Ansible Installation on Master VM

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - Jenkins & Ansible Setup           ║"
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

echo "Installing on Master VM: $MASTER_VM"
echo ""

# Run installation on Master VM
wsl.exe -d "$MASTER_VM" -u root -- bash -c '

echo "═══════════════════════════════════════════════════════════"
echo "Step 1: Updating system packages"
echo "═══════════════════════════════════════════════════════════"
apt-get update
apt-get upgrade -y

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Installing prerequisites"
echo "═══════════════════════════════════════════════════════════"
apt-get install -y \
    openjdk-17-jdk \
    git \
    python3 \
    python3-pip \
    openssh-server \
    curl \
    wget \
    gnupg \
    software-properties-common

# Set Java 17 as default
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Installing Ansible"
echo "═══════════════════════════════════════════════════════════"
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 4: Installing Jenkins"
echo "═══════════════════════════════════════════════════════════"

# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
apt-get update
apt-get install -y jenkins

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 5: Starting services"
echo "═══════════════════════════════════════════════════════════"

# Start SSH
service ssh start
echo "✓ SSH service started"

# Start Jenkins
service jenkins start
echo "✓ Jenkins service started"

# Wait for Jenkins to start
echo "Waiting for Jenkins to initialize..."
sleep 10

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 6: Configuration"
echo "═══════════════════════════════════════════════════════════"

# Get Jenkins initial admin password
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "Jenkins Initial Admin Password:"
    echo "================================"
    echo "$JENKINS_PASSWORD"
    echo "================================"
else
    echo "Jenkins password file not found yet. Wait a moment and check:"
    echo "  sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "Java version:"
java -version

echo ""
echo "Ansible version:"
ansible --version | head -1

echo ""
echo "Jenkins status:"
service jenkins status | head -5

'

# Get Master VM IP
master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Master VM IP: $master_ip"
echo ""
echo "Access Jenkins at: http://$master_ip:8080"
echo ""
echo "To get Jenkins initial password:"
echo "  wsl -d $MASTER_VM"
echo "  sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "Verify installations:"
echo "  wsl -d $MASTER_VM"
echo "  java -version"
echo "  ansible --version"
echo "  sudo service jenkins status"
echo ""
