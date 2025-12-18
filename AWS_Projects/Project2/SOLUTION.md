# CI/CD Pipeline Solution for Abstergo Corp

## Project Overview
This solution implements a complete CI/CD pipeline with continuous monitoring for Abstergo Corp's train schedule application. The pipeline automates the entire workflow from code commit to production deployment.

## Architecture

### Components
1. **GitHub** - Source code repository
2. **Jenkins** - CI/CD automation server
3. **Docker Hub** - Container image registry
4. **Kubernetes** - Container orchestration platform
5. **Prometheus** - Monitoring and metrics collection
6. **Grafana** - Metrics visualization and dashboarding

### Pipeline Flow
```
Developer → GitHub → Jenkins → Docker Build → Docker Hub → Kubernetes → Prometheus → Grafana
    ↓           ↓         ↓           ↓             ↓            ↓            ↓
  Commit     Webhook   Build &     Push Image   Pull & Deploy  Monitor    Visualize
                       Test                                     Metrics
```

## Prerequisites

### Required Software
- **Git** - Version control
- **Docker** - Container runtime
- **Kubernetes** - Use one of:
  - Minikube (local development)
  - Docker Desktop with Kubernetes enabled
  - Cloud provider (AWS EKS, GKE, AKS)
- **Jenkins** - CI/CD server
- **kubectl** - Kubernetes CLI

### Required Accounts
- GitHub account
- Docker Hub account

## Step-by-Step Setup Guide

### 1. Fork and Clone Repository

```bash
# Fork the repository on GitHub
# https://github.com/bhavukm/cicd-pipeline-train-schedule-autodeploy

# Clone your forked repository
git clone https://github.com/<your-username>/cicd-pipeline-train-schedule-autodeploy.git
cd cicd-pipeline-train-schedule-autodeploy

# Copy solution files to the cloned repository
cp -r <solution-path>/* .
```

### 2. Setup Docker Hub

```bash
# Login to Docker Hub
docker login

# Note your Docker Hub username for later use
```

### 3. Setup Kubernetes Cluster

#### Option A: Using Minikube
```bash
# Start Minikube
minikube start --driver=docker

# Enable metrics server for HPA
minikube addons enable metrics-server
```

#### Option B: Using Docker Desktop
```bash
# Enable Kubernetes in Docker Desktop settings
# Settings → Kubernetes → Enable Kubernetes
```

### 4. Deploy Monitoring Stack

```bash
# Create monitoring namespace
kubectl apply -f monitoring/namespace.yaml

# Deploy Prometheus
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy Grafana
kubectl apply -f monitoring/grafana-deployment.yaml

# Verify deployments
kubectl get pods -n monitoring
```

### 5. Setup Jenkins

#### Install Jenkins
```bash
# Using Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

#### Configure Jenkins

1. **Access Jenkins**: Open http://localhost:8080
2. **Get Initial Password**:
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

3. **Install Required Plugins**:
   - Docker Pipeline
   - Kubernetes CLI
   - Git
   - GitHub Integration

4. **Add Docker Hub Credentials**:
   - Go to: Manage Jenkins → Credentials → System → Global credentials
   - Click "Add Credentials"
   - Kind: Username with password
   - ID: `dockerhub-credentials`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password

5. **Configure Kubernetes**:
   - Install kubectl in Jenkins container:
     ```bash
     docker exec -u root jenkins apt-get update
     docker exec -u root jenkins apt-get install -y kubectl
     ```
   - Copy kubeconfig:
     ```bash
     docker exec jenkins mkdir -p /var/jenkins_home/.kube
     docker cp ~/.kube/config jenkins:/var/jenkins_home/.kube/config
     ```

6. **Setup GitHub Webhook**:
   - Go to your GitHub repository → Settings → Webhooks
   - Add webhook:
     - Payload URL: `http://<your-jenkins-url>:8080/github-webhook/`
     - Content type: application/json
     - Events: Just the push event

### 6. Create Jenkins Pipeline Job

1. **Create New Job**:
   - Click "New Item"
   - Enter job name: `train-schedule-pipeline`
   - Select "Pipeline"
   - Click OK

2. **Configure Pipeline**:
   - In "Pipeline" section:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: Your forked repository URL
     - Branch: */main (or your default branch)
     - Script Path: Jenkinsfile

3. **Enable GitHub Hook Trigger**:
   - Check "GitHub hook trigger for GITScm polling"

4. **Save Configuration**

### 7. Update Deployment Configuration

```bash
# Update k8s/deployment.yaml with your Docker Hub username
sed -i 's/<your-dockerhub-username>/YOUR_DOCKERHUB_USERNAME/g' k8s/deployment.yaml
```

### 8. Initial Deployment

```bash
# Deploy application manually first time
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployment
kubectl get pods
kubectl get svc
```

### 9. Test the Pipeline

```bash
# Make a change to the application
echo "# Test change" >> README.md

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

Jenkins will automatically:
1. Detect the push via webhook
2. Clone the repository
3. Build the application
4. Create Docker image
5. Push to Docker Hub
6. Deploy to Kubernetes

### 10. Setup Grafana Dashboard

1. **Access Grafana**: http://localhost:30030
2. **Login**: admin/admin (change password on first login)
3. **Add Prometheus Data Source**:
   - Configuration → Data Sources → Add data source
   - Select Prometheus
   - URL: http://prometheus.monitoring:9090
   - Click "Save & Test"

4. **Import Dashboard**:
   - Create → Import
   - Upload `monitoring/grafana-dashboard.json`
   - Select Prometheus data source
   - Click Import

## Accessing Services

### Application
- **Local**: http://localhost:30080
- **Minikube**: `minikube service train-schedule-service`

### Monitoring
- **Prometheus**: http://localhost:30090
- **Grafana**: http://localhost:30030
  - Username: admin
  - Password: admin

### Jenkins
- **URL**: http://localhost:8080

## Pipeline Stages

### 1. Checkout
- Clones code from GitHub repository
- Triggered automatically on push via webhook

### 2. Build
- Installs Node.js dependencies
- Prepares application for Docker build

### 3. Test
- Runs application tests
- Continues even if tests fail (configurable)

### 4. Build Docker Image
- Creates Docker image using Dockerfile
- Tags with build number and 'latest'

### 5. Push to Docker Hub
- Authenticates with Docker Hub
- Pushes both tagged and latest images

### 6. Deploy to Kubernetes
- Updates deployment with new image
- Waits for rollout to complete

### 7. Verify Deployment
- Checks pod status
- Displays service information

## Kubernetes Resources

### Deployment
- **Name**: train-schedule-deployment
- **Replicas**: 2 (initial)
- **Image**: Your Docker Hub image
- **Port**: 8080
- **Resources**:
  - Request: 100m CPU, 128Mi memory
  - Limit: 200m CPU, 256Mi memory

### Service
- **Type**: NodePort
- **Port**: 8080
- **NodePort**: 30080
- **Selector**: app=train-schedule

### HPA (Horizontal Pod Autoscaler)
- **Min Replicas**: 2
- **Max Replicas**: 10
- **Metrics**:
  - CPU: 70% utilization
  - Memory: 80% utilization

## Monitoring Metrics

### Prometheus Targets
- Kubernetes API Server
- Kubernetes Nodes
- Kubernetes Pods
- Train Schedule Application

### Grafana Dashboards
- **Kubernetes Pods Status**: Real-time pod health
- **CPU Usage**: Container CPU consumption
- **Memory Usage**: Container memory usage
- **Deployment Replicas**: Current replica count
- **HTTP Request Rate**: Application traffic
- **Container Restarts**: Stability metrics

## Troubleshooting

### Pipeline Fails at Docker Push
```bash
# Check Docker Hub credentials in Jenkins
# Ensure dockerhub-credentials ID matches in Jenkinsfile
```

### Kubernetes Deployment Fails
```bash
# Check image name in deployment.yaml
kubectl describe deployment train-schedule-deployment

# Check pod logs
kubectl logs -l app=train-schedule
```

### HPA Not Scaling
```bash
# Check metrics server
kubectl top nodes
kubectl top pods

# Install metrics server if missing
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Prometheus Not Scraping Metrics
```bash
# Check Prometheus targets
# Access Prometheus UI → Status → Targets
# Verify ServiceAccount permissions
kubectl get clusterrolebinding prometheus -n monitoring
```

### Grafana Dashboard Empty
```bash
# Verify Prometheus data source
# Check if Prometheus is reachable from Grafana
kubectl exec -it deployment/grafana -n monitoring -- wget -O- http://prometheus.monitoring:9090/api/v1/query?query=up
```

## Automation Scripts

### Setup Script
```bash
# Run complete setup
bash scripts/setup.sh
```

### Deploy Script
```bash
# Deploy application
bash scripts/deploy.sh
```

### Cleanup Script
```bash
# Remove all resources
bash scripts/cleanup.sh
```

## Security Best Practices

1. **Credentials Management**:
   - Store sensitive data in Jenkins credentials
   - Use Kubernetes secrets for sensitive configs
   - Never commit credentials to Git

2. **Image Security**:
   - Scan images for vulnerabilities
   - Use specific image tags (not latest in production)
   - Keep base images updated

3. **Network Security**:
   - Use NetworkPolicies in Kubernetes
   - Restrict ingress/egress traffic
   - Enable TLS for external endpoints

4. **Access Control**:
   - Use RBAC in Kubernetes
   - Limit ServiceAccount permissions
   - Enable authentication in Jenkins

## Business Value

### Reduced Deployment Time
- Manual deployment: 30-60 minutes
- Automated pipeline: 5-10 minutes
- **Time saved**: 80-85%

### Improved Reliability
- Automated testing catches bugs early
- Consistent deployment process
- Easy rollback capabilities

### Enhanced Monitoring
- Real-time visibility into system health
- Proactive issue detection
- Performance optimization insights

### Scalability
- HPA automatically scales based on load
- Infrastructure as Code for easy replication
- Cloud-agnostic design

## Future Enhancements

1. **Multi-Environment Support**:
   - Dev, Staging, Production environments
   - Environment-specific configurations
   - Progressive rollouts

2. **Advanced Testing**:
   - Integration tests
   - Performance tests
   - Security scanning

3. **GitOps**:
   - ArgoCD for declarative deployments
   - Git as single source of truth
   - Automated sync and reconciliation

4. **Service Mesh**:
   - Istio for advanced traffic management
   - Circuit breakers and retries
   - Distributed tracing

## Conclusion

This solution provides a production-ready CI/CD pipeline that:
- ✅ Automates the entire deployment process
- ✅ Reduces time to market for new features
- ✅ Ensures consistent and reliable deployments
- ✅ Provides comprehensive monitoring and observability
- ✅ Scales automatically based on demand
- ✅ Follows DevOps best practices

The pipeline is designed to be maintainable, extensible, and aligned with industry standards for continuous integration and continuous deployment.
