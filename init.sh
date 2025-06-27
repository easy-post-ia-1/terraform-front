#!/bin/bash

WORKSPACE=$1

if [ -z "$WORKSPACE" ]; then
  echo "Usage: ./init.sh [workspace]"
  exit 1
fi

terraform init \
  -backend-config="bucket=easy-post-ia-frontend-${WORKSPACE}-bucket" \
  -backend-config="key=tf-infra/${WORKSPACE}.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=easy-post-ia-frontend-${WORKSPACE}-table" \
  -backend-config="encrypt=true"

