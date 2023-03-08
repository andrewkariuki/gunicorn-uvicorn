#!/usr/bin/env bash

set -e

LOGIN_ERRORS=$(echo "$DOCKER_PASSWORD" | docker login ghcr.io -u "$DOCKER_USERNAME" --password-stdin 2>&1)
if [ $? -eq 0 ]; then
    echo "$LOGIN_ERRORS"
    echo "Successfully logged in to container registry"
    exit 0
else
    echo "Failed to login container registry"
    echo "$LOGIN_ERRORS"
    exit 1
fi
