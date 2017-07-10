#!/bin/bash
set -e
set -o pipefail
exec docker-compose run --rm -e APP_UID="$(id -u)" -e APP_GID="$(id -g)" playground
