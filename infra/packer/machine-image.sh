#!/bin/bash

# Purpose: This script creates a GCP machine image from an existing storage image.
# It does this by creating a temporary VM, then creating a machine image from that VM.

# Configuration Variables
PROJECT_ID="dev-project-451923"                         # The GCP project ID
ZONE="us-east1-b"                                       # The GCP zone where resources will be created
MACHINE_TYPE="e2-medium"                                # The VM type for the temporary instance
STORAGE_IMAGE_NAME="custom-nodejs-mysql-1740455384"     # The source image to use
TEMP_INSTANCE_NAME="custom-nodejs-temp-vm"              # Name for temporary VM
MACHINE_IMAGE_NAME="custom-nodejs-mysql-machine-image"  # Name for the output machine image
STORAGE_LOCATION="us"                                   # The storage location for the machine image

# Step 1: Create a temporary VM instance from the source storage image
echo "Step 1: Creating a temporary VM from the storage image..."
gcloud compute instances create $TEMP_INSTANCE_NAME \
  --image=$STORAGE_IMAGE_NAME \
  --image-project=$PROJECT_ID \
  --machine-type=$MACHINE_TYPE \
  --zone=$ZONE \
  --tags=allow-ssh

# Wait for the VM to fully initialize before proceeding
echo "Waiting for VM to initialize..."
sleep 30 # 30-second delay to ensure VM is ready

# Step 2: Create a machine image from the temporary VM
# Machine images capture the full VM state including disk and configuration
echo "Step 2: Creating a Machine Image from the VM..."
gcloud compute machine-images create $MACHINE_IMAGE_NAME \
  --source-instance=$TEMP_INSTANCE_NAME \
  --source-instance-zone=$ZONE \
  --project=$PROJECT_ID \
  --storage-location=$STORAGE_LOCATION

# Step 3: Verify the machine image was created successfully
echo "Step 3: Verifying the Machine Image..."
gcloud compute machine-images list --filter="name=$MACHINE_IMAGE_NAME"

# Step 4: Clean up by deleting the temporary VM to avoid unnecessary costs
echo "Step 4: Deleting the temporary VM..."
gcloud compute instances delete $TEMP_INSTANCE_NAME --zone=$ZONE --quiet

# Completion message
echo "Done! Your new Machine Image is ready: $MACHINE_IMAGE_NAME"
