#!/bin/bash
set -e

# Check if zone parameter is provided
if [ -z "$1" ]; then
  echo "Error: Zone parameter is required"
  echo "Usage: $0 <zone>"
  exit 1
fi

ZONE="$1"
LATEST_IMAGE=$(gcloud compute images list --project=${GCP_PROJECT_ID} --filter="name:custom-nodejs-mysql" --format="value(name)" --sort-by=~creationTimestamp --limit=1)

echo "Latest image found: ${LATEST_IMAGE}"

if [ -z "${LATEST_IMAGE}" ]; then
  echo "Error: No source image found in project ${GCP_PROJECT_ID}"
  exit 1
fi

# Create a copy of the image in the DEMO project
echo "Creating copy of image in DEMO project..."
gcloud compute images create "copy-${LATEST_IMAGE}" \
  --project=${GCP_DEMO_PROJECT_ID} \
  --source-image=${LATEST_IMAGE} \
  --source-image-project=${GCP_PROJECT_ID}

# Create machine image in DEMO project
echo "Creating machine image in DEMO project..."
gcloud compute machine-images create "mi-demo-${LATEST_IMAGE}" \
  --project=${GCP_DEMO_PROJECT_ID} \
  --source-image="copy-${LATEST_IMAGE}" \
  --source-image-project=${GCP_DEMO_PROJECT_ID} \
  --storage-location=us-east1

echo "Successfully migrated image to DEMO project"