#!/bin/bash

# Quickstart Script for Abstergo Corp CI/CD Pipeline Project
# This script handles complete setup, testing, and cleanup

set -e  # Exit on error

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
====================================
Abstergo Corp CI/CD Quickstart
====================================

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  setup       Setup and deploy everything (Docker + Kubernetes + Monitoring)
  deploy      Deploy only to Kubernetes (assumes Docker image exists)
  cleanup     Remove all resources (Docker containers, K8s resources)
  status      Show status of all resources
  help        Show this help message

Options:
  --skip-docker     Skip Docker build and container (for deploy command)
  --docker-only     Only build and run Docker container
  --k8s-only        Only deploy to Kubernetes

Examples:
  $0 setup                    # Full setup
  $0 setup --docker-only      # Only Docker
  $0 deploy                   # Deploy to K8s
  $0 cleanup                  # Remove everything
  $0 status                   # Check status

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing=0
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        missing=1
    else
        print_info "✓ Docker found: $(docker --version)"
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        missing=1
    else
        print_info "✓ kubectl found"
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Kubernetes cluster is not running"
        print_info "Please start Docker Desktop Kubernetes"
        missing=1
    else
        print_info "✓ Kubernetes cluster is running"
    fi
    
    if [ ! -d "app/website" ]; then
        print_error "Application submodule not found"
        print_info "Initializing submodule..."
        git submodule update --init --recursive
    else
        print_info "✓ Application submodule found"
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Prerequisites check failed. Please install missing components."
        exit 1
    fi
    
    print_info "All prerequisites satisfied!"
}

# Function to build Docker image
build_docker_image() {
    print_info "Building Docker image..."
    
    read -p "Enter your Docker Hub username (or press Enter for 'local'): " DOCKERHUB_USERNAME
    
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        DOCKERHUB_USERNAME="local"
        IMAGE_NAME="abstergo-website:local"
    else
        IMAGE_NAME="${DOCKERHUB_USERNAME}/abstergo-website:latest"
    fi
    
    docker build -t "$IMAGE_NAME" .
    
    if [ $? -eq 0 ]; then
        print_info "✓ Docker image built successfully: $IMAGE_NAME"
        echo "$IMAGE_NAME" > .image-name
        echo "$DOCKERHUB_USERNAME" > .dockerhub-username
    else
        print_error "Docker build failed"
        exit 1
    fi
}

# Function to run Docker container
run_docker_container() {
    print_info "Starting Docker container..."
    
    # Stop and remove existing container if it exists
    if docker ps -a | grep -q abstergo-website; then
        print_warning "Stopping existing container..."
        docker stop abstergo-website 2>/dev/null || true
        docker rm abstergo-website 2>/dev/null || true
    fi
    
    IMAGE_NAME=$(cat .image-name 2>/dev/null || echo "abstergo-website:local")
    
    docker run -d --name abstergo-website -p 8080:80 "$IMAGE_NAME"
    
    if [ $? -eq 0 ]; then
        print_info "✓ Docker container started on port 8080"
        sleep 3
        
        # Test the application
        if curl -s http://localhost:8080 > /dev/null; then
            print_info "✓ Application is accessible at http://localhost:8080"
        else
            print_warning "Application may not be ready yet, check: docker logs abstergo-website"
        fi
    else
        print_error "Failed to start Docker container"
        exit 1
    fi
}

# Function to deploy to Kubernetes
deploy_to_kubernetes() {
    print_info "Deploying to Kubernetes..."
    
    # Get Docker Hub username
    if [ -f .dockerhub-username ]; then
        DOCKERHUB_USERNAME=$(cat .dockerhub-username)
    else
        DOCKERHUB_USERNAME="local"
    fi
    
    # Update deployment.yaml with correct image
    if [ "$DOCKERHUB_USERNAME" = "local" ]; then
        IMAGE_NAME="abstergo-website:local"
        PULL_POLICY="IfNotPresent"
    else
        IMAGE_NAME="${DOCKERHUB_USERNAME}/abstergo-website:latest"
        PULL_POLICY="Always"
    fi
    
    # Create temporary deployment file
    cat k8s/deployment.yaml | \
        sed "s|image:.*|image: $IMAGE_NAME|g" | \
        sed "s|imagePullPolicy:.*|imagePullPolicy: $PULL_POLICY|g" > k8s/deployment.yaml.tmp
    
    mv k8s/deployment.yaml.tmp k8s/deployment.yaml
    
    # Apply Kubernetes manifests
    print_info "Applying application manifests..."
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml
    kubectl apply -f k8s/hpa.yaml
    
    print_info "Waiting for pods to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/abstergo-website-deployment 2>/dev/null || \
        print_warning "Deployment may take longer, check with: kubectl get pods"
    
    print_info "✓ Application deployed to Kubernetes"
}

# Function to deploy monitoring stack
deploy_monitoring() {
    print_info "Deploying monitoring stack..."
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy Prometheus
    print_info "Deploying Prometheus..."
    kubectl apply -f monitoring/prometheus-deployment.yaml
    
    # Deploy Grafana
    print_info "Deploying Grafana..."
    kubectl apply -f monitoring/grafana-deployment.yaml
    
    print_info "Waiting for monitoring stack to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n monitoring 2>/dev/null || \
        print_warning "Prometheus may take longer to start"
    kubectl wait --for=condition=available --timeout=120s deployment/grafana -n monitoring 2>/dev/null || \
        print_warning "Grafana may take longer to start"
    
    print_info "✓ Monitoring stack deployed"
}

# Function to cleanup all resources
cleanup_all() {
    print_info "Cleaning up all resources..."
    
    # Stop and remove Docker container
    print_info "Stopping Docker container..."
    docker stop abstergo-website 2>/dev/null || true
    docker rm abstergo-website 2>/dev/null || true
    
    # Delete Kubernetes resources
    print_info "Deleting Kubernetes resources..."
    kubectl delete -f k8s/hpa.yaml --ignore-not-found=true 2>/dev/null || true
    kubectl delete -f k8s/service.yaml --ignore-not-found=true 2>/dev/null || true
    kubectl delete -f k8s/deployment.yaml --ignore-not-found=true 2>/dev/null || true
    
    # Delete monitoring resources
    print_info "Deleting monitoring resources..."
    kubectl delete -f monitoring/grafana-deployment.yaml --ignore-not-found=true 2>/dev/null || true
    kubectl delete -f monitoring/prometheus-deployment.yaml --ignore-not-found=true 2>/dev/null || true
    kubectl delete namespace monitoring --ignore-not-found=true 2>/dev/null || true
    
    # Clean up temporary files
    rm -f .image-name .dockerhub-username
    
    print_info "✓ Cleanup completed!"
    
    # Optional: Remove Docker images
    echo ""
    read -p "Do you want to remove Docker images as well? (y/N): " REMOVE_IMAGES
    if [ "$REMOVE_IMAGES" = "y" ] || [ "$REMOVE_IMAGES" = "Y" ]; then
        print_info "Removing Docker images..."
        docker rmi abstergo-website:local 2>/dev/null || true
        docker rmi $(docker images | grep abstergo-website | awk '{print $3}') 2>/dev/null || true
        print_info "✓ Docker images removed"
    fi
}

# Function to show status
show_status() {
    echo ""
    echo "======================================"
    echo "Current Status"
    echo "======================================"
    echo ""
    
    # Docker container status
    echo "Docker Container:"
    echo "----------------"
    if docker ps | grep -q abstergo-website; then
        print_info "✓ Running on port 8080"
        echo "  Access: http://localhost:8080"
    else
        print_warning "✗ Not running"
    fi
    echo ""
    
    # Kubernetes application status
    echo "Kubernetes Application:"
    echo "----------------------"
    if kubectl get deployment abstergo-website-deployment &>/dev/null; then
        kubectl get pods -l app=abstergo-website
        echo ""
        kubectl get svc abstergo-website-service
        echo ""
        echo "Port-forward to access: kubectl port-forward svc/abstergo-website-service 8081:80"
    else
        print_warning "✗ Not deployed"
    fi
    echo ""
    
    # Monitoring status
    echo "Monitoring Stack:"
    echo "----------------"
    if kubectl get namespace monitoring &>/dev/null; then
        kubectl get pods -n monitoring
        echo ""
        echo "Access Prometheus: kubectl port-forward -n monitoring svc/prometheus 9090:9090"
        echo "Access Grafana:    kubectl port-forward -n monitoring svc/grafana 3000:3000"
    else
        print_warning "✗ Not deployed"
    fi
    echo ""
    
    # HPA status
    echo "Horizontal Pod Autoscaler:"
    echo "-------------------------"
    if kubectl get hpa abstergo-website-hpa &>/dev/null; then
        kubectl get hpa abstergo-website-hpa
    else
        print_warning "✗ Not configured"
    fi
    echo ""
}

# Function to display access information
show_access_info() {
    echo ""
    echo "======================================"
    echo "✓ Setup Complete!"
    echo "======================================"
    echo ""
    echo "Access URLs:"
    echo "------------"
    echo "• Website (Docker):  http://localhost:8080"
    echo ""
    echo "• Website (K8s):     kubectl port-forward svc/abstergo-website-service 8081:80"
    echo "                     Then: http://localhost:8081"
    echo ""
    echo "• Prometheus:        kubectl port-forward -n monitoring svc/prometheus 9090:9090"
    echo "                     Then: http://localhost:9090"
    echo ""
    echo "• Grafana:           kubectl port-forward -n monitoring svc/grafana 3000:3000"
    echo "                     Then: http://localhost:3000 (admin/admin)"
    echo ""
    echo "Useful Commands:"
    echo "---------------"
    echo "• Check status:      $0 status"
    echo "• View pods:         kubectl get pods -A"
    echo "• View logs:         kubectl logs -l app=abstergo-website"
    echo "• Cleanup:           $0 cleanup"
    echo ""
}

# Main script logic
main() {
    COMMAND=${1:-help}
    SKIP_DOCKER=false
    DOCKER_ONLY=false
    K8S_ONLY=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --docker-only)
                DOCKER_ONLY=true
                shift
                ;;
            --k8s-only)
                K8S_ONLY=true
                shift
                ;;
        esac
    done
    
    case $COMMAND in
        setup)
            echo "======================================"
            echo "Abstergo Corp CI/CD Pipeline Setup"
            echo "======================================"
            echo ""
            
            check_prerequisites
            echo ""
            
            if [ "$K8S_ONLY" = false ]; then
                build_docker_image
                echo ""
                run_docker_container
                echo ""
            fi
            
            if [ "$DOCKER_ONLY" = false ]; then
                deploy_to_kubernetes
                echo ""
                deploy_monitoring
                echo ""
            fi
            
            show_access_info
            ;;
            
        deploy)
            echo "======================================"
            echo "Deploying to Kubernetes"
            echo "======================================"
            echo ""
            
            check_prerequisites
            echo ""
            
            if [ "$SKIP_DOCKER" = false ]; then
                if [ ! -f .image-name ]; then
                    build_docker_image
                    echo ""
                fi
            fi
            
            deploy_to_kubernetes
            echo ""
            deploy_monitoring
            echo ""
            
            show_access_info
            ;;
            
        cleanup)
            echo "======================================"
            echo "Cleaning Up Resources"
            echo "======================================"
            echo ""
            
            cleanup_all
            echo ""
            ;;
            
        status)
            show_status
            ;;
            
        help|--help|-h)
            show_usage
            ;;
            
        *)
            print_error "Unknown command: $COMMAND"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
