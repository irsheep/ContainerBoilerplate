#!/bin/sh

# Application shutdown, this is called after the container receives a 'stop'
# command and sends a SIGTERM(15) to the entrypoint.sh script (PID 1).
StopContainer() {

  # Run the application shutdown scripts
  # NOTE: the total runtime of the scripts should not take more than 10 seconds, as Docker will kill a container if it fails so stop within 10 seconds.
  STOP_SCRIPTS=/opt/entrypoint/stop.d
  if [ -d "$STOP_SCRIPTS" ]; then
    /bin/run-parts "$STOP_SCRIPTS"
  fi

  exit 0
}

# Define handlers for system traps:
# - TERM or SIGTEM (signal 15) for a clean exit
trap StopContainer 15

# Remove pid files if found
find /tmp -type f -name "*.pid" -maxdepth 1 -exec rm {} +

# Run application startup scripts
START_SCRIPTS=/opt/entrypoint/start.d
if [ -d "$START_SCRIPTS" ]; then
  /bin/run-parts "$START_SCRIPTS"
fi

# If the container is invoked with a command (CMD), then execute the command
# otherwise loop until the container is terminated
if [ "$#" -gt 0 ]; then
  # Replace the 'entrypoint.sh' process (PID 1) with the arguments passed in CMD.
  # This will cause the container to terminate once the new process terminates.
  exec "$@"
else
  # Prevents 'entrypoint.sh' script from terminating, so it can receive the SIGTERM(15) trap and run the 'StopContainer' function
  tail -f /dev/null & wait ${!}
fi
