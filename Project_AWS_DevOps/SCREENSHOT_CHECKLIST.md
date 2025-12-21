# Screenshot Capture Checklist

Use this checklist to ensure you capture all required screenshots for your submission.

---

## ✅ Requirement 1: Infrastructure as Code (3 screenshots)

- [ ] **1.1** Terraform module structure (`ls -R terraform/modules`)
- [ ] **1.2** Terraform state output (`terraform show | head -50`)
- [ ] **1.3** main.tf showing module instantiations (VS Code screenshot)

---

## ✅ Requirement 2: Multi-Region Architecture (5 screenshots)

- [ ] **2.1** AWS VPC Dashboard showing both VPCs (10.0.0.0/16 and 10.1.0.0/16)
- [ ] **2.2** ECS Cluster in us-east-1 with running tasks
- [ ] **2.3** ECS Cluster in us-east-2 with running tasks
- [ ] **2.4** ALB in us-east-1 showing active status
- [ ] **2.5** ALB in us-east-2 showing active status

---

## ✅ Requirement 3: Container Management (5 screenshots)

- [ ] **3.1** Dockerfile showing multi-stage build (VS Code)
- [ ] **3.2** ECR repository in us-east-1 with images
- [ ] **3.3** ECR repository in us-east-2 with images
- [ ] **3.4** ECS Task Definition with container config
- [ ] **3.5** ECS Service showing auto-scaling configuration

---

## ✅ Requirement 4: Automated CI/CD Pipeline (6 screenshots)

- [ ] **4.1** CodePipeline showing all 5 stages (us-east-1)
- [ ] **4.2** Pipeline execution history with successful runs
- [ ] **4.3** CodeBuild project configuration
- [ ] **4.4** CodeBuild successful build logs
- [ ] **4.5** Manual approval stage configuration
- [ ] **4.6** buildspec.yml file (VS Code)

---

## ✅ Requirement 5: Source Code Replication (7 screenshots)

- [ ] **5.1** Lambda function overview page
- [ ] **5.2** Lambda function code showing Python replication logic
- [ ] **5.3** EventBridge rule for CodeCommit events
- [ ] **5.4** Lambda logs showing successful replication
- [ ] **5.5** Primary CodeCommit repository with commits
- [ ] **5.6** Secondary CodeCommit with "[Replicated]" commits
- [ ] **5.7** codecommit-replication Terraform module (VS Code)

---

## ✅ Requirement 6: Continuous Monitoring (6 screenshots)

- [ ] **6.1** CloudWatch Dashboard for us-east-1
- [ ] **6.2** CloudWatch Dashboard for us-east-2
- [ ] **6.3** CloudWatch Alarms list (us-east-1)
- [ ] **6.4** SNS topic with email subscription
- [ ] **6.5** Detailed alarm configuration (any alarm)
- [ ] **6.6** CloudWatch Log Groups list

---

## ✅ Requirement 7: Approval Gate (6 screenshots)

- [ ] **7.1** Pipeline showing approval stage waiting
- [ ] **7.2** Approval action configuration in pipeline
- [ ] **7.3** SNS approval notification email
- [ ] **7.4** Approval stage with "Review" button
- [ ] **7.5** Production stage after approval
- [ ] **7.6** IAM policy for CodePipeline (Terraform file)

---

## ✅ Additional Evidence (3 screenshots)

- [ ] **A.1** Primary region application in browser (with URL visible)
- [ ] **A.2** Secondary region application in browser (with URL visible)
- [ ] **A.3** Terraform output showing all resources

---

## 📋 Screenshot Quality Checklist

For each screenshot, ensure:
- [ ] High resolution (at least 1920x1080 or equivalent)
- [ ] Text is readable and not blurry
- [ ] Relevant section is visible (not too much whitespace)
- [ ] AWS region is visible in the screenshot
- [ ] Resource names clearly show "logicworks-devops" tags
- [ ] No sensitive information (passwords, access keys) visible
- [ ] Timestamp visible where relevant
- [ ] Console breadcrumbs/navigation visible for context

---

## 🖼️ Screenshot Naming Convention

Save screenshots with descriptive names:
```
Req1_1_Terraform_Modules.png
Req1_2_Terraform_State.png
Req1_3_Main_TF_Modules.png
Req2_1_VPCs_Both_Regions.png
Req2_2_ECS_Primary_Region.png
...and so on
```

---

## Quick Commands for Screenshots

### Requirement 1: IAC
```bash
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/Project_AWS_DevOps
tree terraform/modules -L 2
cd terraform
terraform show | head -50
```

### Requirement 4: Pipeline Status
```bash
aws codepipeline get-pipeline-state \
  --name logicworks-devops-pipeline-us-east-1 \
  --region us-east-1 \
  --query 'stageStates[*].[stageName,latestExecution.status]' \
  --output table
```

### Requirement 5: Lambda Logs
```bash
MSYS_NO_PATHCONV=1 aws logs filter-log-events \
  --log-group-name /aws/lambda/logicworks-devops-production-codecommit-replication \
  --region us-east-1 \
  --start-time $(($(date +%s) - 3600))000 \
  --query 'events[*].message' \
  --output text | grep -A 3 "Successfully replicated"
```

### Requirement 6: Log Groups
```bash
aws logs describe-log-groups \
  --region us-east-1 \
  --query 'logGroups[?contains(logGroupName, `logicworks`)].logGroupName' \
  --output table
```

### Application Health
```bash
echo "Primary Region:"
curl -I http://logicworks-devops-alb-us-east-1-799240009.us-east-1.elb.amazonaws.com

echo -e "\nSecondary Region:"
curl -I http://logicworks-devops-alb-us-east-2-234487.us-east-2.elb.amazonaws.com
```

### Terraform Outputs
```bash
cd terraform
terraform output
```

---

## AWS Console URLs for Quick Access

### Primary Region (us-east-1)
- **VPC:** https://us-east-1.console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
- **ECS:** https://us-east-1.console.aws.amazon.com/ecs/v2/clusters?region=us-east-1
- **ECR:** https://us-east-1.console.aws.amazon.com/ecr/repositories?region=us-east-1
- **Load Balancers:** https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:
- **CodePipeline:** https://us-east-1.console.aws.amazon.com/codesuite/codepipeline/pipelines?region=us-east-1
- **CodeCommit:** https://us-east-1.console.aws.amazon.com/codesuite/codecommit/repositories?region=us-east-1
- **CodeBuild:** https://us-east-1.console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-1
- **Lambda:** https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions
- **EventBridge:** https://us-east-1.console.aws.amazon.com/events/home?region=us-east-1#/rules
- **CloudWatch Dashboards:** https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:
- **CloudWatch Alarms:** https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:
- **SNS Topics:** https://us-east-1.console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics

### Secondary Region (us-east-2)
- Replace `us-east-1` with `us-east-2` in all URLs above

---

## Tips for High-Quality Screenshots

1. **Use Snipping Tool or Snip & Sketch (Windows)**
   - Press `Win + Shift + S` for quick screenshot
   - Select rectangular area carefully
   - Paste directly into Word or save as PNG

2. **Zoom Level**
   - Set browser zoom to 100% or 90% for optimal content fit
   - Avoid 125% or 150% zoom as it may cut off content

3. **Window Size**
   - Use full-screen browser (F11) for AWS Console screenshots
   - Maximize VS Code window for code screenshots
   - Ensure terminal output is not cut off

4. **Annotations (Optional)**
   - Use arrows to highlight important elements
   - Add text boxes to explain specific sections
   - Use red rectangles to draw attention to key areas

5. **Consistency**
   - Use same screenshot tool throughout
   - Maintain consistent window sizes
   - Use same VS Code theme for all code screenshots

---

## Time Estimate

- **Requirement 1:** 10 minutes (3 screenshots)
- **Requirement 2:** 15 minutes (5 screenshots)
- **Requirement 3:** 15 minutes (5 screenshots)
- **Requirement 4:** 20 minutes (6 screenshots)
- **Requirement 5:** 20 minutes (7 screenshots)
- **Requirement 6:** 15 minutes (6 screenshots)
- **Requirement 7:** 15 minutes (6 screenshots)
- **Additional:** 10 minutes (3 screenshots)

**Total Time:** ~2 hours for all screenshots

---

## Before You Start

Make sure:
- [ ] Both pipelines have run at least once successfully
- [ ] Both applications are accessible via ALB URLs
- [ ] Lambda has executed successfully (check logs)
- [ ] You're logged into AWS Console with appropriate permissions
- [ ] Browser zoom is set to 100%
- [ ] Screenshots folder created for organizing captures
- [ ] This checklist is printed or on second screen for reference

---

## After Capturing All Screenshots

- [ ] Review each screenshot for quality and readability
- [ ] Rename files with descriptive names
- [ ] Organize into folders by requirement
- [ ] Verify no sensitive data is visible
- [ ] Create backup of all screenshots
- [ ] Insert into Word document with captions
- [ ] Add figure numbers (Figure 1.1, Figure 1.2, etc.)
- [ ] Cross-check with submission guide

---

Good luck! 📸
