# Kubernetes Assignment - Employee Application Deployment

## Problem Statement
Deploy a multi-tier NodeJS application (devopsedu/employee) with MongoDB
database on a Kubernetes cluster.

## Environment Setup
- **Cluster**: kind (Kubernetes in Docker) with podman provider
- **Cluster Name**: k8s-assignment
- **Kubernetes Version**: v1.34.0

## Solution Overview

### 1. Created Kubernetes Cluster
```bash
KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name k8s-assignment
```

### 2. Kubernetes Resources Created

#### MongoDB Deployment (`mongo-deployment.yaml`)
- Name: `mongo`
- Image: `mongo:5.0`
- Port: 27017
- Database: employeedb

#### MongoDB Service (`mongo-service.yaml`)
- Name: `mongo`
- Type: ClusterIP
- Port: 27017

#### Employee App Deployment (`employee-deployment.yaml`)
- Name: `employee-app`
- Image: `devopsedu/employee:latest`
- Port: 8888
- Environment Variables:
  - MONGO_HOST: mongo
  - MONGO_PORT: 27017

#### Employee App Service (`employee-service.yaml`)
- Name: `employee-app`
- Type: NodePort
- Port: 8888
- NodePort: 30888

### 3. Deployment Commands

All manifests are located in:
`/Users/C177341/Local_Mac/Edureka_DevOps_Arch_Training/8_case_study/k8s-manifests/`

```bash
# Deploy MongoDB
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-service.yaml

# Deploy Employee App
kubectl apply -f employee-deployment.yaml
kubectl apply -f employee-service.yaml
```

### 4. Verify Deployment

```bash
# Check pods
kubectl get pods

# Expected output:
# NAME                            READY   STATUS    RESTARTS   AGE
# employee-app-6cb8d9778c-t4r5l   1/1     Running   0          2m57s
# mongo-8658f8766-8k2gl           1/1     Running   0          4s

# Check services
kubectl get services

# Expected output:
# NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# employee-app   NodePort    10.96.57.125    <none>        8888:30888/TCP   2m53s
# mongo          ClusterIP   10.96.225.118   <none>        27017/TCP        3m13s
```

### 5. Access the Application

Since kind runs in podman, use port-forward to access the application:

```bash
kubectl port-forward service/employee-app 8888:8888
```

Then access the application at: http://localhost:8888

### 6. Testing the Application

1. Open http://localhost:8888 in your browser
2. Navigate to "Add Employee" page
3. Fill in employee details and submit
4. Navigate to "Get Employee" page
5. Verify your employee data is displayed

## Important Notes for kind with Podman

Due to TLS certificate issues with Docker Hub when using kind+podman, the mongo
image was pulled manually:

```bash
# Pull image with TLS verification disabled
podman pull --tls-verify=false docker.io/library/mongo:5.0

# Save image to tar
podman save -o /tmp/mongo-5.0.tar docker.io/library/mongo:5.0

# Load into kind cluster
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive /tmp/mongo-5.0.tar --name k8s-assignment
```

## Cleanup

To delete the cluster when done:
```bash
KIND_EXPERIMENTAL_PROVIDER=podman kind delete cluster --name k8s-assignment
```

## Key Requirements Met ✓

- [x] NodeJS application deployed on port 8888
- [x] MongoDB deployed on port 27017
- [x] MongoDB service and deployment named "mongo"
- [x] Application can connect to MongoDB
- [x] Deployed using kubectl CLI
- [x] Application accessible and functional
- [x] Can add and retrieve employee data
