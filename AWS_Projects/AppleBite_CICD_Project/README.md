# AppleBite CI/CD Project

## 📚 Documentation

This project has **two main documentation files**:

### 1. [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)
**Complete technical reference and setup guide**

Contains:
- Project overview and architecture
- Prerequisites and requirements
- Jenkins configuration (step-by-step)
- Pipeline stages explanation
- Troubleshooting guide
- Git submodules setup
- Quick reference commands

**Use this when:** Setting up the project, configuring Jenkins, or
troubleshooting issues.



### 2. [DEMO_GUIDE.md](DEMO_GUIDE.md)
**Step-by-step manual demonstration script**

Contains:
- Pre-demo setup checklist
- Complete demo walkthrough with commands
- Explanation of each component
- Common demo scenarios
- 30-minute demo timeline
- Tips for successful demonstrations

**Use this when:** Presenting the project, giving a demo, or showing manual
steps without automation.



## 🚀 Quick Start

### For New Users
1. Read **PROJECT_DOCUMENTATION.md** sections 1-4
2. Configure Jenkins following section 4
3. Run your first build

### For Demonstrations
1. Follow **DEMO_GUIDE.md** Pre-Demo Setup
2. Execute demo script Phase 1-8
3. Use the provided commands to show each component



## 📁 Project Structure

```
AppleBite_CICD_Project/
├── PROJECT_DOCUMENTATION.md    ← Complete reference guide
├── DEMO_GUIDE.md               ← Manual demo script
├── app/                        ← PHP application (submodule)
├── docker/                     ← Dockerfiles and compose files
├── jenkins/                    ← Jenkinsfile (CI/CD pipeline)
├── ansible/                    ← Configuration management
└── scripts/                    ← Utility scripts
```



## 🔗 Important URLs

- **Jenkins:** http://127.0.0.1:8090
- **Test Environment:** http://127.0.0.1:8080
- **Stage Environment:** http://127.0.0.1:8081
- **Production Environment:** http://127.0.0.1:8082



## 🛠️ Technologies

- **Git** - Version control with submodules
- **Jenkins** - CI/CD automation (local Windows installation)
- **Docker** - Application containerization
- **Ansible** - Configuration management (optional)
- **PHP 7.4 + Apache** - Application stack



## 📋 Problem Statement

AppleBite Co. needs to:
- Deliver frequent updates with high quality
- Accelerate software delivery and reduce feedback time
- Automate deployment from dev → test → stage → production

**Solution:** Automated CI/CD pipeline triggered by Git push.



## ✅ Success Criteria

- ✅ Push to GitHub → Build triggers automatically
- ✅ Pipeline completes all stages successfully
- ✅ Application deploys to test environment (port 8080)
- ✅ Integration tests pass
- ✅ Application returns HTTP 200 OK



## 🆘 Quick Help

**Pipeline not triggering?** → Check Jenkins Build Triggers (Poll SCM
configured)

**HTTP 403 error?** → Fixed! Volume mount corrected in docker-compose.test.yml

**Container unhealthy?** → Run: `bash scripts/diagnose-test-environment.sh`

**More help:** → See PROJECT_DOCUMENTATION.md Troubleshooting section



**Repository:** https://github.com/NitishK1/Edureka_DevOps_Arch_Training **Last
Updated:** December 12, 2025
