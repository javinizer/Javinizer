#!/bin/sh
umask 000

# Start powershell
set -e
echo "Starting pwsh"
exec "$@";

pwsh
