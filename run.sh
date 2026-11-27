#!/bin/bash
# Omini add-on for Home Assistant: runs the upstream binary on :8080
# with host networking so ARP/ping/mDNS/SSDP reach the LAN.

DATA_DIR=/data/omini
mkdir -p "${DATA_DIR}"

export OMINI_DATA_DIR="${DATA_DIR}"
export OMINI_ADDR=":8080"
export OMINI_AUTOSCAN=true
export UV_PYTHON_DOWNLOADS=never
export UV_CACHE_DIR="${DATA_DIR}/.cache/uv"
export TZ="$(bashio::supervisor.timezone 2>/dev/null || echo UTC)"

if [ "$(bashio::config 'omini_nmap')" = "install" ] && ! command -v nmap >/dev/null 2>&1; then
    bashio::log.info "Installing nmap ..."
    apk add --no-cache nmap >/dev/null 2>&1 \
        || bashio::log.warning "Could not install nmap — the nmap integration will report it."
fi

bashio::log.info "Starting Omini on :8080 ..."
exec /usr/local/bin/omini
