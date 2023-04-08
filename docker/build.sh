#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DOCKER_OPTIONS=""
DOCKER_OPTIONS+="-f $SCRIPT_DIR/nerf-slam.Dockerfile "
DOCKER_OPTIONS+="--build-arg USER_NAME=$(whoami)"

DOCKER_CMD="docker build $DOCKER_OPTIONS $SCRIPT_DIR"
echo $DOCKER_CMD
exec $DOCKER_CMD