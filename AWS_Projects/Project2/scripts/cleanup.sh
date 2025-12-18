#!/bin/bash

# Cleanup script for CI/CD Pipeline
echo "======================================"
echo "Cleaning up CI/CD Pipeline resources"
echo "======================================"

# Delete application resources
echo "Deleting application resources..."
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true

# Delete monitoring resources
echo "Deleting monitoring resources..."
kubectl delete -f monitoring/grafana-deployment.yaml --ignore-not-found=true
kubectl delete -f monitoring/prometheus-deployment.yaml --ignore-not-found=true
kubectl delete -f monitoring/namespace.yaml --ignore-not-found=true

echo ""
echo "======================================"
echo "Cleanup completed!"
echo "======================================"
