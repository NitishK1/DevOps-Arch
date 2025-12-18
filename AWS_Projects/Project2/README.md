# CI/CD Pipeline for Abstergo Corp - Train Schedule Application

## Project Overview
This project implements a complete CI/CD pipeline with continuous monitoring for
Abstergo Corp's online shopping portal. The solution automates the deployment of
new features from code commit to production using Jenkins, Docker, and
Kubernetes.

## Prerequisites
- GitHub Account
- Jenkins Server
- Docker Hub Account
- Kubernetes Cluster (can use Minikube, Docker Desktop K8s, or cloud provider)
- Prometheus and Grafana for monitoring

## Quick Start

### 1. Fork and Clone the Repository
```bash
# Fork the repository from GitHub
# https://github.com/bhavukm/cicd-pipeline-train-schedule-autodeploy

# Clone your forked repository
git clone https://github.com/<your-username>/cicd-pipeline-train-schedule-autodeploy.git
cd cicd-pipeline-train-schedule-autodeploy
```

### 2. Copy Solution Files
Copy all files from this solution directory to your cloned repository:
- `Dockerfile`
- `Jenkinsfile`
- `k8s/` directory (Kubernetes manifests)
- `monitoring/` directory (Prometheus and Grafana configs)

### 3. Setup Jenkins
1. Install Jenkins plugins:
   - Docker Pipeline
   - Kubernetes CLI
   - Git
2. Configure Docker Hub credentials in Jenkins (ID: `dockerhub-credentials`)
3. Configure Kubernetes config in Jenkins (ID: `kubeconfig`)
4. Create a new Pipeline job pointing to your forked repository

### 4. Setup Kubernetes
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/
```

### 5. Setup Monitoring
```bash
# Deploy Prometheus and Grafana
kubectl apply -f monitoring/
```

## Architecture Components

### CI/CD Pipeline Flow
1. **Developer** commits code to GitHub
2. **Jenkins** automatically triggers build via webhook
3. **Docker** image is built and pushed to Docker Hub
4. **Kubernetes** pulls image and deploys to cluster
5. **Prometheus** monitors all components
6. **Grafana** visualizes metrics

## Next Steps
Refer to `SOLUTION.md` for detailed setup instructions and troubleshooting.
