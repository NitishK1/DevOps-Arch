#!/bin/bash
# Demo Git Operations for Assignment
# This script demonstrates all required Git operations

set -e

echo "=================================================="
echo "Git Operations Demo - Assignment 18"
echo "=================================================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_section() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_command() {
    echo -e "${YELLOW}Running:${NC} $1"
}

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "Error: Not in a git repository. Please run from the repository root."
    exit 1
fi

# 1. View Repository Status
print_section "1. View Repository Status"
print_command "git status"
git status

# 2. View Commit History
print_section "2. View Commit History"
print_command "git log --oneline --graph --all --decorate"
git log --oneline --graph --all --decorate -10

# 3. View Detailed History for Specific File
print_section "3. View File History (app/math_helper.py)"
print_command "git log --oneline app/math_helper.py"
git log --oneline app/math_helper.py

# 4. Compare Changes Between Commits
print_section "4. Compare Historical Changes"
print_info "Comparing last 2 commits..."
print_command "git diff HEAD~1 HEAD"
git diff HEAD~1 HEAD --stat

print_info "Detailed diff for math_helper.py:"
git diff HEAD~1 HEAD app/math_helper.py || echo "No changes in this file"

# 5. View Specific Commit Details
print_section "5. View Latest Commit Details"
print_command "git show HEAD"
git show HEAD --stat

# 6. View All Branches
print_section "6. View Branches"
print_command "git branch -a"
git branch -a

# 7. View Remote Information
print_section "7. View Remote Repository"
print_command "git remote -v"
git remote -v

# 8. View Tags
print_section "8. View Tags (if any)"
print_command "git tag"
git tag || echo "No tags created yet"

# 9. View Contributors
print_section "9. View Contributors"
print_command "git shortlog -sn"
git shortlog -sn

# 10. View File Changes Summary
print_section "10. Files Changed Summary"
print_command "git diff --stat HEAD~2 HEAD"
git diff --stat HEAD~2 HEAD || echo "Not enough commits"

# 11. Create and Demonstrate Feature Branch
print_section "11. Create Feature Branch Demo"
read -p "Create a new feature branch? (y/n): " create_branch

if [ "$create_branch" = "y" ]; then
    print_command "git checkout -b feature/demo-branch"
    git checkout -b feature/demo-branch

    print_info "Creating a demo file..."
    echo "# Demo Feature" > demo-feature.txt
    echo "This is a demonstration of branching" >> demo-feature.txt

    print_command "git add demo-feature.txt"
    git add demo-feature.txt

    print_command "git commit -m 'feat: Add demo feature file'"
    git commit -m "feat: Add demo feature file"

    print_info "Feature branch created and committed"

    print_command "git log --oneline --graph --all"
    git log --oneline --graph --all -5

    print_info "Switching back to main branch..."
    git checkout main || git checkout master
fi

# 12. Summary
print_section "Assignment Demonstration Complete"
echo "All Git operations demonstrated:"
echo "  ✓ View status and history"
echo "  ✓ Compare historical changes"
echo "  ✓ View commit details"
echo "  ✓ Branch management"
echo "  ✓ Remote repository information"
echo ""
echo "Repository is ready for submission!"
echo "=================================================="
