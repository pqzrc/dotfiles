#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=/etc/systemd/logind.conf.d/60-rice-power.conf
if [[ -e $target && ! -e $target.before-rice ]]; then
    cp -a "$target" "$target.before-rice"
fi
install -D -m 644 "$repo/system/60-rice-power.conf" "$target"
# Reloading preserves the running graphical session.
systemctl reload systemd-logind.service
echo 'Power-button policy installed and reloaded: short press suspends.'
