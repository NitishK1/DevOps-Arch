# Jenkins Setup Guide for Abstergo Corp CI/CD Pipeline

## Issue: Kubernetes Authentication Failed

The pipeline is failing because Jenkins cannot access your Kubernetes cluster.
Here's how to fix it:

## Solution Options

### Option 1: Run Jenkins with kubectl Access (Recommended for Local Testing)

1. **Stop Jenkins service**:
   ```cmd
   # If running as Windows service
   net stop jenkins

   # If running in Docker
   docker stop jenkins
   ```

2. **Copy kubectl config to Jenkins**:
   ```cmd
   # Create Jenkins .kube directory
   mkdir C:\ProgramData\Jenkins\.jenkins\.kube

   # Copy your kubeconfig
   copy %USERPROFILE%\.kube\config C:\ProgramData\Jenkins\.jenkins\.kube\config
   ```

3. **Restart Jenkins**:
   ```cmd
   # If running as Windows service
   net start jenkins

   # If running in Docker
   docker start jenkins
   ```

### Option 2: Configure kubectl in Jenkins Pipeline (Recommended for Production)

Add this to your Jenkinsfile before kubectl commands:

```groovy
withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
    // Your kubectl commands here
}
```

**Setup Steps:**

1. **Add kubeconfig as Jenkins credential**:
   - Go to Jenkins → Manage Jenkins → Credentials
   - Add new credential:
     - Kind: Secret file
     - File: Upload your `%USERPROFILE%\.kube\config`
     - ID: `kubeconfig-credentials`

2. **Install Kubernetes CLI Plugin**:
   - Go to Jenkins → Manage Jenkins → Plugins
   - Install "Kubernetes CLI" plugin

3. **Update Jenkinsfile** (see example below)

### Option 3: Skip Kubernetes Deployment (For Docker-only Testing)

Comment out the Kubernetes stages in Jenkinsfile:

```groovy
// stage('Deploy to Kubernetes') { ... }
// stage('Verify Deployment') { ... }
```

## Updated Jenkinsfile with Kubernetes Authentication

```groovy
stage('Deploy to Kubernetes') {
    steps {
        echo 'Deploying to Kubernetes cluster...'
        script {
            dir("${WORKSPACE_PATH}") {
                def dockerhubUsername = env.DOCKERHUB_USERNAME ?: 'local'

                // Use kubeconfig credential
                withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
                    if (isUnix()) {
                        sh """
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl apply -f k8s/hpa.yaml
                            kubectl rollout status deployment/abstergo-website-deployment --timeout=2m
                        """
                    } else {
                        bat """
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl apply -f k8s/hpa.yaml
                            kubectl rollout status deployment/abstergo-website-deployment --timeout=2m
                        """
                    }
                }
            }
        }
    }
}
```

## Verification Steps

After configuration, test kubectl access:

1. **From Jenkins Pipeline**:
   ```groovy
   stage('Test Kubernetes Connection') {
       steps {
           script {
               if (isUnix()) {
                   sh 'kubectl cluster-info'
                   sh 'kubectl get nodes'
               } else {
                   bat 'kubectl cluster-info'
                   bat 'kubectl get nodes'
               }
           }
       }
   }
   ```

2. **From Jenkins System Groovy Script Console**:
   - Go to Jenkins → Manage Jenkins → Script Console
   - Run:
   ```groovy
   def proc = "kubectl cluster-info".execute()
   proc.waitFor()
   println proc.text
   ```

## Common Issues and Solutions

### Issue: "Authentication required"
**Cause**: Jenkins doesn't have kubectl configured **Solution**: Use Option 1 or
Option 2 above

### Issue: "kubectl: command not found"
**Cause**: kubectl not installed on Jenkins server **Solution**: Install kubectl
on Windows:
```cmd
# Using Chocolatey
choco install kubernetes-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Issue: "The system cannot find the file specified"
**Cause**: Using `sh` command on Windows Jenkins **Solution**: Already fixed in
updated Jenkinsfile (uses `bat` for Windows)

### Issue: "Error from server (Forbidden)"
**Cause**: kubeconfig pointing to wrong cluster or expired credentials
**Solution**:
```cmd
# Verify your kubectl works locally
kubectl cluster-info
kubectl get nodes

# If working, copy config to Jenkins as shown in Option 1
```

## Quick Test Without Kubernetes

To test the pipeline without Kubernetes deployment:

1. **Create a simplified Jenkinsfile**:
   ```groovy
   pipeline {
       agent any

       environment {
           IMAGE_NAME = "abstergo-website"
           IMAGE_TAG = "${env.BUILD_NUMBER}"
           WORKSPACE_PATH = "AWS_Projects/Project2"
       }

       stages {
           stage('Checkout') {
               steps {
                   checkout scm
                   script {
                       if (isUnix()) {
                           sh 'git submodule update --init --recursive'
                       } else {
                           bat 'git submodule update --init --recursive'
                       }
                   }
               }
           }

           stage('Build Docker Image') {
               steps {
                   script {
                       dir("${WORKSPACE_PATH}") {
                           if (isUnix()) {
                               sh "docker build -t local/${IMAGE_NAME}:${IMAGE_TAG} ."
                           } else {
                               bat "docker build -t local/${IMAGE_NAME}:${IMAGE_TAG} ."
                           }
                       }
                   }
               }
           }

           stage('Test Docker Image') {
               steps {
                   script {
                       if (isUnix()) {
                           sh "docker images | grep ${IMAGE_NAME}"
                       } else {
                           bat "docker images | findstr ${IMAGE_NAME}"
                       }
                   }
               }
           }
       }
   }
   ```

## Next Steps

1. ✅ Fix Kubernetes authentication using one of the options above
2. ✅ Test kubectl access from Jenkins
3. ✅ Run pipeline again
4. ✅ Verify deployment with `kubectl get pods`

## Support

If issues persist, check:
- Jenkins logs: `C:\ProgramData\Jenkins\.jenkins\logs\`
- Kubernetes logs: `kubectl get events`
- Docker logs: `docker logs <container-id>`
