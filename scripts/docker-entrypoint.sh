#!/bin/sh
set -e

if [[ -n "$GID" ]]; then
    groupmod -o -g $GID mole
fi

if [[ -n "$UID" ]]; then
    usermod -o -u $UID mole
fi

# Re-set permission to the `openmole` user if current user is root
# This avoids permission denied if the data volume is mounted by root
if [ "$1" = 'mole' -a "$(id -u)" = '0' ]; then
    chown -R mole /home/openmole/
    exec su-exec mole "$@"
fi

exec "$@"
