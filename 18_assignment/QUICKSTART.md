# Quick Start Guide - Complete in Under 3 Hours

## Prerequisites Check (5 minutes)
```bash
# Verify installations
git --version
python --version
az --version  # Install Azure CLI if not present
```

If Azure CLI is not installed:
```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I AzureCLI.msi /quiet' -Wait
```

## Step 1: Azure DevOps Setup (15 minutes)

### 1.1 Create Organization and Project
1. Go to https://dev.azure.com
2. Sign in with your Azure account
3. Click "Create new organization" or use existing
4. Create new project:
   - **Name**: `HooliMathHelper`
   - **Visibility**: Private
   - **Version Control**: Git
   - **Work Item Process**: Agile

### 1.2 Configure Azure CLI
```bash
# Login to Azure
az login

# Install Azure DevOps extension
az extension add --name azure-devops

# Configure default organization and project
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG_NAME project=HooliMathHelper
```

## Step 2: Create Work Items (20 minutes)

### Option A: Manual Creation (GUI)
1. Go to **Boards** → **Work Items**
2. Create Epic: "Math Helper Library Development"
3. Create User Stories:
   - "Implement Basic Arithmetic Operations"
   - "Implement Trigonometric Functions"
   - "Implement Geometry Calculations"
4. Create Tasks under each story (see work-items/*.json for details)
5. Create Sprint 1 and assign items

### Option B: Automated Creation (Recommended)
```bash
# Navigate to assignment directory
cd c:/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/18_assignment

# Run PowerShell script
powershell -ExecutionPolicy Bypass -File scripts/setup-azure-devops.ps1
```

## Step 3: Setup Git Repository (15 minutes)

### 3.1 Clone Repository
```bash
# Get repository URL from Azure DevOps
# Go to Repos → Files → Clone

cd c:/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/18_assignment

# Clone the empty repository
git clone https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper repo

cd repo
```

### 3.2 Copy Project Files
```bash
# Copy application files
cp -r ../app .
cp ../README.md .

# Initial commit
git add .
git commit -m "Initial commit: Project structure and basic math functions"
git push origin main
```

## Step 4: Implement Functions (30 minutes)

### 4.1 Create Initial Implementation
All functions are already created in `app/math_helper.py`. Review and test:

```bash
cd app
python test_math_helper.py
```

### 4.2 Commit Initial Implementation
```bash
git add app/math_helper.py
git commit -m "feat: Implement addition and multiplication functions #1"
git push origin main
```

### 4.3 Add Trigonometric Functions
```bash
# Functions already in math_helper.py
git add app/math_helper.py
git commit -m "feat: Add sin and cos calculation functions #2"
git push origin main
```

### 4.4 Add Distance Calculation
```bash
git add app/math_helper.py
git commit -m "feat: Add distance calculation function #3"
git push origin main
```

## Step 5: Demonstrate Git Operations (20 minutes)

### 5.1 View History
```bash
# View commit history
git log --oneline --graph --all

# View specific file history
git log --oneline app/math_helper.py

# Compare changes
git diff HEAD~2 HEAD app/math_helper.py
```

### 5.2 Create Feature Branch
```bash
# Create new branch for extended features
git checkout -b feature/extended-math

# Copy extended functions
cp ../app/math_helper_extended.py app/

git add app/math_helper_extended.py
git commit -m "feat: Add power, square root, and factorial functions"
git push origin feature/extended-math
```

### 5.3 Create Pull Request
1. Go to Azure DevOps → Repos → Pull Requests
2. Click "New pull request"
3. Source: `feature/extended-math` → Target: `main`
4. Complete and merge

### 5.4 Clone to New Location (Simulate New Developer)
```bash
cd c:/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/18_assignment

# Create new clone
git clone https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper repo-developer2

cd repo-developer2
git log --oneline
```

## Step 6: Update Work Items (15 minutes)

### Update Task Status
1. Go to **Boards** → **Sprints**
2. Move tasks across board:
   - To Do → In Progress → Done
3. Update tasks as completed
4. Link commits to work items (use #1, #2, #3 in commit messages)

## Step 7: Documentation and Screenshots (20 minutes)

### Take Screenshots
1. Azure Boards - Epic view
2. Azure Boards - Sprint board with tasks
3. Azure Repos - File explorer
4. Azure Repos - Commit history
5. Azure Repos - Pull request
6. Git log output from terminal
7. Git diff comparison
8. Test execution results

### Save in screenshots folder
```bash
# Organize screenshots
# Save all screenshots to: 18_assignment/screenshots/
```

## Step 8: Export Artifacts (10 minutes)

### Before Account Expires
```bash
# Export work items (if needed for evidence)
# Go to Boards → Queries → New Query → Export to CSV

# Clone repositories to backup location
cd c:/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/18_assignment
git clone --mirror https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper backup

# Save Git logs
cd repo
git log --all --graph --pretty=format:'%h -%d %s (%cr) <%an>' > ../git-history.txt
```

## Completion Checklist

- [ ] Azure DevOps organization and project created
- [ ] Epic, User Stories, and Tasks created
- [ ] Sprint created and work items assigned
- [ ] Git repository initialized and pushed to Azure DevOps
- [ ] All 4 math functions implemented
- [ ] Multiple commits with proper messages
- [ ] Feature branch created and merged
- [ ] Git history viewed and compared
- [ ] New local repository cloned
- [ ] Work item statuses updated
- [ ] Screenshots captured (minimum 7)
- [ ] Repository backed up locally
- [ ] Assignment documentation completed

## Time Saving Tips

1. **Use provided scripts** - Automate work item creation
2. **Copy-paste Git commands** - Pre-tested commands save time
3. **Take screenshots continuously** - Don't wait until end
4. **Use Azure DevOps CLI** - Faster than GUI for repetitive tasks
5. **Keep browser tabs open** - Azure DevOps, Azure Portal, Git History
6. **Test functions once** - They're pre-tested and working
7. **Use commit message templates** - Link to work items with #number

## Troubleshooting

### Git Authentication Issues
```bash
# Use Personal Access Token (PAT)
# Go to Azure DevOps → User Settings → Personal Access Tokens
# Create token with Code (Read & Write) permissions
# Use PAT as password when prompted
```

### Azure CLI Authentication
```bash
az logout
az login
az account show
```

### Python Issues
```bash
# Install required packages
pip install -r app/requirements.txt
```

## Support
If you encounter issues, the code and documentation are self-contained. All
necessary files are in this directory structure.
