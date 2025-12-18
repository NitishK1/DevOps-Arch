# ProjectX Demo Guide

## 🎯 Overview

This guide provides step-by-step instructions for demonstrating the ProjectX Order Management System and its complete Azure DevOps implementation.

## 📋 Prerequisites Before Demo

1. **Complete Setup**
   - Run `./scripts/quickstart.sh` successfully
   - All Azure resources created
   - Repository pushed to Azure Repos
   - Pipeline executed at least once

2. **Open Browser Tabs** (for quick switching during demo)
   - Azure DevOps Project Overview
   - Azure Boards
   - Azure Repos
   - Azure Pipelines
   - Environments page
   - Staging Web App
   - Production Web App

3. **Test Endpoints**
   ```bash
   # Verify staging is running
   curl https://projectx-staging.azurewebsites.net/api/health

   # Verify production is running
   curl https://projectx-production.azurewebsites.net/api/health
   ```

## 🎬 Demo Flow (20-30 minutes)

### Part 1: Project Overview (3 minutes)

**What to Say:**
> "Today I'll demonstrate how we've implemented a complete DevOps workflow for ProjectX, an order management system for TechCo. We're using Azure DevOps to streamline the entire Software Development Lifecycle, from planning to production deployment."

**What to Show:**
1. Open Azure DevOps Project Overview
2. Point out the main sections: Boards, Repos, Pipelines
3. Highlight the project description and team

**URL:** `https://dev.azure.com/YOUR_ORG/ProjectX`

---

### Part 2: Azure Boards - Work Item Management (5 minutes)

**What to Say:**
> "First, let's look at how we organized the work using Azure Boards. We've broken down the project into manageable pieces using Agile methodology."

**What to Show:**

1. **Backlog View**
   - Navigate to Boards > Backlogs
   - Show the Epic: "ProjectX - Order Management System"
   - Expand to show User Stories underneath
   - Point out the hierarchy: Epic → User Stories → Tasks

2. **User Story Details**
   - Click on User Story 1: "User Authentication and Authorization"
   - Show:
     - Description
     - Acceptance Criteria (list 2-3 key points)
     - Tasks breakdown
     - State and Priority
   - Mention: "Each user story has clear acceptance criteria to ensure we deliver what the business needs"

3. **Tasks Breakdown**
   - Open a task: "Implement user registration API endpoint"
   - Show:
     - Detailed description
     - Estimated hours
     - Parent user story link
   - Mention: "Tasks are the actual work items developers pick up"

4. **Board View** (Optional)
   - Switch to Boards > Board view
   - Show Kanban board with columns
   - Mention workflow: New → Active → Resolved → Closed

**Key Points to Emphasize:**
- ✓ Organized hierarchy (Epic → Stories → Tasks)
- ✓ Clear acceptance criteria
- ✓ Proper work item relationships
- ✓ Agile project management

**URL:** `https://dev.azure.com/YOUR_ORG/ProjectX/_boards`

---

### Part 3: Azure Repos - Source Control (4 minutes)

**What to Say:**
> "All our code is managed in Azure Repos, which provides enterprise-grade Git repository hosting with branch policies and pull request workflows."

**What to Show:**

1. **Repository Structure**
   - Navigate to Repos > Files
   - Walk through folder structure:
     ```
     ├── app/              (Node.js application)
     ├── pipelines/        (CI/CD configurations)
     ├── scripts/          (Automation scripts)
     ├── work-items/       (Work item templates)
     └── config/           (Project configuration)
     ```

2. **Application Code**
   - Open `app/server.js`
   - Briefly scroll through to show:
     - Express.js server
     - API endpoints
     - Authentication routes
     - Order management endpoints
   - Mention: "This is a real working application with REST APIs"

3. **Pipeline Configuration**
   - Open `pipelines/azure-pipelines.yml`
   - Show the three stages:
     - Build & Test
     - Deploy to Staging
     - Deploy to Production
   - Mention: "Everything is defined as code, including our CI/CD pipeline"

4. **Commits**
   - Click on Commits tab
   - Show commit history
   - Point out: Commit messages, author, date

5. **Branch Policies** (if configured)
   - Go to Branches
   - Show main branch
   - Click on branch policies
   - Mention protection rules

**Key Points to Emphasize:**
- ✓ Complete application code
- ✓ Infrastructure as Code (pipeline YAML)
- ✓ Version control with Git
- ✓ Organized project structure

**URL:** `https://dev.azure.com/YOUR_ORG/ProjectX/_git/ProjectX`

---

### Part 4: CI Pipeline - Continuous Integration (5 minutes)

**What to Say:**
> "Now let's look at our CI/CD pipeline. Every time we push code to the main branch, it automatically builds, tests, and deploys the application."

**What to Show:**

1. **Pipeline Overview**
   - Navigate to Pipelines
   - Show the "ProjectX-CICD" pipeline
   - Show recent runs list

2. **Pipeline Run Details**
   - Click on a recent successful run
   - Show the visual pipeline with stages:
     - Build and Test ✓
     - Deploy to Staging ✓
     - Deploy to Production ✓

3. **Build Stage**
   - Click on "Build and Test" stage
   - Show the steps:
     - Install Node.js
     - Install Dependencies
     - Run Linting
     - Run Unit Tests ✓
     - Build Application
     - Publish Artifacts
   - Click on "Run Unit Tests" step
   - Show test output and results

4. **Test Results**
   - Click on "Tests" tab
   - Show:
     - Tests passed: X/X
     - Pass rate: 100%
     - Test duration
   - Mention: "All tests must pass before deployment"

5. **Artifacts**
   - Click on "Artifacts" or related tab
   - Show the published artifact (zip file)
   - Mention: "This artifact contains our deployable application"

**Key Points to Emphasize:**
- ✓ Automated on every code push
- ✓ Runs unit tests automatically
- ✓ Creates deployable artifacts
- ✓ Fails fast if tests fail

**URL:** `https://dev.azure.com/YOUR_ORG/ProjectX/_build`

---

### Part 5: CD Pipeline - Staging Deployment (4 minutes)

**What to Say:**
> "After the build succeeds, the application automatically deploys to our staging environment for testing."

**What to Show:**

1. **Staging Deployment Stage**
   - In the same pipeline run, click "Deploy to Staging"
   - Show deployment steps:
     - Download Artifacts
     - Deploy to Azure Web App (Staging)
     - Smoke Test - Staging ✓

2. **Deployment Logs**
   - Click on "Deploy to Azure Web App" step
   - Show Azure deployment logs
   - Point out: "Deploying to Azure Web App"

3. **Smoke Tests**
   - Click on "Smoke Test - Staging" step
   - Show health check test
   - Output: "✓ Staging health check passed!"

4. **Staging Environment**
   - Open new tab: `https://projectx-staging.azurewebsites.net`
   - Show the running application
   - Click on "Check Health Status" button
   - Show JSON response

5. **Test API Endpoints**
   - In terminal or using browser:
   ```bash
   # Get products
   curl https://projectx-staging.azurewebsites.net/api/products
   ```
   - Show product data returned

**Key Points to Emphasize:**
- ✓ Automatic deployment after build
- ✓ Deployed to staging first (safe environment)
- ✓ Automated smoke tests
- ✓ Real working application

---

### Part 6: Manual Approval Gate (3 minutes)

**What to Say:**
> "Before deploying to production, we have a manual approval gate. This ensures a human reviews the staging deployment before it goes live."

**What to Show:**

1. **Approval Configuration**
   - Navigate to Pipelines > Environments
   - Click on "ProjectX-Production" environment
   - Show "Approvals and checks" section
   - Point out who the approvers are

2. **Pending Approval** (if available)
   - In a running pipeline, show "Waiting for approval" status
   - Click on the approval request
   - Show approval dialog with options:
     - Approve
     - Reject
     - Comments field

3. **Approval Process**
   - Mention: "At this point, we would:"
     - Review staging deployment
     - Check test results
     - Verify functionality
     - Then approve for production

4. **Approval Workflow**
   - If you have a pending approval, demonstrate:
     - Add a comment: "Staging looks good, approved for production"
     - Click "Approve"
   - Show pipeline resuming after approval

**Key Points to Emphasize:**
- ✓ Safety gate before production
- ✓ Requires manual verification
- ✓ Audit trail with comments
- ✓ Can reject if issues found

**URL:** `https://dev.azure.com/YOUR_ORG/ProjectX/_environments`

---

### Part 7: Production Deployment (3 minutes)

**What to Say:**
> "Once approved, the application automatically deploys to our production environment where real users access it."

**What to Show:**

1. **Production Deployment Stage**
   - Show "Deploy to Production" stage (after approval)
   - Show deployment steps:
     - Download Artifacts
     - Deploy to Azure Web App (Production)
     - Smoke Test - Production ✓
     - Send Notification

2. **Production App**
   - Open: `https://projectx-production.azurewebsites.net`
   - Show the live application
   - Mention: "This is our production environment"
   - Show environment badge: "PROD"

3. **Test Production API**
   ```bash
   # Health check
   curl https://projectx-production.azurewebsites.net/api/health

   # Products API
   curl https://projectx-production.azurewebsites.net/api/products

   # Create order
   curl -X POST https://projectx-production.azurewebsites.net/api/orders \
     -H 'Content-Type: application/json' \
     -d '{"userId": 1, "items": [{"productId": 1, "quantity": 2}]}'
   ```

4. **Show Created Order**
   ```bash
   # Get orders
   curl https://projectx-production.azurewebsites.net/api/orders?userId=1
   ```

**Key Points to Emphasize:**
- ✓ Deployed after approval
- ✓ Same artifact as staging (consistency)
- ✓ Production configuration applied
- ✓ Live and working

---

### Part 8: Complete Workflow Demo (3 minutes)

**What to Say:**
> "Let me show you the complete workflow by making a small change and watching it flow through the entire pipeline."

**What to Show:**

1. **Make a Code Change**
   - In Azure Repos, edit a file (or use local Git)
   - Example: Edit `app/public/index.html`
   - Add a comment or change version number
   - Commit with message: "Demo: Update version number"

2. **Automatic Pipeline Trigger**
   - Navigate to Pipelines
   - Show new run starting automatically
   - Point out: "Triggered by commit to main branch"

3. **Watch Pipeline Execute**
   - Show progression through stages:
     - Build (running...)
     - Deploy Staging (waiting...)
     - Deploy Production (waiting for approval...)

4. **Fast Forward** (if time limited)
   - Mention: "In real-time this takes about 5-10 minutes"
   - Show a completed run from earlier
   - Walk through the successful deployment

**Key Points to Emphasize:**
- ✓ Fully automated workflow
- ✓ From code commit to production
- ✓ No manual deployment steps
- ✓ Complete CI/CD implementation

---

## 🎯 Closing Summary (2 minutes)

**What to Say:**
> "Let me summarize what we've implemented for ProjectX..."

**Show Summary Slide or Talk Through:**

### ✅ Requirements Met

1. **Azure Boards** ✓
   - Epic created for overall project
   - User Stories with acceptance criteria
   - Tasks broken down for implementation
   - Agile workflow established

2. **Azure Repos** ✓
   - Git repository created
   - Complete application code
   - Branch strategy (main branch)
   - Version control established

3. **CI/CD Pipeline** ✓
   - Continuous Integration pipeline
   - Automated builds on commit
   - Automated testing
   - Artifact generation

4. **Continuous Deployment** ✓
   - Staging environment deployment
   - Production environment deployment
   - Manual approval gates
   - Automated smoke tests

### 🚀 Key Benefits

- **Speed**: Automated deployment in minutes
- **Quality**: Tests run automatically
- **Safety**: Approval gates protect production
- **Repeatability**: Infrastructure as Code
- **Visibility**: Complete audit trail

### 💡 Infrastructure as Code Advantage

**What to Say:**
> "The best part? Everything we've shown is defined as code and stored in Git. When my Azure account expires in 6 hours, I can get a new one, update credentials, run one script, and have this entire environment recreated in 10 minutes!"

**Demonstrate:**
```bash
# Show the quickstart script
cat scripts/quickstart.sh

# Show credentials template
cat config/credentials.template.sh
```

**Mention:**
- "All scripts are in the Git repository"
- "Just update credentials and run ./scripts/quickstart.sh"
- "Everything redeploys automatically"
- "Perfect for learning environments with temporary accounts"

---

## 🛠️ Troubleshooting During Demo

### If Staging/Production is Down
```bash
# Check Azure Web App status
az webapp show --name projectx-staging --resource-group projectx-rg

# Restart if needed
az webapp restart --name projectx-staging --resource-group projectx-rg
```

### If Pipeline Fails
- Have a backup successful run ready to show
- Explain: "This is expected in real scenarios - the pipeline catches issues"
- Show how to debug with logs

### If Tests Fail
- Show test results tab
- Explain failure reason
- Mention: "This is a safety feature - prevents bad code from deploying"

---

## 📊 Additional Things to Show (If Time Permits)

### Analytics
- Navigate to Pipelines > Analytics
- Show deployment frequency
- Show success rate

### Work Item Linking
- Show how commits link to work items
- Mention traceability: Requirement → Code → Deployment

### Rollback Strategy
- Explain how to redeploy previous artifact
- Show artifact history

### Environment Variables
- Show how different configs for staging vs production
- Mention security best practices

---

## 📝 Q&A Preparation

**Common Questions:**

**Q: How long does the full pipeline take?**
A: "Approximately 5-10 minutes from commit to production deployment (including approval time)"

**Q: What if tests fail?**
A: "The pipeline stops immediately and notifies the team. No deployment happens until tests pass."

**Q: Can you deploy to production without approval?**
A: "No, we've configured a mandatory approval gate for the production environment."

**Q: How do you handle rollbacks?**
A: "We can redeploy a previous artifact or create a new commit that reverts changes."

**Q: What about database changes?**
A: "In a full implementation, we'd add database migration steps to the pipeline."

**Q: How much does this cost on Azure?**
A: "With B1/S1 tiers, approximately $50-100/month. Free tier available for learning."

**Q: Can this work with other cloud providers?**
A: "Yes, Azure DevOps can deploy to AWS, GCP, or on-premises. The pipeline would need minor adjustments."

---

## ✅ Demo Checklist

**Before Starting:**
- [ ] All scripts have executable permissions
- [ ] Credentials configured correctly
- [ ] At least one successful pipeline run exists
- [ ] Staging and production apps are running
- [ ] Browser tabs pre-opened
- [ ] Terminal/command prompt ready
- [ ] Demo script reviewed

**During Demo:**
- [ ] Speak clearly and at moderate pace
- [ ] Show, don't just tell
- [ ] Pause for questions
- [ ] Highlight key features
- [ ] Explain "why" not just "what"

**After Demo:**
- [ ] Share links to documentation
- [ ] Offer to answer more questions
- [ ] Provide GitHub repository link
- [ ] Share quickstart guide

---

## 🔗 Quick Reference Links

| Resource | URL Pattern |
|----------|-------------|
| Project Home | `https://dev.azure.com/{ORG}/{PROJECT}` |
| Boards | `https://dev.azure.com/{ORG}/{PROJECT}/_boards` |
| Repos | `https://dev.azure.com/{ORG}/{PROJECT}/_git/{REPO}` |
| Pipelines | `https://dev.azure.com/{ORG}/{PROJECT}/_build` |
| Environments | `https://dev.azure.com/{ORG}/{PROJECT}/_environments` |
| Staging App | `https://{STAGING_NAME}.azurewebsites.net` |
| Production App | `https://{PRODUCTION_NAME}.azurewebsites.net` |

---

## 🎓 Learning Outcomes Demonstrated

By the end of this demo, audience should understand:

1. ✓ How to organize work using Azure Boards
2. ✓ How to manage code with Azure Repos
3. ✓ How to implement CI/CD pipelines
4. ✓ How to deploy to multiple environments
5. ✓ How to use approval gates
6. ✓ How to implement Infrastructure as Code
7. ✓ Complete DevOps workflow from planning to production

---

**Good luck with your demo! 🚀**
