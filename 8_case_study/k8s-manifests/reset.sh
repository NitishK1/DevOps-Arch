# Step 1: Delete everything
kubectl delete -f .

# Step 2: Wait a moment for cleanup
sleep 5

# Step 3: Recreate MongoDB
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-service.yaml

# Step 4: Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongo --timeout=60s

# Step 5: Deploy Employee App
kubectl apply -f employee-deployment.yaml
kubectl apply -f employee-service.yaml

# Step 6: Verify deployment
kubectl get pods
kubectl get services

# Step 7: wait for Employee App to be ready
kubectl wait --for=condition=ready pod -l app=employee-app --timeout=60s

## Step 8: Test the Employee App
kubectl port-forward service/employee-app 8888:8888
