#!/bin/bash

# Configuration
# ====================================================
# Default zone value - can be overridden with command line parameter
DEFAULT_ZONE="us-east1-b"  # Matches gcp_build_zone
ZONE=${1:-$DEFAULT_ZONE}

# Paths to GCP Service Account JSON Keys using GitHub Actions secrets
DEV_GCP_KEY="gcp-dev-credentials.json"
DEMO_GCP_KEY="gcp-demo-credentials.json"

# Compute Instance and Image Details
MACHINE_TYPE="e2-medium"  # Matches gcp_vm_type
STORAGE_LOCATION="us"     # Matches gcp_storage_region
TIMESTAMP=$(date +%s)
IMAGE_PREFIX="custom-nodejs-mysql"

# Helper Functions
# ====================================================
log_info() {
  echo "===== $1 ====="
}

extract_project_info() {
  log_info "Extracting project information"
  
  # Extract project IDs from credential files
  DEV_PROJECT_ID=$(jq -r '.project_id' "$DEV_GCP_KEY")    # Maps to gcp_dev_project
  DEMO_PROJECT_ID=$(jq -r '.project_id' "$DEMO_GCP_KEY")  # Maps to gcp_target_project

  # Extract service account emails
  DEV_SERVICE_ACCOUNT=$(jq -r '.client_email' "$DEV_GCP_KEY")
  DEMO_SERVICE_ACCOUNT=$(jq -r '.client_email' "$DEMO_GCP_KEY")

  echo "DEV Project ID: $DEV_PROJECT_ID"
  echo "DEMO Project ID: $DEMO_PROJECT_ID"
  echo "DEV Service Account: $DEV_SERVICE_ACCOUNT"
  echo "DEMO Service Account: $DEMO_SERVICE_ACCOUNT"
  echo "Using Zone: $ZONE"
}

authenticate_dev_project() {
  log_info "Authenticating with DEV project ($DEV_PROJECT_ID)"
  gcloud auth activate-service-account --key-file="$DEV_GCP_KEY"
  gcloud config set project "$DEV_PROJECT_ID"
}

authenticate_demo_project() {
  log_info "Authenticating with DEMO project ($DEMO_PROJECT_ID)"
  gcloud auth activate-service-account --key-file="$DEMO_GCP_KEY"
  gcloud config set project "$DEMO_PROJECT_ID"
}

find_latest_image() {
  log_info "Finding latest compute image"
  
  # Get the latest compute image name with our prefix
  COMPUTE_IMAGE_NAME=$(gcloud compute images list --project="$DEV_PROJECT_ID" \
    --filter="name~'$IMAGE_PREFIX'" \
    --sort-by=~creationTimestamp --limit=1 \
    --format="value(name)")

  if [ -z "$COMPUTE_IMAGE_NAME" ]; then
    echo "No compute image found with prefix '$IMAGE_PREFIX'. Exiting..."
    exit 1
  fi

  echo "Found latest compute image: $COMPUTE_IMAGE_NAME"
}

setup_instance_names() {
  # Set up instance and image names with timestamps
  TEMP_INSTANCE_DEV="temp-vm-dev-${TIMESTAMP}"
  TEMP_INSTANCE_DEMO="temp-vm-demo-${TIMESTAMP}"
  MACHINE_IMAGE_NAME_DEV="mi-${COMPUTE_IMAGE_NAME}"
  MACHINE_IMAGE_NAME_DEMO="mi-demo-${COMPUTE_IMAGE_NAME}"
  COPIED_COMPUTE_IMAGE_NAME="copy-${COMPUTE_IMAGE_NAME}"
}

create_dev_resources() {
  log_info "Creating resources in DEV project"
  
  echo "Creating temporary VM ($TEMP_INSTANCE_DEV)..."
  gcloud compute instances create "$TEMP_INSTANCE_DEV" \
    --image="$COMPUTE_IMAGE_NAME" \
    --image-project="$DEV_PROJECT_ID" \
    --machine-type="$MACHINE_TYPE" \
    --zone="$ZONE" \
    --tags=allow-ssh

  echo "Waiting for VM to initialize..."
  sleep 15

  echo "Creating Machine Image ($MACHINE_IMAGE_NAME_DEV)..."
  gcloud compute machine-images create "$MACHINE_IMAGE_NAME_DEV" \
    --source-instance="$TEMP_INSTANCE_DEV" \
    --source-instance-zone="$ZONE" \
    --project="$DEV_PROJECT_ID" \
    --storage-location="$STORAGE_LOCATION"

  echo "Verifying Machine Image in DEV..."
  gcloud compute machine-images list --project="$DEV_PROJECT_ID" --filter="name=$MACHINE_IMAGE_NAME_DEV"

  echo "Deleting temporary VM..."
  gcloud compute instances delete "$TEMP_INSTANCE_DEV" --zone="$ZONE" --quiet
}

share_image_with_demo() {
  log_info "Sharing image with DEMO project"
  
  echo "Granting DEMO Project access to Compute Image..."
  gcloud compute images add-iam-policy-binding "$COMPUTE_IMAGE_NAME" \
    --project="$DEV_PROJECT_ID" \
    --member="serviceAccount:$DEMO_SERVICE_ACCOUNT" \
    --role="roles/compute.imageUser"
}

copy_image_to_demo() {
  log_info "Copying image to DEMO project"
  
  echo "Creating copy of Compute Image in DEMO Project..."
  gcloud compute images create "$COPIED_COMPUTE_IMAGE_NAME" \
    --source-image="$COMPUTE_IMAGE_NAME" \
    --source-image-project="$DEV_PROJECT_ID" \
    --project="$DEMO_PROJECT_ID"

  echo "Verifying Compute Image in DEMO..."
  gcloud compute images list --project="$DEMO_PROJECT_ID" --filter="name=$COPIED_COMPUTE_IMAGE_NAME"

  # Wait until Compute Image is available
  WAIT_TIME=10
  MAX_RETRIES=10
  retry=0
  while ! gcloud compute images describe "$COPIED_COMPUTE_IMAGE_NAME" --project="$DEMO_PROJECT_ID" &>/dev/null; do
    if [[ $retry -ge $MAX_RETRIES ]]; then
      echo "Compute Image copy failed to appear in DEMO project. Exiting..."
      exit 1
    fi
    echo "Waiting for Compute Image to be available in DEMO ($WAIT_TIME seconds)..."
    sleep $WAIT_TIME
    ((retry++))
  done
}

create_demo_resources() {
  log_info "Creating resources in DEMO project"
  
  echo "Creating temporary VM ($TEMP_INSTANCE_DEMO)..."
  gcloud compute instances create "$TEMP_INSTANCE_DEMO" \
    --image="$COPIED_COMPUTE_IMAGE_NAME" \
    --image-project="$DEMO_PROJECT_ID" \
    --machine-type="$MACHINE_TYPE" \
    --zone="$ZONE" \
    --tags=allow-ssh

  echo "Waiting for VM to initialize..."
  sleep 15

  echo "Creating Machine Image ($MACHINE_IMAGE_NAME_DEMO)..."
  gcloud compute machine-images create "$MACHINE_IMAGE_NAME_DEMO" \
    --source-instance="$TEMP_INSTANCE_DEMO" \
    --source-instance-zone="$ZONE" \
    --project="$DEMO_PROJECT_ID" \
    --storage-location="$STORAGE_LOCATION"

  echo "Verifying Machine Image in DEMO..."
  gcloud compute machine-images list --project="$DEMO_PROJECT_ID" --filter="name=$MACHINE_IMAGE_NAME_DEMO"

  echo "Deleting temporary VM..."
  gcloud compute instances delete "$TEMP_INSTANCE_DEMO" --zone="$ZONE" --quiet
}

# Main Execution
# ====================================================
main() {
  extract_project_info
  authenticate_dev_project
  find_latest_image
  setup_instance_names
  create_dev_resources
  share_image_with_demo
  authenticate_demo_project
  copy_image_to_demo
  create_demo_resources
  
  log_info "Migration Complete"
  echo "Machine Image successfully created in both DEV and DEMO projects!"
}

# Execute main function
main