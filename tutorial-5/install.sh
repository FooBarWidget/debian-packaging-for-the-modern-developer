#!/bin/bash
set -ex
mkdir -p "$DESTDIR/usr/bin"
cp hello "$DESTDIR/usr/bin/hello"
