#!/bin/bash

# Jenkins Setup Script for AppleBite CI/CD Project
# This script installs and configures Jenkins

set -e

echo "======================================"
echo "Jenkins Setup for AppleBite CI/CD"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running on Windows/WSL
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo -e "${YELLOW}Detected Windows environment${NC}"
    echo "For Windows, we recommend using Docker to run Jenkins"
    echo ""

    JENKINS_OPTION=""
    echo "Select Jenkins installation method:"
    echo "1) Run Jenkins in Docker (Recommended)"
    echo "2) Manual setup instructions"
    read -p "Enter your choice (1 or 2): " JENKINS_OPTION

    if [ "$JENKINS_OPTION" = "1" ]; then
        echo ""
        echo "Starting Jenkins in Docker..."

        # Create Jenkins home directory
        mkdir -p jenkins_home

        # Get absolute path for Windows compatibility
        JENKINS_HOME_PATH="$(pwd)/jenkins_home"

        # Run Jenkins container with Docker access (disable Git Bash path conversion)
        echo "Creating Jenkins with Docker CLI access..."
        MSYS_NO_PATHCONV=1 docker run -d \
            --name jenkins-applebite \
            --restart=unless-stopped \
            -p 8090:8080 \
            -p 50000:50000 \
            -v "${JENKINS_HOME_PATH}:/var/jenkins_home" \
            -v //var/run/docker.sock:/var/run/docker.sock \
            --user root \
            jenkins/jenkins:lts

        echo ""
        echo -e "${GREEN}Jenkins container created...${NC}"
        echo "Installing Docker CLI in Jenkins container (this may take 2-3 minutes)..."

        # Install Docker CLI inside Jenkins
        docker exec --user root jenkins-applebite bash -c '
            apt-get update -qq && \
            apt-get install -y -qq ca-certificates curl gnupg && \
            install -m 0755 -d /etc/apt/keyrings && \
            curl -fsSL "https://download.docker.com/linux/debian/gpg" -o /etc/apt/keyrings/docker.asc && \
            chmod a+r /etc/apt/keyrings/docker.asc && \
            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
            apt-get update -qq && \
            apt-get install -y -qq docker-ce-cli docker-compose-plugin
        ' > /dev/null 2>&1

        echo -e "${GREEN}✓ Docker CLI installed in Jenkins${NC}"

        echo ""
        echo -e "${GREEN}Jenkins is starting...${NC}"
        echo "Waiting for Jenkins to initialize (this may take a minute)..."
        sleep 30

        # Get initial admin password
        echo ""
        echo "======================================"
        echo "Jenkins Initial Admin Password"
        echo "======================================"
        PASSWORD=$(MSYS_NO_PATHCONV=1 docker exec jenkins-applebite cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
        if [ -z "$PASSWORD" ]; then
            echo "Password file not ready yet. Wait 10 more seconds and run:"
            echo "  MSYS_NO_PATHCONV=1 docker exec jenkins-applebite cat /var/jenkins_home/secrets/initialAdminPassword"
        else
            echo "$PASSWORD"
        fi
        echo ""

        echo -e "${GREEN}Jenkins is running with Docker access!${NC}"
        echo ""
        echo "Access Jenkins at: http://127.0.0.1:8090"
        echo ""
        echo "Next steps:"
        echo "1. Open http://127.0.0.1:8090 in your browser"
        echo "2. Enter the initial admin password shown above"
        echo "3. Install suggested plugins"
        echo "4. Create an admin user"
        echo "5. Run: ./quickstart.sh and select option 3 to configure the pipeline"
        echo ""

        exit 0
    fi

    # Manual setup for Windows
    echo ""
    echo "======================================"
    echo "Manual Jenkins Setup for Windows"
    echo "======================================"
    echo ""
    echo -e "${YELLOW}Option 1: Download Jenkins WAR file${NC}"
    echo ""
    echo "1. Download Jenkins:"
    echo "   https://www.jenkins.io/download/"
    echo ""
    echo "2. Ensure Java is installed:"
    echo "   Download from: https://www.oracle.com/java/technologies/downloads/"
    echo "   Or use: winget install Oracle.JDK.21"
    echo ""
    echo "3. Run Jenkins:"
    echo "   java -jar jenkins.war --httpPort=8090"
    echo ""
    echo "4. Access Jenkins at: http://127.0.0.1:8090"
    echo ""
    echo -e "${YELLOW}Option 2: Install Jenkins MSI (Recommended)${NC}"
    echo ""
    echo "1. Download Jenkins Windows installer:"
    echo "   https://www.jenkins.io/download/thank-you-downloading-windows-installer-stable"
    echo ""
    echo "2. Run the installer and follow the wizard"
    echo ""
    echo "3. Access Jenkins at: http://127.0.0.1:8080"
    echo ""
    echo -e "${YELLOW}Option 3: Use Docker (Already available - choose option 1)${NC}"
    echo ""
    echo "The Docker option (option 1) is the easiest method and includes:"
    echo "  - No Java installation needed"
    echo "  - Docker CLI pre-configured"
    echo "  - Easy cleanup and reset"
    echo "  - Port 8090 (to avoid conflicts)"
    echo ""
    echo "======================================"
    echo "After Installation"
    echo "======================================"
    echo ""
    echo "1. Get the initial admin password from:"
    echo "   - Docker: MSYS_NO_PATHCONV=1 docker exec jenkins-applebite cat /var/jenkins_home/secrets/initialAdminPassword"
    echo "   - Windows: C:\\Program Files\\Jenkins\\secrets\\initialAdminPassword"
    echo ""
    echo "2. Install suggested plugins"
    echo ""
    echo "3. Install additional plugins:"
    echo "   - Docker Pipeline"
    echo "   - Docker"
    echo "   - Git"
    echo "   - Pipeline"
    echo ""
    echo "4. Create admin user"
    echo ""
    echo "5. Run: ./quickstart.sh and select option 3 to configure pipeline"
    echo ""

    exit 0
fi

# Linux installation (for WSL or actual Linux systems)
echo "Installing Jenkins on Linux/WSL..."
echo ""

# Check if Jenkins is already installed
if command -v jenkins >/dev/null 2>&1; then
    echo -e "${YELLOW}Jenkins is already installed${NC}"
    jenkins --version
    echo ""
    read -p "Do you want to reinstall? (y/n): " REINSTALL
    if [ "$REINSTALL" != "y" ]; then
        echo "Skipping installation"
        exit 0
    fi
fi

# Install Java (required for Jenkins)
echo "Installing Java..."
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk

# Add Jenkins repository
echo "Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
echo "Installing Jenkins..."
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins
echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Get initial admin password
echo ""
echo "======================================"
echo "Jenkins Initial Admin Password"
echo "======================================"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""

echo -e "${GREEN}Jenkins installation completed!${NC}"
echo ""
echo "Access Jenkins at: http://127.0.0.1:8080"
echo ""
echo "Next steps:"
echo "1. Open http://127.0.0.1:8080 in your browser"
echo "2. Enter the initial admin password shown above"
echo "3. Install suggested plugins"
echo "4. Install additional plugins:"
echo "   - Docker Pipeline"
echo "   - Ansible Plugin"
echo "   - Git Plugin"
echo "   - Pipeline Plugin"
echo "5. Create an admin user"
echo "6. Configure Jenkins credentials for Git and Docker Hub"
echo ""

# Configure Jenkins to use Docker
echo "Configuring Jenkins user for Docker access..."
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo ""
echo "======================================"
echo "Creating Jenkins Pipeline Job"
echo "======================================"
echo ""
echo "To create the pipeline job:"
echo "1. Go to Jenkins dashboard"
echo "2. Click 'New Item'"
echo "3. Enter name: 'AppleBite-CICD-Pipeline'"
echo "4. Select 'Pipeline' and click OK"
echo "5. In Pipeline section, select 'Pipeline script from SCM'"
echo "6. SCM: Git"
echo "7. Repository URL: Your GitHub repo URL"
echo "8. Script Path: jenkins/Jenkinsfile"
echo "9. Save"
echo ""
echo "Or use the provided Jenkinsfile directly in 'Pipeline script' option"
echo ""
echo -e "${GREEN}Setup complete!${NC}"
