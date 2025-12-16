# AppleBite CI/CD Project - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Jenkins Configuration](#jenkins-configuration)
5. [Pipeline Stages](#pipeline-stages)
6. [Troubleshooting](#troubleshooting)
7. [Git Submodules](#git-submodules)



## Project Overview

### Business Problem
AppleBite Co. uses Cloud for their products with modular components, multiple
frameworks, and development by different teams. They need to:
- Deliver product updates frequently with high quality & reliability
- Accelerate software delivery speed and reduce feedback time
- Manage complex builds and incremental deployments

### Solution
Automated CI/CD pipeline using:
- **Git** - Version control (Main repo: `NitishK1/Edureka_DevOps_Arch_Training`,
  App submodule: `edureka-devops/projCert`)
- **Jenkins** - Continuous integration and deployment (Local Windows
  installation on port 8090)
- **Docker** - Application containerization
- **Ansible** - Configuration management (optional, skipped on Windows)

### How It Works
1. Developer pushes code to GitHub main branch
2. Jenkins detects changes (via SCM polling every 5 minutes or webhook)
3. Pipeline automatically:
   - Checks out code and submodules
   - Builds Docker image
   - Runs unit tests
   - Deploys to Test environment (port 8080)
   - Runs integration tests
   - Can deploy to Stage (8081) and Production (8082) on master branch



## Architecture

### Directory Structure
```
AWS_Projects/AppleBite_CICD_Project/
├── app/                          # Git submodule (edureka-devops/projCert)
│   └── website/                  # PHP application files
│       ├── index.php
│       ├── config.php
│       ├── functions.php
│       ├── content/
│       └── template/
├── docker/
│   ├── Dockerfile                # Multi-stage (base, production, development)
│   ├── docker-compose.test.yml   # Test environment (port 8080)
│   ├── docker-compose.stage.yml  # Stage environment (port 8081)
│   └── docker-compose.prod.yml   # Production environment (port 8082)
├── jenkins/
│   └── Jenkinsfile               # Main CI/CD pipeline (Windows-compatible)
├── ansible/
│   ├── inventory/
│   │   ├── test.ini
│   │   ├── stage.ini
│   │   └── prod.ini
│   └── playbooks/
│       ├── provision-server.yml
│       └── deploy-app.yml
└── scripts/
    ├── setup.sh
    ├── build.sh
    ├── deploy.sh
    └── diagnose-test-environment.sh
```

### Technology Stack
- **Base Image:** PHP 7.4-Apache
- **Web Server:** Apache 2.4.54
- **Database:** MySQL 8.0 (optional, for testing)
- **Container Platform:** Docker Desktop on Windows
- **CI/CD:** Jenkins LTS (local installation)



## Prerequisites

### Required Software
1. **Git** - For version control
2. **Docker Desktop** - For containerization
3. **Jenkins** - Local installation on Windows (port 8090)
4. **curl** - For testing endpoints

### Repository Access
- Main repository:
  `https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git`
- App submodule: `https://github.com/edureka-devops/projCert.git` (public, no
  credentials needed)



## Jenkins Configuration

### 1. Create Pipeline Job
1. Open Jenkins: http://127.0.0.1:8090
2. Click **New Item**
3. Enter name: `AppleBite-Pipeline`
4. Select **Pipeline**
5. Click **OK**

### 2. Configure Pipeline
In the job configuration:

#### General Settings
- Description: `AppleBite CI/CD Pipeline`
- Check: ✅ **Discard old builds** (Keep last 10 builds)

#### Build Triggers (Choose one)
**Option A: SCM Polling (Recommended for local Jenkins)**
- Check: ✅ **Poll SCM**
- Schedule: `H/5 * * * *` (checks GitHub every 5 minutes)

**Option B: GitHub Webhook (For production)**
- Check: ✅ **GitHub hook trigger for GITScm polling**
- Requires Jenkins to be publicly accessible (use ngrok or similar)

#### Pipeline Configuration
- **Definition:** `Pipeline script from SCM`
- **SCM:** `Git`
- **Repository URL:**
  `https://github.com/NitishK1/Edureka_DevOps_Arch_Training.git`
- **Credentials:** None (public repo) or add GitHub credentials if private
- **Branch Specifier:** `*/main`
- **Script Path:** `AWS_Projects/AppleBite_CICD_Project/jenkins/Jenkinsfile` ⬅️
  **CRITICAL!**

#### Additional Behaviours
Click **Add** → **Advanced sub-modules behaviours**:
- ✅ **Recursively update submodules**
- ✅ **Update tracking submodules to tip of branch**

### 3. Save and Test
1. Click **Save**
2. Click **Build Now**
3. Monitor console output for any errors



## Pipeline Stages

### 1. Initialize
- Displays build information
- Shows workspace and build number

### 2. Checkout Code
- Clones main repository: `NitishK1/Edureka_DevOps_Arch_Training`
- Recursively checks out submodules (app code from `edureka-devops/projCert`)
- Location: `${WORKSPACE}/AWS_Projects/AppleBite_CICD_Project/app`

### 3. Code Quality Check
- Runs PHP syntax checks (if PHP installed)
- Skipped on Windows by default

### 4. Build Docker Image
- Builds multi-stage Docker image
- Tags: `applebite-app:${BUILD_NUMBER}` and `applebite-app:latest`
- Uses development target for test environment
- **Windows note:** Uses `bat` commands with path conversion (backslashes)

### 5. Run Unit Tests
- Runs tests inside a temporary Docker container
- Uses Linux shell `/bin/bash` inside container (even on Windows host)
- Tests pass if container executes successfully

### 6. Provision Test Server (Optional)
- Uses Ansible playbook to provision server
- Skipped on Windows (uses Docker Compose directly)

### 7. Deploy to Test
- Stops existing test containers
- Deploys using `docker-compose.test.yml`
- Waits 60 seconds for containers to be healthy
- Test URL: http://127.0.0.1:8080

### 8. Integration Tests
- Tests Test environment with retry logic (5 attempts, 10-second delays)
- Uses `curl -f http://127.0.0.1:8080`
- **Properly fails** the pipeline if all retries fail
- Windows: Uses `returnStatus: true` for proper error handling

### 9. Deploy to Stage (master branch only)
- Deploys to stage environment
- Stage URL: http://127.0.0.1:8081

### 10. Smoke Tests on Stage (master branch only)
- Validates stage deployment
- Similar retry logic as integration tests

### 11. Approval for Production (master branch only)
- Manual approval step
- Requires admin/devops approval

### 12. Deploy to Production (master branch only)
- Backs up current production (Unix only)
- Deploys to production environment
- Production URL: http://127.0.0.1:8082

### 13. Production Health Check (master branch only)
- Validates production deployment

### 14. Cleanup
- Removes old Docker images (older than 72 hours)



## Troubleshooting

### Build Not Triggering Automatically
**Problem:** Pushed to GitHub but Jenkins didn't start a build.

**Solution:**
1. Check **Build Triggers** are configured (Poll SCM or GitHub webhook)
2. For polling, check **Polling Log** (left menu in job) to verify it's running
3. Verify repository URL and branch specifier are correct

### Integration Tests Failing with HTTP 403
**Problem:** Container runs but returns 403 Forbidden.

**Solution:** Fixed! The volume mount in `docker-compose.test.yml` now correctly
mounts `../app/website:/var/www/html` (not `../app:/var/www/html`).

**Verify:**
```bash
docker ps --filter "name=applebite-test-web"  # Should show (healthy)
curl -I http://127.0.0.1:8080                 # Should return HTTP 200 OK
```

### Container Shows "unhealthy" Status
**Problem:** Docker container is running but marked unhealthy.

**Diagnostic:**
```bash
# Check container logs
docker logs applebite-test-web

# Check health check status
docker inspect applebite-test-web | grep -A 10 Health

# Run diagnostic script
bash scripts/diagnose-test-environment.sh
```

**Common causes:**
- Apache not starting correctly
- Files not mounted properly
- Health check endpoint failing

### "exec: cmd: not found" Error
**Problem:** Jenkinsfile tried to run Windows `cmd` inside Linux container.

**Solution:** Fixed! Docker containers always run Linux, so commands **inside**
the container must use `/bin/bash`, even when Jenkins is on Windows.

### Path Not Found Errors on Windows
**Problem:** Jenkins can't find paths like
`C:\...\AWS_Projects\AppleBite_CICD_Project`.

**Solutions:**
- Ensure PROJECT_DIR is correctly set in Jenkinsfile
- Verify submodules are checked out: `git submodule status`
- Check path conversion in bat commands uses backslashes

### Wrong Jenkinsfile Being Used
**Problem:** Jenkins is using `app/Jenkinsfile` instead of
`jenkins/Jenkinsfile`.

**Solution:**
1. Go to job **Configure** → **Pipeline** section
2. Verify **Script Path:**
   `AWS_Projects/AppleBite_CICD_Project/jenkins/Jenkinsfile`
3. The app/Jenkinsfile is from the submodule and lacks Windows compatibility



## Git Submodules

### Understanding the Setup
This project uses Git submodules to separate the main infrastructure code from
the application code:
- **Main repository:** DevOps configuration, Jenkins pipeline, Docker files,
  Ansible playbooks
- **Submodule (app):** PHP application code from third-party repo

### Submodule Location
```
AWS_Projects/AppleBite_CICD_Project/app  → https://github.com/edureka-devops/projCert.git
```

### Updating Submodule Manually
```bash
cd AWS_Projects/AppleBite_CICD_Project
git submodule update --init --recursive  # Initialize submodules
git submodule update --remote app        # Update to latest version
```

### Jenkins Automatic Submodule Checkout
Jenkins automatically checks out submodules when configured with:
- **Additional Behaviours** → **Advanced sub-modules behaviours**
- **Recursively update submodules** enabled

### How It Works
1. Jenkins checks out main repository to workspace
2. Jenkins reads `.gitmodules` file
3. Jenkins clones app code from `edureka-devops/projCert` into `app/` directory
4. Pipeline builds and deploys the app code



## Quick Reference

### Important URLs
- Jenkins: http://127.0.0.1:8090
- Test Environment: http://127.0.0.1:8080
- Stage Environment: http://127.0.0.1:8081
- Production Environment: http://127.0.0.1:8082

### Important Paths
- **Jenkinsfile:** `AWS_Projects/AppleBite_CICD_Project/jenkins/Jenkinsfile`
- **App Code:** `AWS_Projects/AppleBite_CICD_Project/app/website/`
- **Docker Files:** `AWS_Projects/AppleBite_CICD_Project/docker/`

### Docker Commands
```bash
# View running containers
docker ps

# View test environment logs
docker logs applebite-test-web

# Restart test environment
cd AWS_Projects/AppleBite_CICD_Project/docker
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.test.yml up -d

# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}"

# Access container shell
winpty docker exec -it applebite-test-web bash
```

### Pipeline Environment Variables
- `DOCKER_IMAGE`: `applebite-app`
- `DOCKER_TAG`: `${BUILD_NUMBER}`
- `PROJECT_DIR`: `${WORKSPACE}/AWS_Projects/AppleBite_CICD_Project`
- `TEST_PORT`: `8080`
- `STAGE_PORT`: `8081`
- `PROD_PORT`: `8082`



## Project Success Metrics

### What Does Success Look Like?
1. ✅ Push code to GitHub → Build triggers automatically within 5 minutes
2. ✅ All pipeline stages complete successfully
3. ✅ Test environment deploys and passes integration tests
4. ✅ Application accessible at http://127.0.0.1:8080
5. ✅ Container shows "healthy" status
6. ✅ HTTP 200 OK response from test endpoint

### Build Time
- Typical successful build: 3-5 minutes
- Includes: checkout, build, test, deploy, integration tests



## Notes

### Windows vs Linux Compatibility
The Jenkinsfile uses `isUnix()` checks to run different commands based on the
host OS:
- **Unix hosts:** Use `sh` commands
- **Windows hosts:** Use `bat` commands with path conversion

**Important:** Commands **inside Docker containers** always use Linux shell,
even on Windows.

### Why Test Environment Uses Volume Mount
The test environment (`docker-compose.test.yml`) mounts
`../app/website:/var/www/html` as a volume for rapid development. This allows:
- Live code updates without rebuilding image
- Faster development iteration
- Easy debugging

Stage and Production don't use volume mounts (files are baked into the image for
immutability).

### Docker Multi-Stage Build
The Dockerfile has three stages:
1. **base:** Common dependencies (PHP extensions, Apache config)
2. **production:** Optimized for production (minimal, runs as www-data)
3. **development:** Includes debugging tools (Xdebug, vim, nano)

Test environment uses `development` target, Stage/Prod use `production` target.



**Document Version:** 1.0 **Last Updated:** December 12, 2025 **Project
Repository:** https://github.com/NitishK1/Edureka_DevOps_Arch_Training
