#!/usr/bin/env bash
set -euo pipefail

mode=${1:---normal}
case "$mode" in
    --normal) controller_mode=dual ;;
    --pairing) controller_mode=bredr ;;
    *)
        echo 'Usage: sudo bash install/airpods-system.sh [--normal|--pairing]' >&2
        exit 2
        ;;
esac

if [[ $EUID -ne 0 ]]; then
    echo 'Run this script with sudo.' >&2
    exit 1
fi

config=/etc/bluetooth/main.conf
if [[ ! -f $config ]]; then
    echo "Missing $config. Install bluez first." >&2
    exit 1
fi

cp --archive --no-clobber "$config" "$config.pre-airpods"

python3 - "$config" "$controller_mode" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
controller_mode = sys.argv[2]
lines = path.read_text().splitlines()

try:
    start = next(i for i, line in enumerate(lines) if line.strip() == "[General]")
except StopIteration as error:
    raise SystemExit("[General] is missing from /etc/bluetooth/main.conf") from error

end = next(
    (i for i in range(start + 1, len(lines)) if re.match(r"^\s*\[.+\]\s*$", lines[i])),
    len(lines),
)

def set_option(name: str, value: str) -> None:
    pattern = re.compile(rf"^\s*#?\s*{re.escape(name)}\s*=.*$")
    for index in range(start + 1, end):
        if pattern.match(lines[index]):
            lines[index] = f"{name} = {value}"
            return
    lines.insert(start + 1, f"{name} = {value}")

set_option("ControllerMode", controller_mode)
set_option("Experimental", "true")
path.write_text("\n".join(lines) + "\n")
PY

systemctl enable bluetooth.service >/dev/null
systemctl restart bluetooth.service

if [[ $mode == --pairing ]]; then
    cat <<'EOF'
BlueZ is temporarily in BR/EDR-only pairing mode.
Pair the AirPods, then restore normal Bluetooth support with:
  sudo bash install/airpods-system.sh --normal
EOF
else
    cat <<'EOF'
BlueZ now uses dual BR/EDR + LE mode. Experimental battery reporting is enabled.
The original config is at /etc/bluetooth/main.conf.pre-airpods.
EOF
fi
