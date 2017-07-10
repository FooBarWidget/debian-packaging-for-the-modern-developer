#!/bin/bash
set -e
set -o pipefail

if [[ "$APP_UID" = '' || "$APP_GID" = '' ]]; then
	echo "ERROR: please set the APP_UID and APP_GID environment variables by passing: -e APP_UID=\$(id -u) -e APP_GID=\$(id -g)" >&2
	exit 1
fi

mkdir /host
bindfs -u app -g app \
	--create-for-user="$APP_UID" --create-for-group="$APP_GID" \
	--chown-ignore --chgrp-ignore \
	/host.real /host
cd /host

if [[ $# -gt 0 ]]; then
	exec "$@"
fi
