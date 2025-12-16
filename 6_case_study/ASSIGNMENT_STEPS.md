# DevOps Case Study - Docker Assignment

## Manual Commands to Complete Assignment

### Prerequisites

**For Windows with Git Bash:**
```bash
# Ensure Docker Desktop is running
# Docker Desktop should have Swarm mode available

# Verify Docker is running
docker --version
docker info
```

**For macOS with Podman:**
```bash
# Ensure Podman is running
podman machine start
```



### Step 1: Build the Docker Image

**For Windows with Git Bash:**
```bash
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/6_case_study

docker build -t company-website:latest .
```

**For macOS with Podman:**
```bash
cd /Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/6_case_study

podman build --tls-verify=false -t company-website:latest .
```

**Verify:**
```bash
# Windows/Docker
docker images | grep company-website

# macOS/Podman
podman images | grep company-website
```



### Step 2: Test Locally (Optional)

**For Windows with Git Bash:**
```bash
docker run -d --name test-website -p 8080:80 \
  -v "$(pwd)/dockerContent/Case-study app:/var/www/html" \
  company-website:latest

# Test
curl http://localhost:8080

# Cleanup
docker stop test-website
docker rm test-website
```

**For macOS with Podman:**
```bash
podman run -d --name test-website -p 8080:80 \
  -v "$(pwd)/dockerContent/Case-study app:/var/www/html" \
  company-website:latest

# Test
curl http://localhost:8080

# Cleanup
podman stop test-website
podman rm test-website
```



### Step 3: Push to Docker Hub

**For Windows with Git Bash:**
```bash
# Login to Docker Hub
docker login
# Username: hardikgangwar
# Password: [enter your password]

# Tag the image
docker tag company-website:latest hardikgangwar/company-website:latest
docker tag company-website:latest hardikgangwar/company-website:v1.0

# Push to Docker Hub
docker push hardikgangwar/company-website:latest
docker push hardikgangwar/company-website:v1.0
```

**For macOS with Podman:**
```bash
# Login to Docker Hub
podman login docker.io
# Username: hardikgangwar
# Password: [enter your password]

# Tag the image
podman tag company-website:latest docker.io/hardikgangwar/company-website:latest
podman tag company-website:latest docker.io/hardikgangwar/company-website:v1.0

# Push to Docker Hub
podman push --tls-verify=false docker.io/hardikgangwar/company-website:latest
podman push --tls-verify=false docker.io/hardikgangwar/company-website:v1.0
```

**Verify:**
- Visit https://hub.docker.com/r/hardikgangwar/company-website



### Step 4: Initialize Docker Swarm Cluster

```bash
# Initialize Docker Swarm
docker swarm init

# Verify Swarm is active
docker info | grep Swarm
```

**Output should show:** `Swarm: active`



### Step 5: Deploy Service to Swarm

**Method 1: Using docker stack with docker-compose-swarm.yml (Recommended)**
```bash
# Deploy the entire stack
DOCKERHUB_USERNAME=hardikgangwar docker stack deploy -c docker-compose-swarm.yml company

# Verify deployment
docker stack ls
docker stack services company
docker service ps company_web
```

**Method 2: Using docker service create command**
```bash
# Create a named volume for persistence
docker volume create company-website-data

# Deploy service with 3 replicas
# IMPORTANT: Use MSYS_NO_PATHCONV=1 to prevent Git Bash path conversion issues
MSYS_NO_PATHCONV=1 docker service create \
  --name company-website \
  --replicas 3 \
  --publish 80:80 \
  --mount type=volume,source=company-website-data,target=/var/www/html \
  hardikgangwar/company-website:latest
```

**Verify Service:**
```bash
# Check service status
docker service ls

# Check service replicas and their status
docker service ps company_web   # if using stack
docker service ps company-website   # if using service create

# View service logs
docker service logs company_web   # if using stack
docker service logs company-website   # if using service create
```



### Step 6: Access the Website

Open in browser:
- **Local:** http://localhost
- **Docker Hub:** docker pull docker.io/hardikgangwar/company-website:latest



## Assignment Checklist

- [x] Dockerfile created with proper configuration
- [x] Volume configured for `/var/www/html`
- [x] Image pushed to Docker Hub
- [x] Docker Swarm cluster initialized
- [x] Service deployed with 3 replicas on port 80
- [x] Volume mount configured for persistence
- [x] Port 80 exposed (container) / 8080 (host)



## Quick Commands Reference

**Docker Stack Commands (when using docker-compose-swarm.yml):**
```bash
# Deploy stack
DOCKERHUB_USERNAME=hardikgangwar docker stack deploy -c docker-compose-swarm.yml company

# List stacks
docker stack ls

# List services in a stack
docker stack services company

# Remove stack (cleanup)
docker stack rm company

# View service logs
docker service logs company_web
```

**Docker Service Commands (when using service create):**
```bash
# View running services
docker service ls

# View service details
docker service ps company-website

# Scale service
docker service scale company-website=5
docker service scale company_web=5   # if using stack

# Update service image
docker service update --image hardikgangwar/company-website:v1.0 company-website

# Remove service
docker service rm company-website
```

**General Docker Swarm Commands:**
```bash
# Initialize swarm
docker swarm init

# Leave swarm (cleanup)
docker swarm leave --force

# View nodes in swarm
docker node ls

# View running containers
docker ps

# View images
docker images
```

**Important for Windows Git Bash:**
```bash
# Use MSYS_NO_PATHCONV=1 for any commands with Linux paths
# Example:
MSYS_NO_PATHCONV=1 docker service create --mount type=volume,target=/var/www/html ...
```

**For macOS with Podman:**
```bash
# View running containers
podman ps

# View container logs
podman logs <container-name>

# View images
podman images

# Push to registry
podman push --tls-verify=false docker.io/username/image:tag
```

## Troubleshooting

### Windows Git Bash Path Conversion Issue
If you see errors like
`invalid mount target, must be an absolute path: C:/Program Files/Git/var/www/html`:

**Solution:** Prefix your command with `MSYS_NO_PATHCONV=1` to disable automatic
path conversion:
```bash
MSYS_NO_PATHCONV=1 docker service create \
  --mount type=volume,source=data,target=/var/www/html \
  ...
```

### Service Not Starting
Check service status and error messages:
```bash
docker service ps company-website --no-trunc
docker service logs company-website
```
