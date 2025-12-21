# Project Submission - Artifact Collection Guide

## Overview
This guide provides **brief descriptions** and **screenshot instructions** for each problem statement requirement to include in your Word document submission.

---

## Requirement 1: Infrastructure as Code (IAC)

### Description (for Word doc):
```
Implemented Infrastructure as Code using Terraform v1.14.3 with AWS provider.
All infrastructure components (VPC, ECS, ALB, CodePipeline, ECR, CodeCommit, 
Lambda, CloudWatch) are defined in modular Terraform configurations, enabling 
rapid environment replication across regions and customers.
```

### Screenshots to Capture:

**Screenshot 1.1: Terraform Directory Structure**
```bash
# Run this command and take screenshot:
ls -R terraform/modules
```
**What to show**: Module structure (vpc, ecs, ecr, codecommit, codepipeline, monitoring, codecommit-replication)

**Screenshot 1.2: Terraform Apply Output**
```bash
cd terraform
terraform show | head -50
```
**What to show**: Terraform state showing managed resources

**Screenshot 1.3: Terraform Modules in main.tf**
- Open: `terraform/main.tf` in VS Code
- **What to show**: Lines showing module instantiations for primary and secondary regions

---

## Requirement 2: Multi-Region Architecture

### Description (for Word doc):
```
Deployed complete infrastructure in two AWS regions (us-east-1 and us-east-2)
for High Availability and Disaster Recovery. Each region has isolated VPC with
public/private subnets, NAT Gateways, Internet Gateway, ECS clusters, ALBs, 
and independent CI/CD pipelines ensuring regional fault tolerance.
```

### Screenshots to Capture:

**Screenshot 2.1: VPCs in Both Regions**
- AWS Console → VPC Dashboard
- Filter by tag: Project = logicworks-devops
- **What to show**: Two VPCs (10.0.0.0/16 in us-east-1, 10.1.0.0/16 in us-east-2)

**Screenshot 2.2: Primary Region ECS Cluster (us-east-1)**
- AWS Console → ECS → Clusters → logicworks-devops-cluster-us-east-1
- **What to show**: Running service with tasks

**Screenshot 2.3: Secondary Region ECS Cluster (us-east-2)**
- AWS Console → ECS → Clusters → logicworks-devops-cluster-us-east-2
- **What to show**: Running service with tasks

**Screenshot 2.4: ALB in Primary Region**
- AWS Console → EC2 → Load Balancers (us-east-1)
- Select: logicworks-devops-alb-us-east-1
- **What to show**: Active ALB with target groups

**Screenshot 2.5: ALB in Secondary Region**
- AWS Console → EC2 → Load Balancers (us-east-2)
- Select: logicworks-devops-alb-us-east-2
- **What to show**: Active ALB with target groups

---

## Requirement 3: Container Management System

### Description (for Word doc):
```
Application containerized using Docker with multi-stage builds for optimization.
Images stored in Amazon ECR (Elastic Container Registry) in both regions.
Container orchestration managed by Amazon ECS Fargate, providing serverless
compute for containers with auto-scaling capabilities configured to handle
container growth (target tracking based on CPU/Memory utilization).
```

### Screenshots to Capture:

**Screenshot 3.1: Dockerfile**
- Open: `app/Dockerfile` in VS Code
- **What to show**: Multi-stage build configuration using Node.js base image

**Screenshot 3.2: ECR Repository - Primary Region**
- AWS Console → ECR → Repositories (us-east-1)
- Select: logicworks-devops-app
- **What to show**: Repository with images and tags

**Screenshot 3.3: ECR Repository - Secondary Region**
- AWS Console → ECR → Repositories (us-east-2)
- Select: logicworks-devops-app
- **What to show**: Repository with images and tags

**Screenshot 3.4: ECS Task Definition**
- AWS Console → ECS → Task Definitions
- Select: logicworks-devops-task-us-east-1 (latest revision)
- **What to show**: Container definitions with image URL, CPU, memory, port mappings

**Screenshot 3.5: ECS Service Auto-Scaling**
- AWS Console → ECS → Clusters → logicworks-devops-cluster-us-east-1
- Click on service → Auto Scaling tab
- **What to show**: Configured auto-scaling policies (target tracking)

---

## Requirement 4: Automated CI/CD Pipeline

### Description (for Word doc):
```
Implemented fully automated CI/CD pipeline using AWS CodePipeline with five stages:
1. Source (CodeCommit) - Automatically triggers on code push
2. Build (CodeBuild) - Builds Docker image and pushes to ECR
3. Deploy Staging (ECS) - Deploys to staging environment
4. Manual Approval - Requires human approval via SNS notification
5. Deploy Production (ECS) - Deploys approved code to production

Pipeline operates independently in both regions with EventBridge triggers.
```

### Screenshots to Capture:

**Screenshot 4.1: Primary Pipeline Overview**
- AWS Console → CodePipeline → Pipelines (us-east-1)
- Select: logicworks-devops-pipeline-us-east-1
- **What to show**: All 5 stages (Source, Build, Deploy_Staging, Approval, Deploy_Production)

**Screenshot 4.2: Pipeline Execution History**
- Same pipeline → Execution history tab
- **What to show**: Successful pipeline executions with timestamps

**Screenshot 4.3: CodeBuild Project Configuration**
- AWS Console → CodeBuild → Build projects (us-east-1)
- Select: logicworks-devops-build-us-east-1
- **What to show**: Build environment, buildspec, artifacts configuration

**Screenshot 4.4: CodeBuild Build Success**
- CodeBuild → Build history
- Select a successful build
- **What to show**: Build logs showing Docker build and ECR push

**Screenshot 4.5: Manual Approval Stage**
- CodePipeline → logicworks-devops-pipeline-us-east-1
- **What to show**: Approval stage with SNS topic configuration

**Screenshot 4.6: buildspec.yml**
- Open: `buildspec.yml` in VS Code
- **What to show**: Build phases (pre_build, build, post_build) and artifacts

---

## Requirement 5: Source Code Replication

### Description (for Word doc):
```
Implemented automated source code replication using AWS Lambda function triggered
by EventBridge on every CodeCommit push. Lambda function captures commit events
from primary region (us-east-1), fetches changed files using CodeCommit API,
and replicates to secondary region (us-east-2) CodeCommit repository. This
eliminates cross-region latency and ensures both pipelines pull code locally.
```

### Screenshots to Capture:

**Screenshot 5.1: Lambda Function Overview**
- AWS Console → Lambda → Functions (us-east-1)
- Select: logicworks-devops-production-codecommit-replication
- **What to show**: Function configuration with runtime, handler, timeout

**Screenshot 5.2: Lambda Function Code**
- Same Lambda function → Code tab
- **What to show**: Python code showing CodeCommit API calls (get_differences, create_commit)

**Screenshot 5.3: EventBridge Rule**
- AWS Console → EventBridge → Rules (us-east-1)
- Select: logicworks-devops-production-codecommit-push
- **What to show**: Event pattern for CodeCommit push events

**Screenshot 5.4: Lambda Execution Logs**
```bash
# Run this command and capture output:
MSYS_NO_PATHCONV=1 aws logs filter-log-events \
  --log-group-name /aws/lambda/logicworks-devops-production-codecommit-replication \
  --region us-east-1 \
  --start-time $(($(date +%s) - 3600))000 \
  --query 'events[*].message' \
  --output text | grep -A 5 "Successfully replicated"
```
**What to show**: Log showing successful replication with file count and commit IDs

**Screenshot 5.5: Primary CodeCommit Repository**
- AWS Console → CodeCommit → Repositories (us-east-1)
- Select: logicworks-devops-repo
- **What to show**: Commit history showing original commits

**Screenshot 5.6: Secondary CodeCommit Repository**
- AWS Console → CodeCommit → Repositories (us-east-2)
- Select: logicworks-devops-repo
- **What to show**: Commit history showing replicated commits with "[Replicated]" prefix

**Screenshot 5.7: Lambda Replication Module**
- Open: `terraform/modules/codecommit-replication/main.tf`
- **What to show**: Terraform code for Lambda, EventBridge, IAM resources

---

## Requirement 6: Continuous Monitoring with Notifications

### Description (for Word doc):
```
Comprehensive monitoring implemented using CloudWatch with custom dashboards
for both regions. Configured CloudWatch Alarms for critical metrics: ECS CPU/Memory
utilization, ALB 5xx errors, unhealthy targets, high response times, and
application errors. SNS topics configured to send email notifications when
thresholds are breached, enabling proactive incident response.
```

### Screenshots to Capture:

**Screenshot 6.1: CloudWatch Dashboard - Primary Region**
- AWS Console → CloudWatch → Dashboards (us-east-1)
- Select: logicworks-devops-dashboard-us-east-1
- **What to show**: Dashboard with ECS metrics, ALB metrics, application metrics

**Screenshot 6.2: CloudWatch Dashboard - Secondary Region**
- AWS Console → CloudWatch → Dashboards (us-east-2)
- Select: logicworks-devops-dashboard-us-east-2
- **What to show**: Dashboard showing metrics from secondary region

**Screenshot 6.3: CloudWatch Alarms - Primary Region**
- AWS Console → CloudWatch → Alarms (us-east-1)
- Filter by: logicworks-devops
- **What to show**: List of configured alarms (ECS CPU high, Memory high, ALB errors, etc.)

**Screenshot 6.4: SNS Topic Configuration**
- AWS Console → SNS → Topics (us-east-1)
- Select: logicworks-devops-alarms-us-east-1
- **What to show**: Topic with email subscription

**Screenshot 6.5: Alarm Configuration Example**
- CloudWatch → Alarms → Select any alarm
- **What to show**: Alarm threshold, metric, actions (SNS notification)

**Screenshot 6.6: CloudWatch Log Groups**
```bash
# Run this command:
aws logs describe-log-groups --region us-east-1 --query 'logGroups[?contains(logGroupName, `logicworks-devops`)].logGroupName' --output table
```
**What to show**: All log groups (ECS, CodeBuild, Lambda, VPC Flow Logs)

---

## Requirement 7: Approval Gate Before Production

### Description (for Word doc):
```
Manual approval gate implemented as dedicated stage in CodePipeline between
staging and production deployments. Upon successful staging deployment, pipeline
pauses and sends SNS notification to designated approvers. Production deployment
proceeds only after explicit human approval through AWS Console or CLI, ensuring
code quality validation and preventing unauthorized production releases.
```

### Screenshots to Capture:

**Screenshot 7.1: Pipeline with Approval Stage**
- AWS Console → CodePipeline → logicworks-devops-pipeline-us-east-1
- **What to show**: Pipeline showing completed staging and waiting approval

**Screenshot 7.2: Approval Action Configuration**
- Same pipeline → Edit pipeline
- Click on Approval stage → Edit action
- **What to show**: SNS topic configuration for approval notifications

**Screenshot 7.3: SNS Approval Notification Email**
- Check your email inbox
- **What to show**: Email from SNS with approval link and pipeline details

**Screenshot 7.4: Approval in Progress**
- CodePipeline execution view
- **What to show**: Approval stage highlighted with "Review" button

**Screenshot 7.5: Production Deployment After Approval**
- After clicking approve
- **What to show**: Pipeline proceeding to Deploy_Production stage

**Screenshot 7.6: Pipeline IAM Permissions**
- Open: `terraform/modules/codepipeline/main.tf`
- **What to show**: IAM policy granting ECS deployment permissions

---

## Additional Evidence

### Application Running in Both Regions

**Screenshot A.1: Primary Region Application**
```bash
curl http://logicworks-devops-alb-us-east-1-799240009.us-east-1.elb.amazonaws.com
```
- Take screenshot of browser showing application
- **What to show**: Running application with HTTP 200 response

**Screenshot A.2: Secondary Region Application**
```bash
curl http://logicworks-devops-alb-us-east-2-234487.us-east-2.elb.amazonaws.com
```
- Take screenshot of browser showing application
- **What to show**: Running application with HTTP 200 response

**Screenshot A.3: Terraform Outputs**
```bash
cd terraform
terraform output
```
**What to show**: All deployment outputs (ALB URLs, ECR repos, ECS clusters for both regions)

---

## Quick Screenshot Capture Commands

Run these commands to quickly gather evidence:

```bash
# 1. Terraform modules structure
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/Project_AWS_DevOps
tree terraform/modules -L 1

# 2. Pipeline status both regions
aws codepipeline get-pipeline-state --name logicworks-devops-pipeline-us-east-1 --region us-east-1 --query 'stageStates[*].[stageName,latestExecution.status]' --output table

aws codepipeline get-pipeline-state --name logicworks-devops-pipeline-us-east-2 --region us-east-2 --query 'stageStates[*].[stageName,latestExecution.status]' --output table

# 3. Lambda logs showing replication
MSYS_NO_PATHCONV=1 aws logs filter-log-events --log-group-name /aws/lambda/logicworks-devops-production-codecommit-replication --region us-east-1 --start-time $(($(date +%s) - 3600))000 --query 'events[*].message' --output text | grep "Successfully replicated"

# 4. Application health check
curl -I http://logicworks-devops-alb-us-east-1-799240009.us-east-1.elb.amazonaws.com
curl -I http://logicworks-devops-alb-us-east-2-234487.us-east-2.elb.amazonaws.com

# 5. Resource summary
cd terraform
terraform output
```

---

## Word Document Structure Recommendation

### Title Page
- Project Name: AWS Multi-Region DevOps Implementation
- Student Name
- Date: December 20, 2025
- Course: DevOps Architecture

### Table of Contents
1. Executive Summary
2. Requirement 1: Infrastructure as Code
3. Requirement 2: Multi-Region Architecture
4. Requirement 3: Container Management
5. Requirement 4: Automated CI/CD Pipeline
6. Requirement 5: Source Code Replication
7. Requirement 6: Continuous Monitoring
8. Requirement 7: Approval Gate
9. Architecture Diagram
10. Conclusion

### Each Requirement Section Should Have:
1. **Brief Description** (2-3 sentences from this guide)
2. **Implementation Details** (1 paragraph)
3. **Screenshots** (2-4 images with captions)
4. **Technologies Used** (bullet list)

### Formatting Tips:
- Use consistent heading styles (Heading 1, Heading 2)
- Add figure numbers to all screenshots: "Figure 1.1: Terraform Module Structure"
- Include page numbers
- Use bullet points for clarity
- Keep descriptions concise but complete

---

## Checklist Before Submission

- [ ] All 7 requirements documented with descriptions
- [ ] Minimum 3 screenshots per requirement
- [ ] All screenshots clearly labeled with figure numbers
- [ ] Architecture diagram included
- [ ] Table of contents with page numbers
- [ ] All AWS Console screenshots show project tags/names
- [ ] Code screenshots readable with syntax highlighting
- [ ] ALB URLs tested and application screenshots captured
- [ ] Lambda logs showing successful replication
- [ ] Both region resources clearly demonstrated
- [ ] Terraform outputs included
- [ ] Document spell-checked
- [ ] PDF version created for submission

---

## Time-Saving Tip

For bulk screenshot capture, use these AWS Console URLs:

**Primary Region Resources:**
- VPC: https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
- ECS: https://us-east-1.console.aws.amazon.com/ecs/v2/clusters?region=us-east-1
- ECR: https://us-east-1.console.aws.amazon.com/ecr/repositories?region=us-east-1
- CodePipeline: https://us-east-1.console.aws.amazon.com/codesuite/codepipeline/pipelines?region=us-east-1
- CodeCommit: https://us-east-1.console.aws.amazon.com/codesuite/codecommit/repositories?region=us-east-1
- Lambda: https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions
- CloudWatch: https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1

**Secondary Region Resources:**
- Just change `us-east-1` to `us-east-2` in the URLs above

---

Good luck with your submission! 🎉
