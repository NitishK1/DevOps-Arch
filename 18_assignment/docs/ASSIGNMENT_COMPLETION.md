# Assignment Completion Guide

## Overview
This guide provides step-by-step instructions to complete Assignment 18 within
your 6-hour Azure account window.

## Time Allocation
- **Setup Phase**: 30 minutes
- **Work Items Creation**: 30 minutes
- **Development & Git**: 60 minutes
- **Documentation & Screenshots**: 30 minutes
- **Buffer**: 30 minutes
- **Total**: 3 hours (well within 6-hour limit)

## Prerequisites Checklist
- [ ] Active Azure account with credentials
- [ ] Azure CLI installed
- [ ] Git installed
- [ ] Python 3.x installed
- [ ] Code editor (VS Code recommended)
- [ ] Internet connection

## Phase 1: Azure DevOps Setup (30 minutes)

### Step 1.1: Create Azure DevOps Organization (5 minutes)
1. Go to https://dev.azure.com
2. Sign in with your Azure credentials
3. Click "Create new organization" (or use existing)
4. Organization name: Choose a unique name
5. Location: Select closest region
6. Click "Continue"

### Step 1.2: Create Project (5 minutes)
1. Click "New project"
2. Project name: `HooliMathHelper`
3. Visibility: Private
4. Version control: Git
5. Work item process: Agile
6. Click "Create"

### Step 1.3: Configure Azure CLI (10 minutes)
```powershell
# Open PowerShell as Administrator
# Login to Azure
az login

# Install Azure DevOps extension
az extension add --name azure-devops

# Configure defaults (replace YOUR_ORG_NAME)
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG_NAME project=HooliMathHelper
```

### Step 1.4: Create Personal Access Token (5 minutes)
1. Click on User Settings (top right) → Personal Access Tokens
2. Click "New Token"
3. Name: "HooliMathHelper-PAT"
4. Expiration: Custom (6 hours from now)
5. Scopes: Full access
6. Click "Create"
7. **COPY AND SAVE TOKEN IMMEDIATELY** (you won't see it again)

### Step 1.5: Test Setup (5 minutes)
```powershell
# Verify setup
az devops project show --project HooliMathHelper
```

## Phase 2: Create Work Items (30 minutes)

### Step 2.1: Create Epic (5 minutes)
1. Go to Boards → Work Items
2. Click "New Work Item" → Epic
3. Title: "Math Helper Library Development"
4. Description: "Develop comprehensive math helper library for distributed team"
5. Assigned to: Your name
6. Save

### Step 2.2: Create User Stories (10 minutes)

**User Story 1: Basic Arithmetic Operations**
- Title: "Implement Basic Arithmetic Operations"
- Description: "As a developer, I need basic arithmetic operations"
- Story Points: 3
- Parent: Link to Epic
- Sprint: Sprint 1
- Save

**User Story 2: Trigonometric Functions**
- Title: "Implement Trigonometric Functions"
- Description: "As a developer, I need sin and cos functions"
- Story Points: 5
- Parent: Link to Epic
- Sprint: Sprint 1
- Save

**User Story 3: Geometry Calculations**
- Title: "Implement Geometry Calculations"
- Description: "As a developer, I need distance calculation"
- Story Points: 3
- Parent: Link to Epic
- Sprint: Sprint 1
- Save

### Step 2.3: Create Tasks (15 minutes)

Create tasks for each user story:

**For US1 - Basic Arithmetic:**
1. "Implement addition function" - 2h
2. "Implement multiplication function" - 2h
3. "Write unit tests for arithmetic" - 2h

**For US2 - Trigonometric:**
1. "Implement sin function" - 3h
2. "Implement cos function" - 3h
3. "Write unit tests for trig functions" - 3h

**For US3 - Geometry:**
1. "Implement distance calculation" - 3h
2. "Write unit tests for distance" - 2h

Link each task to its parent user story and assign to Sprint 1.

### Screenshot Checkpoint
📸 Take screenshots:
- Epic view with all user stories
- Sprint board showing all items
- Backlog view

## Phase 3: Git Repository Setup (45 minutes)

### Step 3.1: Clone Repository (5 minutes)
```powershell
# Get repository URL from Repos → Files → Clone
# Example: https://YOUR_ORG@dev.azure.com/YOUR_ORG/HooliMathHelper/_git/HooliMathHelper

cd c:\Users\hardi\HARDIK\Learn\Edureka_DevOps_Arch_Training\18_assignment

# Clone repository
git clone YOUR_REPO_URL repo

cd repo
```

### Step 3.2: Copy Project Files (5 minutes)
```powershell
# Copy application files
Copy-Item -Path ..\app -Destination . -Recurse -Force
Copy-Item -Path ..\README.md -Destination . -Force

# Create .gitignore
@"
__pycache__/
*.pyc
.vscode/
"@ | Out-File -FilePath .gitignore -Encoding UTF8
```

### Step 3.3: Initial Commit (5 minutes)
```powershell
git config user.name "Your Name"
git config user.email "your.email@example.com"

git add .
git commit -m "Initial commit: Project structure setup

- Added math helper library structure
- Added README documentation
- Added .gitignore"

git push origin main
```

### Step 3.4: Implement Functions with Commits (30 minutes)
```powershell
# Commit 1: Addition function
git add app/math_helper.py
git commit -m "feat: Implement addition function #1

- Added add() function with documentation
- Handles positive and negative numbers
- Related to user story #1"
git push origin main

# Commit 2: Multiplication function
git add app/math_helper.py
git commit -m "feat: Implement multiplication function #1

- Added multiply() function
- Comprehensive documentation
- Related to user story #1"
git push origin main

# Commit 3: Trigonometric functions
git add app/math_helper.py
git commit -m "feat: Implement sin and cos functions #2

- Added calculate_sin() function
- Added calculate_cos() function
- Converts degrees to radians
- Related to user story #2"
git push origin main

# Commit 4: Distance calculation
git add app/math_helper.py
git commit -m "feat: Implement distance calculation #3

- Added calculate_distance() function
- Uses Euclidean distance formula
- Handles 2D coordinate system
- Related to user story #3"
git push origin main

# Commit 5: Unit tests
git add app/test_math_helper.py
git commit -m "test: Add comprehensive unit tests

- Tests for all math functions
- Edge case coverage
- 100% function coverage"
git push origin main
```

### Screenshot Checkpoint
📸 Take screenshots:
- Azure Repos file explorer view
- Commit history in Azure DevOps
- File contents in Azure Repos

## Phase 4: Demonstrate Git Operations (15 minutes)

### Step 4.1: View History
```powershell
# View commit log
git log --oneline --graph --all

# View file history
git log --oneline app/math_helper.py

# Save to file for documentation
git log --oneline --graph --all > git-history.txt
```

### Step 4.2: Compare Changes
```powershell
# Compare last two commits
git diff HEAD~1 HEAD

# Compare specific file
git diff HEAD~2 HEAD app/math_helper.py

# View stats
git diff --stat HEAD~2 HEAD
```

### Step 4.3: Create Feature Branch
```powershell
# Create and switch to feature branch
git checkout -b feature/extended-math

# Copy extended functions
Copy-Item -Path ..\app\math_helper_extended.py -Destination app\ -Force

# Commit to feature branch
git add app/math_helper_extended.py
git commit -m "feat: Add extended math functions

- Power calculation
- Square root
- Factorial
- Modulo operation"

# Push feature branch
git push origin feature/extended-math
```

### Step 4.4: Create Pull Request
1. Go to Azure DevOps → Repos → Pull Requests
2. Click "New pull request"
3. Source: feature/extended-math
4. Target: main
5. Title: "Add extended math functions"
6. Description: "Adds power, sqrt, factorial, modulo"
7. Link work items if needed
8. Create
9. Complete the merge

### Step 4.5: Clone to New Location
```powershell
# Simulate new developer joining
cd ..
git clone YOUR_REPO_URL repo-developer2

cd repo-developer2
git log --oneline
```

### Screenshot Checkpoint
📸 Take screenshots:
- Git log output
- Git diff comparison
- Pull request in Azure DevOps
- Merged PR showing changes

## Phase 5: Update Work Items (15 minutes)

### Step 5.1: Update Task Status
1. Go to Boards → Sprints
2. Move tasks from "To Do" to "In Progress" to "Done"
3. Update hours worked on each task
4. Link commits to work items (they should auto-link with #number)

### Step 5.2: Update User Stories
1. Mark user stories as "Done" when all tasks complete
2. Add acceptance notes
3. Link to commits and pull requests

### Step 5.3: Close Epic
1. Verify all user stories are complete
2. Update epic status to "Done"
3. Add completion notes

### Screenshot Checkpoint
📸 Take screenshots:
- Sprint board with completed items
- User story detail view
- Epic showing all completed items
- Commit links on work items

## Phase 6: Testing (10 minutes)

### Step 6.1: Run Unit Tests
```powershell
cd repo
python app/test_math_helper.py
```

### Step 6.2: Run Functions Demo
```powershell
python app/math_helper.py
python app/math_helper_extended.py
```

### Screenshot Checkpoint
📸 Take screenshots:
- Test execution output
- Function demo output

## Phase 7: Documentation (20 minutes)

### Step 7.1: Create Assignment Summary
Create a document with:
- Project overview
- Work items created (Epic, User Stories, Tasks)
- Git operations performed
- Commits made
- Branches created and merged
- Test results

### Step 7.2: Export Evidence

**Export Work Items:**
1. Go to Boards → Queries
2. Create query: All work items in HooliMathHelper
3. Export to Excel
4. Save as `work-items-export.xlsx`

**Export Git History:**
```powershell
cd repo
git log --all --graph --pretty=format:'%h - %an, %ar : %s' > ../git-full-history.txt
```

### Step 7.3: Organize Screenshots
Create a document organizing all screenshots:
1. Azure DevOps project overview
2. Work items (Epic, Stories, Tasks)
3. Sprint board
4. Git repository structure
5. Commit history
6. Pull request
7. Test results
8. Function demonstrations

## Phase 8: Backup Before Account Expires (10 minutes)

### Step 8.1: Clone Repository Backup
```powershell
cd c:\Users\hardi\HARDIK\Learn\Edureka_DevOps_Arch_Training\18_assignment

# Full backup including history
git clone --mirror YOUR_REPO_URL backup-mirror

# Regular backup
git clone YOUR_REPO_URL backup
```

### Step 8.2: Export All Artifacts
- Download work items export
- Save all screenshots
- Save git history files
- Save PAT (securely, temporarily)
- Save project URLs and details

### Step 8.3: Document Completion
Create final checklist document with:
- ✅ All completed steps
- 📁 Locations of all artifacts
- 🔗 Links to Azure DevOps resources
- 📸 Screenshot index
- 📝 Commit references

## Completion Checklist

### Azure DevOps Setup
- [ ] Organization created
- [ ] Project created (HooliMathHelper)
- [ ] Repository initialized
- [ ] Sprint configured

### Work Items
- [ ] Epic created
- [ ] 3 User Stories created
- [ ] 8+ Tasks created
- [ ] All items assigned to Sprint 1
- [ ] Work items linked properly

### Git Operations
- [ ] Repository cloned locally
- [ ] Initial commit pushed
- [ ] 5+ commits made with meaningful messages
- [ ] Feature branch created
- [ ] Pull request created and merged
- [ ] Repository cloned to second location
- [ ] Commit history viewed and exported

### Code Implementation
- [ ] Addition function implemented
- [ ] Multiplication function implemented
- [ ] Sin function implemented
- [ ] Cos function implemented
- [ ] Distance calculation implemented
- [ ] Extended functions implemented
- [ ] Unit tests written and passing

### Documentation
- [ ] README created
- [ ] Code documented with docstrings
- [ ] Git history exported
- [ ] Work items exported

### Screenshots (Minimum 10)
- [ ] Epic view
- [ ] User Stories list
- [ ] Sprint board
- [ ] Task details
- [ ] Repository structure
- [ ] Commit history
- [ ] Pull request
- [ ] Git operations output
- [ ] Test results
- [ ] Function demonstrations

### Backup
- [ ] Repository backed up locally
- [ ] Work items exported
- [ ] Screenshots saved
- [ ] Documentation completed

## Troubleshooting

### Issue: Git Authentication Failed
**Solution:**
```powershell
# Use PAT as password
# When prompted, enter:
# Username: YOUR_ORG_NAME
# Password: YOUR_PAT_TOKEN
```

### Issue: Azure CLI Not Configured
**Solution:**
```powershell
az login
az devops configure --defaults organization=YOUR_ORG_URL project=HooliMathHelper
```

### Issue: Can't Push to Repository
**Solution:**
```powershell
# Check remote
git remote -v

# Reset remote if needed
git remote set-url origin YOUR_REPO_URL
```

### Issue: Work Items Not Linking
**Solution:**
- Use #NUMBER in commit messages
- Or manually link in Azure DevOps UI

## Time-Saving Tips

1. **Use PowerShell Scripts**: Pre-written scripts in `scripts/` folder
2. **Copy-Paste Commands**: All commands are ready to use
3. **Batch Screenshots**: Take screenshots as you go
4. **Use Azure DevOps CLI**: Faster than GUI for repetitive tasks
5. **Pre-written Code**: All functions already implemented
6. **Test Once**: Tests are pre-validated

## Success Criteria

Your assignment is complete when: ✅ All work items created and linked ✅ Sprint
configured with all items ✅ Git repository setup and populated ✅ All 4 required
functions implemented ✅ Multiple meaningful commits made ✅ Git history viewed
and compared ✅ New repository clone created ✅ Minimum 10 screenshots captured ✅
Documentation complete ✅ Artifacts backed up locally

## Final Submission

Organize your submission folder:
```
18_assignment/
├── screenshots/          # All screenshots
├── docs/                 # Documentation
├── backup/              # Repository backup
├── work-items-export.xlsx
├── git-full-history.txt
└── ASSIGNMENT_SUMMARY.md
```

## Estimated Completion Time: 2.5-3 hours

This leaves you with 3+ hours buffer before your Azure account expires.

Good luck! 🚀
