#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIRECTORY=$(dirname "$0")

bash ${SCRIPT_DIRECTORY}/../src/windows/build.sh "$@"
