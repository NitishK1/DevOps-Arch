# AWS DevOps Multi-Region Project

A complete Infrastructure as Code (IaC) solution for deploying a containerized
application across multiple AWS regions with automated CI/CD pipeline,
monitoring, and high availability.

## 🎯 Project Overview

This project demonstrates a production-ready AWS DevOps setup that includes:
- ✅ Multi-region architecture (us-east-1 & us-west-2)
- ✅ Container orchestration with ECS Fargate
- ✅ Automated CI/CD pipeline with manual approval
- ✅ ECR for Docker image repository
- ✅ Multi-region CodeCommit repository replication
- ✅ CloudWatch monitoring with SNS notifications
- ✅ Complete Infrastructure as Code using Terraform

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform (>= 1.0)
- Git
- Docker (for local testing)

## 🚀 Quick Start

### 1. Configure Credentials
```bash
# Copy the template and fill in your AWS credentials
cp config/credentials.template.sh config/credentials.sh
nano config/credentials.sh
```

### 2. Deploy Infrastructure
```bash
# Initialize and deploy everything
./scripts/deploy.sh
```

### 3. Access Application
The script will output the load balancer URLs for both regions.

### 4. Cleanup (Before AWS Account Expires)
```bash
# Destroy all resources
./scripts/cleanup.sh
```

## 📁 Project Structure

```
Project_AWS_DevOps/
├── app/                          # Sample Node.js application
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Main configuration
│   ├── variables.tf              # Variables definition
│   ├── outputs.tf                # Output values
│   ├── modules/
│   │   ├── vpc/                  # VPC module
│   │   ├── ecr/                  # ECR repository
│   │   ├── ecs/                  # ECS cluster & service
│   │   ├── codecommit/           # CodeCommit repository
│   │   ├── codepipeline/         # CI/CD pipeline
│   │   └── monitoring/           # CloudWatch & SNS
├── scripts/                      # Automation scripts
│   ├── deploy.sh                 # Main deployment script
│   ├── cleanup.sh                # Resource cleanup
│   └── push-app.sh               # Push app to CodeCommit
├── config/                       # Configuration files
│   ├── credentials.template.sh   # Template for AWS credentials
│   └── buildspec.yml             # CodeBuild specification
└── docs/                         # Documentation
    ├── ARCHITECTURE.md
    └── TROUBLESHOOTING.md
```

## 🏗️ Architecture

### Primary Region (us-east-1)
- VPC with public/private subnets across 2 AZs
- Application Load Balancer (ALB)
- ECS Fargate cluster running containerized app
- ECR repository for Docker images
- CodeCommit repository
- CodePipeline with Build, Staging, Approval, Production stages
- CloudWatch dashboards and alarms
- SNS topic for notifications

### Secondary Region (us-west-2)
- Replicated infrastructure for disaster recovery
- CodeCommit repository replication
- Independent ECS deployment

## 🔄 CI/CD Pipeline

1. **Source**: CodeCommit triggers on main branch
2. **Build**: CodeBuild creates Docker image and pushes to ECR
3. **Deploy to Staging**: Automatic deployment to staging ECS service
4. **Manual Approval**: Required before production deployment
5. **Deploy to Production**: Production ECS service update

## 📊 Monitoring

- **CloudWatch Dashboards**: Application and infrastructure metrics
- **Alarms**: CPU, Memory, HTTP errors, unhealthy targets
- **SNS Notifications**: Email alerts for critical events

## 💾 State Management

Terraform state is stored locally. For production use, consider:
- S3 backend with state locking (DynamoDB)
- Different state files per environment/region

## 🔐 Security Best Practices

- IAM roles with least privilege
- Security groups with minimal required access
- Private subnets for ECS tasks
- ECR image scanning enabled
- CloudWatch Logs for audit trail

## 📝 Notes for 6-Hour AWS Account

Since your AWS account credentials change every 6 hours:

1. **Before Session Expires**:
   - Run `./scripts/cleanup.sh` to destroy all resources
   - Push your code changes to GitHub

2. **With New AWS Account**:
   - Update `config/credentials.sh` with new credentials
   - Run `./scripts/deploy.sh` to recreate everything

3. **Estimated Deployment Time**: 15-20 minutes
4. **Estimated Cleanup Time**: 10-15 minutes

## 🎓 Learning Objectives

- Multi-region AWS architecture
- Infrastructure as Code with Terraform
- Container orchestration with ECS
- CI/CD automation with AWS CodePipeline
- Monitoring and alerting with CloudWatch
- High availability and disaster recovery patterns

## 📖 Additional Documentation

- [Architecture Details](docs/ARCHITECTURE.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

## 🤝 Support

For issues or questions, refer to the troubleshooting guide or AWS
documentation.


**Project**: Logicworks AWS DevOps Multi-Region Setup **Last Updated**: December
2025
