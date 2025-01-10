#!/bin/bash

### script to deploy the latest in the ec2 instance ###

set -e

# Set environment variables
export ECR_REGISTRY=${ECR_REGISTRY}
export ECR_REPOSITORY=${ECR_REPOSITORY}
export IMAGE_TAG=${IMAGE_TAG}


# Log into ECR
echo "Logging into ECR..."
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# Navigate to the directory containing the docker-compose.yaml file
cd /home/ubuntu/entrytrcker-cicd/

# Restart services with the new image
echo "Restarting services with the new image..."
docker compose down
# sleep few seconds to allow the containers to stop
sleep 10

docker compose up -d

#sleep few secondes to let the app up 10
sleep 10

echo "Deployment completed successfully."
