# Deployment Checklist

Use this checklist to ensure smooth deployment and cleanup of your AWS
infrastructure.

## 📋 Pre-Deployment Checklist

### Prerequisites
- [ ] Terraform installed (>= 1.0)
- [ ] AWS CLI installed (>= 2.0)
- [ ] Docker installed and running
- [ ] Git installed
- [ ] AWS account credentials ready
- [ ] Email address for notifications ready

### Verification
```bash
# Verify installations
terraform --version
aws --version
docker --version
git --version
```

### AWS Account Preparation
- [ ] AWS Access Key ID available
- [ ] AWS Secret Access Key available
- [ ] Account has sufficient permissions (AdministratorAccess recommended)
- [ ] Account has no service quota limitations
- [ ] Note your account expiration time (if using temporary account)

## 🚀 Deployment Checklist

### Step 1: Configure Credentials (5 minutes)
- [ ] Navigate to project directory: `cd Project_AWS_DevOps`
- [ ] Copy template: `cp config/credentials.template.sh config/credentials.sh`
- [ ] Edit credentials file
- [ ] Set `AWS_ACCESS_KEY_ID`
- [ ] Set `AWS_SECRET_ACCESS_KEY`
- [ ] Set `NOTIFICATION_EMAIL` (use a valid email you can access)
- [ ] Set `PROJECT_NAME` (default: logicworks-devops)
- [ ] Set `PRIMARY_REGION` (default: us-east-1)
- [ ] Set `SECONDARY_REGION` (default: us-west-2)
- [ ] Verify credentials don't contain quotes or spaces
- [ ] Source credentials: `source config/credentials.sh`

### Step 2: Verify AWS Credentials (1 minute)
```bash
# Test AWS credentials
aws sts get-caller-identity

# Expected output: Your account details
# If error: Check credentials.sh and try again
```
- [ ] AWS credentials work
- [ ] Account ID displayed correctly
- [ ] Region is correct

### Step 3: Make Scripts Executable (Linux/Mac only)
```bash
chmod +x scripts/*.sh
```
- [ ] Scripts are executable

### Step 4: Run Deployment Script (15-20 minutes)
```bash
./scripts/deploy.sh
```

**Monitor the deployment:**
- [ ] Phase 1: Terraform initialization started
- [ ] Phase 2: Infrastructure planning completed
- [ ] Phase 3: Infrastructure deployment in progress
  - [ ] Primary VPC created
  - [ ] Secondary VPC created
  - [ ] ECS clusters created
  - [ ] Load balancers created
  - [ ] CodePipeline created
  - [ ] CloudWatch dashboards created
- [ ] Phase 4: Docker images built
- [ ] Phase 5: Images pushed to ECR (both regions)
- [ ] Phase 6: ECS services stable
- [ ] Phase 7: CodeCommit configured
- [ ] Deployment completed successfully

### Step 5: Post-Deployment Verification (5 minutes)

#### Check Outputs
- [ ] Primary ALB URL displayed
- [ ] Secondary ALB URL displayed
- [ ] ECR repository URLs displayed
- [ ] CodeCommit URLs displayed

#### Confirm SNS Subscriptions
- [ ] Check email inbox
- [ ] Find "AWS Notification - Subscription Confirmation" email (for alarms)
- [ ] Click "Confirm subscription" link
- [ ] Find second email (for pipeline approvals)
- [ ] Click "Confirm subscription" link
- [ ] Both subscriptions confirmed

#### Test Application Access
```bash
# Primary region
curl <PRIMARY_ALB_URL>

# Secondary region
curl <SECONDARY_ALB_URL>
```
- [ ] Primary application accessible
- [ ] Secondary application accessible
- [ ] Application displays correctly in browser
- [ ] Health check endpoint works: `/health`
- [ ] API info endpoint works: `/api/info`

#### Verify Infrastructure
```bash
./scripts/status.sh
```
- [ ] Primary ECS service: ACTIVE
- [ ] Primary tasks: 2/2 running
- [ ] Secondary ECS service: ACTIVE
- [ ] Secondary tasks: 2/2 running

#### Check AWS Console
**Primary Region:**
- [ ] ECS Cluster visible and running
- [ ] ECS Service shows 2 running tasks
- [ ] ALB shows 2 healthy targets
- [ ] ECR repository contains image with 'latest' tag
- [ ] CodeCommit repository exists
- [ ] CodePipeline exists (may show failed first run - normal)
- [ ] CloudWatch dashboard exists

**Secondary Region:**
- [ ] ECS Cluster visible and running
- [ ] ECS Service shows 2 running tasks
- [ ] ALB shows 2 healthy targets
- [ ] ECR repository contains image with 'latest' tag
- [ ] CodeCommit repository exists
- [ ] CloudWatch dashboard exists

## 🔄 Testing CI/CD Pipeline Checklist

### Trigger Pipeline
```bash
# Make a small change
echo "// Test change" >> app/server.js

# Push to CodeCommit
./scripts/push-app.sh "Test CI/CD pipeline"
```

### Monitor Pipeline Execution
- [ ] Navigate to CodePipeline in AWS Console
- [ ] Pipeline execution started
- [ ] Source stage: Succeeded
- [ ] Build stage: In progress / Succeeded
- [ ] Deploy_Staging stage: Succeeded
- [ ] Approval stage: Waiting for approval
- [ ] Check email for approval request
- [ ] Click "Approve" or approve in console
- [ ] Deploy_Production stage: Succeeded
- [ ] Pipeline completed successfully

### Verify Deployment
- [ ] New container version running in ECS
- [ ] Application shows changes (if UI was modified)
- [ ] No 5XX errors in CloudWatch
- [ ] All targets healthy

## 📊 Monitoring Checklist

### CloudWatch Dashboards
- [ ] Open primary region dashboard
- [ ] Dashboard shows metrics:
  - [ ] CPU utilization
  - [ ] Memory utilization
  - [ ] ALB request count
  - [ ] Response times
  - [ ] HTTP response codes
  - [ ] Target health

### CloudWatch Alarms
- [ ] Navigate to CloudWatch Alarms
- [ ] Verify alarms exist:
  - [ ] ECS CPU high
  - [ ] ECS memory high
  - [ ] ALB 5XX errors
  - [ ] Unhealthy targets
  - [ ] High response time
  - [ ] Application errors
- [ ] All alarms in "OK" state (or "INSUFFICIENT_DATA" initially)

### Test Alarm Notification
Optional: Trigger a test alarm to verify notifications work
```bash
# This will trigger high CPU alarm (if needed)
aws cloudwatch set-alarm-state \
  --alarm-name logicworks-devops-ecs-cpu-high-us-east-1 \
  --state-value ALARM \
  --state-reason "Testing alarm" \
  --region us-east-1
```
- [ ] Email notification received
- [ ] Alarm visible in console

## 🧹 Cleanup Checklist (Before Account Expires!)

### Pre-Cleanup
- [ ] Note account expiration time
- [ ] Save any important logs or screenshots
- [ ] Ensure all code is pushed to GitHub
- [ ] Take note of any issues for documentation

### Run Cleanup Script
```bash
./scripts/cleanup.sh
```

**Type 'yes' when prompted**

### Monitor Cleanup Progress
- [ ] Phase 1: ECR images deleted
- [ ] Phase 2: S3 buckets emptied
- [ ] Phase 3: ECS services scaled down
- [ ] Phase 4: Terraform destroy started
- [ ] All resources destroyed
- [ ] Phase 5: Local cleanup completed
- [ ] Cleanup completed successfully

### Verify Cleanup (Optional)
Check AWS Console to ensure resources are deleted:

**Primary Region:**
- [ ] No ECS clusters
- [ ] No load balancers
- [ ] No ECR repositories
- [ ] No VPCs (except default)
- [ ] No CodePipelines
- [ ] No CodeBuild projects
- [ ] No CloudWatch dashboards
- [ ] No custom alarms

**Secondary Region:**
- [ ] No ECS clusters
- [ ] No load balancers
- [ ] No ECR repositories
- [ ] No VPCs (except default)
- [ ] No CloudWatch dashboards

### Cost Verification
```bash
# Check for any remaining resources
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=logicworks-devops \
  --region us-east-1
```
- [ ] No tagged resources remain
- [ ] Check billing dashboard for zero costs

## 🔄 Redeployment Checklist (New AWS Account)

### Step 1: Update Credentials
- [ ] Receive new AWS account credentials
- [ ] Update `config/credentials.sh`:
  - [ ] New AWS_ACCESS_KEY_ID
  - [ ] New AWS_SECRET_ACCESS_KEY
  - [ ] Verify email address is still accessible
- [ ] Source new credentials: `source config/credentials.sh`
- [ ] Test credentials: `aws sts get-caller-identity`

### Step 2: Clean Local State
```bash
cd terraform
rm -f terraform.tfstate*
rm -f tfplan
rm -rf .terraform/
cd ..
```
- [ ] Old state files removed

### Step 3: Redeploy
```bash
./scripts/deploy.sh
```
- [ ] Follow deployment checklist above
- [ ] Deployment successful

## 📝 Troubleshooting Reference

### Common Issues

**Issue: "NoCredentialsError"**
- [ ] Check `config/credentials.sh` exists
- [ ] Verify credentials are correct
- [ ] Source credentials: `source config/credentials.sh`

**Issue: "ResourceAlreadyExistsException"**
- [ ] Run cleanup script first
- [ ] Check for orphaned resources in console
- [ ] Delete manually if needed

**Issue: "InsufficientPermissions"**
- [ ] Verify AWS account has AdministratorAccess
- [ ] Check service quotas
- [ ] Try different region if quota exceeded

**Issue: "Pipeline fails immediately"**
- [ ] Normal on first run (no code in CodeCommit yet)
- [ ] Push code: `./scripts/push-app.sh "Initial commit"`
- [ ] Pipeline should succeed on next run

**Issue: "ECS tasks not starting"**
- [ ] Check CloudWatch Logs: `/ecs/<cluster-name>`
- [ ] Verify ECR image exists
- [ ] Check security groups allow traffic
- [ ] Verify task has internet access via NAT Gateway

**Issue: "Application not accessible"**
- [ ] Wait 2-3 minutes for DNS propagation
- [ ] Check ALB target health
- [ ] Verify security groups
- [ ] Check ECS service events

## 📞 Support Resources

- **Documentation**: Check README.md, ARCHITECTURE.md, TROUBLESHOOTING.md
- **AWS Status**: https://status.aws.amazon.com/
- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/aws/
- **AWS CLI Reference**: https://docs.aws.amazon.com/cli/

## ✅ Success Criteria

Your deployment is successful when:
- [ ] ✅ Both applications accessible via ALB URLs
- [ ] ✅ ECS services running with 2/2 healthy tasks
- [ ] ✅ CI/CD pipeline executes successfully
- [ ] ✅ CloudWatch monitoring active
- [ ] ✅ Email notifications working
- [ ] ✅ No errors in CloudWatch Logs
- [ ] ✅ All security groups properly configured
- [ ] ✅ Multi-region infrastructure validated

## 🎉 Completion

- [ ] Project fully deployed
- [ ] All tests passed
- [ ] Documentation reviewed
- [ ] Ready for demonstration

**Congratulations! Your AWS DevOps Multi-Region infrastructure is live! 🚀**



**Estimated Times:**
- Pre-deployment: 5 minutes
- Deployment: 15-20 minutes
- Post-deployment verification: 5 minutes
- CI/CD testing: 10 minutes
- Cleanup: 10-15 minutes

**Total active time needed: ~45-60 minutes** **Perfect for a 6-hour AWS account
session!**
