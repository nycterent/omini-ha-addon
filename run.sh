#!/bin/bash
# Omini add-on for Home Assistant: runs the upstream binary on :8080
# with host networking so ARP/ping/mDNS/SSDP reach the LAN.
# Self-contained — no bashio dependency.

set -e

DATA_DIR=/data/omini
mkdir -p "${DATA_DIR}"

export OMINI_DATA_DIR="${DATA_DIR}"
export OMINI_ADDR=":8080"
export OMINI_AUTOSCAN=true
export UV_PYTHON_DOWNLOADS=never
export UV_CACHE_DIR="${DATA_DIR}/.cache/uv"
export TZ="${TZ:-UTC}"

# Supervisor exposes config options as SCREAMING_SNAKE_CASE env vars.
if [ "$(printf '%s' "${OMINI_NMAP:-off}" | tr '[:upper:]' '[:lower:]')" = "install" ] \
   && ! command -v nmap >/dev/null 2>&1; then
    echo "[omini] Installing nmap ..."
    apk add --no-cache nmap >/dev/null 2>&1 \
        || echo "[omini] WARNING: could not install nmap — the nmap integration will report it."
fi

echo "[omini] Starting Omini on :8080 ..."
exec /usr/local/bin/omini
