# Assignment 18 - Azure DevOps Git Integration

## Problem Statement
Hooli Inc. is working on a product with a distributed development team across
geographies. This assignment demonstrates Git integration with Azure DevOps
using sample math helper functions.

## Functions to Implement
- Addition
- Multiplication
- Calculation of sin/cos
- Distance between 2 points

## Assignment Objectives
1. Create user stories and tasks using Azure Boards
2. Assign stories and tasks to developers with sprints
3. Change status as per task execution
4. Create and upload project to Azure DevOps Git
5. Add new calculation functions and check-in changes
6. Compare historical changes
7. Create new local repository from master repository

## Quick Start Guide (6-Hour Time Constraint)

### Prerequisites
- Active Azure account (valid for 6 hours)
- Azure DevOps organization
- Git installed locally
- Python 3.x (for the math functions)

### Time-Efficient Workflow
Total estimated time: **2-3 hours** (leaving buffer for your 6-hour window)

1. **Setup Phase (30 minutes)**
   - Create Azure DevOps organization and project
   - Configure Git repository
   - Setup local development environment

2. **Work Items Phase (30 minutes)**
   - Create Epic, User Stories, and Tasks in Azure Boards
   - Assign to sprints
   - Link work items

3. **Development Phase (45 minutes)**
   - Clone repository
   - Implement math helper functions
   - Commit and push initial code

4. **Demonstration Phase (30 minutes)**
   - Add new functions
   - Create branches and pull requests
   - Compare historical changes
   - Clone to new local repository

5. **Documentation Phase (15 minutes)**
   - Take screenshots
   - Document completion
   - Export artifacts

## Directory Structure
```
18_assignment/
├── README.md                           # This file
├── QUICKSTART.md                       # Fast setup guide
├── Problem_Statement.txt               # Original problem statement
├── app/
│   ├── math_helper.py                  # Main math functions
│   ├── math_helper_extended.py         # Additional functions for demo
│   ├── test_math_helper.py             # Unit tests
│   └── requirements.txt                # Python dependencies
├── scripts/
│   ├── setup-azure-devops.sh           # Setup Azure DevOps project
│   ├── setup-git-repo.sh               # Initialize and push to Git
│   ├── demo-git-operations.sh          # Demonstrate Git operations
│   └── setup-azure-devops.ps1          # PowerShell version for Windows
├── work-items/
│   ├── epic.json                       # Epic definition
│   ├── user-stories.json               # User stories
│   └── tasks.json                      # Tasks breakdown
├── docs/
│   ├── ASSIGNMENT_COMPLETION.md        # Assignment checklist
│   └── AZURE_DEVOPS_SETUP.md          # Detailed setup instructions
└── screenshots/
    └── .gitkeep
```

## Important Notes for 6-Hour Constraint
- All scripts are designed for quick execution
- Use provided JSON files for rapid work item creation
- Take screenshots immediately after each major step
- Export work items and Git history before account expires
- Keep credentials in a secure temporary location
- Use automation scripts to save time

## Next Steps
1. Read [QUICKSTART.md](QUICKSTART.md) for immediate setup
2. Run setup scripts in order
3. Follow checklist in
   [docs/ASSIGNMENT_COMPLETION.md](docs/ASSIGNMENT_COMPLETION.md)
4. Take screenshots throughout the process
5. Document your completion before time expires
