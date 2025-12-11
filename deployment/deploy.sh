#!/bin/bash
# deploy.sh - Container refresh script for CD pipeline in Project 5
# 
# Description: This script stops the old container, pulls the latest image,
# and starts a new container with the updated image.
#
# Usage: ./deploy.sh
# Requirements: Requires Docker to be installed and running
#               Requires Docker Hub Authentication (docker login)

# Defaults
DOCKERHUB_USER="jericoco520"
IMAGE_NAME="p4-coffee-website"
CONTAINER_NAME="p4-coffee-website"
HOST_PORT="80"
CONTAINER_PORT="80"

# Full image reference
IMAGE="${DOCKERHUB_USER}/${IMAGE_NAME}:latest"

# ============================================================

echo "=========================================="
echo "Container Refresh Script"
echo "Image: ${IMAGE}"
echo "=========================================="

# Stop the running container if it exists
echo ""
echo "[1/4] Stopping container '${CONTAINER_NAME}'..."
if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then # Check if container is running 
    docker stop "${CONTAINER_NAME}" > /dev/null
    echo "${CONTAINER_NAME} stopped"
else
    echo "${CONTAINER_NAME} not running, skipping stop"
fi

# Remove the container if it exists
echo ""
echo "[2/4] Removing container '${CONTAINER_NAME}'..."
if docker ps -aq -f name="${CONTAINER_NAME}" | grep -q .; then
    docker rm "${CONTAINER_NAME}" > /dev/null
    echo "${CONTAINER_NAME} removed"
else
    echo "Container does not exist, skipping remove"
fi

# Pull the latest image
echo ""
echo "[3/4] Pulling latest image '${IMAGE}'..."
if docker pull "${IMAGE}" > /dev/null; then
    echo "${IMAGE} pulled successfully"
else
    echo "Failed to pull image"
    exit 1
fi

# Run a new container
echo ""
echo "[4/4] Starting new container '${CONTAINER_NAME}'..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    "${IMAGE}" > /dev/null

if [ $? -eq 0 ]; then
    echo "Container started successfully"
else
    echo "Failed to start container"
    exit 1
fi

# Summary
echo ""
echo "=========================================="
echo "  Deployment Successful"
echo "=========================================="
echo "Container: ${CONTAINER_NAME}"
echo "Image:     ${IMAGE}"
echo "Port:      ${HOST_PORT} -> ${CONTAINER_PORT}"
echo ""


