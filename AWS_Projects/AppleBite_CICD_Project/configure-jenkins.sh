#!/bin/bash

# Jenkins Configuration Script for AppleBite CI/CD Project
# This script guides you through configuring Jenkins after installation

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
     __           _    _
    / /__ _ _  __(_)__( )___
   / / -_) ' \/ // / // (_-<
  /_/\__/_/_/_/_//_/\_//__/
   / ___/__  ___  / _(_)__ _
  / /__/ _ \/ _ \/ _/ / _ `/
  \___/\___/_//_/_//_/\_, /
                     /___/

  AppleBite Jenkins Configuration
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}This script will guide you through Jenkins configuration.${NC}"
echo ""

# Detect Jenkins installation type
JENKINS_TYPE=""
JENKINS_URL=""
JENKINS_PORT=""

# Check for Docker Jenkins
if docker ps 2>/dev/null | grep -q jenkins-applebite; then
    JENKINS_TYPE="docker"
    JENKINS_URL="http://127.0.0.1:8090"
    JENKINS_PORT="8090"
    echo -e "${GREEN}✓ Detected Docker Jenkins on port 8090${NC}"
else
    # Check for local Jenkins on common ports
    if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080 2>/dev/null | grep -q "200\|403"; then
        JENKINS_TYPE="local"
        JENKINS_URL="http://127.0.0.1:8080"
        JENKINS_PORT="8080"
        echo -e "${GREEN}✓ Detected local Jenkins on port 8080${NC}"
    elif curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8090 2>/dev/null | grep -q "200\|403"; then
        JENKINS_TYPE="local"
        JENKINS_URL="http://127.0.0.1:8090"
        JENKINS_PORT="8090"
        echo -e "${GREEN}✓ Detected local Jenkins on port 8090${NC}"
    else
        echo -e "${RED}ERROR: Jenkins is not running!${NC}"
        echo ""
        echo "Could not detect Jenkins on:"
        echo "  - Docker (jenkins-applebite container)"
        echo "  - Local installation (ports 8080 or 8090)"
        echo ""
        echo "Please start Jenkins first using one of these methods:"
        echo "  1. Docker: ./quickstart.sh (option 2)"
        echo "  2. Local: Start your local Jenkins service"
        echo ""
        exit 1
    fi
fi

echo ""

# Check if Jenkins is already configured
if [ "$JENKINS_TYPE" = "docker" ]; then
    JENKINS_CONFIGURED=$(docker exec jenkins-applebite sh -c "test -d /var/jenkins_home/users && echo 'yes' || echo 'no'" 2>/dev/null)
else
    # For local Jenkins, check via HTTP
    if curl -s "$JENKINS_URL/login" 2>/dev/null | grep -q "loginLink\|j_username"; then
        JENKINS_CONFIGURED="yes"
    else
        JENKINS_CONFIGURED="no"
    fi
fi

if [ "$JENKINS_CONFIGURED" = "yes" ]; then
    echo -e "${YELLOW}Jenkins appears to be already configured!${NC}"
    echo ""
    echo "Jenkins Dashboard: ${GREEN}${JENKINS_URL}${NC}"
    echo "Installation Type: ${CYAN}${JENKINS_TYPE}${NC}"
    echo ""
    echo "If you've forgotten your password, you'll need to:"
    echo "1. Access Jenkins at ${JENKINS_URL}"
    echo "2. Use your admin credentials you created earlier"
    echo ""
    echo "Or to reset Jenkins completely, use: ./quickstart.sh (option 19)"
    echo ""
    read -p "Do you want to continue with pipeline setup anyway? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo "Configuration cancelled."
        exit 0
    fi
    echo ""
    echo "Skipping initial setup steps..."
    echo ""
    PASSWORD="<your-configured-password>"
else
    # Get Jenkins password
    echo "======================================"
    echo "  Step 1: Jenkins Admin Password"
    echo "======================================"
    echo ""

    # Try multiple methods to get the password based on installation type
    if [ "$JENKINS_TYPE" = "docker" ]; then
        PASSWORD=$(MSYS_NO_PATHCONV=1 docker exec jenkins-applebite cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
    else
        # For local Windows Jenkins installation
        if [ -f "/c/Program Files/Jenkins/secrets/initialAdminPassword" ]; then
            PASSWORD=$(cat "/c/Program Files/Jenkins/secrets/initialAdminPassword" 2>/dev/null || echo "")
        elif [ -f "$HOME/.jenkins/secrets/initialAdminPassword" ]; then
            PASSWORD=$(cat "$HOME/.jenkins/secrets/initialAdminPassword" 2>/dev/null || echo "")
        elif [ ! -z "$JENKINS_HOME" ] && [ -f "$JENKINS_HOME/secrets/initialAdminPassword" ]; then
            PASSWORD=$(cat "$JENKINS_HOME/secrets/initialAdminPassword" 2>/dev/null || echo "")
        else
            PASSWORD=""
        fi
    fi

    if [ -z "$PASSWORD" ]; then
        echo -e "${YELLOW}Could not automatically retrieve Jenkins password${NC}"
        echo ""
        if [ "$JENKINS_TYPE" = "docker" ]; then
            echo "Get the password manually with:"
            echo "  MSYS_NO_PATHCONV=1 docker exec jenkins-applebite cat /var/jenkins_home/secrets/initialAdminPassword"
        else
            echo "Get the password manually from:"
            echo "  Windows: C:\\Program Files\\Jenkins\\secrets\\initialAdminPassword"
            echo "  Or: %JENKINS_HOME%\\secrets\\initialAdminPassword"
        fi
        echo ""
        read -p "Enter the password manually: " PASSWORD
        if [ -z "$PASSWORD" ]; then
            echo -e "${RED}ERROR: Password is required${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Your Jenkins admin password:${NC}"
        echo -e "${GREEN}$PASSWORD${NC}"
    fi

    echo ""
    echo "Copy this password - you'll need it in a moment."
    echo ""
    read -p "Press Enter when you've copied the password..."
fi

# Open Jenkins (skip if already configured)
if [ "$JENKINS_CONFIGURED" != "yes" ]; then
    echo ""
    echo "======================================"
    echo "  Step 2: Open Jenkins Web UI"
    echo "======================================"
    echo ""
    echo "Opening Jenkins in your browser..."
    start "$JENKINS_URL" 2>/dev/null || echo "Please open: $JENKINS_URL"
    echo ""
    echo "In the browser:"
    echo "  1. Paste the password: ${PASSWORD}"
    echo "  2. Click 'Continue'"
    echo ""
    read -p "Press Enter after you've unlocked Jenkins..."

    # Install plugins
    echo ""
    echo "======================================"
    echo "  Step 3: Install Plugins"
    echo "======================================"
    echo ""
    echo "On the 'Customize Jenkins' page:"
    echo ""
    echo -e "${CYAN}SELECT: 'Install suggested plugins'${NC}"
    echo ""
    echo "Wait for all plugins to install (this may take 2-3 minutes)..."
    echo ""
    read -p "Press Enter after plugins are installed..."

    # Create admin user
    echo ""
    echo "======================================"
    echo "  Step 4: Create Admin User"
    echo "======================================"
    echo ""
    echo "On the 'Create First Admin User' page:"
    echo ""
    echo "  Username:  admin"
    echo "  Password:  <choose a strong password>"
    echo "  Full name: AppleBite Admin"
    echo "  Email:     your-email@example.com"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Remember your admin credentials!${NC}"
    echo ""
    read -p "Press Enter after creating admin user..."

    # Instance configuration
    echo ""
    echo "======================================"
    echo "  Step 5: Instance Configuration"
    echo "======================================"
    echo ""
    echo "Jenkins URL should be: $JENKINS_URL/"
    echo ""
    echo "Click 'Save and Finish'"
    echo ""
    read -p "Press Enter after saving..."

    # Start using Jenkins
    echo ""
    echo "======================================"
    echo "  Step 6: Additional Plugins"
    echo "======================================"
    echo ""
    echo "We need to install additional plugins for Docker and Git."
    echo ""
    echo "In Jenkins:"
    echo "  1. Click 'Manage Jenkins' (left sidebar)"
    echo "  2. Click 'Plugins'"
    echo "  3. Click 'Available plugins' tab"
    echo "  4. Search for and install these plugins:"
    echo ""
    echo -e "${CYAN}     ☐ Docker Pipeline${NC}"
    echo -e "${CYAN}     ☐ Docker${NC}"
    echo -e "${CYAN}     ☐ Git${NC}"
    echo -e "${CYAN}     ☐ Pipeline${NC}"
    echo ""
    echo "  5. Check the box next to each plugin"
    echo "  6. Click 'Install' button at the top"
    echo "  7. Check 'Restart Jenkins when installation is complete'"
    echo ""
    read -p "Press Enter after installing plugins..."

    echo ""
    echo "Waiting for Jenkins to restart (30 seconds)..."
    sleep 30
else
    echo ""
    echo "Jenkins is already set up. Opening browser..."
    start "$JENKINS_URL" 2>/dev/null || echo "Please open: $JENKINS_URL"
    echo ""
    echo "Please log in with your admin credentials."
    echo ""
    read -p "Press Enter after logging in..."
fi

# Create pipeline job
echo ""
echo "======================================"
echo "  Step 7: Create Pipeline Job"
echo "======================================"
echo ""

# Check for Docker CLI availability (needed for pipeline)
if [ "$JENKINS_TYPE" = "local" ]; then
    echo -e "${YELLOW}Note: Local Jenkins Installation${NC}"
    echo ""
    echo "For the pipeline to work, Jenkins needs access to Docker CLI."
    echo ""
    echo "Options:"
    echo "  1. If Docker Desktop is installed, ensure Jenkins can access it"
    echo "  2. Add Jenkins user to docker group (Linux/WSL)"
    echo "  3. Or use the Docker version of Jenkins (option 1 in setup)"
    echo ""
    echo "The pipeline script uses Docker commands to build and deploy."
    echo ""
    read -p "Press Enter to continue with pipeline setup..."
    echo ""
fi

echo "Now let's create the CI/CD pipeline:"
echo ""
echo "  1. Click 'New Item' (left sidebar)"
echo "  2. Enter item name: ${CYAN}AppleBite-Pipeline${NC}"
echo "  3. Select 'Pipeline' type"
echo "  4. Click 'OK'"
echo ""
read -p "Press Enter after creating the pipeline job..."

# Configure pipeline
echo ""
echo "======================================"
echo "  Step 8: Configure Pipeline"
echo "======================================"
echo ""
echo "On the pipeline configuration page:"
echo ""
echo -e "${YELLOW}General Section:${NC}"
echo "  ☐ Check 'GitHub project'"
echo "  Project url: https://github.com/NitishK1/Edureka_DevOps_Arch_Training"
echo ""
echo -e "${YELLOW}Build Triggers Section:${NC}"
echo "  Choose one of these options:"
echo ""
echo "  ${CYAN}Option 1 - GitHub Webhook (Recommended):${NC}"
echo "  ☐ Check 'GitHub hook trigger for GITScm polling'"
echo ""
echo "  ${CYAN}Option 2 - Poll SCM (For local development):${NC}"
echo "  ☐ Check 'Poll SCM'"
echo "  Schedule: H/5 * * * *  (checks every 5 minutes)"
echo ""
echo -e "${YELLOW}Pipeline Section:${NC}"
echo "  Definition: Pipeline script from SCM"
echo "  SCM: Git"
echo "  Repository URL: https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git"
echo "  Branch: */main"
echo "  ${CYAN}Additional Behaviours → Add → Advanced sub-modules behaviours${NC}"
echo "    ☑ Recursively update submodules"
echo "  Script Path: AWS_Projects/AppleBite_CICD_Project/jenkins/Jenkinsfile"
echo ""
echo -e "${GREEN}Note:${NC} The app code is in a git submodule (AWS_Projects/AppleBite_CICD_Project/app)"
echo "Jenkins will automatically checkout the main repo and all submodules."
echo ""
read -p "Press Enter to continue..."

# Jenkinsfile info
echo ""
echo "======================================"
echo "  Step 9: Jenkinsfile Configuration"
echo "======================================"
echo ""
echo -e "${GREEN}✓ Jenkinsfile is already configured at:${NC}"
echo "  AWS_Projects/AppleBite_CICD_Project/jenkins/Jenkinsfile"
echo ""
echo "The Jenkinsfile is configured to:"
echo "  • Checkout main repository with submodules"
echo "  • Build Docker images from the app submodule"
echo "  • Deploy to Test, Stage, and Production environments"
echo "  • Run tests and health checks"
echo ""
echo -e "${YELLOW}Click 'Save' at the bottom of the Jenkins configuration page.${NC}"
echo ""
read -p "Press Enter after saving the pipeline..."

# Summary
echo ""
echo -e "${GREEN}"
cat << "EOF"
  ╔═══════════════════════════════════════╗
  ║   Jenkins Configuration Complete!     ║
  ╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""
echo -e "${CYAN}What's Been Configured:${NC}"
echo "  ✓ Jenkins installed and unlocked"
echo "  ✓ Admin user created"
echo "  ✓ Essential plugins installed"
echo "  ✓ Pipeline job created"
echo "  ✓ Pipeline configured"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo ""
echo "1. Test the pipeline:"
echo "   ${YELLOW}• Go to Jenkins dashboard${NC}"
echo "   ${YELLOW}• Click on 'AppleBite-Pipeline'${NC}"
echo "   ${YELLOW}• Click 'Build Now' (left sidebar)${NC}"
echo "   ${YELLOW}• Watch the build progress${NC}"
echo ""
echo "2. Access your environments after deployment:"
echo "   ${GREEN}• Test:       http://127.0.0.1:8080${NC}"
echo "   ${GREEN}• Stage:      http://127.0.0.1:8081${NC}"
echo "   ${GREEN}• Production: http://127.0.0.1:8082${NC}"
echo ""
echo "3. Jenkins Dashboard:"
echo "   ${GREEN}• URL:      $JENKINS_URL${NC}"
echo "   ${GREEN}• Username: admin${NC}"
echo "   ${GREEN}• Password: <the one you set>${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "• The pipeline triggers on pushes to: https://github.com/NitishK1/Edureka_DevOps_Arch_Training"
echo "• The app code is in a git submodule (automatically checked out by Jenkins)"
echo "• You can trigger builds manually or set up automatic triggers"
echo ""
echo -e "${CYAN}Setup Automatic Builds:${NC}"
echo ""
echo "  ${YELLOW}Option 1 - GitHub Webhook:${NC}"
echo "  See: GITHUB_WEBHOOK_SETUP.md for detailed instructions"
echo ""
echo "  ${YELLOW}Option 2 - GitHub Polling:${NC}"
echo "  Already configured if you selected 'Poll SCM' during setup"
echo ""
echo "  ${YELLOW}Option 3 - Manual Trigger:${NC}"
echo "  Just click 'Build Now' in Jenkins dashboard"
echo ""
echo -e "${GREEN}Configuration completed successfully!${NC}"
echo ""
