#!/bin/bash

# Test Script for AppleBite Application
# Runs tests against deployed application

set -e

echo "======================================"
echo "AppleBite Application Testing"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Parse arguments
TEST_ENV=${1:-"test"}
TEST_PORT=""

case $TEST_ENV in
    test)
        TEST_PORT=8080
        ;;
    stage)
        TEST_PORT=8081
        ;;
    prod|production)
        TEST_PORT=8082
        ;;
    *)
        echo -e "${RED}Error: Invalid environment${NC}"
        echo "Usage: $0 [test|stage|prod]"
        exit 1
        ;;
esac

echo -e "${YELLOW}Testing $TEST_ENV environment on port $TEST_PORT${NC}"
echo ""

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name=$1
    local test_command=$2

    ((TESTS_RUN++))

    echo -n "Test $TESTS_RUN: $test_name ... "

    if eval $test_command >/dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Health Check Test
run_test "Application Health Check" \
    "curl -f -s http://localhost:$TEST_PORT"

# Response Code Test
run_test "HTTP Response Code 200" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:$TEST_PORT | grep -q 200"

# Content Test
run_test "Application Content Check" \
    "curl -s http://localhost:$TEST_PORT | grep -qi 'html'"

# Container Status Test
run_test "Docker Container Running" \
    "docker ps | grep -q applebite-$TEST_ENV-web"

# Database Container Test (if exists)
if docker ps | grep -q applebite-$TEST_ENV-db; then
    run_test "Database Container Running" \
        "docker ps | grep -q applebite-$TEST_ENV-db"
fi

# Performance Test - Response Time
run_test "Response Time < 2 seconds" \
    "test \$(curl -s -o /dev/null -w '%{time_total}' http://localhost:$TEST_PORT | cut -d'.' -f1) -lt 2"

# Port Accessibility Test
run_test "Port $TEST_PORT Accessible" \
    "nc -z localhost $TEST_PORT"

echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo ""
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
