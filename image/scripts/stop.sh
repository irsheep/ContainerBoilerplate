#!/usr/bin/env sh

echo Stop script

PID_FILE=/tmp/process.pid && [ -f ${PID_FILE} ] && kill -15 `cat ${PID_FILE}`
