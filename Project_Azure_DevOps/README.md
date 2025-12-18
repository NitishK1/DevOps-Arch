# Azure DevOps Project - TechCo ProjectX

## 🎯 Project Overview

This project demonstrates a complete Azure DevOps implementation for "ProjectX"
- an order management web application. Everything is configured as code for
rapid deployment when Azure credentials change.

## 🚀 Quick Start (New Azure Account)

When you get new Azure credentials, follow these steps:

### Prerequisites
- Azure account with DevOps access
- Azure CLI installed
- Git installed
- Node.js 14+ (for the web app)

### 1. Update Credentials
```bash
# Edit config/credentials.sh with your new Azure details
nano config/credentials.sh
```

### 2. Deploy Everything
```bash
# Run the automated deployment script
./scripts/quickstart.sh
```

### 3. Demo the Project
```bash
# Run the demo script to showcase all features
./scripts/demo.sh
```

## 📁 Project Structure

```
Project_Azure_DevOps/
├── README.md                          # This file
├── DEMO_GUIDE.md                      # Step-by-step demo instructions
├── PROJECT_DOCUMENTATION.md           # Detailed project documentation
├── config/
│   ├── credentials.sh                 # Azure credentials (gitignored)
│   ├── credentials.template.sh        # Template for credentials
│   └── project-config.json            # Project configuration
├── scripts/
│   ├── quickstart.sh                  # One-command deployment
│   ├── setup-azure-devops.sh          # Azure DevOps setup
│   ├── create-work-items.sh           # Create boards/work items
│   ├── setup-repo.sh                  # Repository setup
│   ├── setup-pipelines.sh             # CI/CD pipeline setup
│   ├── cleanup.sh                     # Cleanup resources
│   └── demo.sh                        # Guided demo script
├── work-items/
│   ├── epic.json                      # Epic definition
│   ├── user-stories.json              # User stories definitions
│   └── tasks.json                     # Tasks definitions
├── pipelines/
│   ├── azure-pipelines-ci.yml         # CI pipeline
│   ├── azure-pipelines-cd.yml         # CD pipeline
│   └── azure-pipelines.yml            # Combined CI/CD pipeline
├── infrastructure/
│   ├── webapp.bicep                   # Azure Web App infrastructure
│   ├── staging-webapp.bicep           # Staging environment
│   └── production-webapp.bicep        # Production environment
├── app/
│   ├── package.json                   # Node.js dependencies
│   ├── server.js                      # Express server
│   ├── public/                        # Static files
│   ├── src/                           # Application source code
│   └── tests/                         # Unit and integration tests
└── screenshots/                        # Screenshots for documentation
```

## 🔧 Configuration

### Setting Up New Azure Credentials

1. Copy the credentials template:
```bash
cp config/credentials.template.sh config/credentials.sh
```

2. Edit `config/credentials.sh`:
```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_DEVOPS_ORG="your-org-name"
export AZURE_DEVOPS_PROJECT="ProjectX"
export AZURE_DEVOPS_PAT="your-personal-access-token"
```

3. The script will automatically use these credentials

## 📋 Features Implemented

### 1. Azure DevOps Boards
- ✅ Epic: ProjectX - Order Management System
- ✅ 5 User Stories with acceptance criteria
- ✅ 15+ Tasks broken down by functionality
- ✅ Sprint planning and backlog management

### 2. Azure Repos
- ✅ Git repository with branch strategy
- ✅ Main branch protection
- ✅ Feature branch workflow
- ✅ Pull request templates
- ✅ Code review process

### 3. CI/CD Pipelines
- ✅ Continuous Integration (CI)
  - Automated builds on commit
  - Unit tests execution
  - Code quality checks
  - Artifact generation
- ✅ Continuous Deployment (CD)
  - Automatic deployment to staging
  - Manual approval gate for production
  - Environment-specific configurations
  - Rollback capabilities

### 4. Web Application
- ✅ Order management system
- ✅ RESTful API
- ✅ Frontend interface
- ✅ Database integration
- ✅ Authentication & authorization

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure DevOps                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Boards (Epic → User Stories → Tasks)                        │
│     ↓                                                         │
│  Repos (Git Repository)                                      │
│     ↓                                                         │
│  Pipelines (CI/CD)                                           │
│     ├─ CI: Build → Test → Package                           │
│     └─ CD: Deploy Staging → Approval → Deploy Prod          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
              ┌────────────────────────┐
              │   Azure Web Apps       │
              ├────────────────────────┤
              │  Staging Environment   │
              │  Production Environment│
              └────────────────────────┘
```

## 📚 Documentation

- **[DEMO_GUIDE.md](./DEMO_GUIDE.md)** - Step-by-step demonstration guide
- **[PROJECT_DOCUMENTATION.md](./PROJECT_DOCUMENTATION.md)** - Detailed
  technical documentation
- **Problem_Statement.txt** - Original project requirements

## 🎬 Demo Workflow

1. **Show Azure DevOps Boards** - Epics, User Stories, Tasks
2. **Show Repository** - Branch strategy, PRs, code structure
3. **Trigger CI Pipeline** - Push code, watch automated build
4. **Show CD Pipeline** - Staging deployment, approval gate
5. **Deploy to Production** - Approve and deploy
6. **Show Live Application** - Demonstrate the order management system

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Run all tests with coverage
npm run test:coverage
```

## 🔄 Updating for New Azure Account

When your Azure account changes:

1. Login to Azure:
```bash
az login
```

2. Update credentials:
```bash
nano config/credentials.sh
```

3. Run quickstart:
```bash
./scripts/quickstart.sh
```

4. Total time: ~5-10 minutes

## 📸 Screenshots

Screenshots demonstrating each requirement are saved in the `screenshots/`
directory:
- Azure Boards setup
- Repository and branches
- CI pipeline execution
- CD pipeline with approval gates
- Live application

## 🛠️ Troubleshooting

### Issue: Azure DevOps PAT expired
```bash
# Generate new PAT and update
echo "export AZURE_DEVOPS_PAT='new-token'" >> config/credentials.sh
source config/credentials.sh
```

### Issue: Pipeline failing
```bash
# Check pipeline logs
az pipelines runs show --id <run-id> --org $AZURE_DEVOPS_ORG --project $AZURE_DEVOPS_PROJECT
```

### Issue: Deployment failing
```bash
# Check webapp logs
az webapp log tail --name projectx-staging --resource-group projectx-rg
```

## 🧹 Cleanup

To remove all Azure resources:
```bash
./scripts/cleanup.sh
```

## 📝 License

This is a learning project for Azure DevOps demonstration purposes.

## 👤 Author

Created for Edureka DevOps Architecture Training



**Note:** Always ensure `config/credentials.sh` is added to `.gitignore` to
prevent credential leaks.
