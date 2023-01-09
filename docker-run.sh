#!/bin/bash

docker run \
#   If we want to pull the git internally for build, we don't need to bind an external source
#    --mount type=bind,source=$HOME/dev/lichess,target=/home/lichess/projects \
    # Lila port
    --publish 9663:9663 \
    # Lila websocket
    --publish 9664:9664 \
    # Don't know what this port does, disable for now
#    --publish 8212:8212 \
    --name lichess \
    --interactive \
    --tty \
    lichess
