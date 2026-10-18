# AirPods on Sway

This setup gives the paired AirPods a permanent Waybar item, an Apple-style control panel, a quick-connect action, and explicit disconnect behavior.

## What changed from the original guide

The useful part of the guide is its explicit handoff model. Disconnecting blocks only the AirPods, so this computer cannot silently take them back from the phone. The next manual connection unblocks them first.

This setup changes three details:

- `ControllerMode = bredr` is only a pairing workaround. Normal use returns BlueZ to its default `dual` mode so Bluetooth LE devices still work.
- A user service listens to BlueZ over D-Bus. It replaces the root udev callback and avoids a hard-coded Bluetooth address.
- Waybar opens a native GTK 4 layer-shell panel. The panel shows the paired device name, connection state, an available BlueZ battery value, and connect or disconnect controls.
- PipeWire remembers the current output before connecting, makes the AirPods the default, and moves active audio streams. Disconnecting restores the remembered output and moves the streams back.

Sources:

- Original workflow: https://mil.ad/blog/2024/airpods-on-arch.html
- BlueZ default controller mode: https://github.com/bluez/bluez/blob/master/src/main.conf
- Waybar Bluetooth battery support: `man 5 waybar-bluetooth`

## Install

The desktop packages are listed in `manifests/desktop.txt`. Apply the dotfiles, enable the disconnect guard, and update BlueZ:

```sh
cd ~/Clone/dotfiles
stow --target="$HOME" --verbose .
systemctl --user daemon-reload
systemctl --user enable --now airpods-guard.service
sudo bash install/airpods-system.sh --normal
swaymsg reload
pkill -SIGUSR2 waybar
```

The system step restores `ControllerMode = dual`, enables BlueZ's experimental battery interface, and restarts Bluetooth. It creates `/etc/bluetooth/main.conf.pre-airpods` before the first edit.

## Pair once

This machine already has `Rénald’s AirPods Pro` paired. On another machine, try normal dual-mode pairing first. Open Bluetooth Settings from the AirPods panel, hold the case button until the status light flashes white, then pair.

If BlueZ cannot pair the AirPods, temporarily use BR/EDR-only mode:

```sh
sudo bash install/airpods-system.sh --pairing
blueman-manager
sudo bash install/airpods-system.sh --normal
```

Do not leave the controller in `bredr` mode. It disables Bluetooth LE for every device on the machine.

## Use

- Left-click the Waybar AirPods item to open the control panel.
- Right-click it to connect or disconnect immediately.
- Press `Super+Shift+B` to open the same panel from Sway.
- Press Escape to close the panel.

Audio already playing follows the connection. The previous default output is stored in `~/.local/state/airpods/audio-route.json` only while the AirPods session is active. An unexpected disconnect, such as closing the case or walking out of range, restores that output through the guard service.

The script finds the first paired device whose name contains `AirPods`. No device address is committed to the dotfiles. If several pairs are present, set `AIRPODS_ADDRESS` to select one.

## Limits and the next step

BlueZ and PipeWire handle audio and media controls. They cannot reproduce Apple's iCloud handoff, Find My network, or spatial-audio head tracking.

BlueZ may expose one battery percentage, not separate left, right, and case values. For the closer Apple experience, `podctl` adds AirPods Pro 2 battery values, listening modes, in-ear playback control, and a case-open popup. It is a young third-party project, so install it as a separate, reviewed step rather than hiding it inside the dotfiles installer:

https://github.com/Rockykln/podctl
