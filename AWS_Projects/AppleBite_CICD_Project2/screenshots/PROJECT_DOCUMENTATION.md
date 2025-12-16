# AppleBite CI/CD Project - Complete Documentation

## Table of Contents
- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Pipeline Configuration](#pipeline-configuration)
- [Deployment Guide](#deployment-guide)
- [Troubleshooting](#troubleshooting)



## Overview

This project implements a complete CI/CD pipeline for deploying a PHP
application using Jenkins, Ansible, Docker, and Puppet. The pipeline automates
the entire deployment process from code commit to production deployment.

**Key Features:**
- Automated CI/CD pipeline with 4 jobs
- Infrastructure as Code with Ansible and Puppet
- Docker containerization
- Multi-environment deployment (Test/Production)
- Automatic trigger on Git push
- Failure recovery mechanism



## Problem Statement

**AppleBite Co.** needs to implement Continuous Integration & Continuous
Deployment to:
- Automate complex builds
- Manage incremental builds efficiently
- Deploy code automatically to dev/stage/prod environments
- Trigger deployments automatically on Git push to master branch

**Requirements:**
1. Use Git for version control
2. Use Jenkins for CI/CD automation
3. Use Docker for containerization with `devopsedu/webapp` base image
4. Use Ansible for configuration management
5. Use Puppet agent on slave nodes
6. Implement 4 Jenkins pipeline jobs:
   - Job 1: Install and configure Puppet agent
   - Job 2: Install Docker via Ansible
   - Job 3: Build and deploy application
   - Job 4: Cleanup on failure



## Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          MASTER VM                              │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   Jenkins    │  │   Ansible    │  │     Git      │        │
│  │   Master     │  │              │  │              │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                  │                  │                 │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │ SSH              │ SSH              │ Pull Code
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TEST SERVER (Slave)                        │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   Jenkins    │  │   Docker     │  │   Puppet     │        │
│  │   Slave      │  │   Engine     │  │   Agent      │        │
│  └──────────────┘  └──────┬───────┘  └──────────────┘        │
│                            │                                    │
│                            ▼                                    │
│         ┌────────────────────────────────────┐                │
│         │     Docker Container               │                │
│         │  ┌──────────────────────────────┐  │                │
│         │  │   Apache + PHP               │  │                │
│         │  │   AppleBite Application      │  │                │
│         │  │   Port: 80                   │  │                │
│         │  └──────────────────────────────┘  │                │
│         └────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### Pipeline Flow

```
Developer pushes code to Git
    ↓
Git webhook triggers Jenkins
    ↓
┌─────────────────────────────────┐
│ Job 1: Setup Puppet Agent       │
│ - Installs Puppet on slave node │
│ - Configures agent               │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│ Job 2: Install Docker           │
│ - Runs Ansible playbook         │
│ - Installs Docker on test server│
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│ Job 3: Build & Deploy           │
│ - Pulls code from Git           │
│ - Builds Docker image           │
│ - Deploys container             │
│ - Verifies deployment           │
└─────────────────────────────────┘
    ↓
    Success? ──No──→ ┌─────────────────────────┐
    │                 │ Job 4: Cleanup          │
    │                 │ - Removes failed        │
    │                 │   container             │
    │                 └─────────────────────────┘
    Yes
    ↓
Application is live!
```



## Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| **Git** | Version control | 2.x+ |
| **Jenkins** | CI/CD automation server | 2.x+ |
| **Docker** | Container platform | 20.10+ |
| **Ansible** | Configuration management | 2.9+ |
| **Puppet** | Agent configuration | 7.x+ |
| **PHP** | Application language | 7.4+ |
| **Apache** | Web server | 2.4+ |



## Project Structure

```
AppleBite_CICD_Project2/
├── PROJECT_DOCUMENTATION.md    # This file - Complete documentation
├── DEMO_GUIDE.md              # Quick demo and deployment guide
├── Dockerfile                 # Docker container definition
├── Jenkinsfile                # Jenkins Pipeline (4 jobs)
├── Jenkinsfile-with-prod      # Extended pipeline with prod deployment
│
├── app/                       # PHP Application
│   ├── index.php             # Home page
│   ├── about.php             # About page
│   ├── contact.php           # Contact page
│   └── style.css             # Stylesheet
│
├── ansible/                   # Ansible Configuration
│   ├── inventory/
│   │   └── hosts             # Inventory file (test & prod servers)
│   └── playbooks/
│       └── install-docker.yml # Docker installation playbook
│
├── puppet/                    # Puppet Scripts
│   └── setup-agent.sh        # Puppet agent setup script
│
└── scripts/                   # Utility Scripts
    ├── deploy.sh             # Manual deployment script
    └── cleanup.sh            # Cleanup script
```



## Prerequisites

### Master VM Requirements
- **OS**: Ubuntu 20.04 LTS or later
- **Resources**: Minimum 2GB RAM, 2 vCPUs, 20GB disk
- **Software**:
  - Jenkins 2.x or later
  - Ansible 2.9 or later
  - Git 2.x or later
  - Java 11 (for Jenkins)
  - Python 3.x
  - SSH server
- **Network**: SSH access to slave nodes

### Slave Node (Test/Production Server) Requirements
- **OS**: Ubuntu 20.04 LTS or later
- **Resources**: Minimum 2GB RAM, 2 vCPUs, 20GB disk
- **Software**:
  - Python 3.x
  - OpenSSH server
  - Git
- **Network**: Port 80 open for web access



## Setup Instructions

### Step 1: Prepare Master VM

#### 1.1 Install Jenkins
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### 1.2 Install Ansible
```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify installation
ansible --version
```

#### 1.3 Install Git
```bash
sudo apt install -y git
git --version
```

#### 1.4 Install Required Jenkins Plugins
1. Access Jenkins at `http://<MASTER_IP>:8080`
2. Go to **Manage Jenkins** → **Manage Plugins** → **Available**
3. Install the following plugins:
   - Pipeline
   - Git Plugin
   - SSH Agent
   - Build Pipeline Plugin
   - Post-build Task Plugin
   - Ansible Plugin

### Step 2: Prepare Slave Node(s)

#### 2.1 Install Required Packages
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and SSH
sudo apt install -y python3 python3-pip openssh-server git

# Start and enable SSH
sudo systemctl start ssh
sudo systemctl enable ssh
```

#### 2.2 Configure SSH Access
On the **Master VM**, generate and copy SSH key:
```bash
# Generate SSH key (if not already present)
ssh-keygen -t rsa -b 4096 -C "jenkins@master"

# Copy public key to slave node
ssh-copy-id ubuntu@<SLAVE_NODE_IP>

# Test connection
ssh ubuntu@<SLAVE_NODE_IP>
```

### Step 3: Configure Ansible

#### 3.1 Update Ansible Inventory
Edit `ansible/inventory/hosts`:
```ini
[test_servers]
test-server ansible_host=<TEST_SERVER_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[prod_servers]
prod-server ansible_host=<PROD_SERVER_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

#### 3.2 Test Ansible Connection
```bash
ansible -i ansible/inventory/hosts all -m ping
```

### Step 4: Configure Jenkins

#### 4.1 Add SSH Credentials in Jenkins
1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** → **Add Credentials**
3. Select **SSH Username with private key**
4. Fill in:
   - **ID**: `slave-ssh-key`
   - **Username**: `ubuntu`
   - **Private Key**: Enter directly or from file `~/.ssh/id_rsa`
5. Save

#### 4.2 Create Jenkins Pipeline
1. Click **New Item**
2. Enter name: `AppleBite-CICD-Pipeline`
3. Select **Pipeline**
4. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `<YOUR_GIT_REPO_URL>`
   - Script Path: `Jenkinsfile`
5. Under **Build Triggers**:
   - Check **Poll SCM**
   - Schedule: `H/5 * * * *` (polls every 5 minutes)
6. Save

### Step 5: Update Configuration Files

#### 5.1 Update Jenkinsfile
Replace `<TEST_SERVER_IP>` and `<PROD_SERVER_IP>` with actual IPs:
```groovy
environment {
    TEST_SERVER = '<TEST_SERVER_IP>'
    PROD_SERVER = '<PROD_SERVER_IP>'
}
```

#### 5.2 Update Docker Compose (if using)
Update any references to IP addresses in Docker configuration files.



## Pipeline Configuration

### Jenkins Pipeline Jobs

The `Jenkinsfile` defines a 4-stage pipeline:

#### Job 1: Setup Puppet Agent
```groovy
stage('Setup Puppet Agent') {
    steps {
        script {
            sh '''
                ssh ubuntu@${TEST_SERVER} 'bash -s' < puppet/setup-agent.sh
            '''
        }
    }
}
```
**Purpose**: Installs and configures Puppet agent on the slave node

#### Job 2: Install Docker via Ansible
```groovy
stage('Install Docker') {
    steps {
        ansiblePlaybook(
            playbook: 'ansible/playbooks/install-docker.yml',
            inventory: 'ansible/inventory/hosts',
            credentialsId: 'slave-ssh-key'
        )
    }
}
```
**Purpose**: Uses Ansible to install Docker and dependencies on the test server

#### Job 3: Build and Deploy
```groovy
stage('Build and Deploy') {
    steps {
        script {
            // Copy files to test server
            sh "scp -r app/ Dockerfile ubuntu@${TEST_SERVER}:~/"

            // Build and run Docker container
            sh '''
                ssh ubuntu@${TEST_SERVER} << 'EOF'
                    cd ~/
                    docker build -t applebite-app:latest .
                    docker stop applebite-container 2>/dev/null || true
                    docker rm applebite-container 2>/dev/null || true
                    docker run -d --name applebite-container -p 80:80 applebite-app:latest
                    docker ps
EOF
            '''
        }
    }
}
```
**Purpose**: Builds Docker image and deploys the container

#### Job 4: Cleanup on Failure
```groovy
post {
    failure {
        script {
            sh '''
                ssh ubuntu@${TEST_SERVER} << 'EOF'
                    docker stop applebite-container 2>/dev/null || true
                    docker rm applebite-container 2>/dev/null || true
                    docker image prune -f
EOF
            '''
        }
    }
}
```
**Purpose**: Automatically cleans up failed deployments



## Deployment Guide

### Automatic Deployment (Recommended)

**Trigger**: Git push to repository

1. Make changes to your code
2. Commit and push:
   ```bash
   git add .
   git commit -m "Update application"
   git push origin main
   ```
3. Jenkins automatically detects the push (polls every 5 minutes)
4. Pipeline executes automatically
5. Monitor progress in Jenkins dashboard
6. Access application at `http://<TEST_SERVER_IP>/`

### Manual Deployment via Jenkins

1. Go to Jenkins Dashboard
2. Select `AppleBite-CICD-Pipeline`
3. Click **Build Now**
4. Monitor the build progress in **Console Output**
5. Verify deployment at `http://<TEST_SERVER_IP>/`

### Manual Deployment via Script

For manual deployment without Jenkins:

```bash
# SSH into test server
ssh ubuntu@<TEST_SERVER_IP>

# Clone repository (first time only)
git clone <YOUR_REPO_URL> ~/applebite-app
cd ~/applebite-app

# Or pull latest changes
cd ~/applebite-app
git pull

# Run deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh v1.0
```

### Verify Deployment

```bash
# Check if container is running
ssh ubuntu@<TEST_SERVER_IP> docker ps

# Test application
curl http://<TEST_SERVER_IP>/

# Check container logs
ssh ubuntu@<TEST_SERVER_IP> docker logs applebite-container

# Check resource usage
ssh ubuntu@<TEST_SERVER_IP> docker stats applebite-container
```



## Troubleshooting

### Common Issues and Solutions

#### 1. Jenkins Cannot Connect to Slave Node

**Symptoms**: SSH connection failures, "Permission denied" errors

**Solution**:
```bash
# On Master VM, verify SSH key
ssh -v ubuntu@<SLAVE_NODE_IP>

# Re-copy SSH key if needed
ssh-copy-id ubuntu@<SLAVE_NODE_IP>

# Check SSH service on slave
ssh ubuntu@<SLAVE_NODE_IP> sudo systemctl status ssh
```

#### 2. Ansible Playbook Fails

**Symptoms**: "Host unreachable", "Authentication failure"

**Solution**:
```bash
# Test Ansible connection
ansible -i ansible/inventory/hosts all -m ping

# Run with verbose output
ansible-playbook -i ansible/inventory/hosts \
    ansible/playbooks/install-docker.yml -vvv

# Verify Python installation on slave
ssh ubuntu@<SLAVE_NODE_IP> python3 --version
```

#### 3. Docker Build Fails

**Symptoms**: "Cannot find Dockerfile", "Build context error"

**Solution**:
```bash
# Verify Dockerfile exists
ssh ubuntu@<SLAVE_NODE_IP> ls -la ~/Dockerfile

# Check Docker service
ssh ubuntu@<SLAVE_NODE_IP> sudo systemctl status docker

# Build manually to see detailed error
ssh ubuntu@<SLAVE_NODE_IP>
docker build -t applebite-app:latest .
```

#### 4. Container Not Starting

**Symptoms**: Container exits immediately, port conflicts

**Solution**:
```bash
# Check container logs
ssh ubuntu@<SLAVE_NODE_IP> docker logs applebite-container

# Check if port 80 is already in use
ssh ubuntu@<SLAVE_NODE_IP> sudo netstat -tulpn | grep :80

# Stop conflicting service
ssh ubuntu@<SLAVE_NODE_IP> sudo systemctl stop apache2

# Try running container interactively
ssh ubuntu@<SLAVE_NODE_IP>
docker run -it --rm applebite-app:latest /bin/bash
```

#### 5. Application Not Accessible

**Symptoms**: Cannot access http://<SLAVE_NODE_IP>/

**Solution**:
```bash
# Check if container is running
ssh ubuntu@<SLAVE_NODE_IP> docker ps

# Check firewall
ssh ubuntu@<SLAVE_NODE_IP> sudo ufw status

# Allow port 80 if needed
ssh ubuntu@<SLAVE_NODE_IP> sudo ufw allow 80/tcp

# Test from slave itself
ssh ubuntu@<SLAVE_NODE_IP> curl http://localhost/
```

#### 6. Jenkins Pipeline Hangs

**Symptoms**: Pipeline stuck in "Building" state

**Solution**:
```bash
# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins

# Check disk space on Master
df -h

# Clear Jenkins workspace
rm -rf /var/lib/jenkins/workspace/*
```

#### 7. Puppet Agent Installation Fails

**Symptoms**: Puppet agent script errors

**Solution**:
```bash
# Run puppet script manually
ssh ubuntu@<SLAVE_NODE_IP>
bash puppet/setup-agent.sh

# Check if Puppet is already installed
puppet --version

# Remove and reinstall if needed
sudo apt remove puppet-agent
```

### Cleanup and Reset

#### Clean Docker Resources
```bash
ssh ubuntu@<SLAVE_NODE_IP>

# Remove all containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Clean system
docker system prune -a -f
```

#### Reset Jenkins Pipeline
```bash
# On Master VM
# Delete workspace
rm -rf /var/lib/jenkins/workspace/AppleBite-CICD-Pipeline

# Rebuild from scratch
# Go to Jenkins UI → AppleBite-CICD-Pipeline → Build Now
```

### Useful Commands

#### Docker Commands
```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View container logs
docker logs <container-name>

# Execute command in container
docker exec -it <container-name> /bin/bash

# View container resource usage
docker stats

# Inspect container
docker inspect <container-name>
```

#### Jenkins Commands
```bash
# Restart Jenkins
sudo systemctl restart jenkins

# View Jenkins status
sudo systemctl status jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f
```

#### Ansible Commands
```bash
# Test connectivity
ansible -i ansible/inventory/hosts all -m ping

# Run ad-hoc command
ansible -i ansible/inventory/hosts all -m shell -a "uptime"

# Run playbook with verbose
ansible-playbook -i ansible/inventory/hosts playbook.yml -vvv
```



## Additional Resources

### File Locations

**Master VM:**
- Jenkins config: `/var/lib/jenkins/`
- Ansible config: `/etc/ansible/`
- SSH keys: `~/.ssh/`

**Slave Node:**
- Docker: `/var/lib/docker/`
- Application files: `~/`

### Port Reference

| Port | Service | Description |
|------|---------|-------------|
| 8080 | Jenkins | Jenkins web interface |
| 80 | Apache | Web application |
| 22 | SSH | Remote access |

### Security Considerations

1. **SSH Keys**: Use strong SSH keys (4096-bit RSA minimum)
2. **Firewall**: Configure UFW/iptables to allow only necessary ports
3. **Jenkins**: Change default admin password immediately
4. **Docker**: Run containers as non-root user when possible
5. **Secrets**: Store sensitive data in Jenkins credentials, not in code

### Performance Tuning

1. **Jenkins**: Increase heap size if needed (`JAVA_OPTS=-Xmx2048m`)
2. **Docker**: Configure resource limits for containers
3. **Ansible**: Use parallel execution for multiple servers
4. **Git**: Use shallow clones for faster checkouts



## Project Completion Status

✅ **All requirements implemented:**
- Git version control
- Jenkins CI/CD pipeline with 4 jobs
- Docker containerization with devopsedu/webapp base
- Ansible for Docker installation
- Puppet agent configuration
- Automatic deployment on Git push
- Cleanup mechanism on failure
- Multi-environment support (Test/Production)



## Support and Maintenance

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Jenkins console output for specific errors
3. Check application logs: `docker logs applebite-container`
4. Verify network connectivity between Master and Slave nodes



**Last Updated**: December 2025 **Project Version**: 2.0 **Maintainer**: DevOps
Team
