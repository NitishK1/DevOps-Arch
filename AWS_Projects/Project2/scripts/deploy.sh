#!/bin/bash

# Deploy script for CI/CD Pipeline
echo "======================================"
echo "Deploying Train Schedule Application"
echo "======================================"

# Get Docker Hub username
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME

# Update deployment file with Docker Hub username
echo "Updating deployment with your Docker Hub username..."
sed -i "s/<your-dockerhub-username>/${DOCKERHUB_USERNAME}/g" k8s/deployment.yaml

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Check deployment status
echo "Checking deployment status..."
kubectl rollout status deployment/train-schedule-deployment

# Display service information
echo ""
echo "======================================"
echo "Deployment completed!"
echo "======================================"
echo ""
kubectl get pods -l app=train-schedule
echo ""
kubectl get svc train-schedule-service
echo ""
echo "Application is accessible at: http://localhost:30080"
echo ""
