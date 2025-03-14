#!/bin/bash

# Purpose: This script copies the latest custom NodeJS/MySQL AMI from a development AWS account to a demo AWS account.
# It handles the entire process including authentication, finding the latest AMI, sharing permissions, and copying.

# Get AWS credentials from environment variables
SOURCE_AWS_ACCESS_KEY="${DEV_AWS_ACCESS_KEY_ID}"
SOURCE_AWS_SECRET_KEY="${DEV_AWS_SECRET_ACCESS_KEY}"
TARGET_AWS_ACCESS_KEY="${DEMO_AWS_ACCESS_KEY_ID}"
TARGET_AWS_SECRET_KEY="${DEMO_AWS_SECRET_ACCESS_KEY}"

# Input Region Details
AWS_REGION="us-east-1"
# Create a unique name for the new AMI with timestamp
NEW_AMI_NAME="Copied-custom-nodejs-mysql-$(date +%Y%m%d-%H%M%S)"

# Set up AWS CLI profiles for both source and target accounts
# This allows us to run commands against both accounts in the same script
aws configure set aws_access_key_id $SOURCE_AWS_ACCESS_KEY --profile source-account
aws configure set aws_secret_access_key $SOURCE_AWS_SECRET_KEY --profile source-account
aws configure set region $AWS_REGION --profile source-account
aws configure set aws_access_key_id $TARGET_AWS_ACCESS_KEY --profile target-account
aws configure set aws_secret_access_key $TARGET_AWS_SECRET_KEY --profile target-account
aws configure set region $AWS_REGION --profile target-account
echo "AWS CLI Profiles Configured"

# Retrieve the source account's AWS account ID
# This is needed for filtering AMIs owned by this account
echo "Getting source account ID..."
SOURCE_ACCOUNT_ID=$(aws sts get-caller-identity \
  --profile source-account \
  --query 'Account' \
  --output text)
echo "Source Account ID: $SOURCE_ACCOUNT_ID"

# Find the most recently created AMI that matches our naming pattern
# Sort by creation date and select the newest one
echo "Getting latest AMI ID..."
SOURCE_AMI_ID=$(aws ec2 describe-images \
  --profile source-account \
  --owners $SOURCE_ACCOUNT_ID \
  --filters "Name=name,Values=custom-nodejs-mysql-*" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
echo "Found latest AMI: $SOURCE_AMI_ID"

# Retrieve the target account's AWS account ID
# This is needed to share the AMI with this specific account
echo "Getting target account ID..."
TARGET_ACCOUNT_ID=$(aws sts get-caller-identity \
  --profile target-account \
  --query 'Account' \
  --output text)
echo "Target Account ID: $TARGET_ACCOUNT_ID"

# Modify the AMI permissions to allow the target account to use it
# This is required before the AMI can be copied to another account
echo "Sharing AMI ($SOURCE_AMI_ID) with target account ($TARGET_ACCOUNT_ID)..."
aws ec2 modify-image-attribute \
  --profile source-account \
  --image-id $SOURCE_AMI_ID \
  --launch-permission "Add=[{UserId=$TARGET_ACCOUNT_ID}]" \
  --region $AWS_REGION

# Get the associated EBS snapshot ID for the AMI
# AMIs are backed by snapshots, which also need to be shared
echo "Fetching Snapshot ID..."
SNAPSHOT_ID=$(aws ec2 describe-images \
  --profile source-account \
  --image-ids $SOURCE_AMI_ID \
  --region $AWS_REGION \
  --query 'Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' \
  --output text)
echo "Found Snapshot ID: $SNAPSHOT_ID"

# Share the snapshot with the target account
# Without this step, the AMI copy operation would fail
echo "Sharing Snapshot ($SNAPSHOT_ID) with target account ($TARGET_ACCOUNT_ID)..."
aws ec2 modify-snapshot-attribute \
  --profile source-account \
  --snapshot-id $SNAPSHOT_ID \
  --attribute createVolumePermission \
  --operation-type add \
  --user-ids $TARGET_ACCOUNT_ID \
  --region $AWS_REGION

# Initiate the AMI copy operation from the target account
# This creates a new AMI in the target account based on the shared AMI
echo "Copying AMI to target account..."
TARGET_AMI_ID=$(aws ec2 copy-image \
  --profile target-account \
  --source-image-id $SOURCE_AMI_ID \
  --source-region $AWS_REGION \
  --region $AWS_REGION \
  --name "$NEW_AMI_NAME" \
  --query 'ImageId' --output text)
echo "AMI Copy Started: $TARGET_AMI_ID"

# Wait for the AMI copying process to complete
# The AMI needs to be in 'available' state before it can be used
echo "Waiting for AMI ($TARGET_AMI_ID) to be available..."
aws ec2 wait image-available --profile target-account --image-ids $TARGET_AMI_ID --region $AWS_REGION
echo "AMI ($TARGET_AMI_ID) is now available in target account!"

echo "Migration Complete!"
