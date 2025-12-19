# Troubleshooting Guide

## Common Issues and Solutions

### 1. Terraform Errors

#### Error: "Error creating VPC"
**Cause**: Insufficient permissions or region limits **Solution**:
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify IAM permissions include VPC creation
# Check service quotas for VPC in AWS Console
```

#### Error: "ResourceAlreadyExistsException"
**Cause**: Resources from previous deployment still exist **Solution**:
```bash
# Run cleanup script
./scripts/cleanup.sh

# Or manually destroy
cd terraform
terraform destroy -auto-approve
```

#### Error: "terraform.tfstate.lock"
**Cause**: State file is locked from interrupted operation **Solution**:
```bash
# Remove lock (only if you're sure no other terraform process is running)
cd terraform
rm -f .terraform.tfstate.lock.info
```

### 2. AWS Credential Issues

#### Error: "NoCredentialsError"
**Cause**: AWS credentials not configured **Solution**:
```bash
# Update credentials file
nano config/credentials.sh

# Source the credentials
source config/credentials.sh

# Verify
aws sts get-caller-identity
```

#### Error: "SignatureDoesNotMatch"
**Cause**: Incorrect AWS credentials or time sync issues **Solution**:
```bash
# Check system time is synchronized
date

# Verify credentials are correct
aws configure list

# Try with new credentials if account changed
```

### 3. CodePipeline Issues

#### Pipeline Stuck in "InProgress"
**Cause**: Build or deployment taking longer than expected **Solution**:
```bash
# Check CodeBuild logs
aws codebuild batch-get-builds --ids <build-id>

# Check ECS service events
aws ecs describe-services --cluster <cluster-name> --services <service-name>
```

#### Manual Approval Not Working
**Cause**: SNS subscription not confirmed **Solution**:
1. Check email for SNS subscription confirmation
2. Click confirm link
3. Retry pipeline

#### Build Fails with "Image Pull Error"
**Cause**: ECR permissions or image doesn't exist **Solution**:
```bash
# Check ECR repository exists
aws ecr describe-repositories

# Verify ECS task execution role has ECR permissions
aws iam get-role-policy --role-name ecsTaskExecutionRole --policy-name ECRAccessPolicy
```

### 4. ECS Service Issues

#### Tasks Keep Failing
**Cause**: Various - check logs **Solution**:
```bash
# Get task ID that's failing
aws ecs list-tasks --cluster <cluster-name> --service-name <service-name>

# Describe the task
aws ecs describe-tasks --cluster <cluster-name> --tasks <task-id>

# Check CloudWatch logs
aws logs tail /ecs/<cluster-name>/<service-name> --follow
```

#### Cannot Access Application
**Cause**: Security group or health check issues **Solution**:
```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verify security groups
# - ALB security group allows inbound on port 80/443
# - ECS security group allows inbound from ALB security group

# Check ECS service is running
aws ecs describe-services --cluster <cluster-name> --services <service-name>
```

### 5. Networking Issues

#### NAT Gateway Not Working
**Cause**: Route table configuration or EIP limit **Solution**:
```bash
# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Verify NAT Gateway is active
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"

# Check Elastic IP quota
aws ec2 describe-addresses
```

#### Cannot Reach Internet from Private Subnet
**Cause**: NAT Gateway or route table misconfiguration **Solution**:
- Verify NAT Gateway is in public subnet
- Check route table has route to NAT Gateway
- Verify Internet Gateway is attached to VPC

### 6. Monitoring Issues

#### CloudWatch Alarms Not Triggering
**Cause**: Incorrect metric configuration or SNS subscription **Solution**:
```bash
# Check alarm configuration
aws cloudwatch describe-alarms --alarm-names <alarm-name>

# Test SNS topic
aws sns publish --topic-arn <topic-arn> --message "Test"

# Verify email subscription is confirmed
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>
```

#### No Logs in CloudWatch
**Cause**: IAM permissions or log group doesn't exist **Solution**:
```bash
# Check log group exists
aws logs describe-log-groups --log-group-name-prefix /ecs/

# Verify ECS task role has CloudWatch Logs permissions
# Check ECS task definition has logConfiguration
```

### 7. Deployment Script Issues

#### deploy.sh Fails
**Cause**: Various - check error message **Solution**:
```bash
# Run with debug mode
bash -x ./scripts/deploy.sh

# Check prerequisites
which terraform
which aws
which git

# Verify credentials are sourced
echo $AWS_ACCESS_KEY_ID
```

#### cleanup.sh Not Removing Everything
**Cause**: Dependencies or deletion protection **Solution**:
```bash
# Check terraform state
cd terraform
terraform show

# Force destroy specific resources
terraform state list
terraform destroy -target=<resource>

# Manual cleanup if needed
aws ecs delete-service --cluster <cluster> --service <service> --force
aws ecs delete-cluster --cluster <cluster>
```

### 8. Multi-Region Issues

#### Secondary Region Not Deploying
**Cause**: Region not enabled or quota issues **Solution**:
```bash
# Verify region is enabled
aws ec2 describe-regions

# Check if opted-in to region
aws account list-regions

# Deploy regions separately
cd terraform
terraform apply -target=module.primary_region
terraform apply -target=module.secondary_region
```

#### CodeCommit Replication Not Working
**Cause**: Replication not configured or timing issue **Solution**:
```bash
# Check replication status (this is manual in our setup)
# Push to secondary region manually if needed

# Alternatively, set up AWS CodeStar Connections for automation
```

### 9. Cost Issues

#### Unexpected High Costs
**Cause**: NAT Gateway or ALB running continuously **Solution**:
```bash
# Review cost breakdown
aws ce get-cost-and-usage --time-period Start=2025-01-01,End=2025-01-31 --granularity DAILY --metrics BlendedCost

# Check running resources
aws ecs list-tasks --cluster <cluster>
aws ec2 describe-nat-gateways
aws elbv2 describe-load-balancers

# Cleanup when not in use
./scripts/cleanup.sh
```

### 10. Six-Hour Account Limitation

#### Need to Quickly Redeploy
**Solution**:
```bash
# Before account expires - save state
./scripts/cleanup.sh
git add .
git commit -m "Save before account expires"
git push

# With new account - quick restore
source config/credentials.sh  # Update with new credentials
./scripts/deploy.sh
```

#### Lost Resources After Account Change
**Solution**:
- All state is in GitHub
- Simply deploy with new credentials
- Takes 15-20 minutes for full deployment

## Debug Commands

### General AWS Debugging
```bash
# Verify credentials and account
aws sts get-caller-identity

# Check region
aws configure get region

# List all resources (use AWS Console or)
aws resourcegroupstaggingapi get-resources --tag-filters Key=Project,Values=logicworks-devops
```

### ECS Debugging
```bash
# List clusters
aws ecs list-clusters

# Describe cluster
aws ecs describe-clusters --clusters <cluster-name>

# List services
aws ecs list-services --cluster <cluster-name>

# Describe service (detailed info)
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# List tasks
aws ecs list-tasks --cluster <cluster-name>

# Describe task (detailed info)
aws ecs describe-tasks --cluster <cluster-name> --tasks <task-id>

# Get task logs
aws logs tail /ecs/<cluster-name>/<service-name> --follow
```

### CodePipeline Debugging
```bash
# Get pipeline status
aws codepipeline get-pipeline-state --name <pipeline-name>

# Get pipeline execution history
aws codepipeline list-pipeline-executions --pipeline-name <pipeline-name>

# Get build logs
aws codebuild batch-get-builds --ids <build-id>
```

### Networking Debugging
```bash
# List VPCs
aws ec2 describe-vpcs

# List subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Check security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>"

# Check NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"

# Check Internet Gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=<vpc-id>"
```

### Load Balancer Debugging
```bash
# List load balancers
aws elbv2 describe-load-balancers

# Check target groups
aws elbv2 describe-target-groups --load-balancer-arn <alb-arn>

# Check target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Getting Help

### AWS Support
- AWS Documentation: https://docs.aws.amazon.com/
- AWS Forums: https://forums.aws.amazon.com/
- AWS Support (if enabled in account)

### Terraform
- Terraform Documentation: https://www.terraform.io/docs/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/

### Project-Specific
- Check README.md for architecture overview
- Review ARCHITECTURE.md for detailed component information
- Ensure all prerequisites are installed

## Emergency Procedures

### Critical Production Issue
1. Check CloudWatch dashboards
2. Review recent deployments
3. Rollback if needed: Revert in CodeCommit and re-deploy
4. Check CloudWatch alarms and logs

### Need to Pause Deployment
```bash
# Stop the pipeline
aws codepipeline stop-pipeline-execution --pipeline-name <name> --pipeline-execution-id <id>

# Scale down ECS services
aws ecs update-service --cluster <cluster> --service <service> --desired-count 0
```

### Total Environment Reset
```bash
# Nuclear option - destroy and rebuild
./scripts/cleanup.sh
rm -rf terraform/.terraform terraform/terraform.tfstate*
./scripts/deploy.sh
```



**Note**: Always check AWS service status page if experiencing widespread
issues: https://status.aws.amazon.com/
