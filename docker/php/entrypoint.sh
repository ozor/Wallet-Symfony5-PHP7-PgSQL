#!/bin/sh
set -e

if ! ping -q -c1 "host.docker.internal." > /dev/null 2>&1 && ! cat /etc/hosts | grep host.docker.internal > /dev/null 2>&1
then
  HOST_IP=$(ip route | awk 'NR==1 {print $3}')
  # shellcheck disable=SC2039
  echo -e "$HOST_IP\t host.docker.internal" >> /etc/hosts
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- php-fpm "$@"
fi

exec "$@"
