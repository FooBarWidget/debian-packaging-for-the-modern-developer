#!/bin/bash
set -e
exec docker build --force-rm -t phusion/dpmd-playground:latest docker-env
