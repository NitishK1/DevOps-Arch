# AWS DevOps Multi-Region Project - Progress Log

## Date: December 20, 2025



## ✅ COMPLETED TODAY

### 1. Script Automation
- ✅ **deploy.sh** - Fully automated deployment without manual intervention
  - Added pre-deployment cleanup for CloudWatch Log Groups
  - Fixed CodeCommit credential handling
  - Uses local git config (not global)

- ✅ **cleanup.sh** - Automated resource destruction
  - Removed manual confirmation prompt
  - Phase 1: ECR cleanup
  - Phase 2: S3 bucket cleanup (versions + delete markers)
  - Phase 3: ECS service scale-down
  - Phase 4: CloudWatch Log Groups deletion (with MSYS_NO_PATHCONV=1 for Git
    Bash)
  - Phase 5: Terraform destroy
  - Phase 6: Local cleanup

- ✅ **push-app.sh** - CodeCommit push automation
  - Uses CodeCommit Git credentials (username/password)
  - Embedded credentials in HTTPS URL
  - Works with Git Bash on Windows

### 2. CI/CD Pipeline Fixes
- ✅ Fixed Docker Hub rate limit → Using ECR Public Gallery
  (`public.ecr.aws/docker/library/node:18-alpine`)
- ✅ Fixed container name mismatch → `logicworks-devops-container` in
  imagedefinitions.json
- ✅ Enhanced CodePipeline IAM role:
  - Added `ecs:TagResource`
  - Updated `iam:PassRole` conditions for ECS
  - Added ELB permissions (DescribeTargetGroups, ModifyListener, etc.)

### 3. Infrastructure Deployment
- ✅ Multi-region infrastructure deployed:
  - **Primary (us-east-1)**: VPC, ECS, ALB, ECR, CodeCommit, CodePipeline,
    CloudWatch
  - **Secondary (us-east-2)**: VPC, ECS, ALB, ECR, CloudWatch
- ✅ Pipeline successfully builds and deploys to PRIMARY region
- ✅ Monitoring and alerting configured in both regions



## 🟢 CURRENT STATE

### Working Components
- Infrastructure deployed in both regions
- CI/CD pipeline operational (primary region only)
- Containers running and healthy
- Push to CodeCommit triggers pipeline
- Build → Test → Deploy-Staging → Manual Approval → Deploy-Production
- Monitoring dashboards active

### URLs
- **Primary ALB**:
  http://logicworks-devops-alb-us-east-1-409649726.us-east-1.elb.amazonaws.com
- **Secondary ALB**:
  http://logicworks-devops-alb-us-east-2-1959001207.us-east-2.elb.amazonaws.com
- **Pipeline**: https://console.aws.amazon.com/codesuite/codepipeline/pipelines

### Credentials
- AWS credentials: `config/credentials.sh` (includes CodeCommit
  username/password)
- Credentials expire: 6-hour rotation
- Template: `config/credentials.template.sh`



## ⚠️ REQUIREMENTS GAP

### Current Compliance: 80%

**Fully Met**:
1. ✅ Infrastructure as Code (Terraform)
2. ✅ Multi-region infrastructure (us-east-1, us-east-2)
3. ✅ Containerization (Docker + ECS + ECR)
4. ⚠️ CI/CD automation (exists but only deploys to primary)
5. ❌ CodeCommit replication to secondary region
6. ✅ Monitoring with notifications (CloudWatch + SNS)
7. ✅ Manual approval stage

**Missing**:
- Pipeline only deploys to PRIMARY region (should deploy to both)
- CodeCommit NOT replicated to secondary region



## 📋 NEXT SESSION PLAN: Option A Implementation

### Phase 1: Update buildspec.yml (15 min)
```yaml
Add to post_build:
- Login to secondary ECR (us-east-2)
- Tag image for secondary ECR
- Push to secondary ECR:latest and :$IMAGE_TAG
```

### Phase 2: Update CodePipeline (20 min)
Add new stages to `terraform/modules/codepipeline/main.tf`:
1. **Deploy-Staging-Secondary** (after Deploy-Staging-Primary)
   - Provider: ECS (us-east-2)
   - Cluster: logicworks-devops-cluster-us-east-2
   - Service: logicworks-devops-service-us-east-2

2. **Deploy-Production-Secondary** (after Deploy-Production-Primary)
   - Provider: ECS (us-east-2)
   - Cluster: logicworks-devops-cluster-us-east-2
   - Service: logicworks-devops-service-us-east-2

### Phase 3: Update IAM Permissions (10 min)
Add to CodePipeline role:
- ECR permissions for us-east-2
- ECS permissions for us-east-2
- Cross-region resource access

### Phase 4: CodeCommit Replication (15 min)
Options:
- **Simple**: Manual sync script
- **Advanced**: Lambda-based replication trigger

### Phase 5: Testing (20 min)
1. Apply Terraform changes
2. Push test commit to CodeCommit
3. Verify pipeline deploys to both regions
4. Test both ALB URLs
5. Verify secondary region serves new image

**Total Time**: ~80 minutes



## 📁 KEY FILES

### Scripts
- `scripts/deploy.sh` - Infrastructure deployment
- `scripts/cleanup.sh` - Resource cleanup
- `scripts/push-app.sh` - Push code to CodeCommit

### Terraform
- `terraform/main.tf` - Root module
- `terraform/modules/codepipeline/main.tf` - Pipeline configuration
- `terraform/modules/ecs/main.tf` - ECS cluster, services, tasks
- `terraform/modules/vpc/main.tf` - Networking
- `terraform/modules/ecr/main.tf` - Docker registry

### Application
- `app/Dockerfile` - Container image (node:18-alpine from ECR Public)
- `app/server.js` - Node.js Express application
- `buildspec.yml` - CodeBuild instructions

### Config
- `config/credentials.sh` - AWS credentials (not in git)
- `config/credentials.template.sh` - Template for credentials



## 🔧 TROUBLESHOOTING NOTES

### Git Bash on Windows Issues
- Use `MSYS_NO_PATHCONV=1` prefix for AWS CLI commands with paths starting with
  `/`
- Example:
  `MSYS_NO_PATHCONV=1 aws logs delete-log-group --log-group-name "/aws/vpc/..."`

### CodeCommit Authentication
- Use Git credentials (username/password), NOT credential helper
- Embedded in URL: `https://${USERNAME}:${PASSWORD}@git-codecommit...`

### Docker Hub Rate Limits
- Use ECR Public Gallery: `public.ecr.aws/docker/library/node:18-alpine`
- No authentication needed for public images

### CloudWatch Log Groups
- Must be deleted BEFORE Terraform destroy
- Pre-deployment cleanup in deploy.sh prevents conflicts



## 📊 RESOURCE COUNT

**Deployed Resources**: ~75 per Terraform run
- 2 VPCs (primary + secondary)
- 2 ECS Clusters
- 2 ALBs
- 2 ECR Repositories
- 1 CodePipeline (primary only)
- 1 CodeBuild project
- 1 CodeCommit repository (primary only)
- 6+ CloudWatch Dashboards and Alarms
- 3 SNS Topics

**Cost Estimate**: ~$50-100/day (ECS Fargate + NAT Gateways are primary costs)



## 🎯 SUCCESS CRITERIA (Next Session)

- [ ] Pipeline deploys Docker image to BOTH regions
- [ ] CodeCommit code available in secondary region
- [ ] Both ALB URLs serve the same application version
- [ ] Single push triggers deployment to both regions
- [ ] 100% requirements compliance



## 📝 NOTES

- AWS credentials rotate every 6 hours (AWS Academy)
- Always source credentials before running scripts:
  `source config/credentials.sh`
- Test cleanup.sh in non-production to verify automated cleanup
- Secondary region currently has infrastructure but receives no automatic
  deployments
- Pipeline stages: Source → Build → Deploy-Staging (Primary) → Manual Approval →
  Deploy-Production (Primary)



**Session End Time**: December 20, 2025 **Status**: Infrastructure operational,
80% requirements met **Next**: Implement cross-region pipeline deployment
(Option A)
