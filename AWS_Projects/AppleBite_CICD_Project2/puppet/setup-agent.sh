#!/bin/bash

# Puppet Agent Setup Script
# This script installs and configures Puppet agent on the slave node

echo "=========================================="
echo "Setting up Puppet Agent"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS $VER"

# Install Puppet based on OS
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "Installing Puppet on Ubuntu/Debian..."

    # Download and install Puppet repository
    wget https://apt.puppet.com/puppet7-release-focal.deb -O /tmp/puppet7-release.deb
    dpkg -i /tmp/puppet7-release.deb
    apt-get update

    # Install Puppet agent
    apt-get install -y puppet-agent

elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    echo "Installing Puppet on CentOS/RHEL..."

    # Download and install Puppet repository
    rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm

    # Install Puppet agent
    yum install -y puppet-agent

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Add Puppet to PATH
export PATH=/opt/puppetlabs/bin:$PATH
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> ~/.bashrc

# Verify installation
if command -v puppet &> /dev/null; then
    echo "=========================================="
    echo "Puppet Agent installed successfully!"
    puppet --version
    echo "=========================================="
else
    echo "Puppet Agent installation failed"
    exit 1
fi

# Basic puppet configuration (optional)
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
certname = $(hostname -f)
server = puppet-master
environment = production
runinterval = 1h
EOF

echo "Puppet Agent setup completed!"
