# 🚀 Quick Setup Instructions

## For Your New Azure Account (6-hour session)

When you get a new Azure account with new credentials:

### 1. Update Credentials (2 minutes)

```bash
cd Project_Azure_DevOps

# Copy template if needed
cp config/credentials.template.sh config/credentials.sh

# Edit with your new Azure credentials
nano config/credentials.sh
# or
code config/credentials.sh
```

Update these values:
- `AZURE_SUBSCRIPTION_ID` - Get from Azure Portal
- `AZURE_TENANT_ID` - Get from Azure Portal
- `AZURE_DEVOPS_ORG` - Your Azure DevOps organization name
- `AZURE_DEVOPS_PAT` - Generate new Personal Access Token

### 2. Run Quickstart (5-10 minutes)

```bash
# Make scripts executable (if on Linux/Mac)
chmod +x scripts/*.sh

# Run the automated setup
./scripts/quickstart.sh
```

This will automatically:
- ✓ Create Azure DevOps project
- ✓ Create Epic, User Stories, and Tasks
- ✓ Initialize Git repository
- ✓ Push code to Azure Repos
- ✓ Create CI/CD pipeline
- ✓ Deploy Azure Web Apps

### 3. Manual Configuration (3-5 minutes)

Follow the instructions printed by the quickstart script:

1. **Create Service Connection:**
   - Go to Project Settings → Service connections
   - Create "Azure Resource Manager" connection
   - Name it: `Azure-ServiceConnection`

2. **Add Pipeline Variables:**
   - Go to Pipelines → Edit pipeline
   - Add variables from the output

3. **Configure Production Approval:**
   - Go to Environments → ProjectX-Production
   - Add approval check with yourself as approver

### 4. Trigger Pipeline

```bash
# Make a small change
echo "# Demo" >> README.md
git add .
git commit -m "Trigger pipeline"
git push azure main
```

### 5. Demo!

```bash
# Run the guided demo script
./scripts/demo.sh
```



## 📊 What You Get

- Complete Azure DevOps project setup
- Epic with 5 User Stories and 40+ Tasks
- Git repository with full application code
- CI/CD pipeline with staging and production
- Working order management web application
- All Infrastructure as Code



## 🔗 Quick Links Template

After setup, you'll have:

```
Project: https://dev.azure.com/{YOUR_ORG}/ProjectX
Boards: https://dev.azure.com/{YOUR_ORG}/ProjectX/_boards
Repos: https://dev.azure.com/{YOUR_ORG}/ProjectX/_git/ProjectX
Pipelines: https://dev.azure.com/{YOUR_ORG}/ProjectX/_build
Staging: https://projectx-staging.azurewebsites.net
Production: https://projectx-production.azurewebsites.net
```



## 🧹 Cleanup (When Done)

```bash
# Remove all Azure resources
./scripts/cleanup.sh
```

This keeps your costs down when the demo is over!



## 📚 Full Documentation

- **[README.md](README.md)** - Complete project overview
- **[DEMO_GUIDE.md](DEMO_GUIDE.md)** - Step-by-step demo instructions
- **[PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)** - Technical details



## ❓ Troubleshooting

**Scripts won't execute on Windows:**
```bash
# Use Git Bash or WSL
# Or run in Azure Cloud Shell
```

**Authentication issues:**
```bash
# Ensure you're logged in
az login

# Set correct subscription
az account set --subscription "Your Subscription Name"

# Check current account
az account show
```

**Pipeline variables not set:**
- Manually add them in Azure DevOps UI
- Follow instructions in setup-pipelines.sh output



**Total Time: ~10-15 minutes from new credentials to working demo!** ⏱️
