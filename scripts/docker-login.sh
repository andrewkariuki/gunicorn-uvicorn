#!/usr/bin/env bash

set -e

if [ "$(echo "$CONTAINER_REGISTRY_PASSWORD" | docker login ghcr.io -u "$CONTAINER_REGISTRY_USERNAME" --password-stdin 2>&1)" -eq 0 ]; then
    echo "Successfully logged in to container registry"
    exit 0
fi
