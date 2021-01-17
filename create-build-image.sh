#!/bin/sh

set -e
set -u

docker build --pull -t marlin-build .
