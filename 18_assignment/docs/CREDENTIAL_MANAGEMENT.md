# Credential Management Guide for Rotating Azure Accounts

## Overview
This assignment now includes **secure credential management** for Azure accounts
that rotate every 6 hours.

## 🔐 New Security Features

### 1. Credential Setup Script
**Securely stores your Azure credentials for the session**

```bash
./scripts/setup-credentials.sh
```

This will prompt you for:
- Azure account email
- Azure account password
- Azure DevOps organization name

Your credentials are stored in `config/credentials.ps1` (automatically excluded
from Git).

### 2. Session Tracking
The scripts now track:
- ✅ Session start time
- ✅ Session expiry time (6 hours)
- ✅ Remaining time
- ✅ Automatic expiry warnings

### 3. Secure Azure DevOps Setup
**Uses your stored credentials automatically**

```bash
./scripts/setup-azure-devops-secure.sh
```

This script:
- Loads your credentials securely
- Validates session hasn't expired
- Logs into Azure automatically
- Sets up Azure DevOps project
- Saves Personal Access Token (PAT)

### 4. Quick Git Repository Setup
**Clones and configures repository with your credentials**

```bash
./scripts/quick-setup-secure.sh
```

This script:
- Uses your saved credentials
- Clones repository automatically
- Configures Git user settings
- Pushes initial commit

## 📋 Complete Workflow (Updated)

### First Time Setup

**Step 1: Set up credentials (5 minutes)**
```bash
cd /c/Users/hardi/HARDIK/Learn/Edureka_DevOps_Arch_Training/18_assignment
./scripts/setup-credentials.sh
```

**Step 2: Set up Azure DevOps (20 minutes)**
```bash
./scripts/setup-azure-devops-secure.sh
```

**Step 3: Set up Git repository (15 minutes)**
```bash
./scripts/quick-setup-secure.sh
```

**Step 4: Continue with assignment** Follow the rest of
[QUICKSTART.md](QUICKSTART.md) from Step 4 onwards.

### When You Get New Credentials (Every 6 Hours)

**Step 1: Update credentials**
```bash
./scripts/setup-credentials.sh --force
```

**Step 2: Continue working** All your work is preserved. Just re-authenticate
when needed:
```bash
az login
```

## 🔍 Monitoring Your Session

### Check Session Status
```bash
./scripts/check-session.sh
```

This shows:
- Current session status (ACTIVE/EXPIRED)
- Time remaining
- Progress bar
- Warnings when time is running low

### Manual Check
```bash
# Load credentials and check
source ./config/credentials.sh
show_session_info
```

## 💾 Backup Before Expiry

### Automatic Backup
**Run this when you have less than 30 minutes remaining:**

```bash
./scripts/backup-before-expiry.sh
```

This backs up:
- ✅ Full Git repository with history
- ✅ All commits and branches
- ✅ Configuration files
- ✅ Work items
- ✅ Screenshots
- ✅ Documentation

### Manual Backup
```bash
# Backup to specific location
./scripts/backup-before-expiry.sh /c/MyBackups/assignment18
```

## 🔒 Security Best Practices

### What's Protected
✅ Credentials file is **excluded from Git** (.gitignore) ✅ Personal Access Token
stored securely ✅ Passwords stored in environment variables ✅ Session expiry
tracking ✅ Automatic warnings before expiry

### What You Should Do
- ✅ Never share `config/credentials.sh`
- ✅ Delete credentials file after assignment completion
- ✅ Set calendar reminders for expiry time
- ✅ Backup work regularly
- ✅ Update credentials immediately when they change

### What NOT to Do
- ❌ Don't commit `credentials.sh` to Git
- ❌ Don't share your Personal Access Token
- ❌ Don't ignore expiry warnings
- ❌ Don't store credentials in other files

## 📁 File Structure (Updated)

```
18_assignment/
├── config/
│   ├── credentials.template.sh     # Template (safe to commit)
│   └── credentials.sh               # YOUR credentials (NEVER commit)
├── scripts/
│   ├── setup-credentials.sh         # NEW: Set up credentials
│   ├── setup-azure-devops-secure.sh # NEW: Secure Azure setup
│   ├── quick-setup-secure.sh        # NEW: Secure Git setup
│   ├── check-session.sh             # NEW: Check session status
│   ├── backup-before-expiry.sh      # NEW: Pre-expiry backup
│   ├── setup-azure-devops.sh        # Original (manual auth)
│   └── demo-git-operations.sh       # Git operations demo
└── .gitignore                       # Updated with security rules
```

## 🚨 Session Expiry Workflow

### 4 Hours Remaining
✅ Status: Good
- Continue working normally
- No action needed

### 2 Hours Remaining
⚠️ Status: Monitor
- Check progress regularly
- Start planning completion
- Take screenshots as you go

### 1 Hour Remaining
⚠️ Status: Warning
- Complete critical work
- Start taking final screenshots
- Begin backup preparations

### 30 Minutes Remaining
🚨 Status: Critical
- **RUN BACKUP IMMEDIATELY**
  ```powershell
  .\scripts\backup-before-expiry.ps1
  ```
- Push all commits
- Update work items
- Export everything

### Expired
❌ Status: Expired
1. Get new credentials from instructor
2. Run: `.\scripts\setup-credentials.ps1 -Force`
3. Re-authenticate: `az login`
4. Continue from your backup

## 🎯 Quick Command Reference

### Setup Commands
```bash
# First time setup
./scripts/setup-credentials.sh
./scripts/setup-azure-devops-secure.sh
./scripts/quick-setup-secure.sh

# Update credentials (after rotation)
./scripts/setup-credentials.sh --force
```

### Monitoring Commands
```bash
# Check session status
./scripts/check-session.sh

# Quick status check
source ./config/credentials.sh
show_session_info
```

### Backup Commands
```bash
# Full backup
./scripts/backup-before-expiry.sh

# Backup to specific location
./scripts/backup-before-expiry.sh /path/to/backup
```

### Azure CLI Commands
```bash
# Login
az login

# Check current account
az account show

# Configure DevOps defaults
az devops configure --defaults organization=YOUR_ORG project=HooliMathHelper
```

## 💡 Pro Tips

1. **Set Multiple Reminders**
   - 4 hours: "Halfway point"
   - 2 hours: "Start wrapping up"
   - 1 hour: "Final push"
   - 30 min: "Backup now!"

2. **Work Incrementally**
   - Commit frequently
   - Push after each major change
   - Take screenshots continuously
   - Don't wait until the end

3. **Use Session Check**
   ```bash
   # Add to your bash profile for automatic checks
   alias check-azure="./scripts/check-session.sh"
   ```

4. **Automated Reminders**
   ```bash
   # Run this in background to get alerts
   while true; do
       ./scripts/check-session.sh
       sleep 1800  # Check every 30 minutes
   done
   ```

## 📞 Troubleshooting

### "Credentials file not found"
```bash
./scripts/setup-credentials.sh
```

### "Session expired"
```bash
./scripts/setup-credentials.sh --force
az login
```

### "Cannot authenticate to Azure DevOps"
1. Check your PAT is valid
2. Recreate PAT in Azure DevOps
3. Update credentials file manually or re-run setup

### "Git push fails"
```bash
# Re-authenticate
az login

# Or use PAT directly
git remote set-url origin https://EMAIL:PAT@dev.azure.com/...
```

## 📚 Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure DevOps PAT Guide](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [Git Credential Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)



**Remember**: Your credentials change every 6 hours. The scripts help you manage
this automatically! 🔐

## 🔧 Making Scripts Executable

On Linux/Mac or Git Bash on Windows, you may need to make the scripts
executable:

```bash
chmod +x scripts/*.sh
```
