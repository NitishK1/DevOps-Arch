#!/bin/bash
# Session Status Check
# Quick script to check remaining time and credential validity

CREDENTIALS_FILE=""

# Parse arguments
if [ -n "$1" ]; then
    CREDENTIALS_FILE="$1"
fi

# Load credentials
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$CREDENTIALS_FILE" ]; then
    CREDENTIALS_FILE="$SCRIPT_DIR/../config/credentials.sh"
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "====================================================="
    echo -e "\033[0;31mNo Credentials Found\033[0m"
    echo "====================================================="
    echo ""
    echo -e "\033[1;33mPlease set up your credentials first:\033[0m"
    echo "  ./scripts/setup-credentials.sh"
    echo ""
    exit 1
fi

source "$CREDENTIALS_FILE"

# Display detailed session info
CURRENT=$(date +%s)
REMAINING=$((SESSION_EXPIRY - CURRENT))
ELAPSED=$((CURRENT - SESSION_START))

echo ""
echo "====================================================="
echo -e "\033[0;36mAzure Session Status\033[0m"
echo "====================================================="
echo ""
echo -e "\033[1;33mAccount Details:\033[0m"
echo "  Email: $AZURE_EMAIL"
echo "  Organization: $AZURE_DEVOPS_ORG_NAME"
echo "  Org URL: $AZURE_DEVOPS_ORG_URL"
echo ""
echo -e "\033[1;33mSession Timing:\033[0m"
echo "  Started: $(date -d @$SESSION_START 2>/dev/null || date -r $SESSION_START)"
echo "  Expires: $(date -d @$SESSION_EXPIRY 2>/dev/null || date -r $SESSION_EXPIRY)"
echo "  Current: $(date)"
echo ""

if [ $REMAINING -lt 0 ]; then
    ABS_HOURS=$(( -REMAINING / 3600 ))
    ABS_MINUTES=$(( (-REMAINING % 3600) / 60 ))

    echo -e "\033[0;31mStatus: EXPIRED\033[0m"
    echo -e "  \033[0;31mSession expired ${ABS_HOURS}h ${ABS_MINUTES}m ago\033[0m"
    echo ""
    echo "====================================================="
    echo -e "\033[0;31mACTION REQUIRED\033[0m"
    echo "====================================================="
    echo ""
    echo -e "\033[1;33mYour Azure account has expired. You need NEW credentials.\033[0m"
    echo ""
    echo -e "\033[1;33mSteps:\033[0m"
    echo "  1. Get new Azure account credentials from your instructor"
    echo "  2. Run: ./scripts/setup-credentials.sh --force"
    echo "  3. Continue your work"
    echo ""
else
    HOURS=$((REMAINING / 3600))
    MINUTES=$(((REMAINING % 3600) / 60))
    ELAPSED_HOURS=$((ELAPSED / 3600))
    ELAPSED_MINUTES=$(((ELAPSED % 3600) / 60))
    PERCENT_USED=$((ELAPSED * 100 / 21600))

    echo -e "\033[0;32mStatus: ACTIVE\033[0m"
    echo "  Time Elapsed: ${ELAPSED_HOURS}h ${ELAPSED_MINUTES}m"

    if [ $REMAINING -lt 3600 ]; then
        echo -e "  Time Remaining: \033[0;31m${HOURS}h ${MINUTES}m\033[0m"
    elif [ $REMAINING -lt 7200 ]; then
        echo -e "  Time Remaining: \033[1;33m${HOURS}h ${MINUTES}m\033[0m"
    else
        echo -e "  Time Remaining: \033[0;32m${HOURS}h ${MINUTES}m\033[0m"
    fi

    echo "  Session Used: ${PERCENT_USED}%"
    echo ""

    # Progress bar
    BAR_LENGTH=50
    FILLED_LENGTH=$((BAR_LENGTH * PERCENT_USED / 100))
    EMPTY_LENGTH=$((BAR_LENGTH - FILLED_LENGTH))
    BAR=$(printf '=%.0s' $(seq 1 $FILLED_LENGTH))$(printf ' %.0s' $(seq 1 $EMPTY_LENGTH))

    if [ $PERCENT_USED -gt 83 ]; then
        echo -e "  Progress: [\033[0;31m$BAR\033[0m] ${PERCENT_USED}%"
    elif [ $PERCENT_USED -gt 66 ]; then
        echo -e "  Progress: [\033[1;33m$BAR\033[0m] ${PERCENT_USED}%"
    else
        echo -e "  Progress: [\033[0;32m$BAR\033[0m] ${PERCENT_USED}%"
    fi
    echo ""

    # Warnings
    if [ $REMAINING -lt 1800 ]; then
        echo "====================================================="
        echo -e "\033[0;31mURGENT: Less than 30 minutes remaining!\033[0m"
        echo "====================================================="
        echo ""
        echo -e "\033[0;31mIMMEDIATE ACTIONS:\033[0m"
        echo "  1. Save all your work NOW"
        echo "  2. Take final screenshots"
        echo "  3. Run backup script: ./scripts/backup-before-expiry.sh"
        echo "  4. Export work items to CSV"
        echo ""
    elif [ $REMAINING -lt 3600 ]; then
        echo "====================================================="
        echo -e "\033[0;31mWARNING: Less than 1 hour remaining!\033[0m"
        echo "====================================================="
        echo ""
        echo -e "\033[1;33mRecommended Actions:\033[0m"
        echo "  • Start backing up your work"
        echo "  • Take important screenshots now"
        echo "  • Complete any in-progress commits"
        echo "  • Export work items and documentation"
        echo ""
    elif [ $REMAINING -lt 7200 ]; then
        echo -e "\033[1;33mNote: Less than 2 hours remaining\033[0m"
        echo "Consider starting to wrap up and backup your work"
        echo ""
    fi

    # Recommendations
    echo "====================================================="
    echo -e "\033[0;36mRecommendations\033[0m"
    echo "====================================================="
    echo ""

    if [ $REMAINING -gt 14400 ]; then
        echo -e "\033[0;32m✓ Plenty of time remaining\033[0m"
        echo "  Continue working on your assignment"
    elif [ $REMAINING -gt 7200 ]; then
        echo -e "\033[1;33m⚠ Moderate time remaining\033[0m"
        echo "  Focus on completing core requirements"
    else
        echo -e "\033[0;31m⚠ Limited time remaining\033[0m"
        echo "  Prioritize completion and backup"
    fi
    echo ""
fi

echo "====================================================="

# Check if Azure CLI is still logged in
echo ""
echo -e "\033[1;33mChecking Azure CLI status...\033[0m"
ACCOUNT=$(az account show --query "user.name" -o tsv 2>/dev/null || echo "")
if [ -n "$ACCOUNT" ]; then
    echo -e "\033[0;32m✓ Azure CLI: Logged in as $ACCOUNT\033[0m"
else
    echo -e "\033[0;31m✗ Azure CLI: Not logged in\033[0m"
    echo "  Run: az login"
fi

echo ""
echo "====================================================="
