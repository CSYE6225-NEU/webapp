#!/bin/bash

# This script automates the process of copying NodeJS/MySQL AMIs between AWS accounts.
# It handles authentication, discovery of the latest AMI, permission management, and AMI copying.

# Extract credentials from environment variables
SOURCE_AWS_ACCESS_KEY="${DEV_AWS_ACCESS_KEY_ID}"
SOURCE_AWS_SECRET_KEY="${DEV_AWS_SECRET_ACCESS_KEY}"
TARGET_AWS_ACCESS_KEY="${DEMO_AWS_ACCESS_KEY_ID}"
TARGET_AWS_SECRET_KEY="${DEMO_AWS_SECRET_ACCESS_KEY}"

# Configuration settings
AWS_REGION="us-east-1"
# Generate a unique identifier for the new AMI
NEW_AMI_NAME="Copied-custom-nodejs-mysql-$(date +%Y%m%d-%H%M%S)"

# Configure AWS CLI with separate profiles for source and target accounts
aws configure set aws_access_key_id $SOURCE_AWS_ACCESS_KEY --profile source-account
aws configure set aws_secret_access_key $SOURCE_AWS_SECRET_KEY --profile source-account
aws configure set region $AWS_REGION --profile source-account
aws configure set aws_access_key_id $TARGET_AWS_ACCESS_KEY --profile target-account
aws configure set aws_secret_access_key $TARGET_AWS_SECRET_KEY --profile target-account
aws configure set region $AWS_REGION --profile target-account
echo "AWS authentication profiles created successfully"

# Identify source account ID for AMI filtering
echo "Retrieving source account identifier..."
SOURCE_ACCOUNT_ID=$(aws sts get-caller-identity \
  --profile source-account \
  --query 'Account' \
  --output text)
echo "Source Account: $SOURCE_ACCOUNT_ID"

# Locate the most recent matching AMI in the source account
echo "Searching for the latest NodeJS/MySQL AMI..."
SOURCE_AMI_ID=$(aws ec2 describe-images \
  --profile source-account \
  --owners $SOURCE_ACCOUNT_ID \
  --filters "Name=name,Values=custom-nodejs-mysql-*" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
echo "Located source AMI: $SOURCE_AMI_ID"

# Identify target account ID for permission configuration
echo "Retrieving target account identifier..."
TARGET_ACCOUNT_ID=$(aws sts get-caller-identity \
  --profile target-account \
  --query 'Account' \
  --output text)
echo "Target Account: $TARGET_ACCOUNT_ID"

# Grant the target account permission to access the source AMI
echo "Configuring AMI access permissions for target account..."
aws ec2 modify-image-attribute \
  --profile source-account \
  --image-id $SOURCE_AMI_ID \
  --launch-permission "Add=[{UserId=$TARGET_ACCOUNT_ID}]" \
  --region $AWS_REGION

# Identify the underlying storage snapshot that supports this AMI
echo "Identifying associated EBS snapshot..."
SNAPSHOT_ID=$(aws ec2 describe-images \
  --profile source-account \
  --image-ids $SOURCE_AMI_ID \
  --region $AWS_REGION \
  --query 'Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' \
  --output text)
echo "Located snapshot: $SNAPSHOT_ID"

# Grant the target account permission to access the source snapshot
echo "Configuring snapshot access permissions for target account..."
aws ec2 modify-snapshot-attribute \
  --profile source-account \
  --snapshot-id $SNAPSHOT_ID \
  --attribute createVolumePermission \
  --operation-type add \
  --user-ids $TARGET_ACCOUNT_ID \
  --region $AWS_REGION

# Start the AMI copy operation from the target account
echo "Initiating cross-account AMI copy procedure..."
TARGET_AMI_ID=$(aws ec2 copy-image \
  --profile target-account \
  --source-image-id $SOURCE_AMI_ID \
  --source-region $AWS_REGION \
  --region $AWS_REGION \
  --name "$NEW_AMI_NAME" \
  --query 'ImageId' --output text)
echo "AMI copy initiated - new AMI ID: $TARGET_AMI_ID"

# Wait for the new AMI to become fully available
echo "Waiting for new AMI to become available (this may take several minutes)..."
aws ec2 wait image-available --profile target-account --image-ids $TARGET_AMI_ID --region $AWS_REGION
echo "New AMI $TARGET_AMI_ID is now ready for use in target account"

echo "AMI migration completed successfully!"