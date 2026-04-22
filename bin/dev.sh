#!/usr/bin/env sh

[ $(id -u) -ne 0 ] && echo This script must run as root && exit 1

# Load .env as variables
[ ! -f .env ] && echo Environment file .env not found. && exit 2
for f in `cat .env | grep -vE "^#"`; do export ${f}; done

docker run \
  -d \
  --rm \
  -v ./volumes/dir:/some/path \
  -p 8080:80 \
  --name ${CONTAINER_NAME}-dev \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

docker exec -it ${CONTAINER_NAME}-dev /bin/sh
