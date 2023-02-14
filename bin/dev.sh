#!/bin/sh

# Create the default settings.env if it does not exist
if [ ! -f conf/settings.env ]; then
  echo settings.env not found, using defaults.
  cp conf/settings.default.env conf/settings.env
fi

# Load container setup variables
for f in `cat conf/settings.env`; do export $f; done

# Define the image source
export IMAGE_SOURCE=${IMAGE_NAME}
[ ${PRIVATE_REGISTRY} ] && export IMAGE_SOURCE=${PRIVATE_REGISTRY}/${IMAGE_NAME}

docker run \
-d \
--rm \
-v ./volumes:/some/path \
-p 8080:80 \
--name ${CONTAINER_NAME}-dev \
${IMAGE_SOURCE}:${IMAGE_TAG}

docker exec -it ${CONTAINER_NAME}-dev /bin/sh
