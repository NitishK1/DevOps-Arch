# ProjectX - Technical Documentation

## 📖 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Application Structure](#application-structure)
5. [Azure DevOps Implementation](#azure-devops-implementation)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Deployment Strategy](#deployment-strategy)
8. [Security Considerations](#security-considerations)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Troubleshooting](#troubleshooting)



## 1. Project Overview

### Business Context

**TechCo** is implementing a modern order management system (ProjectX) to
streamline their software development lifecycle and improve operational
efficiency.

### Project Goals

- Develop a web-based order management system
- Implement complete DevOps practices
- Automate build, test, and deployment processes
- Enable rapid feature delivery while maintaining quality
- Provide clear visibility into development progress

### Success Criteria

1. ✓ All work items organized in Azure Boards
2. ✓ Source code managed in Azure Repos with proper branching
3. ✓ Automated CI pipeline building and testing code
4. ✓ Automated CD pipeline deploying to staging
5. ✓ Manual approval gate before production deployment
6. ✓ Working application accessible in production



## 2. Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure DevOps                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────┐      ┌────────────┐      ┌──────────────┐       │
│  │  Boards   │─────▶│   Repos    │─────▶│  Pipelines   │       │
│  │           │      │            │      │              │       │
│  │ Epic      │      │ Git Repo   │      │ CI/CD YAML   │       │
│  │ Stories   │      │ Branches   │      │ Stages       │       │
│  │ Tasks     │      │ Pull Req.  │      │ Approval     │       │
│  └───────────┘      └────────────┘      └──────────────┘       │
│                                                   │               │
└───────────────────────────────────────────────────┼───────────────┘
                                                    │
                                                    ▼
                            ┌───────────────────────────────────┐
                            │        Azure Cloud                │
                            ├───────────────────────────────────┤
                            │                                   │
                            │  ┌─────────────────────────┐     │
                            │  │  Staging Environment    │     │
                            │  │  - App Service (B1)     │     │
                            │  │  - Auto Deploy          │     │
                            │  └─────────────────────────┘     │
                            │                                   │
                            │  ┌─────────────────────────┐     │
                            │  │  Production Environment │     │
                            │  │  - App Service (S1)     │     │
                            │  │  - Manual Approval      │     │
                            │  └─────────────────────────┘     │
                            │                                   │
                            └───────────────────────────────────┘
```

### Application Architecture

```
┌────────────────────────────────────────────────────────────┐
│                     Client (Browser)                        │
└────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS
                            ▼
┌────────────────────────────────────────────────────────────┐
│                    Azure App Service                        │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │            Express.js Server                      │      │
│  │                                                    │      │
│  │  ┌──────────────────────────────────────────┐   │      │
│  │  │  Middleware Layer                         │   │      │
│  │  │  - CORS                                   │   │      │
│  │  │  - Helmet (Security)                      │   │      │
│  │  │  - Rate Limiting                          │   │      │
│  │  │  - Request Logging                        │   │      │
│  │  └──────────────────────────────────────────┘   │      │
│  │                                                    │      │
│  │  ┌──────────────────────────────────────────┐   │      │
│  │  │  API Routes                               │   │      │
│  │  │  - /api/auth/*    (Authentication)        │   │      │
│  │  │  - /api/products/* (Product Catalog)      │   │      │
│  │  │  - /api/orders/*   (Order Management)     │   │      │
│  │  │  - /api/admin/*    (Admin Functions)      │   │      │
│  │  └──────────────────────────────────────────┘   │      │
│  │                                                    │      │
│  │  ┌──────────────────────────────────────────┐   │      │
│  │  │  Business Logic                           │   │      │
│  │  │  - Order Processing                       │   │      │
│  │  │  - Inventory Management                   │   │      │
│  │  │  - User Management                        │   │      │
│  │  └──────────────────────────────────────────┘   │      │
│  │                                                    │      │
│  │  ┌──────────────────────────────────────────┐   │      │
│  │  │  Data Access Layer                        │   │      │
│  │  │  - In-Memory Store (Demo)                 │   │      │
│  │  │  - MongoDB (Production-ready)             │   │      │
│  │  └──────────────────────────────────────────┘   │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
└────────────────────────────────────────────────────────────┘
```



## 3. Technology Stack

### Application

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Runtime | Node.js | 18.x LTS | Server-side JavaScript runtime |
| Framework | Express.js | 4.18.x | Web application framework |
| Language | JavaScript | ES2020+ | Programming language |
| Package Manager | npm | 9.x+ | Dependency management |

### Development Tools

| Tool | Purpose |
|------|---------|
| Jest | Unit testing framework |
| ESLint | Code linting and style checking |
| Nodemon | Development auto-restart |
| Morgan | HTTP request logger |

### Azure Services

| Service | SKU | Purpose |
|---------|-----|---------|
| Azure DevOps | Free Tier | Complete DevOps platform |
| App Service (Staging) | B1 | Staging environment hosting |
| App Service (Production) | S1 | Production environment hosting |
| Azure Repos | Included | Git repository hosting |
| Azure Pipelines | Free for public | CI/CD automation |

### Security & Middleware

| Package | Purpose |
|---------|---------|
| Helmet | HTTP security headers |
| CORS | Cross-origin resource sharing |
| express-rate-limit | API rate limiting |
| bcrypt | Password hashing |
| jsonwebtoken | JWT authentication |



## 4. Application Structure

### Directory Layout

```
app/
├── server.js                 # Express server and API routes
├── package.json             # Dependencies and scripts
├── .env.example             # Environment variables template
├── public/                  # Static files
│   └── index.html          # Landing page
├── src/                     # Source code (future expansion)
│   ├── controllers/        # Request handlers
│   ├── models/            # Data models
│   ├── routes/            # Route definitions
│   ├── middleware/        # Custom middleware
│   └── utils/             # Helper functions
└── tests/                   # Test files
    ├── api.test.js         # API endpoint tests
    ├── unit/               # Unit tests
    └── integration/        # Integration tests
```

### API Endpoints

#### Authentication Endpoints

```
POST   /api/auth/register    Register new user
POST   /api/auth/login       Login existing user
POST   /api/auth/logout      Logout user
POST   /api/auth/reset       Request password reset
```

#### Product Endpoints

```
GET    /api/products         Get all products (with filters)
GET    /api/products/:id     Get specific product
POST   /api/products         Create new product (admin)
PUT    /api/products/:id     Update product (admin)
DELETE /api/products/:id     Delete product (admin)
```

#### Order Endpoints

```
POST   /api/orders           Create new order
GET    /api/orders           Get user's orders
GET    /api/orders/:id       Get specific order
PATCH  /api/orders/:id       Update order status
DELETE /api/orders/:id       Cancel order
```

#### Admin Endpoints

```
GET    /api/admin/dashboard         Dashboard statistics
GET    /api/admin/orders            All orders (with filters)
PATCH  /api/admin/orders/:id/status Update order status
POST   /api/admin/orders/:id/cancel Cancel and refund order
GET    /api/admin/reports           Generate reports
```

#### Health & Monitoring

```
GET    /api/health           Health check endpoint
GET    /api/version          Application version info
```

### Request/Response Examples

#### Create Order

**Request:**
```bash
POST /api/orders
Content-Type: application/json

{
  "userId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2
    },
    {
      "productId": 3,
      "quantity": 1
    }
  ]
}
```

**Response:**
```json
{
  "message": "Order created successfully",
  "order": {
    "id": 1,
    "userId": 1,
    "items": [
      {
        "productId": 1,
        "productName": "Laptop",
        "quantity": 2,
        "price": 999.99,
        "subtotal": 1999.98
      },
      {
        "productId": 3,
        "productName": "Keyboard",
        "quantity": 1,
        "price": 79.99,
        "subtotal": 79.99
      }
    ],
    "total": 2079.97,
    "status": "Pending",
    "createdAt": "2025-12-18T10:30:00.000Z",
    "statusHistory": [
      {
        "status": "Pending",
        "timestamp": "2025-12-18T10:30:00.000Z"
      }
    ]
  }
}
```



## 5. Azure DevOps Implementation

### Work Items Structure

#### Epic Level
- **Epic Name:** ProjectX - Order Management System
- **Purpose:** Overall project goal and vision
- **Contains:** 5 User Stories

#### User Story Level

1. **US1: User Authentication and Authorization**
   - Story Points: 8
   - Priority: 1 (High)
   - Tasks: 7

2. **US2: Create and Submit Orders**
   - Story Points: 13
   - Priority: 2 (High)
   - Tasks: 9

3. **US3: View and Track Orders**
   - Story Points: 8
   - Priority: 2 (High)
   - Tasks: 7

4. **US4: Order Management for Administrators**
   - Story Points: 13
   - Priority: 3 (Medium)
   - Tasks: 9

5. **US5: Product Catalog Management**
   - Story Points: 8
   - Priority: 3 (Medium)
   - Tasks: 9

#### Task Level

Each task includes:
- Title
- Detailed description
- Estimated hours
- State (New, Active, Closed)
- Tags (backend, frontend, testing, etc.)
- Parent user story link

### Repository Structure

```
ProjectX/
├── .gitignore                 # Git ignore rules
├── README.md                  # Project documentation
├── DEMO_GUIDE.md             # Demo instructions
├── PROJECT_DOCUMENTATION.md   # This file
├── app/                       # Application code
├── pipelines/                 # CI/CD configurations
├── scripts/                   # Automation scripts
├── work-items/               # Work item templates
│   ├── epic.json
│   ├── user-stories.json
│   └── tasks.json
└── config/                    # Configuration files
    ├── credentials.template.sh
    └── project-config.json
```

### Branch Strategy

#### Main Branch
- **Purpose:** Production-ready code
- **Protection:** Enabled
- **Requirements:**
  - Pull request required
  - Successful build required
  - Code review required (recommended)

#### Feature Branches (Future)
- **Pattern:** `feature/<feature-name>`
- **Purpose:** New feature development
- **Merge:** Via pull request to main

#### Hotfix Branches (Future)
- **Pattern:** `hotfix/<issue-name>`
- **Purpose:** Critical production fixes
- **Merge:** Via pull request to main



## 6. CI/CD Pipeline

### Pipeline Overview

The pipeline consists of three main stages:

1. **Build & Test** (CI)
2. **Deploy to Staging** (CD)
3. **Deploy to Production** (CD with approval)

### Stage 1: Build & Test

**Triggers:**
- Push to `main` branch
- Push to `develop` branch
- Pull request to `main` branch

**Steps:**

```yaml
1. Setup Environment
   - Install Node.js 18.x
   - Configure build agent

2. Install Dependencies
   - npm ci (clean install)
   - Verify package-lock.json

3. Code Quality
   - Run ESLint
   - Check code style

4. Run Tests
   - Execute unit tests
   - Generate coverage report
   - Publish test results

5. Build Application
   - Run build script
   - Prepare for deployment

6. Create Artifacts
   - Archive application files
   - Publish to artifact store
```

**Outputs:**
- Build artifact (ZIP file)
- Test results
- Code coverage report

**Duration:** ~3-5 minutes

### Stage 2: Deploy to Staging

**Triggers:**
- Successful build on `main` branch

**Steps:**

```yaml
1. Download Artifacts
   - Retrieve build artifact from stage 1

2. Deploy to Azure Web App
   - Target: Staging App Service
   - Method: ZIP deploy
   - Runtime: Node 18-lts
   - Start command: npm start

3. Configure Environment
   - Set NODE_ENV=staging
   - Set application settings

4. Wait for Deployment
   - 30 second stabilization wait

5. Smoke Tests
   - Health check endpoint
   - Basic API verification
   - Response validation
```

**Environment:** ProjectX-Staging **URL:**
`https://projectx-staging.azurewebsites.net` **Duration:** ~2-3 minutes

### Stage 3: Deploy to Production

**Triggers:**
- Successful staging deployment
- Manual approval granted

**Approval Gate:**
- **Required:** Yes
- **Approvers:** Project admins
- **Timeout:** 30 days
- **Instructions:** "Review staging deployment before approving"

**Steps:**

```yaml
1. Manual Approval
   - Wait for human approval
   - Review staging environment
   - Approve or reject

2. Download Artifacts
   - Retrieve same artifact from stage 1

3. Deploy to Azure Web App
   - Target: Production App Service
   - Method: ZIP deploy
   - Runtime: Node 18-lts
   - Start command: npm start

4. Configure Environment
   - Set NODE_ENV=production
   - Set production settings

5. Wait for Deployment
   - 30 second stabilization wait

6. Smoke Tests
   - Health check endpoint
   - Critical API verification
   - Performance check

7. Notifications
   - Send deployment notification
   - Update deployment dashboard
```

**Environment:** ProjectX-Production **URL:**
`https://projectx-production.azurewebsites.net` **Duration:** ~2-3 minutes (+
approval time)

### Pipeline Variables

| Variable | Type | Description |
|----------|------|-------------|
| `azureSubscription` | Service Connection | Azure RM connection |
| `resourceGroupName` | String | Azure resource group |
| `stagingWebAppName` | String | Staging app name |
| `productionWebAppName` | String | Production app name |
| `nodeVersion` | String | Node.js version (18.x) |

### Pipeline Artifacts

**Artifact Name:** `drop` **Contents:**
```
projectx-<buildId>.zip
├── server.js
├── package.json
├── package-lock.json
├── public/
│   └── index.html
└── node_modules/ (excluded, npm install on target)
```



## 7. Deployment Strategy

### Blue-Green Deployment (Future Enhancement)

```
┌─────────────────────────────────────────────────────┐
│              Azure App Service                       │
├─────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────────────┐         ┌─────────────────┐   │
│  │  Blue (Current) │◄────────│  Traffic Manager │   │
│  │  Version 1.0    │   100%  │                  │   │
│  └─────────────────┘         └─────────────────┘   │
│                                         │            │
│  ┌─────────────────┐                   │            │
│  │  Green (New)    │                   │ 0%         │
│  │  Version 1.1    │◄──────────────────┘            │
│  └─────────────────┘                                │
│                                                       │
└─────────────────────────────────────────────────────┘

After validation, swap traffic to Green
```

### Rollback Strategy

**Method 1: Redeploy Previous Artifact**
```bash
# List previous builds
az pipelines runs list --branch main

# Download specific artifact
az pipelines runs artifact download \
  --run-id <previous-run-id> \
  --artifact-name drop

# Redeploy to production
az webapp deployment source config-zip \
  --resource-group projectx-rg \
  --name projectx-production \
  --src <artifact-path>
```

**Method 2: Git Revert**
```bash
# Revert last commit
git revert HEAD

# Push to trigger new deployment
git push origin main
```

### Environment Configuration

#### Staging Environment
```yaml
App Service Plan: projectx-asp-staging
SKU: B1 (Basic)
OS: Linux
Runtime: Node 18-lts
Always On: Disabled
Environment Variables:
  - NODE_ENV: staging
  - PORT: 8080
  - LOG_LEVEL: debug
```

#### Production Environment
```yaml
App Service Plan: projectx-asp-prod
SKU: S1 (Standard)
OS: Linux
Runtime: Node 18-lts
Always On: Enabled
Auto-scaling: Enabled (2-10 instances)
Environment Variables:
  - NODE_ENV: production
  - PORT: 8080
  - LOG_LEVEL: error
```



## 8. Security Considerations

### Application Security

1. **HTTP Security Headers** (Helmet.js)
   - X-Content-Type-Options: nosniff
   - X-Frame-Options: DENY
   - X-XSS-Protection: 1; mode=block
   - Strict-Transport-Security

2. **Rate Limiting**
   - 100 requests per 15 minutes per IP
   - Prevents brute force attacks

3. **CORS Configuration**
   - Restricted origins in production
   - Credentials allowed for authorized domains

4. **Input Validation**
   - Request body validation
   - Query parameter sanitization
   - SQL injection prevention

5. **Authentication** (Future)
   - JWT-based authentication
   - Password hashing with bcrypt
   - Session management

### Azure Security

1. **Service Connections**
   - Service Principal with least privilege
   - Automatic secret rotation
   - Audit logging enabled

2. **Pipeline Secrets**
   - Stored in Azure Key Vault
   - Never logged in pipeline output
   - Encrypted at rest

3. **Network Security**
   - HTTPS only (TLS 1.2+)
   - Private endpoints (future)
   - VNet integration (future)

4. **Access Control**
   - Azure RBAC for resource access
   - DevOps organization policies
   - Branch protection policies

### Best Practices

- ✓ Never commit secrets to Git
- ✓ Use environment variables for configuration
- ✓ credentials.sh in .gitignore
- ✓ Regular dependency updates
- ✓ Security scanning in pipeline (future)
- ✓ Penetration testing (future)



## 9. Monitoring and Logging

### Application Logging

**Morgan HTTP Logger:**
```javascript
app.use(morgan('combined'));
```

**Log Format:**
```
:remote-addr - :remote-user [:date] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent"
```

**Example:**
```
192.168.1.1 - - [18/Dec/2025:10:30:45 +0000] "GET /api/products HTTP/1.1" 200 1234 "-" "Mozilla/5.0..."
```

### Azure App Service Logs

**Enable Logging:**
```bash
# Enable application logging
az webapp log config \
  --name projectx-production \
  --resource-group projectx-rg \
  --application-logging filesystem \
  --level information

# Enable web server logging
az webapp log config \
  --name projectx-production \
  --resource-group projectx-rg \
  --web-server-logging filesystem
```

**View Live Logs:**
```bash
az webapp log tail \
  --name projectx-production \
  --resource-group projectx-rg
```

### Monitoring Endpoints

#### Health Check
```
GET /api/health

Response:
{
  "status": "healthy",
  "timestamp": "2025-12-18T10:30:00.000Z",
  "version": "1.0.0",
  "environment": "production"
}
```

### Azure Monitor Integration (Future)

**Application Insights:**
- Request tracking
- Dependency tracking
- Exception tracking
- Custom events

**Metrics to Track:**
- Response time
- Request rate
- Error rate
- CPU/Memory usage
- Active connections

**Alerts:**
- Response time > 2s
- Error rate > 5%
- CPU > 80%
- Memory > 85%



## 10. Troubleshooting

### Common Issues

#### Issue: Pipeline Fails at Build Stage

**Symptoms:**
- npm ci fails
- Tests fail
- Build errors

**Solutions:**
```bash
# Verify package.json locally
npm ci
npm test
npm run build

# Check Node.js version
node --version  # Should be 18.x

# Clear npm cache in pipeline (add to YAML)
- script: npm cache clean --force
```

#### Issue: Staging Deployment Fails

**Symptoms:**
- Azure deployment times out
- Health check fails
- 500 Internal Server Error

**Solutions:**
```bash
# Check Azure Web App logs
az webapp log tail \
  --name projectx-staging \
  --resource-group projectx-rg

# Restart the Web App
az webapp restart \
  --name projectx-staging \
  --resource-group projectx-rg

# Check app settings
az webapp config appsettings list \
  --name projectx-staging \
  --resource-group projectx-rg
```

#### Issue: Production Approval Stuck

**Symptoms:**
- Pipeline waiting indefinitely
- No approval notification

**Solutions:**
1. Check Environments page
2. Verify approver configuration
3. Check email notifications
4. Manually trigger approval from UI

#### Issue: Application Not Responding

**Symptoms:**
- 502 Bad Gateway
- 503 Service Unavailable
- Timeout errors

**Solutions:**
```bash
# Check Web App status
az webapp show \
  --name projectx-production \
  --resource-group projectx-rg \
  --query state

# Scale up temporarily
az appservice plan update \
  --name projectx-asp-prod \
  --resource-group projectx-rg \
  --sku S2

# Check recent deployments
az webapp deployment list \
  --name projectx-production \
  --resource-group projectx-rg
```

### Debugging Commands

```bash
# View all resources
az resource list \
  --resource-group projectx-rg \
  --output table

# Check Web App configuration
az webapp config show \
  --name projectx-production \
  --resource-group projectx-rg

# View deployment history
az webapp deployment list-publishing-profiles \
  --name projectx-production \
  --resource-group projectx-rg

# SSH into Web App (if configured)
az webapp ssh \
  --name projectx-production \
  --resource-group projectx-rg
```

### Pipeline Debugging

```bash
# View pipeline runs
az pipelines runs list \
  --branch main \
  --top 5

# Get specific run details
az pipelines runs show \
  --id <run-id>

# Download pipeline logs
az pipelines runs artifact download \
  --run-id <run-id> \
  --artifact-name logs
```

### Health Check Script

```bash
#!/bin/bash
# check-health.sh

STAGING_URL="https://projectx-staging.azurewebsites.net"
PROD_URL="https://projectx-production.azurewebsites.net"

echo "Checking Staging..."
curl -f $STAGING_URL/api/health || echo "Staging DOWN"

echo "Checking Production..."
curl -f $PROD_URL/api/health || echo "Production DOWN"
```



## Appendix A: Script Reference

### quickstart.sh
Complete automated setup script. Runs all setup scripts in sequence.

**Usage:**
```bash
./scripts/quickstart.sh
```

### setup-azure-devops.sh
Creates Azure DevOps project.

### create-work-items.sh
Creates Epic, User Stories, and Tasks in Azure Boards.

### setup-repo.sh
Initializes Git repository and pushes to Azure Repos.

### setup-pipelines.sh
Creates CI/CD pipeline and Azure resources.

### demo.sh
Interactive demo walkthrough script.

### cleanup.sh
Removes all Azure resources.



## Appendix B: Useful Commands

### Azure CLI

```bash
# Login
az login

# Set subscription
az account set --subscription <id>

# List resources
az resource list --resource-group projectx-rg

# View Web App logs
az webapp log tail --name projectx-production --resource-group projectx-rg
```

### Azure DevOps CLI

```bash
# Configure defaults
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=ProjectX

# List pipelines
az pipelines list

# Run pipeline
az pipelines run --name ProjectX-CICD

# List work items
az boards work-item list --query "[].{ID:id, Title:fields.'System.Title'}"
```

### Git Commands

```bash
# Check status
git status

# Add and commit
git add .
git commit -m "Your message"

# Push to Azure Repos
git push azure main

# View commit history
git log --oneline -10
```



## Appendix C: Cost Estimation

### Monthly Costs (USD)

| Service | SKU | Quantity | Monthly Cost |
|---------|-----|----------|--------------|
| App Service Plan (Staging) | B1 | 1 | $13.14 |
| App Service Plan (Production) | S1 | 1 | $73.00 |
| Azure DevOps | Free Tier | - | $0 |
| Azure Repos | Free Tier | - | $0 |
| Azure Pipelines | Free Tier | - | $0 |
| **Total** | | | **~$86/month** |

**Notes:**
- Free tier available for learning (F1 SKU)
- Costs vary by region
- Stop resources when not in use to save costs



## Appendix D: References

### Documentation Links

- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)

### Learning Resources

- [Edureka DevOps Training](https://www.edureka.co/)
- [Azure DevOps Labs](https://azuredevopslabs.com/)
- [Microsoft Learn - DevOps](https://docs.microsoft.com/en-us/learn/browse/?products=azure-devops)



**Document Version:** 1.0.0 **Last Updated:** December 18, 2025 **Maintained
By:** TechCo DevOps Team
