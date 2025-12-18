#!/bin/bash

# Quick Local Test Script for Abstergo Corp Website
echo "======================================"
echo "Testing Abstergo Corp Website Locally"
echo "======================================"

# Navigate to Project2 directory
cd "$(dirname "$0")/.."
PROJECT_DIR=$(pwd)

echo "Project directory: $PROJECT_DIR"

# Check if app submodule exists
if [ ! -d "app/website" ]; then
    echo "Error: app/website directory not found"
    echo "Please ensure the submodule is initialized"
    exit 1
fi

# Get Docker Hub username
read -p "Enter your Docker Hub username (or press Enter to skip pushing to Docker Hub): " DOCKERHUB_USERNAME

if [ -z "$DOCKERHUB_USERNAME" ]; then
    DOCKERHUB_USERNAME="local"
    echo "Using 'local' as image name (won't push to Docker Hub)"
fi

IMAGE_NAME="${DOCKERHUB_USERNAME}/abstergo-website:latest"

echo ""
echo "Step 1: Building Docker image..."
echo "------------------------------------------------"
docker build -t ${IMAGE_NAME} .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

echo ""
echo "✓ Docker image built successfully!"

echo ""
echo "Step 2: Testing with Docker..."
echo "------------------------------------------------"

# Stop and remove existing container if it exists
docker stop abstergo-website 2>/dev/null
docker rm abstergo-website 2>/dev/null

# Run container
docker run -d --name abstergo-website -p 8080:80 ${IMAGE_NAME}

if [ $? -ne 0 ]; then
    echo "Error: Failed to start Docker container"
    exit 1
fi

# Wait for container to start
echo "Waiting for container to start..."
sleep 3

# Test the application
echo "Testing application..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Application is running successfully!"
    echo ""
    echo "======================================"
    echo "Docker Test Successful!"
    echo "======================================"
    echo ""
    echo "Access the website at: http://localhost:8080"
    echo ""
    echo "To view logs: docker logs abstergo-website"
    echo "To stop: docker stop abstergo-website"
    echo ""
else
    echo "✗ Application returned HTTP code: $HTTP_CODE"
    echo "Checking container logs..."
    docker logs abstergo-website
fi

# Ask if user wants to deploy to Kubernetes
echo ""
read -p "Do you want to deploy to Kubernetes? (y/n): " DEPLOY_K8S

if [ "$DEPLOY_K8S" = "y" ] || [ "$DEPLOY_K8S" = "Y" ]; then
    echo ""
    echo "Step 3: Deploying to Kubernetes..."
    echo "------------------------------------------------"

    # Update deployment.yaml with Docker Hub username
    if [ "$DOCKERHUB_USERNAME" != "local" ]; then
        sed -i "s/<your-dockerhub-username>/${DOCKERHUB_USERNAME}/g" k8s/deployment.yaml
    else
        # For local testing, use the local image
        sed -i "s|<your-dockerhub-username>/abstergo-website:latest|${IMAGE_NAME}|g" k8s/deployment.yaml
        # Add imagePullPolicy: Never for local images
        if ! grep -q "imagePullPolicy" k8s/deployment.yaml; then
            sed -i 's|image:.*|&\n        imagePullPolicy: Never|' k8s/deployment.yaml
        fi
    fi

    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

    # Apply Kubernetes manifests
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml
    kubectl apply -f k8s/hpa.yaml

    # Deploy monitoring
    echo "Deploying monitoring stack..."
    kubectl apply -f monitoring/prometheus-deployment.yaml
    kubectl apply -f monitoring/grafana-deployment.yaml

    # Wait for deployment
    echo "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/abstergo-website-deployment 2>/dev/null || echo "Note: Deployment may take a bit longer..."

    echo ""
    echo "======================================"
    echo "✓ Kubernetes Deployment Complete!"
    echo "======================================"
    echo ""
    echo "Access URLs:"
    echo "  - Website (Docker):  http://localhost:8080"
    echo "  - Website (K8s):     http://localhost:30080"
    echo "  - Prometheus:        http://localhost:30090"
    echo "  - Grafana:           http://localhost:30030 (admin/admin)"
    echo ""
    echo "Check status:"
    echo "  kubectl get pods"
    echo "  kubectl get svc"
    echo "  kubectl logs -l app=abstergo-website"
    echo ""
fi

echo "======================================"
echo "Testing Complete!"
echo "======================================"
