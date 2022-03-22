@echo off

:: Load container setup variables
for /F "usebackq" %%i in (conf\settings.env) do set %%i

:: Define the image source
set IMAGE_SOURCE=%IMAGE_NAME%
if DEFINED DOCKER_REGISTRY (
    set IMAGE_SOURCE=%DOCKER_REGISTRY%/%IMAGE_NAME%
)

:: Tag and push the image
docker image tag %IMAGE_SOURCE%:%IMAGE_TAG% %DOCKER_REGISTRY_SERVER%:%DOCKER_REGISTRY_PORT%/%IMAGE_NAME%:%IMAGE_TAG%
docker push %DOCKER_REGISTRY_SERVER%:%DOCKER_REGISTRY_PORT%/%IMAGE_NAME%:%IMAGE_TAG%