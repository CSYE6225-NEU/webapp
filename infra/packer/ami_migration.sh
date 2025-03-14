#!/bin/bash

# Purpose: This script copies the latest custom NodeJS/MySQL AMI from a development AWS account to a demo AWS account.
# It handles the entire process including authentication, finding the latest AMI, sharing permissions, and copying.

# Configuration
# ============================================================
# Get AWS credentials from environment variables
SOURCE_AWS_ACCESS_KEY="${DEV_AWS_ACCESS_KEY_ID}"
SOURCE_AWS_SECRET_KEY="${DEV_AWS_SECRET_ACCESS_KEY}"
TARGET_AWS_ACCESS_KEY="${DEMO_AWS_ACCESS_KEY_ID}"
TARGET_AWS_SECRET_KEY="${DEMO_AWS_SECRET_ACCESS_KEY}"

# AWS region and AMI naming - matches aws_build_region
AWS_REGION="us-east-1"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
NEW_AMI_NAME="Copied-custom-nodejs-mysql-${TIMESTAMP}"
AMI_NAME_PATTERN="custom-nodejs-mysql-*"

# Helper Functions
# ============================================================
configure_aws_profiles() {
  # Set up AWS CLI profiles for both source and target accounts
  aws configure set aws_access_key_id "$SOURCE_AWS_ACCESS_KEY" --profile source-account
  aws configure set aws_secret_access_key "$SOURCE_AWS_SECRET_KEY" --profile source-account
  aws configure set region "$AWS_REGION" --profile source-account
  
  aws configure set aws_access_key_id "$TARGET_AWS_ACCESS_KEY" --profile target-account
  aws configure set aws_secret_access_key "$TARGET_AWS_SECRET_KEY" --profile target-account
  aws configure set region "$AWS_REGION" --profile target-account
  
  echo "AWS CLI Profiles Configured"
}

get_account_ids() {
  # Retrieve the source account's AWS account ID
  echo "Getting source account ID..."
  SOURCE_ACCOUNT_ID=$(aws sts get-caller-identity \
    --profile source-account \
    --query 'Account' \
    --output text)
  echo "Source Account ID: $SOURCE_ACCOUNT_ID"

  # Retrieve the target account's AWS account ID
  echo "Getting target account ID..."
  TARGET_ACCOUNT_ID=$(aws sts get-caller-identity \
    --profile target-account \
    --query 'Account' \
    --output text)
  echo "Target Account ID: $TARGET_ACCOUNT_ID"  # This is the target_account_id
}

find_latest_ami() {
  # Find the most recently created AMI that matches our naming pattern
  echo "Getting latest AMI ID..."
  SOURCE_AMI_ID=$(aws ec2 describe-images \
    --profile source-account \
    --owners "$SOURCE_ACCOUNT_ID" \
    --filters "Name=name,Values=$AMI_NAME_PATTERN" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text)
  echo "Found latest AMI: $SOURCE_AMI_ID"
}

share_ami_with_target() {
  # Modify the AMI permissions to allow the target account to use it
  echo "Sharing AMI ($SOURCE_AMI_ID) with target account ($TARGET_ACCOUNT_ID)..."
  aws ec2 modify-image-attribute \
    --profile source-account \
    --image-id "$SOURCE_AMI_ID" \
    --launch-permission "Add=[{UserId=$TARGET_ACCOUNT_ID}]" \
    --region "$AWS_REGION"
}

share_snapshot_with_target() {
  # Get the associated EBS snapshot ID for the AMI
  echo "Fetching Snapshot ID..."
  SNAPSHOT_ID=$(aws ec2 describe-images \
    --profile source-account \
    --image-ids "$SOURCE_AMI_ID" \
    --region "$AWS_REGION" \
    --query 'Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' \
    --output text)
  echo "Found Snapshot ID: $SNAPSHOT_ID"

  # Share the snapshot with the target account
  echo "Sharing Snapshot ($SNAPSHOT_ID) with target account ($TARGET_ACCOUNT_ID)..."
  aws ec2 modify-snapshot-attribute \
    --profile source-account \
    --snapshot-id "$SNAPSHOT_ID" \
    --attribute createVolumePermission \
    --operation-type add \
    --user-ids "$TARGET_ACCOUNT_ID" \
    --region "$AWS_REGION"
}

copy_ami_to_target() {
  # Initiate the AMI copy operation from the target account
  echo "Copying AMI to target account..."
  TARGET_AMI_ID=$(aws ec2 copy-image \
    --profile target-account \
    --source-image-id "$SOURCE_AMI_ID" \
    --source-region "$AWS_REGION" \
    --region "$AWS_REGION" \
    --name "$NEW_AMI_NAME" \
    --query 'ImageId' --output text)
  echo "AMI Copy Started: $TARGET_AMI_ID"

  # Wait for the AMI copying process to complete
  echo "Waiting for AMI ($TARGET_AMI_ID) to be available..."
  aws ec2 wait image-available --profile target-account --image-ids "$TARGET_AMI_ID" --region "$AWS_REGION"
  echo "AMI ($TARGET_AMI_ID) is now available in target account!"
}

# Main Execution
# ============================================================
main() {
  configure_aws_profiles
  get_account_ids
  find_latest_ami
  share_ami_with_target
  share_snapshot_with_target
  copy_ami_to_target
  
  echo "Migration Complete!"
}

# Execute main function
main