# Omini — Home Assistant OS add-on

Home Assistant add-on packaging for [riccardoalv/omini](https://github.com/riccardoalv/omini),
the self-hosted multi-vendor network topology and traffic map.

No official HAOS add-on exists upstream — this repository is that packaging.
Built from source inside the Supervisor's Docker builder (Go + Vue UI, targets aarch64).

## Install

In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**,
add `https://a.hackrsvalv.com/saint/omini-ha-addon.git`, refresh, then install **Omini**.

Requires **Full access** privileged ports (NET_RAW/NET_ADMIN) for ARP/ping/mDNS discovery.
