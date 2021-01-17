#!/bin/sh

set -e
set -u

docker run --rm \
            -u root:root \
            -e BOARD=$BOARD \
            -e USE_TAG=$MARLIN_VER \
            -v $(pwd)/firmware:/home/platformio/build \
            -v $(pwd)/config:/home/platformio/CustomConfiguration \
            marlin-build
