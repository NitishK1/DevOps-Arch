# 🎯 AWS DevOps Multi-Region Project - Demo Preparation & Interview Q&A

## 📋 Table of Contents
1. [Demo Script & Flow](#demo-script--flow)
2. [Project Understanding](#project-understanding)
3. [Technical Q&A](#technical-qa)
4. [Architecture Deep Dive](#architecture-deep-dive)
5. [Troubleshooting & Edge Cases](#troubleshooting--edge-cases)



## 🎬 Demo Script & Flow

### Pre-Demo Checklist (5 mins before)
- [ ] AWS Console login ready (Primary region: us-east-1)
- [ ] Terminal/Git Bash open in project directory
- [ ] Browser tabs open:
  - AWS CodePipeline
  - AWS ECS Clusters
  - AWS CloudWatch Dashboards
  - Application URLs (both regions)
- [ ] Code editor open with key files visible
- [ ] Credentials configured in `config/credentials.sh`

### Demo Flow (15-20 minutes)

#### 1. Introduction & Problem Statement (2 mins)
**Say:** "I've built a complete multi-region AWS DevOps infrastructure for
Logicworks, addressing all their requirements for Infrastructure as Code,
container orchestration, automated CI/CD, and continuous monitoring."

**Show:** Open [Problem_Statement.txt](Problem_Statement.txt) and highlight the
7 requirements

#### 2. Architecture Overview (3 mins)
**Say:** "Let me walk you through the architecture. We have a multi-region setup
spanning us-east-1 and us-west-2."

**Show:** Navigate to [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)

**Explain:**
- **Primary Region (us-east-1)**: Full CI/CD pipeline with CodeCommit →
  CodeBuild → ECS deployment
- **Secondary Region (us-west-2)**: Replicated infrastructure for disaster
  recovery
- **VPC Design**: Multi-AZ with public (ALB) and private subnets (ECS)
- **Container Orchestration**: ECS Fargate (serverless)
- **Image Registry**: ECR with lifecycle policies
- **Monitoring**: CloudWatch + SNS notifications

#### 3. Infrastructure as Code (3 mins)
**Say:** "Everything is defined as code using Terraform with modular
architecture for reusability."

**Show in terminal:**
```bash
cd terraform
tree modules  # or ls -R modules
```

**Explain modules:**
- `vpc/` - Network infrastructure (VPC, subnets, NAT gateways, IGW)
- `ecr/` - Container registry with scanning and lifecycle policies
- `ecs/` - Container orchestration (cluster, task definition, service, ALB)
- `codecommit/` - Source code repository
- `codepipeline/` - CI/CD automation (Source → Build → Stage → Approval → Prod)
- `monitoring/` - CloudWatch dashboards, alarms, SNS topics

**Show code snippet from [terraform/main.tf](terraform/main.tf:1-40):**
```terraform
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

module "primary_vpc" {
  source = "./modules/vpc"
  # ...
}
```

#### 4. Containerization (2 mins)
**Say:** "The application is containerized using Docker with multi-stage builds
for optimization."

**Show [app/Dockerfile](app/Dockerfile):**
```dockerfile
# Stage 1: Build - installs dependencies
FROM public.ecr.aws/docker/library/node:18-alpine AS builder
# ...

# Stage 2: Runtime - minimal production image
FROM public.ecr.aws/docker/library/node:18-alpine
# Runs as non-root user for security
USER nodejs
```

**Explain:**
- Multi-stage build reduces image size (~150MB vs 500MB+)
- Uses Amazon ECR Public Gallery to avoid Docker Hub rate limits
- Non-root user for security
- Built-in health checks

#### 5. CI/CD Pipeline Demo (5 mins)
**Say:** "Let me demonstrate the complete CI/CD workflow."

**In AWS Console:**
1. Navigate to **CodePipeline** → `logicworks-devops-pipeline-us-east-1`
2. Show pipeline stages:
   - Source (CodeCommit)
   - Build (CodeBuild)
   - Deploy-Staging
   - Manual-Approval
   - Deploy-Production

**Live Demo:**
```bash
# Make a code change
cd app
# Edit server.js - change version number in HTML
nano server.js  # Change <h1>🚀 Logicworks DevOps</h1> to v2.0

# Push to trigger pipeline
cd ..
./scripts/push-app.sh "Demo: Updated version to 2.0"
```

**In AWS Console:**
1. Show pipeline triggered automatically
2. Navigate to **CodeBuild** → Show build logs
3. Show build creating Docker image and pushing to ECR
4. Show deployment to staging ECS service
5. Show **Manual Approval** stage with SNS notification
6. Approve in console
7. Show deployment to production

#### 6. Monitoring & Observability (3 mins)
**Say:** "Everything is monitored with CloudWatch and alerts sent via SNS."

**In AWS Console:**
1. Navigate to **CloudWatch** → **Dashboards**
2. Open `logicworks-devops-dashboard-us-east-1`

**Show metrics:**
- ECS CPU & Memory utilization
- ALB request count and response times
- HTTP status codes (2xx, 4xx, 5xx)
- Target health status

**Navigate to Alarms:**
- High CPU (>80%)
- High Memory (>80%)
- HTTP 5XX errors
- Unhealthy targets

**Show SNS Setup:**
- Navigate to **SNS** → Topics
- Show email subscription for alerts

#### 7. Multi-Region Architecture (2 mins)
**Say:** "The entire infrastructure is replicated in us-west-2 for high
availability and disaster recovery."

**In AWS Console:**
1. Switch region to **us-west-2**
2. Show ECS cluster running
3. Show CodeCommit repository replicated
4. Open application URL in browser (both regions)

**Show both applications running:**
```
Primary:   http://logicworks-alb-us-east-1-xxx.us-east-1.elb.amazonaws.com
Secondary: http://logicworks-alb-us-west-2-xxx.us-west-2.elb.amazonaws.com
```

#### 8. Repository Replication (1 min)
**Say:** "Code is automatically replicated between regions using Lambda
functions triggered by CodeCommit events."

**In AWS Console:**
1. Navigate to **Lambda** in us-east-1
2. Show `codecommit-replication-function`
3. Explain: EventBridge triggers Lambda on push → Lambda replicates to secondary
   region

#### 9. Deployment Automation (1 min)
**Say:** "The entire infrastructure can be deployed with a single command."

**Show in terminal:**
```bash
cat scripts/deploy.sh  # Show deployment automation
```

**Explain:**
- One-command deployment (`./scripts/deploy.sh`)
- Validates credentials
- Deploys to both regions
- ~15-20 minute total deployment
- One-command cleanup (`./scripts/cleanup.sh`)

#### 10. Wrap-up & Questions (2 mins)
**Summarize achievements:**
- ✅ Complete IaC with Terraform
- ✅ Multi-region architecture (HA & DR)
- ✅ Container orchestration with ECS Fargate
- ✅ Automated CI/CD with manual approval
- ✅ Multi-region code replication
- ✅ Comprehensive monitoring & alerting
- ✅ Production-ready with security best practices



## 🧠 Project Understanding

### What Problem Does This Solve?
Logicworks needed a reusable, automated infrastructure template for deploying
containerized applications across multiple regions with:
- Fast environment replication for different customers
- High availability and disaster recovery
- Automated deployments with approval gates
- Continuous monitoring and alerting

### Key Technologies & Why?

| Technology | Purpose | Why Chosen |
|------------|---------|------------|
| **Terraform** | Infrastructure as Code | Industry standard, cloud-agnostic, modular, state management |
| **Docker** | Containerization | Consistent environments, portability, lightweight |
| **ECS Fargate** | Container orchestration | Serverless (no EC2 management), auto-scaling, AWS-native |
| **ECR** | Image registry | AWS-native, integrated with ECS, security scanning |
| **CodeCommit** | Source control | AWS-native, integrated with CodePipeline, private Git |
| **CodeBuild** | Build automation | Docker builds, integrated with CodePipeline, pay-per-use |
| **CodePipeline** | CI/CD orchestration | AWS-native, visual pipeline, approval gates |
| **CloudWatch** | Monitoring | Comprehensive AWS metrics, logs, dashboards, alarms |
| **SNS** | Notifications | Email/SMS alerts, approval notifications |
| **ALB** | Load balancing | Multi-AZ, health checks, SSL termination capability |

### Architecture Decisions

#### Why ECS Fargate over EKS or EC2?
- **ECS Fargate**: Chose this
  - No server management (serverless)
  - Lower cost for small-medium workloads
  - Faster deployment (no nodes to provision)
  - Simpler to manage
  - AWS-native integration
- **EKS**: Not chosen
  - More complex setup
  - Higher cost (control plane + nodes)
  - Overkill for this use case
- **EC2**: Not chosen
  - Need to manage instances
  - Patching, scaling complexity
  - Higher operational overhead

#### Why Multi-Stage Docker Builds?
- **Smaller image size**: 150MB vs 500MB+
- **Faster deployments**: Less data to transfer
- **Security**: Production image doesn't contain build tools
- **Best practice**: Separate build and runtime dependencies

#### Why CodePipeline over Jenkins?
- **AWS-native**: Better integration with AWS services
- **Managed service**: No infrastructure to maintain
- **Visual interface**: Easy to understand pipeline flow
- **Built-in approval**: Native manual approval support
- **Cost-effective**: Pay only for pipeline executions

#### Why Multi-Region?
- **High Availability**: If one region fails, traffic can be routed to other
- **Disaster Recovery**: Data and application replicated
- **Compliance**: Some industries require multi-region
- **Performance**: Serve users closer to their location (latency)
- **Business Continuity**: Minimize downtime impact



## 💡 Technical Q&A

### Infrastructure & Terraform

**Q1: What is Infrastructure as Code (IaC)?** **A:** Infrastructure as Code is
the practice of managing and provisioning infrastructure through
machine-readable definition files rather than manual processes. Instead of
clicking in AWS console, we define everything in code (Terraform files), which
provides:
- Version control (Git)
- Repeatability (deploy same setup multiple times)
- Documentation (code documents itself)
- Collaboration (multiple team members)
- Testing (validate before applying)
- Automation (CI/CD for infrastructure)

**Q2: Why did you use Terraform instead of CloudFormation?** **A:**
- **Multi-cloud**: Terraform works across AWS, Azure, GCP (not locked to AWS)
- **Better syntax**: HCL is more readable than JSON/YAML
- **Larger ecosystem**: More providers and modules available
- **State management**: Better state handling with remote backends
- **Existing experience**: Industry standard with large community
- *Note*: CloudFormation is AWS-native and deeply integrated, but Terraform's
  flexibility was more important for a consulting company like Logicworks that
  might work with multiple clouds.

**Q3: Explain your Terraform module structure.** **A:** Modular architecture for
reusability and separation of concerns:
```
modules/
├── vpc/          # Networking (VPC, subnets, route tables, NAT, IGW)
├── ecr/          # Container registry
├── ecs/          # Container orchestration (cluster, service, tasks, ALB)
├── codecommit/   # Source repository
├── codepipeline/ # CI/CD pipeline (includes CodeBuild)
└── monitoring/   # CloudWatch & SNS
```
Each module is self-contained with inputs (variables) and outputs, making them
reusable across different projects or environments.

**Q4: How do you handle Terraform state?** **A:** Currently using local state
(`terraform.tfstate`), but in production I would use:
- **S3 backend** for state storage
- **DynamoDB** for state locking (prevent concurrent modifications)
- **Encryption** at rest
- **Versioning** enabled on S3 bucket for state history

Example:
```terraform
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Q5: How do you prevent accidental infrastructure deletion?** **A:** Multiple
safeguards:
- **Lifecycle prevent_destroy**: In Terraform for critical resources
- **State file backups**: Keep previous state versions
- **Approval process**: Review terraform plan before apply
- **Access control**: Limited who can run terraform destroy
- **Resource tagging**: Clear ownership and environment tags
- **Manual verification**: Script asks for confirmation before cleanup

**Q6: How would you handle multiple environments (dev/staging/prod)?** **A:**
Two approaches:
1. **Workspace approach**: `terraform workspace select prod`
2. **Directory approach** (better):
```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
└── modules/
```
Use separate state files and different variable values for each environment.

### Containerization & ECS

**Q7: Explain your Docker multi-stage build.** **A:** Two stages:
```dockerfile
# Stage 1: Builder - installs all dependencies including devDependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production

# Stage 2: Runtime - copies only production artifacts
FROM node:18-alpine
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER nodejs  # Non-root for security
```
**Benefits:**
- Smaller final image (~150MB vs 500+MB)
- Faster deployments and scaling
- More secure (no build tools in production image)
- Build cache efficiency

**Q8: Why ECS Fargate instead of Kubernetes?** **A:**
- **Simpler**: No cluster management, no worker nodes
- **Serverless**: Pay only for container runtime
- **AWS-native**: Deep integration with ALB, CloudWatch, IAM, VPC
- **Faster setup**: No Kubernetes complexity (no master nodes, etcd, etc.)
- **Sufficient for use case**: Requirement was container management, not
  necessarily Kubernetes
- **Cost-effective**: For small-medium workloads, Fargate is cheaper than EKS
- *Note*: If we needed advanced features like custom scheduling, service mesh,
  or Kubernetes API, we'd use EKS.

**Q9: How does ECS auto-scaling work?** **A:** Two types configured:
1. **Target Tracking Scaling**:
   - Monitors CPU/Memory metrics
   - Maintains target value (e.g., 70% CPU)
   - Automatically adjusts task count

2. **Configuration**:
   - **Min tasks**: 2 (high availability)
   - **Max tasks**: 10 (cost control)
   - **Scale-out**: When CPU > 70% for 60 seconds
   - **Scale-in**: When CPU < 50% for 300 seconds
   - **Cooldown**: Prevents flapping

**Q10: What is a Task Definition in ECS?** **A:** Blueprint for running
containers, similar to Kubernetes Pod spec. Defines:
- **Container image**: Which Docker image to run
- **Resources**: CPU (256 units = 0.25 vCPU), Memory (512 MB)
- **Networking**: Port mappings (8080)
- **IAM role**: Permissions for the container
- **Logging**: CloudWatch log group
- **Health checks**: Container health verification
- **Environment variables**: Configuration

**Q11: How do you handle container security?** **A:** Multiple layers:
- **Non-root user**: Container runs as `nodejs` user (UID 1001)
- **Image scanning**: ECR automatically scans for vulnerabilities
- **Private subnets**: ECS tasks run in private subnets (no direct internet)
- **Security groups**: Only ALB can reach containers
- **IAM roles**: Least privilege access
- **Secrets management**: Would use AWS Secrets Manager for sensitive data
- **Image signing**: Could implement with Docker Content Trust
- **Regular updates**: Base image updates in Dockerfile

### CI/CD Pipeline

**Q12: Walk through your CI/CD pipeline stages.** **A:**
1. **Source Stage**:
   - Trigger: Git push to CodeCommit main branch
   - EventBridge rule detects push
   - CodePipeline pulls latest code

2. **Build Stage**:
   - CodeBuild executes `buildspec.yml`
   - Runs tests (`npm test`)
   - Builds Docker image
   - Tags: `<commit-hash>` and `latest`
   - Pushes to ECR
   - Creates `imagedefinitions.json` artifact

3. **Deploy-Staging**:
   - Deploys to staging ECS service
   - Uses blue/green deployment
   - Verifies health checks

4. **Manual-Approval**:
   - SNS email sent to approvers
   - Pipeline pauses
   - Can review staging environment
   - Approve/Reject in console or via email link

5. **Deploy-Production**:
   - Only runs after approval
   - Deploys to production ECS service
   - Same image as staging (proven code)
   - Blue/green deployment with rollback

**Q13: What happens if a build fails?** **A:**
- Pipeline stops at failed stage
- No deployment to staging or production
- SNS notification sent about failure
- CloudWatch Logs contain error details
- Can review logs in CodeBuild console
- Developer fixes issue, pushes again
- Pipeline automatically retries

**Q14: How do you handle rollback?** **A:** Multiple options:
1. **Automatic**: If health checks fail, ECS automatically rolls back
2. **Manual**: Deploy previous working version from ECR
3. **Pipeline**: Re-run previous successful pipeline execution
4. **Git**: Revert commit and push again

In ECS specifically:
- **Deployment circuit breaker**: Automatically rolls back on repeated failures
- **Deployment configuration**: Can set minimum healthy percent (100%) and
  maximum percent (200%) for zero-downtime deployments

**Q15: Why manual approval before production?** **A:** Business and technical
reasons:
- **Testing**: Time to verify staging environment
- **Business review**: Stakeholder approval for changes
- **Compliance**: Some industries require human approval
- **Risk mitigation**: Prevent accidental production deployments
- **Off-hours control**: Deploy during maintenance windows
- **Change management**: Coordinate with other teams

**Q16: Explain your buildspec.yml.** **A:** CodeBuild configuration file:
```yaml
phases:
  pre_build:
    - Login to ECR
    - Set image tags (commit hash)

  build:
    - cd app
    - npm install
    - npm test (CI=true)
    - docker build
    - docker tag (commit hash and latest)

  post_build:
    - docker push to ECR
    - Create imagedefinitions.json

artifacts:
  - imagedefinitions.json (tells ECS which image to deploy)
```

### Networking & Multi-Region

**Q17: Explain your VPC architecture.** **A:**
```
VPC (10.0.0.0/16)
├── Public Subnets (2 AZs)
│   ├── 10.0.1.0/24 (us-east-1a)
│   ├── 10.0.2.0/24 (us-east-1b)
│   ├── Internet Gateway (IGW)
│   └── Application Load Balancer
│
└── Private Subnets (2 AZs)
    ├── 10.0.11.0/24 (us-east-1a)
    ├── 10.0.12.0/24 (us-east-1b)
    ├── NAT Gateways (one per AZ for HA)
    └── ECS Tasks (containers)
```

**Why this design?**
- **Public subnets**: For ALB (needs internet access for users)
- **Private subnets**: For ECS tasks (better security)
- **Multi-AZ**: High availability (if one AZ fails, other continues)
- **NAT Gateways**: Allow containers to reach internet (pull images, updates)
  but aren't directly accessible

**Q18: How does multi-region replication work?** **A:**
1. **Infrastructure**: Terraform deploys to both regions independently
   ```terraform
   provider "aws" { region = "us-east-1", alias = "primary" }
   provider "aws" { region = "us-west-2", alias = "secondary" }
   ```

2. **Code Replication**: Lambda function triggered by EventBridge
   - Developer pushes to us-east-1 CodeCommit
   - EventBridge detects push event
   - Lambda function triggered
   - Lambda fetches changed files
   - Lambda creates identical commit in us-west-2
   - Both regions have same code

3. **Container Images**: ECR repository in each region
   - Primary build pushes to us-east-1 ECR
   - Secondary build pulls from its local ECR
   - Could setup ECR replication if needed

**Q19: How would you handle cross-region traffic routing?** **A:** Would add:
- **Route 53**: DNS-based routing
  - **Failover routing**: Primary → Secondary if primary unhealthy
  - **Geolocation routing**: Route users to nearest region
  - **Latency-based routing**: Route to lowest latency region
- **Health checks**: Monitor ALB endpoints
- **Automated failover**: Route 53 automatically switches on failure

Example:
```
User → Route 53 DNS →
  ├── If healthy: us-east-1 ALB
  └── If unhealthy: us-west-2 ALB
```

**Q20: What about database replication across regions?** **A:** This project
doesn't include a database (stateless application), but would use:
- **RDS Multi-Region**: Read replicas with promotion capability
- **DynamoDB Global Tables**: Multi-region replication
- **Aurora Global Database**: Sub-second replication across regions
- **Application-level**: Sync logic in application code

### Monitoring & Operations

**Q21: What metrics are you monitoring?** **A:** **ECS Metrics**:
- CPU utilization (trigger scaling)
- Memory utilization (trigger scaling)
- Task count (running vs desired)

**ALB Metrics**:
- Request count (traffic volume)
- Response time (performance)
- HTTP 2xx, 4xx, 5xx counts (errors)
- Target health (backend health)
- Connection count

**Application Metrics**:
- Health check endpoint status
- Custom application errors

**Q22: Explain your CloudWatch Alarms.**
**A:**
| Alarm | Threshold | Action |
|-------|-----------|--------|
| High CPU | >80% for 2 minutes | SNS email + Auto-scale |
| High Memory | >80% for 2 minutes | SNS email + Auto-scale |
| HTTP 5XX | >10 errors in 5 min | SNS email (investigate) |
| Unhealthy Targets | >0 for 1 minute | SNS email (immediate) |
| High Response Time | >1 second avg | SNS email (performance issue) |

**Q23: How do you troubleshoot a failed deployment?** **A:** Systematic
approach:
1. **Check CloudWatch Logs**:
   - ECS task logs: `/ecs/logicworks-devops`
   - CodeBuild logs: In build history
   - Application logs: Health check failures

2. **Check ECS Events**:
   - Service events tab shows deployment progress
   - Task stopped reasons

3. **Verify Health Checks**:
   - ALB target group health
   - Application `/health` endpoint

4. **Review Pipeline**:
   - Which stage failed?
   - Error messages in console

5. **Common issues**:
   - Image pull errors (ECR permissions)
   - Health check failures (wrong port)
   - Resource limits (out of memory)
   - Security group misconfigurations

**Q24: How would you improve observability?** **A:** Add:
- **Distributed tracing**: AWS X-Ray for request tracing
- **Application metrics**: Custom CloudWatch metrics
- **Log aggregation**: Centralized logging with CloudWatch Insights
- **APM**: Application Performance Monitoring (Datadog, New Relic)
- **Error tracking**: Sentry or Rollbar for application errors
- **Real User Monitoring**: Track actual user experience

### Security & Best Practices

**Q25: What security best practices did you implement?** **A:**
1. **Network Security**:
   - Private subnets for compute
   - Security groups (least privilege)
   - NACLs for additional network layer security
   - No public IPs on ECS tasks

2. **IAM Security**:
   - Separate roles for each service
   - Least privilege permissions
   - No long-term credentials (IAM roles)

3. **Container Security**:
   - Non-root user in containers
   - Image scanning in ECR
   - Multi-stage builds (minimal attack surface)
   - Regular base image updates

4. **Data Security**:
   - Encryption in transit (HTTPS capable)
   - Would use Secrets Manager for sensitive data
   - No hardcoded credentials

5. **Operational Security**:
   - Infrastructure as Code (audit trail)
   - Manual approval for production
   - CloudWatch logging (audit)
   - Resource tagging (ownership)

**Q26: How do you handle secrets?** **A:** Current: Environment variables in
task definition **Better approach**:
```terraform
# Store in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "logicworks-db-password"
}

# Reference in ECS task definition
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = aws_secretsmanager_secret.db_password.arn
  }
]
```
**Benefits**: Rotation, encryption, audit trail, no code changes to update
secrets

**Q27: What about compliance and auditing?** **A:**
- **CloudTrail**: All API calls logged
- **Config**: Track configuration changes
- **Resource tagging**: Environment, Project, Owner
- **IAM Access Analyzer**: Detect overly permissive policies
- **GuardDuty**: Threat detection
- **Security Hub**: Centralized security findings

### Cost & Operations

**Q28: What's the estimated cost of this infrastructure?** **A:** **Per Region
(Monthly)**:
- ECS Fargate (2 tasks, 0.25 vCPU, 0.5GB each): ~$30
- Application Load Balancer: ~$25
- NAT Gateway: ~$35 (+ data processing)
- ECR storage: ~$5 (10 images)
- CloudWatch (logs, metrics): ~$5-10
- Data transfer: ~$10-20
- CodePipeline: $1 (first free)
- CodeBuild: Pay per minute (~$5/month light usage)

**Total per region**: ~$110-130/month **Both regions**: ~$220-260/month **For
6-hour session**: ~$5-7

**Q29: How would you optimize costs?** **A:**
1. **Right-sizing**: Start with 0.25 vCPU, scale based on actual usage
2. **Fargate Spot**: 70% cost savings for non-critical tasks
3. **ECR lifecycle policies**: Already implemented (keep 10 images)
4. **CloudWatch log retention**: Set to 7-30 days instead of forever
5. **NAT Gateway**: Single NAT for dev environments
6. **Reserved capacity**: Savings Plans for predictable workloads
7. **S3 lifecycle**: Move old artifacts to Glacier
8. **Scheduled scaling**: Scale down during off-hours

**Q30: How do you ensure high availability?** **A:**
1. **Multi-AZ deployment**: Resources across 2+ AZs
2. **Auto-scaling**: Automatic task replacement
3. **Health checks**:
   - ALB target health (every 30 seconds)
   - Container health checks (Docker HEALTHCHECK)
4. **Load balancing**: Traffic distributed across tasks
5. **Multi-region**: Failover capability to us-west-2
6. **Deployment strategy**: Rolling update with minimum healthy 100%
7. **Circuit breaker**: Automatic rollback on deployment failures



## 🏗️ Architecture Deep Dive

### Data Flow: User Request

```
1. User browser → Route 53 DNS (if implemented)
2. Route 53 → Application Load Balancer (ALB)
3. ALB → Target Group health check
4. ALB → ECS Task (container) on Port 8080
5. Container → Processes request
6. Container → Returns HTML response
7. ALB → Returns to user
8. Logs → CloudWatch
```

### Data Flow: Code Push to Production

```
1. Developer → git push to local
2. Script → Pushes to CodeCommit (us-east-1)
3. EventBridge → Detects repository push
4. CodePipeline → Triggered

5. Source Stage:
   - Pulls latest code from CodeCommit

6. Build Stage:
   - CodeBuild starts
   - Executes buildspec.yml
   - npm install + npm test
   - Docker build
   - Docker push to ECR
   - Creates imagedefinitions.json

7. Deploy-Staging Stage:
   - ECS pulls new image from ECR
   - Creates new task revision
   - Starts new tasks
   - Health checks pass
   - Drains old tasks
   - Staging deployment complete

8. Manual-Approval Stage:
   - SNS email sent
   - Pipeline pauses
   - Reviewer tests staging
   - Clicks Approve

9. Deploy-Production Stage:
   - Same process as staging
   - Deploys to production ECS service
   - Zero-downtime deployment

10. Parallel: Lambda Replication
    - EventBridge detects push
    - Lambda function triggered
    - Fetches changes from us-east-1
    - Creates commit in us-west-2
    - us-west-2 pipeline triggered
```

### ECS Task Lifecycle

```
1. Task Definition registered
   - Container image
   - CPU/Memory requirements
   - Port mappings
   - IAM role
   - Logging configuration

2. Service Creation/Update
   - ECS Scheduler plans placement
   - Chooses private subnet
   - Assigns ENI (network interface)
   - Pulls image from ECR

3. Task Startup
   - Docker pull image
   - Container starts
   - Health check begins
   - Waits for /health endpoint

4. Registration
   - Health checks pass
   - ALB registers target
   - Begins receiving traffic

5. Running State
   - Processes requests
   - Sends logs to CloudWatch
   - Reports metrics
   - Health checks every 30s

6. Updates/Scaling
   - New task definition
   - New tasks start
   - Health checks pass
   - Old tasks receive SIGTERM
   - Graceful shutdown (30s)
   - Old tasks removed

7. Failure Scenarios
   - Failed health checks
   - Container crash
   - ECS immediately starts replacement
   - Circuit breaker triggers rollback if repeated failures
```



## 🔧 Troubleshooting & Edge Cases

### Common Issues & Solutions

#### 1. Deployment Fails - Image Pull Error
**Symptom**: ECS tasks fail to start, error "CannotPullContainerError"
**Causes**:
- ECR repository doesn't exist
- Task execution role lacks ECR permissions
- Image tag doesn't exist

**Solution**:
```bash
# Verify ECR repository
aws ecr describe-repositories --repository-names logicworks-devops-repo

# Check images
aws ecr list-images --repository-name logicworks-devops-repo

# Verify IAM role has AmazonECSTaskExecutionRolePolicy
# In Terraform, this is handled by the ECS module
```

#### 2. Application Not Accessible
**Symptom**: ALB URL returns connection timeout **Debugging**:
```bash
# 1. Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# 2. Check security groups
# - ALB security group allows inbound 80/443
# - ECS security group allows inbound from ALB security group

# 3. Verify tasks are running
aws ecs list-tasks --cluster logicworks-devops-cluster-us-east-1

# 4. Check task logs
# Go to CloudWatch Logs → /ecs/logicworks-devops
```

#### 3. Pipeline Stuck in Build Stage
**Symptom**: CodeBuild runs for long time or fails **Check**:
```bash
# View build logs
aws codebuild batch-get-builds --ids <build-id>

# Common causes:
# - Docker Hub rate limit (we use ECR Public Gallery to avoid this)
# - npm install fails (check package.json)
# - Tests fail (check test output)
# - ECR login fails (check IAM permissions)
```

#### 4. High Memory Usage Leading to OOM
**Symptom**: Tasks keep restarting, CloudWatch shows memory at 100%
**Solution**:
```terraform
# Increase memory in task definition
resource "aws_ecs_task_definition" "app" {
  cpu    = "512"   # Was 256
  memory = "1024"  # Was 512
}
```

#### 5. Multi-Region Replication Not Working
**Symptom**: Code in us-west-2 is outdated **Check**:
1. Lambda function exists and has permissions
2. EventBridge rule is enabled
3. Lambda has network connectivity
4. Check Lambda CloudWatch logs for errors

**Manual replication**:
```bash
cd repo
git remote add secondary https://git-codecommit.us-west-2.amazonaws.com/v1/repos/logicworks-devops-repo
git push secondary main
```

#### 6. Terraform State Lock
**Symptom**: "Error locking state" when running terraform **Solution**:
```bash
# If using DynamoDB locking, force unlock
terraform force-unlock <lock-id>

# If local state, delete .terraform.tfstate.lock.info
rm .terraform.tfstate.lock.info
```

#### 7. NAT Gateway Costs High
**Symptom**: Unexpected AWS bill **Investigation**:
- Check CloudWatch metrics for data processed
- NAT Gateway charges per GB processed
- Each AZ has its own NAT gateway

**Optimization**:
```terraform
# For dev/test, use single NAT gateway
nat_gateway_count = var.environment == "production" ? 2 : 1
```

### Best Practices Learned

1. **Always tag resources**: Makes cost allocation and management easier
2. **Use lifecycle policies**: Automatically clean old images
3. **Implement circuit breakers**: Prevent cascading failures
4. **Monitor costs daily**: AWS Cost Explorer, set budgets
5. **Document everything**: README, QUICKSTART, architecture diagrams
6. **Automate cleanup**: Avoid orphaned resources
7. **Test disaster recovery**: Actually failover to secondary region
8. **Use remote state**: Local state is risky for teams
9. **Implement rate limiting**: Protect against DDoS
10. **Regular security audits**: Review IAM policies, security groups



## 🎓 Advanced Interview Questions

**Q31: How would you implement blue-green deployment?** **A:** ECS supports this
natively:
```terraform
deployment_controller {
  type = "CODE_DEPLOY"  # Instead of ECS
}
```
Use CodeDeploy with:
- Two target groups (blue and green)
- Traffic shifting strategies (linear, canary, all-at-once)
- Automatic rollback on CloudWatch alarms
- Testing time window before full cutover

**Q32: How would you implement canary deployments?** **A:** Using CodeDeploy:
1. Deploy new version to 10% of tasks
2. Monitor metrics for 10 minutes
3. If healthy, deploy to 50%
4. Monitor again
5. Deploy to 100%
6. Rollback automatically if alarms trigger

**Q33: How do you handle secrets rotation?** **A:**
```terraform
resource "aws_secretsmanager_secret" "db_password" {
  rotation_rules {
    automatically_after_days = 30
  }
}

# Lambda function handles rotation
# ECS tasks automatically get new value
# No application restart needed
```

**Q34: What about database migrations in CI/CD?** **A:** Add migration stage:
```yaml
# In buildspec.yml
post_build:
  - npm run migrate  # Run migrations
  - npm test         # Test against new schema
  - docker build     # Build with new code
```
Or dedicated ECS task for migrations before deployment.

**Q35: How would you implement API rate limiting?** **A:** Multiple layers:
1. **AWS WAF** on ALB: IP-based rate limiting
2. **Application**: Express middleware
3. **API Gateway**: If we switched from ALB
4. **CloudFront**: If we added CDN

**Q36: Explain your disaster recovery strategy and RTO/RPO.** **A:**
- **RTO (Recovery Time Objective)**: ~5-10 minutes
  - Route 53 health check fails
  - DNS automatically points to secondary region
  - Time = DNS TTL + health check interval

- **RPO (Recovery Point Objective)**: <5 minutes
  - Code replicated on every push
  - If primary region fails mid-push, worst case is one commit behind

**Q37: How would you implement auto-remediation?** **A:**
1. **CloudWatch Alarms** → **SNS** → **Lambda**
2. Lambda performs remediation actions:
   - Restart failed tasks
   - Scale out if high CPU
   - Invoke API to clear cache
   - Trigger backup pipeline

**Q38: How do you handle configuration drift?** **A:**
- **Terraform**: `terraform plan` shows drift
- **AWS Config**: Tracks configuration changes
- **Automated correction**: CI/CD re-applies Terraform periodically
- **Immutable infrastructure**: Never manually change, always redeploy



## 📝 Demo Talking Points Summary

### Opening Statement
*"I built a production-ready, multi-region AWS DevOps infrastructure using
Infrastructure as Code. This solution addresses all seven requirements from
Logicworks, providing automated container orchestration, CI/CD pipeline, and
comprehensive monitoring across two AWS regions."*

### Key Achievements to Highlight
1. ✅ **Complete automation**: One-command deployment and cleanup
2. ✅ **Production-ready**: Security, monitoring, high availability
3. ✅ **Multi-region**: us-east-1 and us-west-2 with automatic replication
4. ✅ **CI/CD**: Fully automated with manual approval gate
5. ✅ **Modular IaC**: Reusable Terraform modules
6. ✅ **Cost-effective**: ~$5-7 for 6-hour session
7. ✅ **Well-documented**: README, QUICKSTART, architecture diagrams

### Things to Emphasize
- **Business value**: Fast environment replication for different customers
- **Reliability**: Multi-AZ, auto-scaling, health checks, circuit breakers
- **Security**: Non-root containers, private subnets, IAM least privilege
- **Observability**: CloudWatch dashboards, alarms, logs, SNS notifications
- **Developer experience**: Simple push-to-deploy workflow

### Potential Weak Points & How to Address
1. **"Why not use EKS?"** - *"ECS Fargate is simpler, more cost-effective for
   this use case, and meets all requirements. Would recommend EKS if we needed
   Kubernetes-specific features like custom schedulers or extensive ecosystem
   tools."*

2. **"Database not included?"** - *"This is a stateless application
   demonstration. In production, I would add RDS with Multi-AZ and read
   replicas, or DynamoDB Global Tables for multi-region."*

3. **"What about HTTPS?"** - *"Would add ACM certificate to ALB listener. Didn't
   implement for demo due to domain requirement, but it's a simple Terraform
   addition."*

4. **"Local Terraform state?"** - *"For demo purposes. Production would use S3
   backend with DynamoDB locking for team collaboration and state protection."*

### Closing Statement
*"This infrastructure is fully functional, automated, and ready for production
use. It demonstrates enterprise-grade DevOps practices including Infrastructure
as Code, containerization, automated deployments, and comprehensive monitoring.
The modular design allows easy customization for different customers and use
cases."*



## 🎯 Final Preparation Checklist

### Before Demo
- [ ] AWS account has sufficient credits/time remaining
- [ ] Infrastructure deployed successfully
- [ ] Both application URLs are accessible
- [ ] Email subscriptions confirmed for SNS
- [ ] CloudWatch dashboards showing data
- [ ] CodeCommit repository has commits
- [ ] Pipeline has at least one successful execution
- [ ] Practice making a code change and pushing

### Documentation to Have Open
- [ ] [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - for architecture
  explanation
- [ ] AWS Console tabs ready (CodePipeline, ECS, CloudWatch, ECR)
- [ ] Terminal ready in project directory
- [ ] Code editor with key files visible

### Practice Responses
- [ ] "Walk me through your architecture" - use diagram
- [ ] "How does your CI/CD work?" - show pipeline stages
- [ ] "What happens when you push code?" - demo it live
- [ ] "How do you handle failures?" - explain circuit breaker, alarms
- [ ] "Why this technology stack?" - know your decisions



**Good luck with your demo! You've built something impressive. Be confident,
know your architecture, and be ready to explain the "why" behind every
decision.**
