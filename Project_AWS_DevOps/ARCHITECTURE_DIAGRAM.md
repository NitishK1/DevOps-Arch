# Multi-Region AWS DevOps Architecture Diagram

## Architecture Overview (Copy this for your Word document)

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          DEVELOPER WORKSTATION                                 ║
║                                                                                ║
║  ┌────────────────────────────────────────────────────────────┐              ║
║  │  Git Push to Primary CodeCommit (us-east-1)                 │              ║
║  │  ./scripts/push-app.sh                                      │              ║
║  └──────────────────────┬─────────────────────────────────────┘              ║
╚═════════════════════════┼══════════════════════════════════════════════════════╝
                          │
                          ▼
╔═════════════════════════════════════════════════════════════════════════════════╗
║                           PRIMARY REGION (us-east-1)                            ║
║                                                                                 ║
║  ┌─────────────────────────────────────────────────────────────────────┐      ║
║  │  CodeCommit Repository: logicworks-devops-repo                      │      ║
║  │  Branch: main                                                        │      ║
║  └────────┬────────────────────────────────────────────┬────────────────┘      ║
║           │                                             │                       ║
║           ▼                                             ▼                       ║
║  ┌──────────────────────┐                    ┌──────────────────────┐         ║
║  │  EventBridge Rule    │                    │  EventBridge Rule    │         ║
║  │  (CodeCommit Push)   │                    │  (Pipeline Trigger)  │         ║
║  └──────────┬───────────┘                    └──────────┬───────────┘         ║
║             │                                            │                      ║
║             ▼                                            ▼                      ║
║  ┌──────────────────────────────┐          ┌─────────────────────────────┐   ║
║  │  Lambda Function             │          │  CodePipeline               │   ║
║  │  Replication Logic           │          │  ┌────────────────────────┐ │   ║
║  │  - Get commit from primary   │          │  │ 1. Source (CodeCommit) │ │   ║
║  │  - Fetch all changed files   │          │  └────────────────────────┘ │   ║
║  │  - Create commit in secondary│          │  ┌────────────────────────┐ │   ║
║  └──────────┬───────────────────┘          │  │ 2. Build (CodeBuild)   │ │   ║
║             │                               │  │    - Docker build      │ │   ║
║             │ Cross-region replication     │  │    - Push to ECR       │ │   ║
║             │                               │  └────────────────────────┘ │   ║
║             ▼                               │  ┌────────────────────────┐ │   ║
║  ┌────────────────────────────┐            │  │ 3. Deploy Staging      │ │   ║
║  │ Secondary CodeCommit       │            │  │    - ECS Service       │ │   ║
║  │ (us-east-2)                │            │  └────────────────────────┘ │   ║
║  └────────────────────────────┘            │  ┌────────────────────────┐ │   ║
║                                             │  │ 4. Manual Approval     │ │   ║
║  ┌──────────────────────┐                  │  │    - SNS Notification  │ │   ║
║  │  ECR Repository      │                  │  └────────────────────────┘ │   ║
║  │  Docker Images       │◄─────────────────│  ┌────────────────────────┐ │   ║
║  └──────────────────────┘                  │  │ 5. Deploy Production   │ │   ║
║                                             │  │    - ECS Service       │ │   ║
║  ┌──────────────────────────────────────┐  │  └────────────────────────┘ │   ║
║  │  VPC (10.0.0.0/16)                   │  └─────────────────────────────┘   ║
║  │  ┌────────────────┬──────────────┐   │                                    ║
║  │  │ Public Subnet  │ Public Subnet│   │  ┌──────────────────────────────┐ ║
║  │  │ us-east-1a     │ us-east-1b   │   │  │  CloudWatch                  │ ║
║  │  │ ┌────────────┐ │ ┌──────────┐ │   │  │  - Dashboard                 │ ║
║  │  │ │    ALB     │ │ │   ALB    │ │   │  │  - Alarms (CPU, Memory, etc) │ ║
║  │  │ │  Target Grp│ │ │ Target Grp│ │  │  │  - Logs (ECS, Build, Lambda) │ ║
║  │  │ └────────────┘ │ └──────────┘ │   │  └──────────────────────────────┘ ║
║  │  └────────────────┴──────────────┘   │                                    ║
║  │  ┌────────────────┬──────────────┐   │  ┌──────────────────────────────┐ ║
║  │  │ Private Subnet │ Private Subnet│  │  │  SNS Topics                  │ ║
║  │  │ us-east-1a     │ us-east-1b   │   │  │  - Pipeline Approval         │ ║
║  │  │ ┌────────────┐ │ ┌──────────┐ │   │  │  - CloudWatch Alarms         │ ║
║  │  │ │ ECS Tasks  │ │ │ ECS Tasks│ │   │  │  Email: <your-email>         │ ║
║  │  │ │ (Fargate)  │ │ │ (Fargate)│ │   │  └──────────────────────────────┘ ║
║  │  │ └────────────┘ │ └──────────┘ │   │                                    ║
║  │  │ NAT Gateway    │ NAT Gateway  │   │                                    ║
║  │  └────────────────┴──────────────┘   │                                    ║
║  │  Internet Gateway                    │                                    ║
║  └──────────────────────────────────────┘                                    ║
║                                                                                ║
║  Application URL:                                                             ║
║  http://logicworks-devops-alb-us-east-1-799240009.us-east-1.elb.amazonaws.com║
╚════════════════════════════════════════════════════════════════════════════════╝
                                    │
                                    │ Code Replication
                                    │ via Lambda
                                    ▼
╔═════════════════════════════════════════════════════════════════════════════════╗
║                          SECONDARY REGION (us-east-2)                           ║
║                                                                                 ║
║  ┌─────────────────────────────────────────────────────────────────────┐      ║
║  │  CodeCommit Repository: logicworks-devops-repo                      │      ║
║  │  Branch: main (replicated from primary)                             │      ║
║  └────────┬────────────────────────────────────────────────────────────┘      ║
║           │                                                                     ║
║           ▼                                                                     ║
║  ┌──────────────────────┐                                                      ║
║  │  EventBridge Rule    │                                                      ║
║  │  (Pipeline Trigger)  │                                                      ║
║  └──────────┬───────────┘                                                      ║
║             │                                                                   ║
║             ▼                                                                   ║
║  ┌─────────────────────────────┐                                              ║
║  │  CodePipeline               │                                              ║
║  │  ┌────────────────────────┐ │                                              ║
║  │  │ 1. Source (CodeCommit) │ │                                              ║
║  │  └────────────────────────┘ │                                              ║
║  │  ┌────────────────────────┐ │                                              ║
║  │  │ 2. Build (CodeBuild)   │ │                                              ║
║  │  │    - Docker build      │ │                                              ║
║  │  │    - Push to ECR       │ │                                              ║
║  │  └────────────────────────┘ │                                              ║
║  │  ┌────────────────────────┐ │                                              ║
║  │  │ 3. Deploy Staging      │ │                                              ║
║  │  │    - ECS Service       │ │                                              ║
║  │  └────────────────────────┘ │                                              ║
║  │  ┌────────────────────────┐ │                                              ║
║  │  │ 4. Manual Approval     │ │                                              ║
║  │  │    - SNS Notification  │ │                                              ║
║  │  └────────────────────────┘ │                                              ║
║  │  ┌────────────────────────┐ │                                              ║
║  │  │ 5. Deploy Production   │ │                                              ║
║  │  │    - ECS Service       │ │                                              ║
║  │  └────────────────────────┘ │                                              ║
║  └─────────────────────────────┘                                              ║
║                                                                                 ║
║  ┌──────────────────────┐                                                      ║
║  │  ECR Repository      │                                                      ║
║  │  Docker Images       │                                                      ║
║  └──────────────────────┘                                                      ║
║                                                                                 ║
║  ┌──────────────────────────────────────┐                                     ║
║  │  VPC (10.1.0.0/16)                   │                                     ║
║  │  ┌────────────────┬──────────────┐   │                                     ║
║  │  │ Public Subnet  │ Public Subnet│   │                                     ║
║  │  │ us-east-2a     │ us-east-2b   │   │                                     ║
║  │  │ ┌────────────┐ │ ┌──────────┐ │   │                                     ║
║  │  │ │    ALB     │ │ │   ALB    │ │   │                                     ║
║  │  │ │  Target Grp│ │ │ Target Grp│ │  │                                     ║
║  │  │ └────────────┘ │ └──────────┘ │   │                                     ║
║  │  └────────────────┴──────────────┘   │                                     ║
║  │  ┌────────────────┬──────────────┐   │  ┌──────────────────────────────┐  ║
║  │  │ Private Subnet │ Private Subnet│  │  │  CloudWatch                  │  ║
║  │  │ us-east-2a     │ us-east-2b   │   │  │  - Dashboard                 │  ║
║  │  │ ┌────────────┐ │ ┌──────────┐ │   │  │  - Alarms                    │  ║
║  │  │ │ ECS Tasks  │ │ │ ECS Tasks│ │   │  │  - Logs                      │  ║
║  │  │ │ (Fargate)  │ │ │ (Fargate)│ │   │  └──────────────────────────────┘  ║
║  │  │ └────────────┘ │ └──────────┘ │   │                                     ║
║  │  │ NAT Gateway    │ NAT Gateway  │   │  ┌──────────────────────────────┐  ║
║  │  └────────────────┴──────────────┘   │  │  SNS Topics                  │  ║
║  │  Internet Gateway                    │  │  - Pipeline Approval         │  ║
║  └──────────────────────────────────────┘  │  - CloudWatch Alarms         │  ║
║                                             └──────────────────────────────┘  ║
║  Application URL:                                                             ║
║  http://logicworks-devops-alb-us-east-2-234487.us-east-2.elb.amazonaws.com   ║
╚════════════════════════════════════════════════════════════════════════════════╝

```

## Component Details

### Infrastructure Layer
- **VPC**: Isolated network in each region with CIDR blocks (10.0.0.0/16, 10.1.0.0/16)
- **Subnets**: 2 public + 2 private subnets per region across multiple AZs
- **NAT Gateways**: 2 per region for high availability
- **Internet Gateway**: 1 per VPC for internet connectivity
- **ALB**: Application Load Balancer distributing traffic to ECS tasks

### Container Layer
- **ECS Fargate**: Serverless container orchestration (2-10 tasks per service)
- **ECR**: Docker image registry in each region
- **Docker**: Multi-stage builds for optimized images

### CI/CD Layer
- **CodeCommit**: Source code repository in both regions
- **CodePipeline**: 5-stage pipeline (Source → Build → Staging → Approval → Production)
- **CodeBuild**: Docker image builds with buildspec.yml
- **EventBridge**: Event-driven pipeline triggers

### Replication Layer
- **Lambda Function**: Python 3.11 function for cross-region replication
- **EventBridge Rule**: Triggers Lambda on CodeCommit push events
- **IAM Roles**: Cross-region permissions for Lambda

### Monitoring Layer
- **CloudWatch Dashboards**: Real-time metrics visualization
- **CloudWatch Alarms**: Threshold-based alerting (CPU, Memory, ALB errors)
- **CloudWatch Logs**: Centralized logging (ECS, CodeBuild, Lambda, VPC)
- **SNS**: Email notifications for alarms and approvals

## Data Flow

### 1. Code Deployment Flow
```
Developer Push → Primary CodeCommit → Lambda Replication → Secondary CodeCommit
                        ↓                                            ↓
                   EventBridge                               EventBridge
                        ↓                                            ↓
                 Primary Pipeline                          Secondary Pipeline
                        ↓                                            ↓
                   CodeBuild                                    CodeBuild
                        ↓                                            ↓
                   Primary ECR                                 Secondary ECR
                        ↓                                            ↓
                   ECS Staging                                 ECS Staging
                        ↓                                            ↓
                Manual Approval                            Manual Approval
                        ↓                                            ↓
                 ECS Production                              ECS Production
```

### 2. Application Traffic Flow
```
User Request → ALB (Health Check) → Target Group → ECS Tasks (Fargate) → Response
                ↓
         CloudWatch Metrics
                ↓
         Alarms (if threshold exceeded)
                ↓
         SNS Email Notification
```

### 3. Monitoring Flow
```
Application Logs → CloudWatch Logs → Metric Filters → CloudWatch Alarms → SNS → Email
ECS Metrics → CloudWatch Dashboard
Pipeline Events → CloudWatch Logs
Lambda Execution → CloudWatch Logs
```

## High Availability Features

1. **Multi-AZ Deployment**: Resources spread across 2 availability zones per region
2. **Regional Isolation**: Complete infrastructure duplication in 2 regions
3. **Auto-Scaling**: ECS tasks scale 2-10 based on CPU/Memory
4. **Load Balancing**: ALB distributes traffic with health checks
5. **Redundant NAT Gateways**: 2 per region for HA
6. **Independent Pipelines**: Regional failures don't affect other region

## Security Measures

1. **IAM Least Privilege**: Minimal permissions per service
2. **Private Subnets**: ECS tasks run in private subnets
3. **Security Groups**: Restrict traffic between components
4. **VPC Flow Logs**: Network traffic logging
5. **ECR Encryption**: Images encrypted at rest
6. **Secrets Management**: No hardcoded credentials

## Disaster Recovery

- **RTO (Recovery Time Objective)**: < 5 minutes (switch traffic to healthy region)
- **RPO (Recovery Point Objective)**: < 1 minute (code replicated in real-time)
- **Failover Strategy**: Manual Route53 failover or automatic via health checks
- **Backup Strategy**: CodeCommit in both regions, ECR images in both regions

---

## Simplified Architecture Diagram (Alternative)

For a simpler diagram in your Word document, use this:

```
┌─────────────────────────────────────────────────────────────┐
│                        DEVELOPER                             │
│                     (Git Push Code)                          │
└────────────────────────┬────────────────────────────────────┘
                         │
           ┌─────────────┴──────────────┐
           ▼                            ▼
    ┌─────────────┐             ┌─────────────┐
    │  us-east-1  │   Lambda    │  us-east-2  │
    │  (Primary)  │─Replication→│ (Secondary) │
    └─────────────┘             └─────────────┘
           │                            │
    ┌──────┴──────┐              ┌──────┴──────┐
    │ CodeCommit  │              │ CodeCommit  │
    │ CodePipeline│              │ CodePipeline│
    │ CodeBuild   │              │ CodeBuild   │
    │ ECR         │              │ ECR         │
    │ ECS Fargate │              │ ECS Fargate │
    │ ALB         │              │ ALB         │
    │ CloudWatch  │              │ CloudWatch  │
    └──────┬──────┘              └──────┬──────┘
           │                            │
           ▼                            ▼
    ┌─────────────┐             ┌─────────────┐
    │ Application │             │ Application │
    │   Running   │             │   Running   │
    │   HTTP 200  │             │   HTTP 200  │
    └─────────────┘             └─────────────┘
```

---

## Technology Stack Summary

**Core AWS Services (11)**
1. VPC - Networking
2. ECS Fargate - Container orchestration
3. ECR - Container registry
4. ALB - Load balancing
5. CodeCommit - Source control
6. CodePipeline - CI/CD orchestration
7. CodeBuild - Build automation
8. Lambda - Replication automation
9. EventBridge - Event-driven triggers
10. CloudWatch - Monitoring & logging
11. SNS - Notifications

**Supporting Services**
- IAM (Identity & Access Management)
- NAT Gateway (Outbound internet)
- Internet Gateway (Inbound internet)
- Security Groups (Firewall)

**Development Tools**
- Terraform (Infrastructure as Code)
- Docker (Containerization)
- Git (Version control)
- Bash scripts (Automation)

---

Use this diagram as reference for creating a visual architecture diagram in tools like:
- Microsoft Visio
- Lucidchart
- Draw.io
- PowerPoint SmartArt
- Or simply include the ASCII diagram in your Word document
