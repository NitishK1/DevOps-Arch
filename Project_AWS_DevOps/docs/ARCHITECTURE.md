# Architecture Documentation

## Overview

This project implements a highly available, multi-region architecture on AWS
following best practices for DevOps and cloud infrastructure.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                    (Infrastructure as Code)                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ Deploy
                            ▼
    ┌───────────────────────────────────────────────────────────┐
    │                    Primary Region (us-east-1)             │
    │                                                             │
    │  ┌─────────────────────────────────────────────────────┐ │
    │  │                        VPC                           │ │
    │  │  ┌──────────────┐        ┌──────────────┐          │ │
    │  │  │ Public Subnet│        │ Public Subnet│          │ │
    │  │  │   (AZ-1)    │        │   (AZ-2)    │          │ │
    │  │  │     ALB      │        │     ALB      │          │ │
    │  │  └──────┬───────┘        └──────┬───────┘          │ │
    │  │         │                        │                   │ │
    │  │  ┌──────▼───────┐        ┌──────▼───────┐          │ │
    │  │  │Private Subnet│        │Private Subnet│          │ │
    │  │  │   (AZ-1)    │        │   (AZ-2)    │          │ │
    │  │  │  ECS Tasks   │        │  ECS Tasks   │          │ │
    │  │  └──────────────┘        └──────────────┘          │ │
    │  └─────────────────────────────────────────────────────┘ │
    │                                                             │
    │  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐   │
    │  │  CodeCommit │  │  CodeBuild   │  │ CodePipeline  │   │
    │  └─────────────┘  └──────────────┘  └───────────────┘   │
    │                                                             │
    │  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐   │
    │  │     ECR     │  │  CloudWatch  │  │      SNS      │   │
    │  └─────────────┘  └──────────────┘  └───────────────┘   │
    └───────────────────────────────────────────────────────────┘
                            │
                            │ Replication
                            ▼
    ┌───────────────────────────────────────────────────────────┐
    │                  Secondary Region (us-west-2)             │
    │              (Disaster Recovery / High Availability)      │
    │                                                             │
    │  ┌─────────────────────────────────────────────────────┐ │
    │  │                        VPC                           │ │
    │  │  ┌──────────────┐        ┌──────────────┐          │ │
    │  │  │ Public Subnet│        │ Public Subnet│          │ │
    │  │  │     ALB      │        │     ALB      │          │ │
    │  │  └──────┬───────┘        └──────┬───────┘          │ │
    │  │         │                        │                   │ │
    │  │  ┌──────▼───────┐        ┌──────▼───────┐          │ │
    │  │  │Private Subnet│        │Private Subnet│          │ │
    │  │  │  ECS Tasks   │        │  ECS Tasks   │          │ │
    │  │  └──────────────┘        └──────────────┘          │ │
    │  └─────────────────────────────────────────────────────┘ │
    │                                                             │
    │  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐   │
    │  │  CodeCommit │  │     ECR      │  │  CloudWatch   │   │
    │  │  (Replica)  │  │  (Replica)   │  │               │   │
    │  └─────────────┘  └──────────────┘  └───────────────┘   │
    └───────────────────────────────────────────────────────────┘
```

## Components

### 1. Networking (VPC)

**Primary & Secondary Regions**:
- VPC CIDR: 10.0.0.0/16 (Primary), 10.1.0.0/16 (Secondary)
- 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24) - for ALB
- 2 Private Subnets (10.0.11.0/24, 10.0.12.0/24) - for ECS tasks
- Internet Gateway for public access
- NAT Gateway for private subnet internet access
- Route tables configured appropriately

### 2. Container Infrastructure

**ECR (Elastic Container Registry)**:
- Repository for Docker images
- Image scanning enabled
- Lifecycle policies for image cleanup
- Cross-region replication to secondary region

**ECS (Elastic Container Service)**:
- Fargate launch type (serverless containers)
- Application Load Balancer for traffic distribution
- Auto-scaling based on CPU/Memory
- Health checks configured
- Blue/Green deployment support

### 3. CI/CD Pipeline

**CodeCommit**:
- Git repository for source code
- Replication from primary to secondary region
- Branch protection for main branch

**CodeBuild**:
- Docker image building
- Runs unit tests
- Pushes images to ECR
- Uses buildspec.yml for build configuration

**CodePipeline**:
- **Source Stage**: Triggers on CodeCommit changes
- **Build Stage**: CodeBuild creates Docker image
- **Staging Stage**: Deploy to staging ECS service
- **Approval Stage**: Manual approval gate
- **Production Stage**: Deploy to production ECS service

### 4. Monitoring & Alerting

**CloudWatch**:
- Custom dashboards for application metrics
- Log groups for ECS tasks, CodeBuild, etc.
- Metric alarms for:
  - High CPU utilization (>80%)
  - High memory utilization (>80%)
  - HTTP 5xx errors
  - Unhealthy target count
  - Pipeline failures

**SNS (Simple Notification Service)**:
- Topic for alarm notifications
- Email subscription configured
- Integration with CloudWatch alarms

## High Availability

### Multi-AZ Deployment
- Resources deployed across 2 Availability Zones
- Load balancer distributes traffic
- ECS tasks automatically replaced if unhealthy

### Multi-Region Strategy
- Active-active configuration
- Independent deployments in each region
- Can failover to secondary region
- Cross-region replication for ECR and CodeCommit

## Security

### Network Security
- Private subnets for application workloads
- Security groups with minimal required access
- No direct public access to ECS tasks

### IAM Roles
- Least privilege principle
- Separate roles for:
  - ECS task execution
  - ECS task role
  - CodeBuild
  - CodePipeline
  - CodeDeploy

### Application Security
- Container image scanning
- Secrets management via Systems Manager Parameter Store
- CloudWatch Logs for audit trail

## Scalability

### Auto Scaling
- ECS Service auto-scaling based on CPU/Memory
- Target tracking scaling policies
- Min: 2 tasks, Max: 10 tasks

### Load Balancing
- Application Load Balancer
- Health checks every 30 seconds
- Automatic unhealthy target removal

## Disaster Recovery

### RTO (Recovery Time Objective)
- Estimated: 15-20 minutes
- Time to deploy to secondary region

### RPO (Recovery Point Objective)
- Near zero with CodeCommit replication
- Docker images replicated to secondary region ECR

### Failover Process
1. Update DNS/Route53 to point to secondary region ALB
2. Secondary region already has deployed infrastructure
3. CodeCommit replicated automatically

## Cost Optimization

### Current Setup
- ECS Fargate (pay per use)
- NAT Gateway (consider NAT instances for dev)
- ALB (consider NLB for lower cost)
- No idle resources

### Cost Estimates (Monthly)
- ECS Fargate (2 tasks): ~$30-50
- ALB: ~$20-30
- NAT Gateway: ~$30-45
- ECR Storage: ~$5-10
- CodePipeline: ~$1 per active pipeline
- **Total**: ~$100-150 per region

## Deployment Process

1. **Initial Setup**: Terraform creates all infrastructure
2. **Application Deployment**: Push code to CodeCommit
3. **CI/CD Trigger**: Pipeline builds and deploys automatically
4. **Manual Approval**: Required for production deployment
5. **Monitoring**: CloudWatch dashboards and alarms active

## Maintenance

### Regular Tasks
- Review CloudWatch logs
- Update Docker base images
- Review and update IAM policies
- Test disaster recovery procedures
- Monitor costs

### Automated Tasks
- ECS task replacement
- Auto-scaling
- Log rotation
- Image lifecycle management

## Future Enhancements

1. **Route53**: Global traffic management with health checks
2. **WAF**: Web Application Firewall for security
3. **CloudFront**: CDN for static content
4. **RDS**: Multi-region database replication
5. **ElastiCache**: Redis for session management
6. **Secrets Manager**: Enhanced secrets management
7. **GuardDuty**: Threat detection
8. **Config**: Compliance and configuration management
