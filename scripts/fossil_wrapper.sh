#!/bin/bash
set -- $SSH_ORIGINAL_COMMAND
while [ $# -gt 1 ] ; do shift ; done
export REMOTE_USER="$USER"
ROOT=/app
exec fossil http "$ROOT/museum/$(basename "$1")"
