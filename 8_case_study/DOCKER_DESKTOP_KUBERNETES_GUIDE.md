# Employee Application - Docker Desktop with Kubernetes Deployment Guide

## Overview
This guide provides instructions for deploying the Employee application using
**Docker Desktop** with **kind (Kubernetes in Docker)** instead of Podman. The
application consists of a NodeJS frontend that connects to a MongoDB database,
deployed on a local Kubernetes cluster.

## Prerequisites

### Required Software
- **Docker Desktop** installed and running (version 4.0 or higher)
  - Download from: https://www.docker.com/products/docker-desktop
  - Ensure Docker Desktop is running before proceeding
- **kubectl** (Kubernetes CLI)
  - Included with Docker Desktop
  - Or install via Homebrew: `brew install kubectl`
- **kind** (Kubernetes in Docker)
  - Install via Homebrew: `brew install kind`
  - Or download from: https://kind.sigs.k8s.io/

### System Requirements
- macOS 10.15 or later
- At least 4GB of available RAM
- Ports 8888 and 30888 available
- Docker Desktop configured with at least 4GB memory and 2 CPUs



## Installation Steps

### Step 1: Install Docker Desktop

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Install and launch Docker Desktop
3. Wait for Docker to start (whale icon in menu bar)
4. Verify installation:

```bash
docker --version
docker ps
```

Expected output:
```
Docker version 24.x.x, build xxxxxx
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
```

### Step 2: Install kind

Using Homebrew (recommended):

```bash
brew install kind
```

Or download binary directly:

```bash
# For macOS (Intel)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-darwin-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# For macOS (Apple Silicon)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-darwin-arm64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
```

Verify installation:

```bash
kind version
```

Expected output:
```
kind v0.30.0 go1.21.x darwin/amd64
```

### Step 3: Verify kubectl

```bash
kubectl version --client
```

Expected output:
```
Client Version: v1.29.x
```



## Deployment Instructions

### Step 1: Create Kubernetes Cluster with kind

**Important**: With Docker Desktop, you DON'T need the
`KIND_EXPERIMENTAL_PROVIDER=podman` prefix.

Create a new kind cluster:

```bash
kind create cluster --name employee-cluster
```

Expected output:
```
Creating cluster "employee-cluster" ...
 ✓ Ensuring node image (kindest/node:v1.34.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-employee-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-employee-cluster
```

### Step 2: Verify Cluster

Check cluster info:

```bash
kubectl cluster-info --context kind-employee-cluster
```

Expected output:
```
Kubernetes control plane is running at https://127.0.0.1:xxxxx
CoreDNS is running at https://127.0.0.1:xxxxx/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Check nodes:

```bash
kubectl get nodes
```

Expected output:
```
NAME                             STATUS   ROLES           AGE   VERSION
employee-cluster-control-plane   Ready    control-plane   1m    v1.34.0
```

### Step 3: Navigate to Manifests Directory

```bash
cd /Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/8_case_study/k8s-manifests
```

### Step 4: Deploy MongoDB

Apply MongoDB deployment and service:

```bash
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-service.yaml
```

Expected output:
```
deployment.apps/mongo created
service/mongo created
```

Verify MongoDB is running:

```bash
kubectl get pods -l app=mongo
```

Wait until status shows `Running`:
```
NAME                     READY   STATUS    RESTARTS   AGE
mongo-8658f8766-xxxxx    1/1     Running   0          30s
```

### Step 5: Deploy Employee Application

Apply employee deployment and service:

```bash
kubectl apply -f employee-deployment.yaml
kubectl apply -f employee-service.yaml
```

Expected output:
```
deployment.apps/employee-app created
service/employee-app created
```

### Step 6: Verify Complete Deployment

Check all pods:

```bash
kubectl get pods
```

Expected output:
```
NAME                            READY   STATUS    RESTARTS   AGE
employee-app-6cb8d9778c-xxxxx   1/1     Running   0          45s
mongo-8658f8766-xxxxx           1/1     Running   0          2m
```

Check all services:

```bash
kubectl get services
```

Expected output:
```
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
employee-app   NodePort    10.96.57.125    <none>        8888:30888/TCP   1m
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP          5m
mongo          ClusterIP   10.96.225.118   <none>        27017/TCP        2m
```



## Accessing the Application

### Option 1: Using Port Forwarding (Recommended)

This works reliably across all platforms:

```bash
kubectl port-forward service/employee-app 8888:8888
```

Keep this terminal window open. Access the application at:
```
http://localhost:8888
```

### Option 2: Using NodePort with Docker

Since kind runs in Docker, you need to map the NodePort:

First, find the NodePort assigned (in this case, 30888):

```bash
kubectl get service employee-app
```

Access via Docker container:

```bash
docker exec -it employee-cluster-control-plane curl http://localhost:30888
```

For browser access, you would need to configure kind with extra port mappings
(see Advanced Configuration below).



## Testing the Application

Once you've accessed http://localhost:8888:

### 1. Add an Employee

1. Click on **"Add Employee"** link/page
2. Fill in the employee details:
   - **Name**: John Doe
   - **Email**: john.doe@example.com
   - **Department**: Engineering
   - **Position**: Software Engineer
   - **Salary**: 75000
3. Click **Submit**
4. You should see a success message

### 2. Retrieve Employee Data

1. Navigate to **"Get Employee"** page
2. Search for or view all employees
3. Verify that John Doe appears in the list with correct details

### 3. Verify Database Connectivity

Check application logs:

```bash
kubectl logs -l app=employee-app
```

You should see successful MongoDB connection messages.



## Management Commands

### View Logs

```bash
# Employee app logs
kubectl logs -l app=employee-app

# Follow logs in real-time
kubectl logs -l app=employee-app -f

# MongoDB logs
kubectl logs -l app=mongo
```

### Check Pod Details

```bash
# Detailed pod information
kubectl describe pod -l app=employee-app

# Get pod events
kubectl get events --sort-by='.lastTimestamp'
```

### Scale the Application

```bash
# Scale employee app to 3 replicas
kubectl scale deployment employee-app --replicas=3

# Verify scaling
kubectl get pods -l app=employee-app
```

### Restart Deployments

```bash
# Restart employee app
kubectl rollout restart deployment employee-app

# Restart MongoDB
kubectl rollout restart deployment mongo
```

### Access MongoDB Shell

```bash
# Get MongoDB pod name
kubectl get pods -l app=mongo

# Connect to MongoDB shell
kubectl exec -it <mongo-pod-name> -- mongosh employeedb
```



## Troubleshooting

### Issue: Docker Desktop Not Running

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
1. Launch Docker Desktop application
2. Wait for Docker to fully start (whale icon stops animating)
3. Try the command again

### Issue: kind Cluster Won't Create

**Error**: `ERROR: failed to create cluster`

**Solution**:
```bash
# Check Docker is running
docker ps

# Delete any existing cluster
kind delete cluster --name employee-cluster

# Create fresh cluster
kind create cluster --name employee-cluster
```

### Issue: Pods Stuck in "Pending" or "ContainerCreating"

**Check**:
```bash
kubectl describe pod <pod-name>
```

**Common Solutions**:
```bash
# Pull images manually
docker pull mongo:5.0
docker pull devopsedu/employee:latest

# Load images into kind cluster
kind load docker-image mongo:5.0 --name employee-cluster
kind load docker-image devopsedu/employee:latest --name employee-cluster
```

### Issue: Cannot Access Application

**Solution**:
```bash
# Stop any existing port-forward
# Press Ctrl+C in the terminal running port-forward

# Start new port-forward
kubectl port-forward service/employee-app 8888:8888

# Access http://localhost:8888
```

### Issue: Port Already in Use

**Error**: `bind: address already in use`

**Solution**:
```bash
# Find process using port 8888
lsof -i :8888

# Kill the process
kill -9 <PID>

# Or use different port
kubectl port-forward service/employee-app 8889:8888
# Then access http://localhost:8889
```



## Cleanup

### Stop Port Forwarding

Press `Ctrl+C` in the terminal running port-forward.

### Delete Kubernetes Resources

```bash
# Delete all resources
kubectl delete -f employee-service.yaml
kubectl delete -f employee-deployment.yaml
kubectl delete -f mongo-service.yaml
kubectl delete -f mongo-deployment.yaml
```

Or delete everything at once:

```bash
cd /Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/8_case_study/k8s-manifests
kubectl delete -f .
```

### Delete kind Cluster

```bash
kind delete cluster --name employee-cluster
```

Expected output:
```
Deleting cluster "employee-cluster" ...
Deleted nodes: ["employee-cluster-control-plane"]
```

### Verify Cleanup

```bash
# Check no kind clusters exist
kind get clusters

# Check no containers running
docker ps
```



## Advanced Configuration

### Creating kind Cluster with Port Mapping

If you want to access NodePort services directly without port-forwarding, create
a custom kind configuration:

Create `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: employee-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30888
    hostPort: 8888
    protocol: TCP
```

Create cluster with this config:

```bash
kind create cluster --config kind-config.yaml
```

Now you can access the application directly at `http://localhost:8888` without
port-forwarding.

### Pre-loading Docker Images

To avoid pulling images during deployment:

```bash
# Pull images locally
docker pull mongo:5.0
docker pull devopsedu/employee:latest

# Load into kind cluster
kind load docker-image mongo:5.0 --name employee-cluster
kind load docker-image devopsedu/employee:latest --name employee-cluster
```



## Key Differences from Podman Setup

| Aspect | Podman (Original) | Docker Desktop (This Guide) |
|--------|-------------------|----------------------------|
| Provider Variable | `KIND_EXPERIMENTAL_PROVIDER=podman` | Not needed (uses Docker) |
| kind Command | `KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster` | `kind create cluster` |
| Container Runtime | Podman | Docker Engine |
| GUI Available | No | Yes (Docker Desktop) |
| Resource Management | Manual | Via Docker Desktop preferences |
| Kubernetes Option | kind only | kind or Docker Desktop's built-in K8s |



## Alternative: Docker Desktop's Built-in Kubernetes

Docker Desktop includes its own Kubernetes option. To use it:

1. Open Docker Desktop
2. Go to **Settings** → **Kubernetes**
3. Check **"Enable Kubernetes"**
4. Click **"Apply & Restart"**
5. Wait for Kubernetes to start

Then deploy using the same manifests:

```bash
# Switch context to docker-desktop
kubectl config use-context docker-desktop

# Deploy application
cd /Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/8_case_study/k8s-manifests
kubectl apply -f .

# Access application
kubectl port-forward service/employee-app 8888:8888
```

**Advantages**:
- Simpler setup (no kind needed)
- Integrated with Docker Desktop UI
- Better resource management

**Disadvantages**:
- Only one cluster at a time
- Less flexible for testing multiple cluster scenarios
- Uses more system resources when not needed



## Quick Reference

```bash
# Create kind cluster
kind create cluster --name employee-cluster

# Verify cluster
kubectl cluster-info
kubectl get nodes

# Deploy application
cd /Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/8_case_study/k8s-manifests
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-service.yaml
kubectl apply -f employee-deployment.yaml
kubectl apply -f employee-service.yaml

# Verify deployment
kubectl get pods
kubectl get services

# Access application
kubectl port-forward service/employee-app 8888:8888
# Open http://localhost:8888

# View logs
kubectl logs -l app=employee-app -f

# Cleanup
kubectl delete -f .
kind delete cluster --name employee-cluster
```



## Additional Resources

- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Documentation](https://kubernetes.io/)



## Support

For issues specific to:
- **Docker Desktop**: Check Docker Desktop logs in the app
- **kind**: Run `kind --help` or visit https://kind.sigs.k8s.io/
- **kubectl**: Run `kubectl --help` or visit
  https://kubernetes.io/docs/reference/kubectl/



*Last Updated: December 9, 2025* *Environment: macOS with Docker Desktop*
