# AppleBite CI/CD Project - Demo Guide

## Quick Start Demo (5 Minutes)

This guide provides step-by-step instructions for demonstrating the CI/CD
pipeline.



## Prerequisites Checklist

Before starting the demo, ensure:
- ✅ Master VM with Jenkins, Ansible, Git installed
- ✅ Slave Node (Test Server) with Python, SSH, Git installed
- ✅ SSH key copied from Master to Slave
- ✅ Network connectivity between Master and Slave
- ✅ Ports 8080 (Jenkins) and 80 (Web) are accessible



## Demo Setup (One-Time)

### 1. Configure IP Addresses

Update the following files with your actual server IPs:

**File: `ansible/inventory/hosts`**
```ini
[test_servers]
test-server ansible_host=<TEST_SERVER_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[prod_servers]
prod-server ansible_host=<PROD_SERVER_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**File: `Jenkinsfile`**
```groovy
environment {
    TEST_SERVER = '<TEST_SERVER_IP>'
    PROD_SERVER = '<PROD_SERVER_IP>'
}
```

### 2. Setup SSH Access

On Master VM:
```bash
# Generate SSH key (if not exists)
ssh-keygen -t rsa -b 4096

# Copy to test server
ssh-copy-id ubuntu@<TEST_SERVER_IP>

# Test connection
ssh ubuntu@<TEST_SERVER_IP> exit
```

### 3. Install Jenkins Plugins

1. Open Jenkins: `http://<MASTER_IP>:8080`
2. Go to **Manage Jenkins** → **Manage Plugins** → **Available**
3. Install:
   - Pipeline
   - Git Plugin
   - SSH Agent
   - Build Pipeline Plugin
   - Ansible Plugin

### 4. Create Jenkins Pipeline

1. Click **New Item**
2. Name: `AppleBite-CICD-Pipeline`
3. Type: **Pipeline**
4. Configuration:
   - **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL:
     `https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git`
   - Script Path: `AWS_Projects/AppleBite_CICD_Project2/Jenkinsfile`
   - **Build Triggers**: Poll SCM `H/5 * * * *`
5. **Save**

### 5. Add SSH Credentials in Jenkins

1. **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** → **Add Credentials**
3. Type: **SSH Username with private key**
4. Details:
   - ID: `slave-ssh-key`
   - Username: `ubuntu`
   - Private Key: Paste from `~/.ssh/id_rsa`
5. **OK**



## Running the Demo

### Option 1: Automatic Deployment (Recommended)

**Show automatic CI/CD on Git push:**

1. **Make a code change:**
   ```bash
   cd AWS_Projects/AppleBite_CICD_Project2

   # Edit a file (e.g., change title in index.php)
   nano app/index.php

   # Commit and push
   git add app/index.php
   git commit -m "Demo: Update homepage title"
   git push origin main
   ```

2. **Monitor Jenkins:**
   - Open Jenkins Dashboard
   - Wait 5 minutes (or trigger manually)
   - Pipeline will auto-start when polling detects changes
   - Watch the stages execute

3. **Show the pipeline stages:**
   - ✅ Stage 1: Setup Puppet Agent
   - ✅ Stage 2: Install Docker via Ansible
   - ✅ Stage 3: Build and Deploy Container
   - ✅ Stage 4: Cleanup (only on failure)

4. **Verify deployment:**
   ```bash
   # Access the application
   curl http://<TEST_SERVER_IP>/

   # Or open in browser
   http://<TEST_SERVER_IP>/
   ```

### Option 2: Manual Deployment via Jenkins

**Trigger the pipeline manually:**

1. Go to Jenkins Dashboard
2. Click on `AppleBite-CICD-Pipeline`
3. Click **Build Now**
4. Click on the build number (e.g., #1)
5. Click **Console Output** to show real-time logs
6. Wait for "SUCCESS" message

### Option 3: Manual Deployment via Script

**Deploy directly on test server:**

```bash
# SSH to test server
ssh ubuntu@<TEST_SERVER_IP>

# Clone repo (first time only)
git clone https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git ~/demo
cd ~/demo/AWS_Projects/AppleBite_CICD_Project2

# Run deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh v1.0
```



## Demo Script (5 Minutes)

### Minute 1: Introduction
"Today I'll demonstrate a complete CI/CD pipeline for AppleBite's PHP
application. This pipeline automates the entire deployment process from code
commit to production."

**Show:**
- Architecture diagram (from PROJECT_DOCUMENTATION.md)
- Explain Master VM, Test Server, and workflow

### Minute 2: Pipeline Overview
"The pipeline has 4 jobs that run automatically:"

**Show in Jenkins:**
1. **Job 1**: Puppet Agent Setup - Configures slave node
2. **Job 2**: Docker Installation - Uses Ansible playbook
3. **Job 3**: Build & Deploy - Builds container and deploys
4. **Job 4**: Cleanup - Runs only on failure

### Minute 3: Trigger Deployment
"Let me show you automatic deployment triggered by a Git push."

**Action:**
```bash
# Edit homepage
echo "<!-- Demo timestamp: $(date) -->" >> app/index.php
git add app/index.php
git commit -m "Demo: Trigger pipeline"
git push origin main
```

**Show:**
- Jenkins dashboard
- Pipeline triggered automatically (or click Build Now)
- Stage view showing progress

### Minute 4: Monitor Execution
"Watch each stage execute in sequence."

**Show in Console Output:**
- Puppet agent installation logs
- Ansible Docker installation
- Docker build process
- Container deployment
- Health check

### Minute 5: Verify and Demonstrate Features
"The application is now live!"

**Show:**
```bash
# Container running
ssh ubuntu@<TEST_SERVER_IP> docker ps

# Application accessible
curl http://<TEST_SERVER_IP>/

# Open in browser
http://<TEST_SERVER_IP>/
```

**Demonstrate:**
- Home page, About page, Contact page
- Show version info
- Show container logs: `docker logs applebite-container`



## Verification Commands

### Check Pipeline Status
```bash
# View all containers on test server
ssh ubuntu@<TEST_SERVER_IP> docker ps

# Expected output:
# CONTAINER ID   IMAGE                  STATUS        PORTS
# xxxxx          applebite-app:latest   Up 2 minutes  0.0.0.0:80->80/tcp
```

### Test Application Endpoints
```bash
# Home page
curl http://<TEST_SERVER_IP>/

# About page
curl http://<TEST_SERVER_IP>/about.php

# Contact page
curl http://<TEST_SERVER_IP>/contact.php
```

### Check Container Health
```bash
ssh ubuntu@<TEST_SERVER_IP> << 'EOF'
    echo "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo -e "\nContainer Logs (last 10 lines):"
    docker logs --tail 10 applebite-container

    echo -e "\nResource Usage:"
    docker stats --no-stream applebite-container
EOF
```

### View Pipeline History
In Jenkins:
- Go to pipeline page
- Check **Build History**
- Click on any build → **Console Output**



## Testing Failure Scenario

### Demonstrate Job 4 (Cleanup on Failure)

1. **Introduce an error:**
   ```bash
   # Edit Dockerfile to cause build failure
   echo "RUN invalid_command" >> Dockerfile
   git add Dockerfile
   git commit -m "Demo: Trigger failure scenario"
   git push origin main
   ```

2. **Show Jenkins:**
   - Pipeline starts
   - Job 3 fails during build
   - Job 4 (Cleanup) automatically executes
   - Shows container and image removal

3. **Verify cleanup:**
   ```bash
   ssh ubuntu@<TEST_SERVER_IP> docker ps
   # Should show container removed
   ```

4. **Fix and redeploy:**
   ```bash
   git revert HEAD
   git push origin main
   # Pipeline runs successfully
   ```



## Common Demo Commands

### Show Application Files
```bash
ssh ubuntu@<TEST_SERVER_IP>
ls -la ~/
cat ~/app/index.php
```

### Show Docker Image
```bash
ssh ubuntu@<TEST_SERVER_IP>
docker images | grep applebite
```

### Show Container Logs in Real-Time
```bash
ssh ubuntu@<TEST_SERVER_IP>
docker logs -f applebite-container
```

### Restart Container
```bash
ssh ubuntu@<TEST_SERVER_IP>
docker restart applebite-container
```

### Clean and Redeploy
```bash
ssh ubuntu@<TEST_SERVER_IP>
docker stop applebite-container
docker rm applebite-container
docker rmi applebite-app:latest
# Then trigger pipeline again
```



## Troubleshooting During Demo

### Pipeline Not Starting

**Issue**: Jenkins not polling Git

**Fix:**
```bash
# Manually trigger
# Jenkins UI → AppleBite-CICD-Pipeline → Build Now
```

### Cannot SSH to Slave

**Issue**: Permission denied

**Fix:**
```bash
# On Master VM
ssh-copy-id ubuntu@<TEST_SERVER_IP>
ssh ubuntu@<TEST_SERVER_IP> exit
```

### Docker Build Fails

**Issue**: Build context error

**Fix:**
```bash
ssh ubuntu@<TEST_SERVER_IP>
cd ~/
ls -la Dockerfile app/
# Ensure files are present
```

### Application Not Accessible

**Issue**: Port 80 blocked

**Fix:**
```bash
ssh ubuntu@<TEST_SERVER_IP>
sudo ufw allow 80/tcp
sudo ufw status
```

### Container Exits Immediately

**Issue**: Application error

**Fix:**
```bash
ssh ubuntu@<TEST_SERVER_IP>
docker logs applebite-container
# Check for PHP errors
```



## Reset Demo Environment

### Quick Reset
```bash
# On Test Server
ssh ubuntu@<TEST_SERVER_IP> << 'EOF'
    docker stop $(docker ps -aq) 2>/dev/null
    docker rm $(docker ps -aq) 2>/dev/null
    docker system prune -f
    rm -rf ~/{Dockerfile,app}
EOF

# Trigger pipeline again
# Jenkins UI → Build Now
```

### Full Reset
```bash
# On Test Server
ssh ubuntu@<TEST_SERVER_IP> << 'EOF'
    # Remove Docker
    sudo apt remove --purge docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker

    # Remove Puppet
    sudo apt remove --purge puppet-agent

    # Clean home directory
    rm -rf ~/*
EOF

# Run pipeline from start
```



## Presentation Tips

### Before Demo
1. ✅ Test the complete flow once
2. ✅ Have Jenkins and application URLs ready
3. ✅ Keep terminals open (Master and Slave)
4. ✅ Browser tab open to Jenkins
5. ✅ Browser tab open to application
6. ✅ Have backup slides with screenshots

### During Demo
1. Explain each step clearly
2. Show Console Output in Jenkins
3. Highlight automatic triggers
4. Emphasize failure recovery (Job 4)
5. Show live application

### After Demo
1. Answer questions about architecture
2. Show any failed build examples
3. Demonstrate manual deployment option
4. Show monitoring/logging capabilities



## Key Points to Highlight

### 1. Automation
- ✅ Automatic trigger on Git push (every 5 minutes polling)
- ✅ No manual intervention needed
- ✅ Complete infrastructure setup via code

### 2. Configuration Management
- ✅ Ansible for Docker installation
- ✅ Puppet for agent configuration
- ✅ Idempotent deployments

### 3. Containerization
- ✅ Docker for application isolation
- ✅ Using devopsedu/webapp base image
- ✅ Port mapping and networking

### 4. Failure Handling
- ✅ Automatic cleanup on failure (Job 4)
- ✅ Health checks
- ✅ Logging and monitoring

### 5. Multi-Environment
- ✅ Test server for staging
- ✅ Production server ready (Jenkinsfile-with-prod)
- ✅ Easy to scale



## Quick Reference Card

| Task | Command |
|------|---------|
| **Trigger Pipeline** | Git push or Jenkins "Build Now" |
| **Check Containers** | `ssh ubuntu@<IP> docker ps` |
| **View Logs** | `ssh ubuntu@<IP> docker logs applebite-container` |
| **Test Application** | `curl http://<IP>/` |
| **Restart Container** | `ssh ubuntu@<IP> docker restart applebite-container` |
| **Clean Resources** | `./scripts/cleanup.sh` |
| **Manual Deploy** | `./scripts/deploy.sh v1.0` |
| **Jenkins URL** | `http://<MASTER_IP>:8080` |
| **Application URL** | `http://<TEST_SERVER_IP>/` |



## Success Criteria

Demo is successful when:
- ✅ Pipeline triggered automatically on Git push
- ✅ All 4 stages execute successfully
- ✅ Application accessible on Test Server
- ✅ All 3 pages (Home, About, Contact) load correctly
- ✅ Failure scenario demonstrates Job 4 cleanup
- ✅ Container logs show no errors



## Additional Demo Scenarios

### Scenario 1: Show Ansible in Action
```bash
# Run Ansible playbook manually
ansible-playbook -i ansible/inventory/hosts \
    ansible/playbooks/install-docker.yml -v

# Show Docker installation verification
ssh ubuntu@<TEST_SERVER_IP> docker --version
```

### Scenario 2: Show Puppet Configuration
```bash
# Show puppet script
cat puppet/setup-agent.sh

# Run manually on slave
ssh ubuntu@<TEST_SERVER_IP>
bash puppet/setup-agent.sh
puppet --version
```

### Scenario 3: Show Multi-Stage Build
```bash
# Use Jenkinsfile-with-prod for production deployment
# Shows deployment to both Test and Prod servers
```



**Demo Time**: ~5 minutes **Setup Time**: ~10 minutes (one-time) **Difficulty**:
Intermediate **Audience**: DevOps Engineers, Managers, Developers



For complete documentation, see `PROJECT_DOCUMENTATION.md`
