# Azure DevOps Setup Guide

## Table of Contents
1. [Azure Account Setup](#azure-account-setup)
2. [Azure DevOps Organization](#azure-devops-organization)
3. [Project Creation](#project-creation)
4. [Repository Configuration](#repository-configuration)
5. [Work Items Setup](#work-items-setup)
6. [Sprint Configuration](#sprint-configuration)
7. [Access and Permissions](#access-and-permissions)

## Azure Account Setup

### Prerequisites
- Active Azure subscription
- Valid email address
- Browser (Chrome, Edge, or Firefox recommended)

### Important Notes for Temporary Accounts
⚠️ **Your Azure account is valid for only 6 hours**
- Save all credentials immediately
- Set reminders at 4-hour and 5-hour marks
- Backup all work before expiration
- Export artifacts early and often

### Account Verification
1. Go to https://portal.azure.com
2. Sign in with provided credentials
3. Verify subscription status
4. Note expiration time

## Azure DevOps Organization

### Creating Organization

**Option 1: Through Azure Portal**
1. Go to https://portal.azure.com
2. Search for "Azure DevOps"
3. Click "Azure DevOps organizations"
4. Click "My Azure DevOps Organizations"
5. Click "Create new organization"
6. Choose organization name (e.g., `hooli-dev-org`)
7. Select region
8. Click "Continue"

**Option 2: Directly on Azure DevOps**
1. Go to https://dev.azure.com
2. Sign in with Azure credentials
3. Click "Create new organization"
4. Follow prompts

### Organization Settings
1. Go to Organization Settings (bottom left)
2. Configure:
   - **Overview**: Review organization details
   - **Users**: Add team members (if applicable)
   - **Billing**: Verify free tier limits
   - **Security**: Review security settings

## Project Creation

### Creating HooliMathHelper Project

1. **Navigate to Organization**
   - Go to https://dev.azure.com/YOUR_ORG_NAME

2. **Create New Project**
   - Click "+ New project" (top right)

3. **Configure Project**
   - **Project name**: `HooliMathHelper`
   - **Description**: `Math Helper Library for distributed development team - Assignment 18`
   - **Visibility**: Private
   - **Version control**: Git
   - **Work item process**: Agile

4. **Create Project**
   - Click "Create"
   - Wait for project initialization (30-60 seconds)

### Project Structure
After creation, you'll see:
- **Overview**: Project dashboard
- **Boards**: Work item management
- **Repos**: Git repositories
- **Pipelines**: CI/CD (not used in this assignment)
- **Test Plans**: Testing management (optional)
- **Artifacts**: Package management (not used)

## Repository Configuration

### Accessing Repository
1. Go to **Repos** → **Files**
2. You'll see an empty repository with initialization instructions

### Getting Repository URL
1. Click **Clone** button (top right)
2. Copy HTTPS URL
3. Format: `https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper`

### Setting Up Local Repository

**Using PowerShell:**
```powershell
# Clone repository
git clone https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper

# Navigate to repository
cd HooliMathHelper

# Configure git
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Initial Repository Structure
```
HooliMathHelper/
├── README.md
├── .gitignore
├── app/
│   ├── math_helper.py
│   ├── math_helper_extended.py
│   ├── test_math_helper.py
│   └── requirements.txt
└── docs/
    └── API.md
```

## Work Items Setup

### Understanding Agile Process
- **Epic**: Large body of work
- **Feature**: (not used in this assignment)
- **User Story**: User-facing functionality
- **Task**: Technical work to complete stories

### Creating Epic

1. **Navigate to Boards**
   - Go to **Boards** → **Work Items**

2. **Create Epic**
   - Click **+ New Work Item** → **Epic**
   - **Title**: `Math Helper Library Development`
   - **Description**:
     ```
     Develop a comprehensive math helper library for Hooli Inc.
     distributed development team. This library will provide
     essential mathematical functions to support product development
     across geographies.
     ```
   - **Assigned to**: Your name
   - **Area**: `HooliMathHelper`
   - **Iteration**: `HooliMathHelper\Sprint 1`
   - **Priority**: 1 (High)
   - **Tags**: `development`, `math`, `library`
   - Click **Save & Close**

### Creating User Stories

**User Story 1: Basic Arithmetic**
```
Title: Implement Basic Arithmetic Operations
Description: As a developer, I need basic arithmetic operations
(addition and multiplication) so that I can perform fundamental
calculations in the application.

Acceptance Criteria:
- Addition function accepts two numbers and returns sum
- Multiplication function accepts two numbers and returns product
- Functions handle both integer and floating-point numbers
- Functions are properly documented
- Unit tests pass

Story Points: 3
Priority: 1
Assigned to: Developer 1
Iteration: Sprint 1
Parent: [Link to Epic]
```

**User Story 2: Trigonometric Functions**
```
Title: Implement Trigonometric Functions
Description: As a developer, I need trigonometric functions
(sine and cosine) so that I can perform angle-based calculations.

Acceptance Criteria:
- Sin function calculates sine of angle in degrees
- Cos function calculates cosine of angle in degrees
- Functions return accurate values
- Functions are properly documented
- Unit tests cover common angles

Story Points: 5
Priority: 1
Assigned to: Developer 2
Iteration: Sprint 1
Parent: [Link to Epic]
```

**User Story 3: Geometry Calculations**
```
Title: Implement Geometry Calculations
Description: As a developer, I need to calculate distance between
two points for location-based features.

Acceptance Criteria:
- Distance function accepts coordinates (x1, y1, x2, y2)
- Calculates Euclidean distance correctly
- Handles edge cases
- Properly documented
- Unit tests verify accuracy

Story Points: 3
Priority: 2
Assigned to: Developer 1
Iteration: Sprint 1
Parent: [Link to Epic]
```

### Creating Tasks

For each User Story, create tasks:

**Example Task for US1:**
```
Title: Implement addition function
Description: Write Python code for addition function with error handling
Parent: [Link to User Story 1]
Assigned to: Developer 1
Activity: Development
Estimated Hours: 2
Remaining Hours: 2
Iteration: Sprint 1
Priority: 1
```

### Linking Work Items
1. Open work item
2. Click **Add link** → **Add parent**
3. Select parent item
4. Click **OK**

## Sprint Configuration

### Creating Sprint

1. **Navigate to Sprints**
   - Go to **Project Settings** (bottom left)
   - Select **Project configuration**
   - Click **Iterations**

2. **Add Sprint**
   - Click **+ New child**
   - **Name**: `Sprint 1`
   - **Start date**: Today or tomorrow
   - **End date**: 2 weeks from start
   - Click **Save and close**

### Assigning Items to Sprint

**Option 1: Drag and Drop**
1. Go to **Boards** → **Backlogs**
2. Drag user stories to Sprint 1

**Option 2: Edit Work Item**
1. Open work item
2. Change **Iteration** to `HooliMathHelper\Sprint 1`
3. Save

### Sprint Board View
1. Go to **Boards** → **Sprints**
2. View Sprint board with columns:
   - **New**
   - **Active** (In Progress)
   - **Resolved**
   - **Closed**

## Access and Permissions

### Personal Access Token (PAT)

**Creating PAT:**
1. Click on **User Settings** (top right avatar)
2. Select **Personal access tokens**
3. Click **+ New Token**
4. Configure:
   - **Name**: `HooliMathHelper-PAT`
   - **Organization**: Your organization
   - **Expiration**: Custom (6 hours)
   - **Scopes**: Full access (or Code: Read & Write)
5. Click **Create**
6. **COPY TOKEN IMMEDIATELY** (won't be shown again)
7. Save securely

**Using PAT for Git:**
```powershell
# When git prompts for password, use PAT
git clone https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper

Username: YOUR_ORG_NAME
Password: YOUR_PAT_TOKEN
```

### Team Member Access
If working with a team:
1. Go to **Project Settings** → **Teams**
2. Click **Add** → **Add user**
3. Enter email address
4. Select access level
5. Click **Save**

## Azure CLI Configuration

### Installing Azure CLI

**Windows:**
```powershell
# Download and run installer
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I AzureCLI.msi /quiet' -Wait
```

**Verify Installation:**
```powershell
az --version
```

### Installing Azure DevOps Extension
```powershell
az extension add --name azure-devops
```

### Login and Configuration
```powershell
# Login to Azure
az login

# Set defaults
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG_NAME project=HooliMathHelper

# Verify configuration
az devops project show --project HooliMathHelper
```

### Using Azure CLI for Work Items

**Create Work Item:**
```powershell
az boards work-item create `
  --title "Sample Task" `
  --type Task `
  --description "Task description" `
  --assigned-to "your.email@example.com"
```

**List Work Items:**
```powershell
az boards work-item show --id 1
```

## Quick Reference Commands

### Git Commands
```powershell
# Clone
git clone YOUR_REPO_URL

# Status
git status

# Add files
git add .

# Commit
git commit -m "message"

# Push
git push origin main

# Create branch
git checkout -b feature/branch-name

# View history
git log --oneline
```

### Azure DevOps CLI Commands
```powershell
# List projects
az devops project list

# List repos
az repos list

# List work items
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems"

# Show repo
az repos show --repository HooliMathHelper
```

## Troubleshooting

### Issue: Can't Access Organization
**Solution:** Verify you're signed in with correct account

### Issue: Repository Clone Fails
**Solution:** Check PAT is valid and has correct permissions

### Issue: Can't Create Work Items
**Solution:** Verify you have Contributor access to project

### Issue: Sprint Not Visible
**Solution:** Ensure sprint is created under correct iteration path

## Best Practices

1. **Commit Often**: Small, frequent commits are better
2. **Meaningful Messages**: Use descriptive commit messages
3. **Link Work Items**: Reference work item numbers in commits (#123)
4. **Update Status**: Keep work item status current
5. **Document Everything**: Good documentation saves time
6. **Backup Regularly**: Clone repository to multiple locations

## Support Resources

- Azure DevOps Documentation: https://docs.microsoft.com/azure/devops
- Git Documentation: https://git-scm.com/doc
- Azure CLI Documentation: https://docs.microsoft.com/cli/azure

## Next Steps

After completing this setup:
1. ✅ Organization and project created
2. ✅ Repository initialized
3. ✅ Work items created
4. ✅ Sprint configured
5. ➡️ Start development
6. ➡️ Make commits
7. ➡️ Complete assignment

---

**Remember**: You have only 6 hours! Work efficiently and backup often.
