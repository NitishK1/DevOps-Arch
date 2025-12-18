# Local Testing Guide for Windows

## Prerequisites ✅
- Docker Desktop with Kubernetes enabled
- Git Bash or WSL
- Docker Hub account

## Quick Test (5 minutes)

### Option 1: Automated Script
```bash
cd AWS_Projects/Project2
chmod +x scripts/local-test.sh
./scripts/local-test.sh
```

### Option 2: Manual Step-by-Step

#### 1. Clone the Application
```bash
git clone https://github.com/bhavukm/cicd-pipeline-train-schedule-autodeploy.git
cd cicd-pipeline-train-schedule-autodeploy
```

#### 2. Copy Solution Files
```bash
cp ../Dockerfile .
cp ../Jenkinsfile .
mkdir -p k8s
cp ../k8s/* k8s/
```

#### 3. Build Docker Image
```bash
# Replace <your-username> with your Docker Hub username
docker build -t <your-username>/train-schedule:local .
```

#### 4. Test Locally with Docker
```bash
# Run container
docker run -d -p 8080:8080 --name train-schedule <your-username>/train-schedule:local

# Test it
curl http://localhost:8080
# Or open http://localhost:8080 in browser
```

#### 5. Deploy to Kubernetes
```bash
# Update deployment.yaml with your Docker Hub username
sed -i 's/<your-dockerhub-username>/<your-username>/g' k8s/deployment.yaml

# Deploy application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Check status
kubectl get pods
kubectl get svc
```

#### 6. Deploy Monitoring Stack
```bash
cd ../
kubectl create namespace monitoring
kubectl apply -f monitoring/prometheus-deployment.yaml
kubectl apply -f monitoring/grafana-deployment.yaml
```

#### 7. Verify Everything is Running
```bash
kubectl get pods -A
kubectl get svc -A
```

## Access Your Application

- **Train Schedule App (Docker)**: http://localhost:8080
- **Train Schedule App (K8s)**: http://localhost:30080
- **Prometheus**: http://localhost:30090
- **Grafana**: http://localhost:30030 (admin/admin)

## Common Commands

### Check Application Status
```bash
kubectl get pods -l app=train-schedule
kubectl logs -l app=train-schedule
kubectl describe pod <pod-name>
```

### Check Services
```bash
kubectl get svc train-schedule-service
```

### Scale Application
```bash
kubectl scale deployment train-schedule-deployment --replicas=3
```

### Update Image
```bash
kubectl set image deployment/train-schedule-deployment train-schedule=<your-username>/train-schedule:v2
```

### View HPA Status
```bash
kubectl get hpa
```

### View Monitoring
```bash
kubectl get pods -n monitoring
kubectl logs -n monitoring -l app=prometheus
```

## Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service Not Accessible
```bash
kubectl get svc
kubectl get endpoints
```

### Docker Build Issues
```bash
# Check if Node.js app files exist
ls -la
# View Dockerfile
cat Dockerfile
```

### Port Already in Use
```bash
# On Windows, find process using port
netstat -ano | findstr :8080
# Kill process if needed
taskkill /PID <process-id> /F
```

## Cleanup

### Stop Docker Container
```bash
docker stop train-schedule
docker rm train-schedule
```

### Delete Kubernetes Resources
```bash
kubectl delete -f k8s/
kubectl delete namespace monitoring
```

### Remove Docker Images
```bash
docker rmi <your-username>/train-schedule:local
```

## Test the CI/CD Pipeline

To test the full pipeline, you'll need:

1. **Fork the repository** to your GitHub account
2. **Set up Jenkins** (can run in Docker)
3. **Configure Jenkins**:
   - Install required plugins
   - Add Docker Hub credentials
   - Add Kubernetes config
4. **Create Pipeline Job** pointing to your fork
5. **Configure GitHub Webhook** to trigger builds

## Quick Jenkins Setup (Optional)

```bash
# Run Jenkins in Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Then access Jenkins at http://localhost:8080

## Next Steps

1. ✅ Test the application locally
2. ✅ Deploy to Kubernetes
3. ✅ Set up monitoring
4. 🔄 Configure Jenkins
5. 🔄 Set up GitHub webhook
6. 🔄 Test end-to-end CI/CD pipeline
