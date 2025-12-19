# Quick Start Guide

Get your AWS DevOps Multi-Region infrastructure up and running in 3 simple
steps!

## ⚡ Prerequisites (5 minutes)

### 1. Install Required Tools

**Windows (PowerShell as Administrator):**
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install terraform awscli docker-desktop git -y
```

**macOS:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install terraform awscli docker git
```

**Linux (Ubuntu/Debian):**
```bash
# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose git -y
sudo usermod -aG docker $USER
```

### 2. Verify Installations
```bash
terraform --version
aws --version
docker --version
git --version
```

## 🚀 Deploy Infrastructure (15 minutes)

### Step 1: Configure Credentials

```bash
# Navigate to project directory
cd Project_AWS_DevOps

# Copy credentials template
cp config/credentials.template.sh config/credentials.sh

# Edit with your AWS credentials
# Windows: notepad config/credentials.sh
# Mac/Linux: nano config/credentials.sh
```

**Required values in `credentials.sh`:**
```bash
export AWS_ACCESS_KEY_ID="AKIA..."           # Your AWS access key
export AWS_SECRET_ACCESS_KEY="xxxxx..."     # Your AWS secret key
export AWS_DEFAULT_REGION="us-east-1"       # Default region
export NOTIFICATION_EMAIL="you@email.com"   # Your email for alerts
export PROJECT_NAME="logicworks-devops"     # Project name
export ENVIRONMENT="production"             # Environment
export PRIMARY_REGION="us-east-1"          # Primary region
export SECONDARY_REGION="us-west-2"        # Secondary region
```

### Step 2: Deploy Everything

**Linux/Mac:**
```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

**Windows (Git Bash):**
```bash
bash scripts/deploy.sh
```

**What happens during deployment:**
1. ✓ Validates AWS credentials (30 seconds)
2. ✓ Initializes Terraform (1 minute)
3. ✓ Creates infrastructure in both regions (12-15 minutes)
   - VPCs, subnets, NAT gateways
   - ECS clusters and services
   - Application Load Balancers
   - ECR repositories
   - CodeCommit, CodeBuild, CodePipeline
   - CloudWatch dashboards and alarms
4. ✓ Builds and pushes Docker images (2 minutes)
5. ✓ Deploys application to ECS (2 minutes)
6. ✓ Sets up CodeCommit repository (1 minute)

**Total time: ~15-20 minutes**

### Step 3: Confirm SNS Subscriptions

1. Check your email inbox
2. Find emails from "AWS Notifications"
3. Click "Confirm subscription" links (2 emails)
   - One for pipeline approvals
   - One for CloudWatch alarms

## 🎯 Access Your Application

After deployment completes, you'll see output like:

```
PRIMARY REGION (us-east-1):
├─ Application URL: http://logicworks-alb-us-east-1-123456789.us-east-1.elb.amazonaws.com
├─ ECS Cluster: logicworks-devops-cluster-us-east-1
└─ CloudWatch Dashboard: logicworks-devops-dashboard-us-east-1

SECONDARY REGION (us-west-2):
├─ Application URL: http://logicworks-alb-us-west-2-123456789.us-west-2.elb.amazonaws.com
├─ ECS Cluster: logicworks-devops-cluster-us-west-2
└─ CloudWatch Dashboard: logicworks-devops-dashboard-us-west-2
```

**Visit the application URLs in your browser!**

## 🔄 Test CI/CD Pipeline

### Make a Change
```bash
# Edit the application
nano app/server.js  # or use your favorite editor

# Change something, like the title
# FROM: <h1>🚀 Logicworks DevOps</h1>
# TO:   <h1>🚀 Logicworks DevOps v2.0</h1>

# Push changes
./scripts/push-app.sh "Updated application title"
```

### Monitor Pipeline
1. Go to AWS Console → CodePipeline
2. Watch your pipeline execute:
   - ✓ Source: Pulls from CodeCommit
   - ✓ Build: Builds Docker image
   - ✓ Deploy_Staging: Deploys to staging
   - ⏸️ Approval: Waiting for your approval
   - ⏳ Deploy_Production: Pending

3. Approve deployment:
   - Check your email for approval request
   - Click "Approve" link
   - Or approve in AWS Console

4. Watch production deployment complete

## 📊 Monitor Your Infrastructure

### CloudWatch Dashboards
```
Primary Region:
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:

Secondary Region:
https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:
```

**Metrics you'll see:**
- ECS CPU and Memory utilization
- ALB request count and response times
- HTTP response codes (2XX, 4XX, 5XX)
- Healthy/Unhealthy target counts

### Check Status Anytime
```bash
./scripts/status.sh
```

## 🧹 Cleanup (Before Account Expires!)

**IMPORTANT:** Run this before your 6-hour AWS account expires:

```bash
./scripts/cleanup.sh
```

**This will:**
1. ✓ Delete all ECS tasks and services
2. ✓ Delete load balancers and target groups
3. ✓ Delete ECR repositories and images
4. ✓ Delete VPCs and networking
5. ✓ Delete CodePipeline, CodeBuild, CodeCommit
6. ✓ Delete CloudWatch dashboards and alarms
7. ✓ Delete S3 buckets
8. ✓ Delete all IAM roles and policies

**Time: ~10-15 minutes**

Your code remains safe in GitHub!

## 🔄 Redeploy with New Account

When you get a new AWS account:

```bash
# 1. Update credentials
nano config/credentials.sh

# 2. Deploy again
./scripts/deploy.sh
```

That's it! Everything redeploys automatically.

## 🆘 Troubleshooting

### Deployment Failed?

**Check credentials:**
```bash
aws sts get-caller-identity
```

**Check Terraform state:**
```bash
cd terraform
terraform show
```

**Re-run deployment:**
```bash
./scripts/deploy.sh
```

### Application Not Accessible?

**Check ECS service:**
```bash
./scripts/status.sh
```

**Check ALB health:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --region us-east-1
```

### Pipeline Not Triggering?

**Check EventBridge rule:**
```bash
aws events list-rules --region us-east-1
```

**Manually trigger pipeline:**
```bash
aws codepipeline start-pipeline-execution \
  --name logicworks-devops-pipeline-us-east-1 \
  --region us-east-1
```

### More Help?

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed debugging guide.

## 📚 Next Steps

- **Add Features**: Modify the Node.js app in `app/`
- **Customize Infrastructure**: Edit Terraform in `terraform/`
- **Add Monitoring**: Extend CloudWatch dashboards
- **Setup DNS**: Add Route53 for custom domain
- **Add SSL**: Configure ACM certificate for HTTPS
- **Add Database**: Integrate RDS or DynamoDB
- **Add Cache**: Add ElastiCache Redis
- **Add CDN**: Configure CloudFront

## 📖 Learn More

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Detailed architecture
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Debug guide



**Time to deploy:** ~20 minutes **Time to cleanup:** ~15 minutes **Perfect for
your 6-hour AWS account! 🎉**
