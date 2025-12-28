# Multi-Account Deployment Strategy (Dev, QA, Prod)

## Current Terraform Structure Analysis

### What It Can Handle ✅
- ✅ **Multi-region deployment** (us-east-1, us-west-2)
- ✅ **Single AWS account**
- ✅ **Single environment** (production)

### What It CANNOT Handle ❌
- ❌ **Multiple AWS accounts** (Dev, QA, Prod)
- ❌ **Environment-specific configurations**
- ❌ **Separate state management per environment**
- ❌ **Different AWS credentials per account**

## Current Limitations

### 1. Single Provider Configuration
```terraform
provider "aws" {
  region = var.primary_region
  alias  = "primary"
  # ❌ Uses default AWS credentials
  # ❌ No account ID specification
  # ❌ No assume role capability
}
```

### 2. No State Isolation
- **Current**: Local state file (`terraform.tfstate`)
- **Issue**: Cannot manage multiple environments independently
- **Risk**: One environment's state could overwrite another

### 3. Hardcoded Environment
```terraform
variable "environment" {
  default     = "production"  # ❌ Hardcoded
}
```

### 4. No Account-Specific Configuration
- No way to specify different AWS account IDs
- No cross-account IAM role assumption
- No account-specific variables

## Solution: Multi-Account Terraform Structure

### Approach 1: Directory-Based (Recommended)

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf              # References shared modules
│   │   ├── variables.tf         # Dev-specific defaults
│   │   ├── terraform.tfvars     # Dev values
│   │   ├── backend.tf           # Dev state backend
│   │   └── providers.tf         # Dev AWS account
│   │
│   ├── qa/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── providers.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── backend.tf
│       └── providers.tf
│
└── modules/                      # Shared modules (unchanged)
    ├── vpc/
    ├── ecs/
    ├── ecr/
    ├── codecommit/
    ├── codepipeline/
    └── monitoring/
```

### Approach 2: Workspace-Based (Alternative)

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod

# Switch between environments
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

**Pros**: Single codebase **Cons**: Shared state backend, easy to make mistakes

## Recommended Implementation: Directory-Based

### Step 1: Create Environment Structure

```bash
cd terraform
mkdir -p environments/{dev,qa,prod}
```

### Step 2: Configure Each Environment

#### Dev Environment (`environments/dev/providers.tf`)

```terraform
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend for Dev
  backend "s3" {
    bucket         = "logicworks-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "logicworks-terraform-locks-dev"
    encrypt        = true
  }
}

# Primary Region Provider - Dev Account
provider "aws" {
  region = var.primary_region
  alias  = "primary"

  # Option 1: Profile-based (for local development)
  profile = "dev"

  # Option 2: Assume Role (for CI/CD or cross-account)
  assume_role {
    role_arn     = "arn:aws:iam::111111111111:role/TerraformRole"
    session_name = "terraform-dev"
  }

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      Account     = "dev"
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# Secondary Region Provider - Dev Account
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"

  profile = "dev"

  assume_role {
    role_arn     = "arn:aws:iam::111111111111:role/TerraformRole"
    session_name = "terraform-dev"
  }

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      Account     = "dev"
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}
```

#### Dev Environment (`environments/dev/terraform.tfvars`)

```terraform
# Dev Account Configuration
project_name     = "logicworks-devops"
environment      = "dev"
aws_account_id   = "111111111111"

# Region Configuration
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Network Configuration
primary_vpc_cidr   = "10.0.0.0/16"
secondary_vpc_cidr = "10.1.0.0/16"

# Dev-specific: Smaller resources
container_cpu    = 256    # 0.25 vCPU
container_memory = 512    # 512 MB
desired_count    = 1      # Single task for dev
min_capacity     = 1
max_capacity     = 3

# Notifications
notification_email = "devops-dev@example.com"
```

#### QA Environment (`environments/qa/terraform.tfvars`)

```terraform
# QA Account Configuration
project_name     = "logicworks-devops"
environment      = "qa"
aws_account_id   = "222222222222"

# Region Configuration
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Network Configuration
primary_vpc_cidr   = "10.10.0.0/16"    # Different CIDR
secondary_vpc_cidr = "10.11.0.0/16"

# QA-specific: Medium resources
container_cpu    = 256
container_memory = 512
desired_count    = 2      # 2 tasks for QA
min_capacity     = 1
max_capacity     = 5

# Notifications
notification_email = "devops-qa@example.com"
```

#### Prod Environment (`environments/prod/terraform.tfvars`)

```terraform
# Production Account Configuration
project_name     = "logicworks-devops"
environment      = "production"
aws_account_id   = "333333333333"

# Region Configuration
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Network Configuration
primary_vpc_cidr   = "10.20.0.0/16"    # Different CIDR
secondary_vpc_cidr = "10.21.0.0/16"

# Production: Full resources
container_cpu    = 512    # 0.5 vCPU
container_memory = 1024   # 1 GB
desired_count    = 3      # 3 tasks minimum
min_capacity     = 3
max_capacity     = 10

# Enable additional features for production
enable_deletion_protection = true
enable_enhanced_monitoring = true

# Notifications
notification_email = "devops-prod@example.com"
```

#### Environment Main File (`environments/dev/main.tf`)

```terraform
# Reference shared modules from parent directory
module "primary_vpc" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
  region       = var.primary_region
  vpc_cidr     = var.primary_vpc_cidr
  azs          = var.primary_azs
}

module "primary_ecr" {
  source = "../../modules/ecr"
  providers = {
    aws = aws.primary
  }

  project_name = var.project_name
  environment  = var.environment
}

# ... rest of modules ...
```

### Step 3: Update Modules for Multi-Account

#### Add Account ID Variables

**File: `terraform/modules/ecr/variables.tf`** (and other modules)

```terraform
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
}
```

#### Use Account-Specific Naming

**File: `terraform/modules/ecr/main.tf`**

```terraform
resource "aws_ecr_repository" "main" {
  name = "${var.project_name}-repo-${var.environment}"  # Include environment

  # ... rest of config ...
}
```

### Step 4: AWS Account Setup

#### Create IAM Roles in Each Account

**Dev Account (111111111111):**
```bash
# Create Terraform execution role
aws iam create-role \
  --role-name TerraformRole \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name TerraformRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

**Trust Policy (`trust-policy.json`):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR-MGMT-ACCOUNT:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### Configure AWS CLI Profiles

**File: `~/.aws/config`**

```ini
[profile dev]
region = us-east-1
role_arn = arn:aws:iam::111111111111:role/TerraformRole
source_profile = default

[profile qa]
region = us-east-1
role_arn = arn:aws:iam::222222222222:role/TerraformRole
source_profile = default

[profile prod]
region = us-east-1
role_arn = arn:aws:iam::333333333333:role/TerraformRole
source_profile = default
```

### Step 5: Create State Backends

#### S3 Buckets for State

```bash
# Dev state bucket
aws s3 mb s3://logicworks-terraform-state-dev --region us-east-1
aws s3api put-bucket-versioning \
  --bucket logicworks-terraform-state-dev \
  --versioning-configuration Status=Enabled

# QA state bucket
aws s3 mb s3://logicworks-terraform-state-qa --region us-east-1
aws s3api put-bucket-versioning \
  --bucket logicworks-terraform-state-qa \
  --versioning-configuration Status=Enabled

# Prod state bucket
aws s3 mb s3://logicworks-terraform-state-prod --region us-east-1
aws s3api put-bucket-versioning \
  --bucket logicworks-terraform-state-prod \
  --versioning-configuration Status=Enabled
```

#### DynamoDB Tables for Locking

```bash
# Dev lock table
aws dynamodb create-table \
  --table-name logicworks-terraform-locks-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# QA lock table
aws dynamodb create-table \
  --table-name logicworks-terraform-locks-qa \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Prod lock table
aws dynamodb create-table \
  --table-name logicworks-terraform-locks-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Deployment Workflow

### Deploy to Dev

```bash
cd terraform/environments/dev

# Initialize (only first time)
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

### Deploy to QA

```bash
cd terraform/environments/qa

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Deploy to Production

```bash
cd terraform/environments/prod

terraform init
terraform plan -out=tfplan

# Extra caution for production
# Review plan carefully
terraform show tfplan

# Apply
terraform apply tfplan
```

## Automated Deployment Scripts

### Create Environment-Aware Script

**File: `scripts/deploy-environment.sh`**

```bash
#!/bin/bash

# Usage: ./scripts/deploy-environment.sh dev|qa|prod

set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "  environment: dev, qa, or prod"
  exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|qa|prod)$ ]]; then
  echo "Error: Environment must be dev, qa, or prod"
  exit 1
fi

echo "========================================="
echo "Deploying to $ENVIRONMENT environment"
echo "========================================="

cd "terraform/environments/$ENVIRONMENT"

# Initialize
echo "Initializing Terraform..."
terraform init

# Validate
echo "Validating configuration..."
terraform validate

# Plan
echo "Creating execution plan..."
terraform plan -out=tfplan

# Prompt for approval (except in CI/CD)
if [ -z "$CI" ]; then
  read -p "Apply this plan to $ENVIRONMENT? (yes/no): " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
  fi
fi

# Apply
echo "Applying changes..."
terraform apply tfplan

echo "========================================="
echo "Deployment to $ENVIRONMENT complete!"
echo "========================================="

# Show outputs
terraform output
```

### Make it executable

```bash
chmod +x scripts/deploy-environment.sh
```

### Usage

```bash
# Deploy to dev
./scripts/deploy-environment.sh dev

# Deploy to QA
./scripts/deploy-environment.sh qa

# Deploy to production (with extra confirmation)
./scripts/deploy-environment.sh prod
```

## CI/CD Integration

### GitHub Actions Example

**File: `.github/workflows/deploy-dev.yml`**

```yaml
name: Deploy to Dev

on:
  push:
    branches: [develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::111111111111:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        working-directory: terraform/environments/dev
        run: terraform init

      - name: Terraform Plan
        working-directory: terraform/environments/dev
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        working-directory: terraform/environments/dev
        run: terraform apply -auto-approve tfplan
```

**File: `.github/workflows/deploy-prod.yml`**

```yaml
name: Deploy to Production

on:
  workflow_dispatch:  # Manual trigger only
    inputs:
      confirm:
        description: 'Type "deploy-to-prod" to confirm'
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    if: github.event.inputs.confirm == 'deploy-to-prod'

    steps:
      # ... same as dev but with prod credentials and environment
```

## Cost Considerations

### Per Environment (Monthly)

| Resource | Dev | QA | Prod | Notes |
|----------|-----|-----|------|-------|
| ECS Tasks | 1 task | 2 tasks | 3 tasks | Different capacity |
| Task Size | 0.25 vCPU | 0.25 vCPU | 0.5 vCPU | Prod gets more resources |
| ALB | $25 | $25 | $25 | Fixed cost |
| NAT Gateway | $35 | $35 | $70 | Prod: 2 AZs, Dev/QA: 1 AZ |
| ECR | $5 | $5 | $5 | Minimal storage |
| **Total/Region** | **~$80** | **~$100** | **~$150** | Approximate |

### Multi-Region Costs

- **Dev**: Single region only (~$80/month)
- **QA**: Single region only (~$100/month)
- **Prod**: Both regions (~$300/month)

**Total: ~$480/month** for all environments

### Cost Optimization Strategies

1. **Dev**: Single region, single AZ NAT, smallest resources
2. **QA**: Single region, scheduled auto-shutdown nights/weekends
3. **Prod**: Full multi-region, high availability

## Environment-Specific Features

### Development Environment

```terraform
# Dev-specific features
enable_deletion_protection = false
enable_enhanced_monitoring = false
log_retention_days        = 3    # Short retention
desired_count             = 1    # Minimal capacity
nat_gateway_count         = 1    # Single NAT
enable_vpc_flow_logs      = false

# Auto-shutdown schedule (save costs)
enable_auto_shutdown      = true
shutdown_cron            = "0 20 * * *"  # 8 PM
startup_cron             = "0 8 * * *"   # 8 AM
```

### QA Environment

```terraform
# QA-specific features
enable_deletion_protection = false
enable_enhanced_monitoring = true
log_retention_days        = 7
desired_count             = 2
nat_gateway_count         = 1
enable_vpc_flow_logs      = true

# Load testing enabled
max_capacity              = 5
enable_stress_testing     = true
```

### Production Environment

```terraform
# Production-specific features
enable_deletion_protection = true   # Prevent accidental deletion
enable_enhanced_monitoring = true
log_retention_days        = 30      # Longer retention
desired_count             = 3       # High availability
nat_gateway_count         = 2       # One per AZ
enable_vpc_flow_logs      = true
enable_waf                = true    # Web Application Firewall
enable_shield             = true    # DDoS protection

# Backup configuration
enable_automated_backups  = true
backup_retention_days     = 30

# Alerts
enable_pagerduty          = true
enable_slack_alerts       = true
```

## Comparison: Current vs Multi-Account Structure

### Current Structure

```
terraform/
├── main.tf           ❌ Single account, single environment
├── variables.tf      ❌ No environment separation
├── modules/          ✅ Reusable
└── terraform.tfstate ❌ Single state file
```

**Limitations:**
- Cannot deploy to multiple accounts
- No environment isolation
- Risk of state conflicts
- One size fits all configuration

### Recommended Structure

```
terraform/
├── environments/
│   ├── dev/          ✅ Isolated configuration
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── qa/           ✅ Separate state
│   └── prod/         ✅ Different AWS account
└── modules/          ✅ Shared across environments
    ├── vpc/
    ├── ecs/
    └── ...
```

**Benefits:**
- ✅ Complete environment isolation
- ✅ Different AWS accounts
- ✅ Environment-specific configurations
- ✅ Independent state management
- ✅ Reduced risk of accidents
- ✅ Parallel development possible

## Migration Path

### Phase 1: Prepare Structure (1 day)

1. Create environment directories
2. Copy current config to `environments/prod/`
3. Set up remote state backends
4. Test production deployment

### Phase 2: Add QA (1 day)

1. Create `environments/qa/`
2. Configure QA AWS account
3. Deploy to QA
4. Test end-to-end

### Phase 3: Add Dev (1 day)

1. Create `environments/dev/`
2. Configure dev AWS account
3. Deploy to dev
4. Update documentation

### Phase 4: CI/CD Integration (1 day)

1. Set up GitHub Actions/Jenkins
2. Configure auto-deploy to dev
3. Manual approval for QA
4. Strict approval for prod

## Interview Talking Points

### When Asked About Multi-Account Strategy

**Good Answer:**

*"The current Terraform structure uses a single AWS account with multi-region
deployment. While this works for the demo, in a real enterprise scenario, I
would restructure it for multi-account deployment across Dev, QA, and Production
accounts.*

*I would use a directory-based approach with separate state backends per
environment. Each environment would have its own `providers.tf` with assume role
configuration to deploy to different AWS accounts. This provides complete
isolation, prevents accidental changes to production, and allows
environment-specific configurations like smaller resources in dev and full HA
setup in production.*

*For state management, I'd use separate S3 buckets and DynamoDB tables per
environment, with appropriate IAM policies to prevent cross-environment access.
The shared modules would remain reusable across all environments, maintaining
code consistency while allowing environment-specific parameter overrides."*

**This Shows:**
- ✅ Understanding of enterprise multi-account strategy
- ✅ Knowledge of Terraform best practices
- ✅ Security and isolation awareness
- ✅ Practical implementation experience

## Conclusion

### Current Terraform Structure:
- **Can Handle**: Single account, multi-region
- **Cannot Handle**: Multi-account, environment isolation

### Required Changes:
1. ✅ Directory-based environment structure
2. ✅ Separate providers with assume role
3. ✅ Remote state backends per environment
4. ✅ Environment-specific variables
5. ✅ IAM roles in each AWS account
6. ✅ Updated deployment scripts

### Effort Required:
- **Code restructuring**: 1-2 days
- **AWS setup**: 1 day
- **Testing**: 1 day
- **Total**: ~4-5 days

### Benefits:
- Complete environment isolation
- Reduced risk of production accidents
- Environment-specific sizing (cost savings)
- Parallel development possible
- Enterprise-grade architecture
