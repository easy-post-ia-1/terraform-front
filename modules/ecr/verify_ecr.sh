#!/bin/bash

# Run AWS CLI command to describe the repository
result=$(aws ecr describe-repositories --repository-names "$1" --region "$2" 2>&1)

# Check if the AWS CLI command was successful
if [ $? -eq 0 ]; then
  # Extract repository URL using grep and sed
  repository_url=$(echo "$result" | grep -o '"repositoryUri":[^,]*' | sed 's/.*"repositoryUri":"\([^"]*\)".*/\1/')

  # Check if the repository URL is not empty
  if [ -n "$repository_url" ]; then
    # Output success JSON
    echo "{\"success\":\"true\", \"repository_url\":\"$repository_url\", \"name\":\"$1\"}"
  else
    # Output error JSON if repository URL is empty
    echo "{\"success\":\"false\", \"error_message\":\"Repository URL not found.\", \"name\":\"$1\"}"
  fi
else
  # Escape double quotes for JSON format
  error_message=$(echo "$result" | sed 's/"/\\"/g')

  # Output error JSON
  echo "{\"success\":\"false\", \"error_message\":\"$error_message\", \"name\":\"$1\"}"
fi
