#!/bin/bash

# Purpose: This script copies a GCP compute image from a DEV project to a DEMO project,
# and creates machine images in both projects for deployment.

# Default zone value - can be overridden with command line parameter
DEFAULT_ZONE="us-east1-b"
ZONE=${1:-$DEFAULT_ZONE}  # Use provided zone or default if not specified

# Paths to GCP Service Account JSON Keys using GitHub Actions secrets
DEV_GCP_KEY="gcp-dev-credentials.json"
DEMO_GCP_KEY="gcp-demo-credentials.json"

echo "Extracting project IDs from credentials..."
# Extract project IDs from credential files using jq
DEV_PROJECT_ID=$(cat $DEV_GCP_KEY | jq -r '.project_id')
DEMO_PROJECT_ID=$(cat $DEMO_GCP_KEY | jq -r '.project_id')

# Extract service account emails for IAM permissions
DEV_SERVICE_ACCOUNT=$(cat $DEV_GCP_KEY | jq -r '.client_email')
DEMO_SERVICE_ACCOUNT=$(cat $DEMO_GCP_KEY | jq -r '.client_email')

echo "DEV Project ID: $DEV_PROJECT_ID"
echo "DEMO Project ID: $DEMO_PROJECT_ID"
echo "DEV Service Account: $DEV_SERVICE_ACCOUNT"
echo "DEMO Service Account: $DEMO_SERVICE_ACCOUNT"
echo "Using Zone: $ZONE"

echo "Finding the latest compute image in DEV project..."
# Authenticate with DEV project to perform operations
gcloud auth activate-service-account --key-file=$DEV_GCP_KEY
gcloud config set project $DEV_PROJECT_ID

# Find the most recent compute image with our naming pattern
# Sort by creation timestamp in descending order and limit to 1 result
COMPUTE_IMAGE_NAME=$(gcloud compute images list --project=$DEV_PROJECT_ID \
  --filter="name~'custom-nodejs-mysql'" \
  --sort-by=~creationTimestamp --limit=1 \
  --format="value(name)")

# Exit if no matching image is found
if [ -z "$COMPUTE_IMAGE_NAME" ]; then
  echo "No compute image found with prefix 'custom-nodejs-mysql'. Exiting..."
  exit 1
fi

echo "Found latest compute image: $COMPUTE_IMAGE_NAME"

# Define compute instance and image configuration
MACHINE_TYPE="e2-medium"  # VM size for temporary instances

# Generate unique names with timestamp to avoid conflicts
TIMESTAMP=$(date +%s)
TEMP_INSTANCE_DEV="temp-vm-dev-${TIMESTAMP}"
TEMP_INSTANCE_DEMO="temp-vm-demo-${TIMESTAMP}"
MACHINE_IMAGE_NAME_DEV="mi-${COMPUTE_IMAGE_NAME}"
MACHINE_IMAGE_NAME_DEMO="mi-demo-${COMPUTE_IMAGE_NAME}"
COPIED_COMPUTE_IMAGE_NAME="copy-${COMPUTE_IMAGE_NAME}"
STORAGE_LOCATION="us"  # Storage region for machine images

echo "Authenticating with GCP DEV Project ($DEV_PROJECT_ID)..."
gcloud auth activate-service-account --key-file=$DEV_GCP_KEY
gcloud config set project $DEV_PROJECT_ID

# Step 1: Create a temporary VM in DEV project from the source compute image
echo "Creating a temporary VM ($TEMP_INSTANCE_DEV) from Compute Image ($COMPUTE_IMAGE_NAME)..."
gcloud compute instances create $TEMP_INSTANCE_DEV \
  --image=$COMPUTE_IMAGE_NAME \
  --image-project=$DEV_PROJECT_ID \
  --machine-type=$MACHINE_TYPE \
  --zone=$ZONE \
  --tags=allow-ssh

# Wait for VM to fully initialize before proceeding
echo "Waiting for VM to initialize..."
sleep 15 # Adjust wait time if needed

# Step 2: Create a machine image from the temporary VM in DEV project
echo "Creating Machine Image ($MACHINE_IMAGE_NAME_DEV) from VM ($TEMP_INSTANCE_DEV)..."
gcloud compute machine-images create $MACHINE_IMAGE_NAME_DEV \
  --source-instance=$TEMP_INSTANCE_DEV \
  --source-instance-zone=$ZONE \
  --project=$DEV_PROJECT_ID \
  --storage-location=$STORAGE_LOCATION

# Verify the machine image was created successfully
echo "Verifying Machine Image in DEV ($MACHINE_IMAGE_NAME_DEV)..."
gcloud compute machine-images list --project=$DEV_PROJECT_ID --filter="name=$MACHINE_IMAGE_NAME_DEV"

# Clean up the temporary VM to avoid unnecessary costs
echo "Deleting temporary VM ($TEMP_INSTANCE_DEV)..."
gcloud compute instances delete $TEMP_INSTANCE_DEV --zone=$ZONE --quiet

# Step 3: Grant the DEMO project service account access to the source compute image
echo "Granting DEMO Project ($DEMO_PROJECT_ID) access to Compute Image ($COMPUTE_IMAGE_NAME)..."
gcloud compute images add-iam-policy-binding $COMPUTE_IMAGE_NAME \
  --project=$DEV_PROJECT_ID \
  --member="serviceAccount:$DEMO_SERVICE_ACCOUNT" \
  --role="roles/compute.imageUser"

# Switch to DEMO project for the remaining operations
echo "Authenticating with GCP DEMO Project ($DEMO_PROJECT_ID)..."
gcloud auth activate-service-account --key-file=$DEMO_GCP_KEY
gcloud config set project $DEMO_PROJECT_ID

# Step 4: Copy the compute image from DEV to DEMO project
echo "Copying Compute Image ($COMPUTE_IMAGE_NAME) to DEMO Project ($DEMO_PROJECT_ID)..."
gcloud compute images create "$COPIED_COMPUTE_IMAGE_NAME" \
  --source-image="$COMPUTE_IMAGE_NAME" \
  --source-image-project="$DEV_PROJECT_ID" \
  --project="$DEMO_PROJECT_ID"

# Verify the image was copied successfully
echo "Verifying Compute Image in DEMO ($COPIED_COMPUTE_IMAGE_NAME)..."
gcloud compute images list --project=$DEMO_PROJECT_ID --filter="name=$COPIED_COMPUTE_IMAGE_NAME"

# Step 5: Wait until the copied compute image is fully available
# Retry logic to handle potential delays in image availability
WAIT_TIME=10
MAX_RETRIES=10
retry=0
while ! gcloud compute images describe $COPIED_COMPUTE_IMAGE_NAME --project=$DEMO_PROJECT_ID &>/dev/null; do
  if [[ $retry -ge $MAX_RETRIES ]]; then
    echo "Compute Image copy failed to appear in DEMO project. Exiting..."
    exit 1
  fi
  echo "Waiting for Compute Image to be available in DEMO ($WAIT_TIME seconds)..."
  sleep $WAIT_TIME
  ((retry++))
done

# Step 6: Create a temporary VM in DEMO project from the copied compute image
echo "Creating a temporary VM ($TEMP_INSTANCE_DEMO) from Copied Compute Image ($COPIED_COMPUTE_IMAGE_NAME)..."
gcloud compute instances create $TEMP_INSTANCE_DEMO \
  --image=$COPIED_COMPUTE_IMAGE_NAME \
  --image-project=$DEMO_PROJECT_ID \
  --machine-type=$MACHINE_TYPE \
  --zone=$ZONE \
  --tags=allow-ssh

# Wait for VM to fully initialize before proceeding
echo "Waiting for VM to initialize..."
sleep 15 # Adjust wait time if needed

# Step 7: Create a machine image from the temporary VM in DEMO project
echo "Creating Machine Image ($MACHINE_IMAGE_NAME_DEMO) from VM ($TEMP_INSTANCE_DEMO)..."
gcloud compute machine-images create $MACHINE_IMAGE_NAME_DEMO \
  --source-instance=$TEMP_INSTANCE_DEMO \
  --source-instance-zone=$ZONE \
  --project=$DEMO_PROJECT_ID \
  --storage-location=$STORAGE_LOCATION

# Verify the machine image was created successfully in DEMO project
echo "Verifying Machine Image in DEMO ($MACHINE_IMAGE_NAME_DEMO)..."
gcloud compute machine-images list --project=$DEMO_PROJECT_ID --filter="name=$MACHINE_IMAGE_NAME_DEMO"

# Clean up the temporary VM to avoid unnecessary costs
echo "Deleting temporary VM ($TEMP_INSTANCE_DEMO)..."
gcloud compute instances delete $TEMP_INSTANCE_DEMO --zone=$ZONE --quiet

echo "Machine Image successfully created in both DEV and DEMO projects!"