#!/usr/bin/env sh

[ $(id -u) -ne 0 ] && echo This script must run as root && exit 1

# Load .env as variables
[ ! -f .env ] && echo Environment file .env not found. && exit 2
for f in `cat .env | grep -vE "^#"`; do export ${f}; done

# Tag the 'current' image with the 'latest' tag on the local registry
docker tag \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
  ${DOCKER_IMAGE_NAME}:latest
[ $? -ne 0 ] && echo Unable to create latest && exit 10

# Tag the current image to the remote registry
docker tag \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
  ${DOCKER_REMOTE_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
[ $? -ne 0 ] && echo Unable to create remote tag && exit 11

# Push the 'current' image to the remote registry
docker push \
  ${DOCKER_REMOTE_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
[ $? -ne 0 ] && echo Unable to push image to remote regsitry && exit 12

# Links the 'current' tag to the 'latest' tag in the remote registry
docker tag \
  ${DOCKER_REMOTE_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
  ${DOCKER_REMOTE_REGISTRY}/${DOCKER_IMAGE_NAME}:latest

# Update the latest tag on the remote registry
docker push ${DOCKER_REMOTE_REGISTRY}/${DOCKER_IMAGE_NAME}:latest
