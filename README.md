# Docker boilerplate

Docker container boilerplate. 

## Structure

- bin: Scripts to build and run the container for Linux and Windows
- conf: Container configuration files
- image: Contains the entrypoint and initialization scripts. Use this directory to store application configuration files or files to be copied into the container at build time
- volumes: Bind mounts to store persistent data required by the container

### bin

Container initialization scripts are kept in this directory, run **build** and **dev** scripts to build the image and verify that the application is working as expected inside the container and once satisfied, you can execute the **run** script to create a persistent container based on the current image.

The scripts will use the **Dockerfile** from the **conf** directory and **.env** from the root, to build, name and tag the image; see the next section for more information.

- build: Builds the container image
- dev: Creates a **non-persistent** container, that will be deleted after exiting
- run: Create a **persistent** container, based on the image created with the **build** script
- push: Upload the local image to a remote repository

Edit the **dev** and **run** scripts to add extra configuration settings such as _volumes_, _ports_, etc. to the initialization of the containers.

### conf

This directory contains Docker configuration files, used by Docker to build the image and start the container. For files that should be _inside_ the container use the **image** directory.

### image

Use **image** directory to store application configuration files and other initialization scripts. By default this boilerplate will execute the **entrypoint.sh** script when starting the container, further information will be provided on this later.

If binary files are required to copied into the container then put them inside the **sources** directory as it is excluded from Git in the ``.gitignore`` file.
Alternatively use the Dockerfile to download and store the files directly in the container.

### volumes

Directories to be used as _bind mounts_ in containers. Create sub-directories for volumes as required.

## Configuration

### Dockerfile
This is the default configuration file to build the container image. Modify its contents to build the image as required.

**NOTE** the package **run-parts** is required to be installed, so that the included entrypoint script can work properly.

### .env
The file **.env** is used to set environment variables to be used by the scripts included in the **bin** directory.

- CONTAINER_NAME: Name to be given to the container
- CONTAINER_ROOT: Path to the volumes directory can be found (./ by default)
- DOCKER_IMAGE_NAME: Name of the image
- DOCKER_IMAGE_TAG: Image tag (version)
- DOCKER_REMOTE_REGISTRY: hostname and port(if required) of the registry server where the **push** script will push the image
- EP_SCRIPTS_DIR: Path to the directory where the start/stop scripts are on the container. This will also be the base directory for the run-parts start/stop _.d_ directories
- EP_RUNPARTS_DIR: If requried the __EP_SCRIPTS_DIR__ can be used to provide a path outise of the scripts directory

If required further variables can be created and used in the scripts.
For example add ``VOLUME_ROOT=/home/user/ContainerBoilerPlate/volumes`` to the **.env**, then modify **dev.sh** and include ``-v ${VOLUME_ROOT}/uploads:/var/www/html/uploads``.

### scripts

Modify the **build**, **dev** and **run** scripts to fine tune the image and containers to your requirements. Changing ports, volumes, etc.

### entrypoint

The container will look for scripts in **start.d** and **stop.d** and execute them in increasing numeric order depending if the container is starting or stopping. If the entrypoint script can't find run-parts installed on the container or the start and stop (.d direcories) in the specified path. Entrypoint will fall back to running _start.sh_ and _stop.sh_ or exit with error if no scripts are found.

If a script in **start.d** directory runs an application that is required to remain running, _NodeJS_ for example, then store its PID in a file so it then can be referenced by a script in **stop.d**.

On **start.d/10-node** add the following command to start nodejs and store its pid to _/tmp/node.pid_.
```bash
node server.js & echo $! > /tmp/node.pid
```

On **stop.d/10-node** add the following, to kill node with a SIGTERM(15) signal. 
```bash
PID_FILE=/tmp/node.pid && [ -f ${PID_FILE} ] && kill -15 `cat ${PID_FILE}`
```

When terminating processes, you need to ensure that the process can handle system signals, starting an internal clean-up, closing files, database connections, etc.
If the process can't handle signals then use SIGKILL(9) instead SIGTERM(15) in the _kill_ command, this will terminate the process immediately without waiting for it to clean-up any resources.

Docker will wait a maximum of 10 seconds before killing all processes in the container, with SIGKILL(9), so ensure that the scripts in **stop.d** run all within 10 seconds.

One last thing to keep in mind when writing _exit_ scripts is that some applications will spawn multiple processes which can detach from the parent, in these cases terminating the initial process is not enough and the other processes need to be terminated also. 

### docker-compose.yaml
A simple _docker-compose.yaml_ with some of the most used settings when creating a full configuration for docker compose.

## Run scripts

Build the image be sure to change the _IMAGE_VERSION_ in _.env_ if required
```bash
$ sudo bin/build.sh
```

Run a dev _non-persistent_ container from based on the image
```bash
$ sudo bin/dev.sh
```

Create a _persistent_ container from the current image
```bash
$ sudo bin/run.sh
```

**NOTE**: the terms non-persistent and persistent used above, just refer to the container itself, if data is mounted into volumes it will always be persistent, until the volume is removed.
