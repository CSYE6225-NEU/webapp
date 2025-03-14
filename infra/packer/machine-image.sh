#!/bin/bash
# GCP Machine Image Creation Utility
#
# This script automates the creation of a GCP machine image from a source disk image.
# It creates a temporary VM instance, captures its state as a machine image, and
# cleans up resources to prevent unnecessary billing charges.

# Environment Configuration
PROJECT_ID="dev-project-451923"      # Target GCP project identifier
ZONE="us-east1-b"                    # Compute zone for resource deployment
MACHINE_TYPE="e2-medium"             # VM instance type for temporary deployment
STORAGE_IMAGE_NAME="custom-nodejs-mysql-1740455384"  # Source disk image name
TEMP_INSTANCE_NAME="custom-nodejs-temp-vm"           # Temporary VM identifier
MACHINE_IMAGE_NAME="custom-nodejs-mysql-machine-image"  # Target machine image name
STORAGE_LOCATION="us"                # Geographic location for image storage

# Phase 1: Temporary VM Provisioning
echo "Initiating temporary VM deployment..."
gcloud compute instances create $TEMP_INSTANCE_NAME \
--image=$STORAGE_IMAGE_NAME \
--image-project=$PROJECT_ID \
--machine-type=$MACHINE_TYPE \
--zone=$ZONE \
--tags=allow-ssh

# Allow VM to complete boot sequence and initialize services
echo "Waiting for VM initialization (30s)..."
sleep 30 # Ensure all services have started before capture

# Phase 2: Machine Image Capture
echo "Capturing machine state as deployable image..."
gcloud compute machine-images create $MACHINE_IMAGE_NAME \
--source-instance=$TEMP_INSTANCE_NAME \
--source-instance-zone=$ZONE \
--project=$PROJECT_ID \
--storage-location=$STORAGE_LOCATION

# Phase 3: Verification
echo "Verifying image creation and availability..."
gcloud compute machine-images list --filter="name=$MACHINE_IMAGE_NAME"

# Phase 4: Resource Cleanup
echo "Performing resource cleanup operations..."
gcloud compute instances delete $TEMP_INSTANCE_NAME --zone=$ZONE --quiet

# Operation Complete
echo "Operation completed successfully."
echo "Machine image '$MACHINE_IMAGE_NAME' is now available for deployment."
echo "Location: $STORAGE_LOCATION"
echo "Project: $PROJECT_ID"