#!/bin/bash
# Build the Omini Home Assistant add-on from source into a loadable tar.
set -euo pipefail
cd "$(dirname "$0")/.."

# Stage only what the add-on build needs: the add-on metadata plus the full
# source tree (the Dockerfile builds Omini inside the add-on image).
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp -R ha-addon "$STAGE/omini"
rm -f "$STAGE/omini/Dockerfile"   # use the add-on Dockerfile we stage below
cp ha-addon/Dockerfile "$STAGE/omini/Dockerfile"
tar -czf omini-addon.tar.gz -C "$STAGE" omini
echo "Built $(pwd)/omini-addon.tar.gz"
