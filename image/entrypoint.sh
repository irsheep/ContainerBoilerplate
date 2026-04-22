#!/usr/bin/env sh

SCRIPTS_DIR=${EP_SCRIPTS_DIR:-/opt/scripts}
RUNPARTS_DIR=${EP_RUNPARTS_DIR:-${SCRIPTS_DIR}/run-parts}

echo Entrypoint started:
echo - SCRIPTS_DIR ${SCRIPTS_DIR}
echo - RUNPARTS_DIR ${RUNPARTS_DIR}
echo

# Checks if run-parts is installed and if the required scripts directory exists.
f_runparts_check() {
  RP_SCRIPTS_DIR=${1:-start}

  which run-parts > /dev/null
  [ $? -ne 0 ] && return 1
  [ ! -d ${RUNPARTS_DIR}/${RP_SCRIPTS_DIR} ] && return 2

  return 0
}

# Check what scripts to run based on system configuration. If run-parts is
# installed and its script directory can be found then run the scripts from the
# run-parts directory, otherwise it will run the single specified script.
f_run_scripts() {
  SCRIPT_NAME=${1:-start}

  f_runparts_check ${SCRIPT_NAME}

  if [ $? -eq 0 ]; then
    echo Running run-parts ${SCRIPT_NAME} scripts
    run-parts --list ${RUNPARTS_DIR}/${SCRIPT_NAME}.d
    run-parts ${RUNPARTS_DIR}/${SCRIPT_NAME}.d
  else
    [ ! -f ${SCRIPTS_DIR}/${SCRIPT_NAME}.sh ] \
      && echo "Could not find ${SCRIPTS_DIR}/${SCRIPT_NAME}.sh" \
      && exit 1
    echo Running script ${SCRIPTS_DIR}/${SCRIPT_NAME}.sh
    ${SCRIPTS_DIR}/${SCRIPT_NAME}.sh
  fi
}

f_exit() {
  echo Stopping container

  # Run the container stop scripts.
  f_run_scripts stop

  # Last thing to call, add cleanup above this.
  exit 0
}

# Define handlers for system traps:
# - TERM or SIGTERM for a clean exit
trap f_exit TERM

# Run the container start scripts.
f_run_scripts start

# If the container is invoked with a command (CMD), then execute the command
# otherwise loop until the container is terminated.
if [ "$#" -gt 0 ]; then
  # The container was started with a CMD.
  echo Running cmd "$@"
  exec "$@"
else
  # Prevents 'entrypoint.sh' script from terminating,
  # so it can receive the SIGTERM/TERM(15) trap and run the 'f_exit' function.
  tail -f /dev/null & wait ${!}
fi
