#!/bin/bash
# AWS Credentials Template
# Copy this file to credentials.sh and fill in your values
# NEVER commit credentials.sh to git!

export AWS_ACCESS_KEY_ID="your-access-key-here"
export AWS_SECRET_ACCESS_KEY="your-secret-key-here"
export AWS_DEFAULT_REGION="us-east-1"

# Optional: AWS Session Token (if using temporary credentials)
# export AWS_SESSION_TOKEN="your-session-token-here"

# Email for SNS notifications
export NOTIFICATION_EMAIL="your-email@example.com"

# Project configuration
export PROJECT_NAME="logicworks-devops"
export ENVIRONMENT="production"

# Regions for multi-region deployment
export PRIMARY_REGION="us-east-1"
export SECONDARY_REGION="us-east-2"
export PRIMARY_REGION="us-east-1"
export SECONDARY_REGION="us-west-2"
