#!/bin/bash
# Backup Script - Run Before Session Expires
# Creates local backup of all work before Azure account expires

set -e

BACKUP_LOCATION=""

# Parse arguments
if [ -n "$1" ]; then
    BACKUP_LOCATION="$1"
fi

echo "====================================================="
echo -e "\033[0;36mPre-Expiry Backup Script\033[0m"
echo "====================================================="
echo ""

# Load credentials to get session info
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRED_FILE="$SCRIPT_DIR/../config/credentials.sh"

if [ -f "$CRED_FILE" ]; then
    source "$CRED_FILE"

    CURRENT=$(date +%s)
    REMAINING=$((SESSION_EXPIRY - CURRENT))
    HOURS=$((REMAINING / 3600))
    MINUTES=$(((REMAINING % 3600) / 60))

    echo -e "\033[1;33mSession expires in: ${HOURS}h ${MINUTES}m\033[0m"
    echo ""
fi

# Set backup location
if [ -z "$BACKUP_LOCATION" ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_LOCATION="$SCRIPT_DIR/../backup/backup-$TIMESTAMP"
fi

echo -e "\033[0;32m[INFO] Creating backup at: $BACKUP_LOCATION\033[0m"
mkdir -p "$BACKUP_LOCATION"

# 1. Backup Git repository
echo ""
echo "====================================================="
echo -e "\033[0;36m1. Backing up Git Repository\033[0m"
echo "====================================================="

REPO_PATH="$SCRIPT_DIR/../repo"
if [ -d "$REPO_PATH" ]; then
    echo -e "\033[0;32m[INFO] Cloning repository for backup...\033[0m"

    cd "$REPO_PATH"

    # Get remote URL
    REMOTE_URL=$(git config --get remote.origin.url)

    # Create full backup with all branches and history
    REPO_BACKUP="$BACKUP_LOCATION/repository"
    git clone --mirror "$REMOTE_URL" "$REPO_BACKUP" 2>&1 | grep -v "password" || true

    # Also create readable copy
    REPO_READABLE="$BACKUP_LOCATION/repository-readable"
    cp -r "$REPO_PATH" "$REPO_READABLE"

    # Export git log
    GIT_LOG_FILE="$BACKUP_LOCATION/git-history.txt"
    git log --all --graph --pretty=format:'%h - %an, %ar : %s' > "$GIT_LOG_FILE"

    # Export commit details
    GIT_DETAIL_FILE="$BACKUP_LOCATION/git-commits-detailed.txt"
    git log --all --stat > "$GIT_DETAIL_FILE"

    cd - > /dev/null

    echo -e "\033[0;32m[SUCCESS] Repository backed up\033[0m"
else
    echo -e "\033[1;33m[WARNING] Repository not found at: $REPO_PATH\033[0m"
fi

# 2. Backup configuration files
echo ""
echo "====================================================="
echo -e "\033[0;36m2. Backing up Configuration\033[0m"
echo "====================================================="

CONFIG_PATH="$SCRIPT_DIR/../config"
if [ -d "$CONFIG_PATH" ]; then
    CONFIG_BACKUP="$BACKUP_LOCATION/config"
    cp -r "$CONFIG_PATH" "$CONFIG_BACKUP"
    echo -e "\033[0;32m[SUCCESS] Configuration backed up\033[0m"
else
    echo -e "\033[1;33m[WARNING] Config directory not found\033[0m"
fi

# 3. Backup work items
echo ""
echo "====================================================="
echo -e "\033[0;36m3. Backing up Work Items\033[0m"
echo "====================================================="

WORK_ITEMS_PATH="$SCRIPT_DIR/../work-items"
if [ -d "$WORK_ITEMS_PATH" ]; then
    WORK_ITEMS_BACKUP="$BACKUP_LOCATION/work-items"
    cp -r "$WORK_ITEMS_PATH" "$WORK_ITEMS_BACKUP"
    echo -e "\033[0;32m[SUCCESS] Work items backed up\033[0m"
fi

# 4. Backup screenshots
echo ""
echo "====================================================="
echo -e "\033[0;36m4. Backing up Screenshots\033[0m"
echo "====================================================="

SCREENSHOTS_PATH="$SCRIPT_DIR/../screenshots"
if [ -d "$SCREENSHOTS_PATH" ]; then
    SCREENSHOT_COUNT=$(find "$SCREENSHOTS_PATH" -type f | wc -l)
    if [ $SCREENSHOT_COUNT -gt 0 ]; then
        SCREENSHOTS_BACKUP="$BACKUP_LOCATION/screenshots"
        cp -r "$SCREENSHOTS_PATH" "$SCREENSHOTS_BACKUP"
        echo -e "\033[0;32m[SUCCESS] $SCREENSHOT_COUNT screenshot(s) backed up\033[0m"
    else
        echo -e "\033[1;33m[WARNING] No screenshots found\033[0m"
    fi
fi

# 5. Backup documentation
echo ""
echo "====================================================="
echo -e "\033[0;36m5. Backing up Documentation\033[0m"
echo "====================================================="

DOCS_PATH="$SCRIPT_DIR/../docs"
if [ -d "$DOCS_PATH" ]; then
    DOCS_BACKUP="$BACKUP_LOCATION/docs"
    cp -r "$DOCS_PATH" "$DOCS_BACKUP"
fi

# Copy README
README_PATH="$SCRIPT_DIR/../README.md"
if [ -f "$README_PATH" ]; then
    cp "$README_PATH" "$BACKUP_LOCATION/"
fi

echo -e "\033[0;32m[SUCCESS] Documentation backed up\033[0m"

# 6. Create backup summary
echo ""
echo "====================================================="
echo -e "\033[0;36m6. Creating Backup Summary\033[0m"
echo "====================================================="

SUMMARY_FILE="$BACKUP_LOCATION/BACKUP-SUMMARY.txt"

cat > "$SUMMARY_FILE" << EOF
Azure DevOps Assignment 18 - Backup Summary
============================================

Backup Created: $(date)
Backup Location: $BACKUP_LOCATION

Session Information:
-------------------
$([ -n "$SESSION_START" ] && echo "Session Started: $(date -d @$SESSION_START 2>/dev/null || date -r $SESSION_START)" || echo "Session info not available")
$([ -n "$SESSION_EXPIRY" ] && echo "Session Expires: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)" || echo "")
$([ -n "$AZURE_EMAIL" ] && echo "Azure Account: $AZURE_EMAIL" || echo "")
$([ -n "$AZURE_DEVOPS_ORG_URL" ] && echo "Organization: $AZURE_DEVOPS_ORG_URL" || echo "")
$([ -n "$PROJECT_NAME" ] && echo "Project: $PROJECT_NAME" || echo "")

Backed Up Items:
---------------
✓ Git Repository (full history and branches)
✓ Git commit log and detailed history
✓ Configuration files
✓ Work items definitions
✓ Screenshots
✓ Documentation

Repository Information:
----------------------
$([ -n "$REMOTE_URL" ] && echo "Repository URL: $REMOTE_URL" || echo "Repository URL not available")

To restore or view this backup:
-------------------------------
1. Repository is in: repository-readable/
2. Git history is in: git-history.txt
3. Configuration is in: config/
4. Screenshots are in: screenshots/
5. Work items are in: work-items/

Next Steps After Getting New Credentials:
------------------------------------------
1. Run: ./scripts/setup-credentials.sh --force
2. Re-authenticate to Azure DevOps
3. Continue working from this backup if needed

IMPORTANT:
----------
This backup contains your LOCAL copy of the work.
The Azure DevOps online version is the source of truth.
Use this backup for reference or recovery only.

Generated by: backup-before-expiry.sh
============================================
EOF

echo -e "\033[0;32m[SUCCESS] Backup summary created\033[0m"

# 7. Display backup information
echo ""
echo "====================================================="
echo -e "\033[0;32mBackup Complete!\033[0m"
echo "====================================================="
echo ""
echo -e "\033[1;33mBackup Location:\033[0m"
echo -e "  \033[0;36m$BACKUP_LOCATION\033[0m"
echo ""
echo -e "\033[1;33mBackup Contents:\033[0m"

BACKUP_SIZE=$(du -sh "$BACKUP_LOCATION" 2>/dev/null | cut -f1)
echo "  Total Size: $BACKUP_SIZE"

for item in "$BACKUP_LOCATION"/*; do
    if [ -d "$item" ]; then
        echo -e "  \033[0;32m✓ $(basename "$item")\033[0m"
    fi
done

echo ""
echo -e "\033[1;33mQuick Actions:\033[0m"
echo "  • View backup: cd '$BACKUP_LOCATION' && ls -la"
echo "  • Read summary: cat '$SUMMARY_FILE'"
echo ""

if [ -n "$REMAINING" ] && [ $REMAINING -lt 1800 ]; then
    echo "====================================================="
    echo -e "\033[0;31mURGENT: Less than 30 minutes remaining!\033[0m"
    echo "====================================================="
    echo ""
    echo -e "\033[1;33mFinal checklist before expiry:\033[0m"
    echo "  □ All commits pushed to Azure DevOps"
    echo "  □ Work items status updated"
    echo "  □ All screenshots taken"
    echo "  □ Work items exported from Azure DevOps"
    echo -e "  \033[0;32m✓ This backup completed\033[0m"
    echo ""
fi

echo "====================================================="
echo -e "\033[0;32mYour work is safely backed up!\033[0m"
echo "====================================================="
