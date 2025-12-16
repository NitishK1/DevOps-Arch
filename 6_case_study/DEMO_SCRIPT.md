# Docker Swarm Demo Script - Company Website Deployment

## Demo Overview
This demo showcases deploying a containerized company website using Docker Swarm
with high availability, load balancing, and rolling updates.



## Prerequisites Check

```bash
# Verify Docker is running
docker --version
docker info | grep -i swarm

# Should show: Swarm: active
# If not active, initialize swarm:
docker swarm init
```



## Demo Script

### Part 1: Show the Application Structure

```bash
# Navigate to project directory
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/6_case_study

# Show the Dockerfile
cat Dockerfile

# Show the docker-compose-swarm.yml
cat docker-compose-swarm.yml

# Explain:
# - Dockerfile: Builds the image (PHP 8.1 + Apache)
# - docker-compose-swarm.yml: Defines the deployment (3 replicas, health checks, auto-restart)
```



### Part 2: Verify Image is Available

```bash
# Check if image exists locally
docker images | grep company-website

# If not available, can pull from Docker Hub
docker pull hardikgangwar/company-website:latest

# Or show that it's already on Docker Hub
echo "Image available at: https://hub.docker.com/r/hardikgangwar/company-website"
```



### Part 3: Deploy to Docker Swarm

```bash
# Deploy the stack using docker-compose-swarm.yml
DOCKERHUB_USERNAME=hardikgangwar docker stack deploy -c docker-compose-swarm.yml company

# Output should show:
# "Creating service company_web"
```

**Explain:**
- Stack named "company" is created
- Service "company_web" with 3 replicas
- Automatic load balancing across replicas
- Health checks to monitor service health



### Part 4: Verify Deployment

```bash
# View deployed stacks
docker stack ls
# Shows: company stack with 1 service

# View services in the stack
docker stack services company
# Shows: company_web with 3/3 replicas

# View detailed service information
docker service ps company_web
# Shows: All 3 replicas running on docker-desktop node

# Check running containers
docker ps
# Shows: 3 containers running for company_web
```

**Key Points:**
- All 3 replicas are running (3/3)
- Load balancing automatically configured
- Service is exposed on port 80



### Part 5: Access the Application

```bash
# Access the website
curl http://localhost
# Or open in browser: http://localhost

# Test multiple times to see load balancing
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://localhost | grep -i "title" || echo "Connection successful"
  sleep 1
done
```

**Demonstrate:**
- Open browser and navigate to `http://localhost`
- Refresh multiple times (traffic is load-balanced across 3 replicas)



### Part 6: Demonstrate High Availability

```bash
# Get one of the container IDs
CONTAINER_ID=$(docker ps --filter "name=company_web" --format "{{.ID}}" | head -1)

echo "Stopping container: $CONTAINER_ID"
docker stop $CONTAINER_ID

# Wait a few seconds
sleep 5

# Check service status - Swarm automatically restarts the container
docker service ps company_web

# Check service still works
curl http://localhost
```

**Explain:**
- Docker Swarm detected the failed container
- Automatically started a new replica
- Service remained available with zero downtime
- This is **self-healing**



### Part 7: Scale the Service

```bash
# Current state: 3 replicas
docker service ls

# Scale up to 5 replicas
docker service scale company_web=5

# Verify scaling
docker service ps company_web
# Shows: 5 replicas running

# Scale back down to 3
docker service scale company_web=3

# Verify
docker service ls
```

**Explain:**
- Easy horizontal scaling
- Can scale based on load
- No downtime during scaling operations



### Part 8: Rolling Update (Optional Advanced Demo)

```bash
# Simulate updating to a new version
# Update with a new image tag (or same with force update for demo)
docker service update --image hardikgangwar/company-website:latest --force company_web

# Watch the rolling update in real-time
watch -n 1 'docker service ps company_web'
# Press Ctrl+C to stop watching

# Explain the update process:
# - Updates one replica at a time (parallelism: 1)
# - Waits 10s between updates
# - Monitors health checks
# - Rolls back automatically if update fails
```

**Key Points:**
- Zero downtime updates
- Gradual rollout
- Automatic rollback on failure



### Part 9: View Logs and Monitoring

```bash
# View service logs
docker service logs company_web --tail 20

# View logs from specific replica
docker service logs company_web --tail 20 --raw

# Check service health
docker service inspect company_web --pretty
```

**Explain:**
- Centralized logging across all replicas
- Easy troubleshooting
- Health check configuration visible



### Part 10: Cleanup

```bash
# Remove the stack (stops all services)
docker stack rm company

# Verify removal
docker stack ls
docker service ls

# Optional: Leave swarm mode (if needed)
# docker swarm leave --force
```



## Demo Key Takeaways

### What We Demonstrated:
1. ✅ **Containerization** - Application packaged in Docker image
2. ✅ **Orchestration** - Docker Swarm managing multiple replicas
3. ✅ **High Availability** - 3 replicas with automatic failover
4. ✅ **Load Balancing** - Built-in ingress routing mesh
5. ✅ **Self-Healing** - Automatic container restart on failure
6. ✅ **Scalability** - Easy horizontal scaling (3 → 5 → 3 replicas)
7. ✅ **Zero Downtime Updates** - Rolling updates with health checks
8. ✅ **Monitoring** - Centralized logging and service inspection

### Production Benefits:
- **Reliability** - Service stays up even if containers fail
- **Performance** - Load distributed across multiple instances
- **Flexibility** - Easy to scale based on demand
- **Maintainability** - Simple updates without downtime
- **Infrastructure as Code** - All configuration in docker-compose-swarm.yml



## Quick Reference

```bash
# Deploy
DOCKERHUB_USERNAME=hardikgangwar docker stack deploy -c docker-compose-swarm.yml company

# Check status
docker stack services company
docker service ps company_web

# Scale
docker service scale company_web=5

# Logs
docker service logs company_web

# Cleanup
docker stack rm company
```



## Troubleshooting Tips

### If deployment fails:
```bash
# Check detailed error messages
docker service ps company_web --no-trunc

# Check service logs
docker service logs company_web

# Verify swarm is active
docker info | grep Swarm
```

### Windows Git Bash path issues:
```bash
# Use MSYS_NO_PATHCONV=1 for Linux paths
MSYS_NO_PATHCONV=1 docker service create --mount type=volume,target=/var/www/html ...
```



**Demo Duration:** 15-20 minutes **Difficulty Level:** Intermediate
**Audience:** DevOps Engineers, System Administrators, Developers
