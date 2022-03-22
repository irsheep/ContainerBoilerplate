#!/bin/bash

# Load container setup variables
for f in `cat conf/settings.env | grep =`; do export $f; done

# Define the image source
export IMAGE_SOURCE=${IMAGE_NAME}
[ ${DOCKER_REGISTRY} ] && export IMAGE_SOURCE=${DOCKER_REGISTRY}/${IMAGE_NAME}

# Tag and push the image
docker image tag ${IMAGE_SOURCE}:${IMAGE_TAG} ${DOCKER_REGISTRY_SERVER}:${DOCKER_REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_REGISTRY_SERVER}:${DOCKER_REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG}