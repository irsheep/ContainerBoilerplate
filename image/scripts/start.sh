#!/usr/bin/env sh

echo Startup script

# Simulate a running service/application
tail -f /dev/null & echo $! > /tmp/process.pid
