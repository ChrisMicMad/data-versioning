#!/bin/bash

set -e

export BASE_DIR=$(pwd)
export SECRETS_DIR=$(pwd)/../secrets/
export GCS_BUCKET_NAME="cheese-app-data-versioning-chris"
export GCP_PROJECT="genial-caster-471216-p7"
export GCP_ZONE="us-central1-a"
export GOOGLE_APPLICATION_CREDENTIALS="/secrets/data-service-account.json"


echo "Building image"
docker build -t data-version-cli -f Dockerfile .

echo "Verifying no secrets in image..."
if docker run --rm --entrypoint ls data-version-cli /app/secrets 2>/dev/null; then
    echo "❌ ERROR: Secrets folder found in image!"
    exit 1
else
    echo "✅ No secrets in image"
fi


echo "Running container"
docker run --rm --name data-version-cli -ti \
--cap-add SYS_ADMIN \
-v "$BASE_DIR":/app \
-v "$SECRETS_DIR":/secrets \
-e GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
-e GCS_BUCKET_NAME=$GCS_BUCKET_NAME data-version-cli

# this works