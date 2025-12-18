#!/bin/bash

# Setup script for CI/CD Pipeline
echo "======================================"
echo "Setting up CI/CD Pipeline for Abstergo Corp"
echo "======================================"

# Check prerequisites
echo "Checking prerequisites..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed. Please install Docker first."
    exit 1
fi

echo "Prerequisites check passed!"

# Create monitoring namespace
echo "Creating monitoring namespace..."
kubectl apply -f monitoring/namespace.yaml

# Deploy Prometheus
echo "Deploying Prometheus..."
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy Grafana
echo "Deploying Grafana..."
kubectl apply -f monitoring/grafana-deployment.yaml

# Wait for monitoring stack to be ready
echo "Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Deploy application
echo "Deploying Train Schedule application..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Wait for application to be ready
echo "Waiting for application to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/train-schedule-deployment

echo ""
echo "======================================"
echo "Setup completed successfully!"
echo "======================================"
echo ""
echo "Access URLs:"
echo "- Application: http://localhost:30080"
echo "- Prometheus: http://localhost:30090"
echo "- Grafana: http://localhost:30030 (admin/admin)"
echo ""
echo "Next steps:"
echo "1. Configure Jenkins with GitHub webhook"
echo "2. Add Docker Hub credentials to Jenkins"
echo "3. Configure kubectl in Jenkins"
echo "4. Create Jenkins pipeline job"
echo ""
