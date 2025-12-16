#!/bin/bash

# Simple Jenkins Pipeline Creation using Jenkins CLI
# This creates a pipeline job that polls GitHub every 5 minutes

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Jenkins Pipeline Creation (CLI Method)              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

MASTER_VM="Ubuntu-22.04"
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

echo "Configuration:"
echo "  Job Name: $JOB_NAME"
echo "  Repository: $GITHUB_REPO"
echo "  Branch: $GITHUB_BRANCH"
echo "  Jenkinsfile: $JENKINSFILE_PATH"
echo "  SCM Polling: Every 5 minutes"
echo ""

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
echo "Step 1: Downloading Jenkins CLI"
echo "═══════════════════════════════════════════════════════════"

# Download Jenkins CLI
cd /tmp
wget -q "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -O jenkins-cli.jar

if [ -f jenkins-cli.jar ]; then
    echo "✓ Jenkins CLI downloaded"
else
    echo "✗ Failed to download Jenkins CLI"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Creating job configuration XML"
echo "═══════════════════════════════════════════════════════════"

# Create job config XML
cat > /tmp/pipeline-job.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <description>AppleBite CI/CD Pipeline - Polls GitHub every 5 minutes for changes</description>
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
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
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
      <submoduleCfg class="empty-list"/>
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
sed -i "s|GITHUB_REPO_PLACEHOLDER|$GITHUB_REPO|g" /tmp/pipeline-job.xml
sed -i "s|GITHUB_BRANCH_PLACEHOLDER|$GITHUB_BRANCH|g" /tmp/pipeline-job.xml
sed -i "s|JENKINSFILE_PATH_PLACEHOLDER|$JENKINSFILE_PATH|g" /tmp/pipeline-job.xml

echo "✓ Job configuration created"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Creating/Updating Jenkins job"
echo "═══════════════════════════════════════════════════════════"

# Check if job exists
JOB_EXISTS=$(java -jar /tmp/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" list-jobs 2>/dev/null | grep "^${JOB_NAME}$")

if [ -n "$JOB_EXISTS" ]; then
    echo "Job exists. Updating..."
    java -jar /tmp/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        update-job "$JOB_NAME" < /tmp/pipeline-job.xml

    if [ $? -eq 0 ]; then
        echo "✓ Job updated successfully"
    else
        echo "✗ Failed to update job"
        exit 1
    fi
else
    echo "Creating new job..."
    java -jar /tmp/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        create-job "$JOB_NAME" < /tmp/pipeline-job.xml

    if [ $? -eq 0 ]; then
        echo "✓ Job created successfully"
    else
        echo "✗ Failed to create job"
        exit 1
    fi
fi

# Clean up
rm -f /tmp/pipeline-job.xml /tmp/jenkins-cli.jar

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✓ Pipeline Job Created Successfully!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Job Details:"
echo "  Name: $JOB_NAME"
echo "  Repository: $GITHUB_REPO"
echo "  Branch: $GITHUB_BRANCH"
echo "  Jenkinsfile: $JENKINSFILE_PATH"
echo "  SCM Polling: H/5 * * * * (every 5 minutes)"
echo ""
echo "The pipeline will:"
echo "  ✓ Poll GitHub every 5 minutes for changes"
echo "  ✓ Automatically trigger builds on new commits"
echo "  ✓ Use Jenkinsfile from your repository"
echo ""

OUTER_EOF

master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     ✓ PIPELINE READY!                                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Access your pipeline:"
echo "  http://$master_ip:8080/job/$JOB_NAME/"
echo ""
echo "Login Credentials:"
echo "  Username: hardikgangwar"
echo "  Password: (use your Jenkins password)"
echo ""
echo "Next Steps:"
echo "  1. Open Jenkins in your browser"
echo "  2. Navigate to '$JOB_NAME'"
echo "  3. Click 'Build Now' to trigger first build"
echo "  4. Pipeline will auto-trigger on future Git commits"
echo ""
