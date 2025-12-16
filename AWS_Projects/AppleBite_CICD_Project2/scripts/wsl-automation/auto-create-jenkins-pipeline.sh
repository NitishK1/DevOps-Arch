#!/bin/bash

# Automated Jenkins Pipeline Creation Script
# Creates a pipeline job that polls GitHub repo every 5 minutes

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Jenkins Pipeline Auto-Creation                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Configuration
MASTER_VM="Ubuntu-22.04"
JENKINS_URL="http://localhost:8080"
JENKINS_USER="hardikgangwar"
JENKINS_PASSWORD="ASK_HARDIK_FOR_PASSWORD"
JOB_NAME="AppleBite-CICD-Pipeline"
GITHUB_REPO="https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git"
GITHUB_BRANCH="main"
JENKINSFILE_PATH="AWS_Projects/AppleBite_CICD_Project2/Jenkinsfile-with-prod"

echo "Configuration:"
echo "  Jenkins URL: $JENKINS_URL"
echo "  Job Name: $JOB_NAME"
echo "  Repository: $GITHUB_REPO"
echo "  Branch: $GITHUB_BRANCH"
echo "  Jenkinsfile: $JENKINSFILE_PATH"
echo ""

# Run on Master VM
wsl.exe -d "$MASTER_VM" bash << 'OUTER_EOF'

JENKINS_URL="http://localhost:8080"
JENKINS_USER="hardikgangwar"
# Get password from environment or prompt user
if [ -z "$JENKINS_PASSWORD" ]; then
    echo "Enter Jenkins password for user $JENKINS_USER:"
    read -s JENKINS_PASSWORD
fi
JOB_NAME="AppleBite-CICD-Pipeline"
GITHUB_REPO="https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git"
GITHUB_BRANCH="main"
JENKINSFILE_PATH="AWS_Projects/AppleBite_CICD_Project2/Jenkinsfile-with-prod"

echo "═══════════════════════════════════════════════════════════"
echo "Step 1: Using Jenkins credentials"
echo "═══════════════════════════════════════════════════════════"

# Ensure Jenkins service is running
sudo service jenkins start 2>/dev/null || true
sleep 3

echo "✓ Using Jenkins user: $JENKINS_USER"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Waiting for Jenkins to be ready"
echo "═══════════════════════════════════════════════════════════"

# Wait for Jenkins to be fully started
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL/login" | grep -q "200\|403"; then
        echo "✓ Jenkins is ready"
        break
    fi
    attempt=$((attempt + 1))
    echo "Waiting for Jenkins... ($attempt/$max_attempts)"
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    echo "✗ Jenkins did not start in time"
    exit 1
fi

# Wait additional time for Jenkins to fully initialize
echo "Waiting for Jenkins to fully initialize..."
sleep 10

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 2.5: Getting Jenkins CSRF crumb"
echo "═══════════════════════════════════════════════════════════"

# Get CSRF crumb for API calls
CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_PASSWORD" \
    "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [ -n "$CRUMB" ]; then
    echo "✓ CSRF crumb obtained"
    CRUMB_HEADER="-H \"$CRUMB\""
else
    echo "⚠ Could not get CSRF crumb (may not be required)"
    CRUMB_HEADER=""
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Checking required Jenkins plugins"
echo "═══════════════════════════════════════════════════════════"

# Check if required plugins are installed
PLUGINS="git workflow-aggregator pipeline-stage-view"

echo "Required plugins: $PLUGINS"
echo "✓ Assuming plugins are installed (skip manual installation)"
echo "  Note: Install these plugins manually if pipeline fails:"
for plugin in $PLUGINS; do
    echo "    - $plugin"
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 4: Creating pipeline job configuration"
echo "═══════════════════════════════════════════════════════════"

# Create job config XML
cat > /tmp/pipeline-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <description>AppleBite CI/CD Pipeline - Automatically polls GitHub every 5 minutes</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/5 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.90">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.10.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>GITHUB_REPO_PLACEHOLDER</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/GITHUB_BRANCH_PLACEHOLDER</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>JENKINSFILE_PATH_PLACEHOLDER</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Replace placeholders
sed -i "s|GITHUB_REPO_PLACEHOLDER|$GITHUB_REPO|g" /tmp/pipeline-config.xml
sed -i "s|GITHUB_BRANCH_PLACEHOLDER|$GITHUB_BRANCH|g" /tmp/pipeline-config.xml
sed -i "s|JENKINSFILE_PATH_PLACEHOLDER|$JENKINSFILE_PATH|g" /tmp/pipeline-config.xml

echo "✓ Pipeline configuration created"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 5: Creating Jenkins job via REST API"
echo "═══════════════════════════════════════════════════════════"

# Parse crumb into field and value
if [ -n "$CRUMB" ]; then
    CRUMB_FIELD=$(echo "$CRUMB" | cut -d: -f1)
    CRUMB_VALUE=$(echo "$CRUMB" | cut -d: -f2)
fi

# Check if job already exists
JOB_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
    --user "$JENKINS_USER:$JENKINS_PASSWORD" \
    "$JENKINS_URL/job/$JOB_NAME/config.xml")

if [ "$JOB_EXISTS" = "200" ]; then
    echo "Job already exists. Updating configuration..."
    # Update existing job
    if [ -n "$CRUMB" ]; then
        HTTP_CODE=$(curl -s -o /tmp/jenkins-response.txt -w "%{http_code}" \
            -X POST "$JENKINS_URL/job/$JOB_NAME/config.xml" \
            --user "$JENKINS_USER:$JENKINS_PASSWORD" \
            -H "$CRUMB_FIELD: $CRUMB_VALUE" \
            -H "Content-Type: application/xml" \
            --data-binary "@/tmp/pipeline-config.xml")
    else
        HTTP_CODE=$(curl -s -o /tmp/jenkins-response.txt -w "%{http_code}" \
            -X POST "$JENKINS_URL/job/$JOB_NAME/config.xml" \
            --user "$JENKINS_USER:$JENKINS_PASSWORD" \
            -H "Content-Type: application/xml" \
            --data-binary "@/tmp/pipeline-config.xml")
    fi

    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ Job updated successfully"
    else
        echo "✗ Failed to update job (HTTP $HTTP_CODE)"
        cat /tmp/jenkins-response.txt 2>/dev/null | head -10
        exit 1
    fi
else
    echo "Creating new job..."
    # Create new job
    if [ -n "$CRUMB" ]; then
        HTTP_CODE=$(curl -s -o /tmp/jenkins-response.txt -w "%{http_code}" \
            -X POST "$JENKINS_URL/createItem?name=$JOB_NAME" \
            --user "$JENKINS_USER:$JENKINS_PASSWORD" \
            -H "$CRUMB_FIELD: $CRUMB_VALUE" \
            -H "Content-Type: application/xml" \
            --data-binary "@/tmp/pipeline-config.xml")
    else
        HTTP_CODE=$(curl -s -o /tmp/jenkins-response.txt -w "%{http_code}" \
            -X POST "$JENKINS_URL/createItem?name=$JOB_NAME" \
            --user "$JENKINS_USER:$JENKINS_PASSWORD" \
            -H "Content-Type: application/xml" \
            --data-binary "@/tmp/pipeline-config.xml")
    fi

    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ Job created successfully"
    else
        echo "✗ Failed to create job (HTTP $HTTP_CODE)"
        cat /tmp/jenkins-response.txt 2>/dev/null | head -10
        exit 1
    fi
fi

# Clean up
rm -f /tmp/pipeline-config.xml

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 6: Verifying job creation"
echo "═══════════════════════════════════════════════════════════"

sleep 2

# Verify job exists
JOB_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
    --user "$JENKINS_USER:$JENKINS_PASSWORD" \
    "$JENKINS_URL/job/$JOB_NAME/")

if [ "$JOB_CHECK" = "200" ]; then
    echo "✓ Job verified successfully"
else
    echo "✗ Job verification failed (HTTP $JOB_CHECK)"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✓ Pipeline Creation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Pipeline Details:"
echo "  Name: $JOB_NAME"
echo "  URL: $JENKINS_URL/job/$JOB_NAME/"
echo ""
echo "Configuration:"
echo "  Repository: $GITHUB_REPO"
echo "  Branch: $GITHUB_BRANCH"
echo "  Jenkinsfile: $JENKINSFILE_PATH"
echo "  Polling: Every 5 minutes (H/5 * * * *)"
echo ""
echo "Next Steps:"
echo "  1. Access Jenkins at: $JENKINS_URL"
echo "  2. Navigate to: $JOB_NAME"
echo "  3. Click 'Build Now' to trigger first build"
echo "  4. Pipeline will auto-trigger on Git changes every 5 minutes"
echo ""

OUTER_EOF

# Get Master VM IP for display
master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     ✓ PIPELINE SETUP COMPLETE!                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Access your pipeline at:"
echo "  http://$master_ip:8080/job/$JOB_NAME/"
echo ""
echo "Jenkins Credentials:"
echo "  Username: admin"
echo "  Password: Run this command to get password:"
echo "    wsl -d $MASTER_VM sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
