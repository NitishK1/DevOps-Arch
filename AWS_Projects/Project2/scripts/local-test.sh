#!/bin/bash

# Local Testing Script for Windows with Docker Desktop Kubernetes
echo "======================================"
echo "Testing CI/CD Solution Locally"
echo "======================================"

# Set your Docker Hub username
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "Error: Docker Hub username is required"
    exit 1
fi

echo ""
echo "Step 1: Cloning the train-schedule application..."
echo "------------------------------------------------"
if [ ! -d "train-schedule-app" ]; then
    git clone https://github.com/bhavukm/cicd-pipeline-train-schedule-autodeploy.git train-schedule-app
    cd train-schedule-app
else
    cd train-schedule-app
    git pull
fi

# Copy solution files
echo ""
echo "Step 2: Copying solution files..."
echo "------------------------------------------------"
cp ../Dockerfile .
cp ../Jenkinsfile .
mkdir -p k8s monitoring scripts
cp ../k8s/* k8s/ 2>/dev/null || true
cp ../monitoring/* monitoring/ 2>/dev/null || true
cp ../scripts/* scripts/ 2>/dev/null || true

# Update deployment with Docker Hub username
echo ""
echo "Step 3: Updating Kubernetes manifests..."
echo "------------------------------------------------"
sed -i "s/<your-dockerhub-username>/${DOCKERHUB_USERNAME}/g" k8s/deployment.yaml

echo ""
echo "Step 4: Building Docker image..."
echo "------------------------------------------------"
docker build -t ${DOCKERHUB_USERNAME}/train-schedule:local .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

echo ""
echo "Step 5: Testing Docker container locally..."
echo "------------------------------------------------"
echo "Starting container on port 8080..."
docker run -d --name train-schedule-test -p 8080:8080 ${DOCKERHUB_USERNAME}/train-schedule:local

# Wait for container to start
sleep 5

# Test the application
echo "Testing application..."
curl -s http://localhost:8080 > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ Application is running successfully!"
    echo "✓ Access it at: http://localhost:8080"
else
    echo "✗ Application test failed"
fi

echo ""
echo "Step 6: Setting up Kubernetes..."
echo "------------------------------------------------"

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy monitoring stack
echo "Deploying Prometheus..."
kubectl apply -f ../monitoring/prometheus-deployment.yaml

echo "Deploying Grafana..."
kubectl apply -f ../monitoring/grafana-deployment.yaml

# Deploy application to Kubernetes
echo ""
echo "Step 7: Deploying to Kubernetes..."
echo "------------------------------------------------"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Wait for deployments
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/train-schedule-deployment 2>/dev/null || echo "Deployment may take a bit longer..."
kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n monitoring 2>/dev/null || echo "Prometheus may take a bit longer..."
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n monitoring 2>/dev/null || echo "Grafana may take a bit longer..."

echo ""
echo "======================================"
echo "✓ Local Testing Setup Complete!"
echo "======================================"
echo ""
echo "Access URLs:"
echo "----------------------------------------"
echo "Application (Docker):    http://localhost:8080"
echo "Application (K8s):       http://localhost:30080"
echo "Prometheus:              http://localhost:30090"
echo "Grafana:                 http://localhost:30030"
echo "  - Username: admin"
echo "  - Password: admin"
echo ""
echo "Useful Commands:"
echo "----------------------------------------"
echo "Check pods:              kubectl get pods -A"
echo "Check services:          kubectl get svc -A"
echo "View app logs:           kubectl logs -l app=train-schedule"
echo "Stop Docker test:        docker stop train-schedule-test && docker rm train-schedule-test"
echo ""
echo "Next Steps:"
echo "----------------------------------------"
echo "1. Open http://localhost:8080 to see the app"
echo "2. Set up Jenkins for the full CI/CD pipeline"
echo "3. Configure GitHub webhook for automatic builds"
echo ""
