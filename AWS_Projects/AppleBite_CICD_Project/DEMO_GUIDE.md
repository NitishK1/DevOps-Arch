# AppleBite CI/CD Project - Demo Guide

**Purpose:** Step-by-step manual commands to demonstrate the CI/CD pipeline
without automation scripts.



## Table of Contents
1. [Pre-Demo Setup](#pre-demo-setup)
2.
   [Demo Script: Full Pipeline Walkthrough](#demo-script-full-pipeline-walkthrough)
3. [Explaining Each Component](#explaining-each-component)
4. [Common Demo Scenarios](#common-demo-scenarios)



## Pre-Demo Setup

### Before Starting the Demo
Ensure these are ready:

```bash
# 1. Verify Docker is running
docker --version
docker ps

# 2. Verify Jenkins is accessible
# Open browser: http://127.0.0.1:8090

# 3. Navigate to project directory
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/AWS_Projects/AppleBite_CICD_Project

# 4. Check Git repository status
git status
git log --oneline -5

# 5. Verify submodule is present
git submodule status
ls app/website/  # Should show index.php, config.php, etc.
```



## Demo Script: Full Pipeline Walkthrough

### Phase 1: Show the Problem Statement

**Talking Points:**
- AppleBite Co. has complex builds with multiple teams
- Need to deploy frequently with high quality
- Manual deployments are slow and error-prone
- Solution: Automated CI/CD pipeline

**Show the Architecture:**
```
Developer Push → GitHub → Jenkins → Build → Test → Deploy → Validate
```



### Phase 2: Version Control (Git + Submodules)

#### Step 1: Show Main Repository
```bash
# Show current repository
git remote -v
# Output: https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git

# Show recent commits
git log --oneline -5

# Show project structure
ls -la
```

**Explain:** Main repository contains DevOps infrastructure (Docker, Jenkins,
Ansible)

#### Step 2: Show Git Submodule (App Code)
```bash
# Show submodule configuration
cat .gitmodules

# Show submodule status
git submodule status

# Navigate to app submodule
cd app

# Show app code repository
git remote -v
# Output: https://github.com/edureka-devops/projCert.git

# Show app files
ls website/
# Output: index.php, config.php, functions.php, content/, template/

cd ..
```

**Explain:** App code is from third-party vendor (separate repository),
integrated as submodule



### Phase 3: Containerization (Docker)

#### Step 3: Show Dockerfile
```bash
# Display Dockerfile structure
cat docker/Dockerfile

# Explain multi-stage build:
# 1. Base stage: PHP + Apache + extensions
# 2. Production stage: Optimized, minimal, secure
# 3. Development stage: Debugging tools included
```

**Key Points:**
- Base image: `php:7.4-apache`
- Installs PHP extensions: `pdo_mysql`, `mbstring`, `gd`
- Enables Apache modules: `rewrite`, `headers`
- Copies app from `./app/website/` to `/var/www/html/`

#### Step 4: Build Docker Image Manually
```bash
# Build the Docker image
docker build -t applebite-app:demo -f docker/Dockerfile --target development .

# This will:
# - Install system dependencies
# - Install PHP extensions
# - Configure Apache
# - Copy application files
# - Set up permissions

# View the built image
docker images | grep applebite-app
```

**Explain:** This is what Jenkins does automatically in the "Build Docker Image"
stage

#### Step 5: Run Unit Tests in Container
```bash
# Run a test container
docker run --rm applebite-app:demo /bin/bash -c "echo 'Running unit tests...' && php -v && echo 'Tests passed'"

# Output shows PHP version and "Tests passed"
```

**Explain:** Tests run inside isolated container, matching production
environment



### Phase 4: Deployment (Docker Compose)

#### Step 6: Show Test Environment Configuration
```bash
# Display test environment compose file
cat docker/docker-compose.test.yml

# Key configurations:
# - Port mapping: 8080:80
# - Volume mount: ../app/website:/var/www/html
# - Environment: test
# - Health check: curl -f http://localhost/
# - MySQL database included
```

**Explain:**
- Test environment uses volume mounts for live code updates
- Includes MySQL for database testing
- Health checks ensure container is ready before proceeding

#### Step 7: Deploy Test Environment Manually
```bash
# Navigate to docker directory
cd docker

# Stop any existing test environment
docker-compose -f docker-compose.test.yml down

# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Wait for containers to be healthy
echo "Waiting for containers to start..."
sleep 15

# Check container status
docker ps --filter "name=applebite-test"

# Expected output:
# applebite-test-web   Up X seconds (healthy)
# applebite-test-db    Up X seconds (healthy)
```

**Explain:** Docker Compose orchestrates multiple containers (web + database)

#### Step 8: Verify Test Deployment
```bash
# Check web container logs
docker logs applebite-test-web --tail 20

# Check if Apache is running
docker exec applebite-test-web ps aux | grep apache

# Verify files are mounted correctly
winpty docker exec applebite-test-web ls -la //var//www//html
# Should show: index.php, config.php, functions.php, etc.

# Check Apache configuration
winpty docker exec applebite-test-web cat //etc//apache2//sites-enabled//000-default.conf
```

**Explain:** Container is running Apache web server serving PHP application



### Phase 5: Testing and Validation

#### Step 9: Run Integration Tests Manually
```bash
# Test the application endpoint
curl -I http://127.0.0.1:8080

# Expected output:
# HTTP/1.1 200 OK
# Server: Apache/2.4.54 (Debian)
# X-Powered-By: PHP/7.4.33

# Get full response
curl http://127.0.0.1:8080 | head -20

# Should show HTML with "Simple PHP Website"

# Open in browser
# Navigate to: http://127.0.0.1:8080
```

**Demonstrate:**
- Application loads successfully
- PHP is executing correctly
- All pages accessible (Home, About Us, Products, Contact)

#### Step 10: Simulate Integration Test Failures (Optional)
```bash
# Stop the web container to simulate failure
docker stop applebite-test-web

# Try to access - should fail
curl -f http://127.0.0.1:8080
# Output: curl: (7) Failed to connect

# Restart container
docker start applebite-test-web
sleep 10

# Test again - should succeed
curl -f http://127.0.0.1:8080
```

**Explain:** Pipeline has retry logic (5 attempts) to handle temporary failures



### Phase 6: CI/CD Automation (Jenkins)

#### Step 11: Show Jenkins Pipeline Configuration
```bash
# Display Jenkinsfile
cat jenkins/Jenkinsfile | head -100

# Key sections:
# - Environment variables
# - Checkout stage with submodules
# - Build Docker image (with Windows compatibility)
# - Run unit tests
# - Deploy to test
# - Integration tests with retry logic
# - Deploy to stage/prod (master branch only)
```

**Explain Pipeline Stages:**
1. **Checkout:** Clone repository + submodules
2. **Build:** Create Docker image
3. **Test:** Run unit tests in container
4. **Deploy:** Deploy to test environment
5. **Validate:** Run integration tests
6. **Promote:** Deploy to stage/production (with approval)

#### Step 12: Access Jenkins
```bash
# Open Jenkins in browser
# URL: http://127.0.0.1:8090

# Show:
# 1. Pipeline job: AppleBite-Pipeline
# 2. Build history
# 3. Recent successful build
# 4. Console output
```

**Navigate in Jenkins UI:**
1. Click on **AppleBite-Pipeline** job
2. Click on latest build (e.g., #12)
3. Click **Console Output**
4. Show pipeline stages executing
5. Point out Windows-specific commands (`bat` vs `sh`)

#### Step 13: Trigger Build from Code Change
```bash
# Make a small change to demonstrate trigger
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training

# Create a test file
echo "Demo at $(date)" > test-demo.txt

# Commit and push
git add test-demo.txt
git commit -m "Demo: Trigger CI/CD pipeline"
git push origin main

# Expected: Jenkins detects change within 5 minutes (SCM polling)
```

**Show in Jenkins:**
1. Wait for polling to detect change
2. Build starts automatically
3. Navigate through pipeline stages in real-time
4. Show Blue Ocean view (optional, if installed)



### Phase 7: Multi-Environment Deployment

#### Step 14: Show Stage Environment (Optional)
```bash
# Deploy to stage environment
cd docker
docker-compose -f docker-compose.stage.yml up -d

# Wait for healthy status
sleep 20

# Check status
docker ps --filter "name=applebite-stage"

# Test stage endpoint
curl -I http://127.0.0.1:8081
```

**Explain:**
- Stage uses production Docker target (no volume mounts)
- Files are baked into image for immutability
- Simulates production environment

#### Step 15: Show Production Environment (Optional)
```bash
# Deploy to production environment
docker-compose -f docker-compose.prod.yml up -d

# Wait for healthy status
sleep 20

# Check status
docker ps --filter "name=applebite-prod"

# Test production endpoint
curl -I http://127.0.0.1:8082
```

**Explain:**
- Production has resource limits
- Requires manual approval in pipeline
- Has backup and rollback capabilities

#### Step 16: Show All Environments Running
```bash
# Display all running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Should show:
# applebite-test-web    (Port 8080)
# applebite-stage-web   (Port 8081)
# applebite-prod-web    (Port 8082)
# + database containers
```

**Open all in browser tabs:**
- Test: http://127.0.0.1:8080
- Stage: http://127.0.0.1:8081
- Production: http://127.0.0.1:8082



### Phase 8: Configuration Management (Ansible)

#### Step 17: Show Ansible Playbooks (Optional)
```bash
# Show inventory files
cat ansible/inventory/test.ini
cat ansible/inventory/stage.ini
cat ansible/inventory/prod.ini

# Show provisioning playbook
cat ansible/playbooks/provision-server.yml

# Show deployment playbook
cat ansible/playbooks/deploy-app.yml
```

**Explain:**
- Ansible automates server provisioning
- Ensures all servers have same configuration
- Currently skipped on Windows (uses Docker Compose directly)
- Would be used in cloud environments (AWS, Azure, GCP)



## Explaining Each Component

### Git + Submodules
**What:** Version control with third-party app code integration **Why:**
Separates infrastructure code from application code **How:** Main repo contains
DevOps config, submodule contains app from vendor

### Docker
**What:** Application containerization **Why:** Consistent environment across
dev/test/prod, eliminates "works on my machine" **How:** Multi-stage Dockerfile
creates optimized images for each environment

### Docker Compose
**What:** Multi-container orchestration **Why:** Manages web server + database +
networking together **How:** YAML files define services, volumes, networks for
each environment

### Jenkins
**What:** CI/CD automation server **Why:** Automates build, test, deploy
workflow, reduces manual errors **How:** Jenkinsfile defines pipeline stages,
triggers on code changes

### Ansible (Optional)
**What:** Configuration management and provisioning **Why:** Ensures consistent
server configuration **How:** Playbooks define desired state, applied to all
servers



## Common Demo Scenarios

### Scenario 1: Show Automatic Deployment
1. Make code change in `app/website/index.php`
2. Commit and push to GitHub
3. Wait for Jenkins to poll (5 minutes)
4. Show build starting automatically
5. Show test deployment succeeding
6. Show updated application at http://127.0.0.1:8080

### Scenario 2: Show Failure Handling
1. Stop test database container: `docker stop applebite-test-db`
2. Trigger build in Jenkins
3. Show integration tests failing
4. Show retry logic (5 attempts)
5. Show pipeline failing correctly
6. Restart database: `docker start applebite-test-db`
7. Re-run build - should succeed

### Scenario 3: Show Multi-Environment
1. Show code running in test (port 8080)
2. Deploy to stage (port 8081)
3. Show same code in different environment
4. Explain manual approval for production
5. Show production deployment (port 8082)

### Scenario 4: Show Rollback (Manual)
1. Tag current production image:
   `docker tag applebite-app:latest applebite-app:backup`
2. Deploy new version to production
3. If issues occur, rollback:
   ```bash
   docker tag applebite-app:backup applebite-app:latest
   cd docker
   docker-compose -f docker-compose.prod.yml up -d --force-recreate
   ```



## Quick Commands Cheat Sheet

### Check Everything Is Working
```bash
# Docker
docker ps
docker images | grep applebite

# Test environment
curl -I http://127.0.0.1:8080

# Container logs
docker logs applebite-test-web --tail 50

# Container health
docker inspect applebite-test-web | grep -A 5 Health
```

### Restart Everything
```bash
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/AWS_Projects/AppleBite_CICD_Project/docker

# Restart test
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.test.yml up -d

# Restart stage
docker-compose -f docker-compose.stage.yml down
docker-compose -f docker-compose.stage.yml up -d

# Restart prod
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### Clean Up After Demo
```bash
# Stop all environments
cd docker
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.stage.yml down
docker-compose -f docker-compose.prod.yml down

# Remove images (optional)
docker rmi applebite-app:demo

# Remove volumes (optional)
docker volume prune
```



## Demo Timeline (Estimated 30 minutes)

| Time | Phase | Activity |
|------|-------|----------|
| 0-5 min | Introduction | Explain business problem, show architecture |
| 5-10 min | Git & Submodules | Show repository structure, submodule setup |
| 10-15 min | Docker | Build image, show Dockerfile, run tests |
| 15-20 min | Deployment | Deploy test environment, verify application |
| 20-25 min | Jenkins Pipeline | Show Jenkinsfile, trigger build, explain stages |
| 25-30 min | Multi-Environment | Show test/stage/prod, explain promotion process |



## Tips for Successful Demo

### Preparation
1. Run through demo script beforehand
2. Have all URLs bookmarked (Jenkins, test, stage, prod)
3. Clear Docker logs before demo
4. Ensure clean Git status (no uncommitted changes)

### During Demo
1. Explain "why" before showing "how"
2. Use browser for visual elements (Jenkins UI, application)
3. Use terminal for technical details (Docker commands, logs)
4. Show failures and recovery (not just success path)

### Common Questions
- **Q: Why use Docker?** A: Consistent environments, eliminates configuration
  drift
- **Q: Why Git submodules?** A: Separates vendor code from infrastructure code
- **Q: Why Jenkins?** A: Automates repetitive tasks, reduces human error
- **Q: Why multiple environments?** A: Test changes before production, reduce
  risk



**Document Version:** 1.0 **Last Updated:** December 12, 2025 **Estimated Demo
Duration:** 30 minutes
