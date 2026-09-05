# dotfiles

Shared Sway desktop for laptop and desktop. The checkout mirrors home-directory paths and is deployed with GNU Stow.

## Layout

- `.config/`: shared application preferences; no shell history or completion caches.
- `.config/rice/hosts/`: hardware-specific Kanshi profiles. Both profiles are installed; connected outputs determine the active layout.
- `Scripts/`: shared desktop commands, including locking and the project sessionizer.
- `manifests/desktop.txt`: core desktop packages.
- `install/`: link preview/apply and read-only dependency checks.

Kanshi owns display modes and positions. Sway owns keybindings, window rules, and workspace preferences. Laptop HDMI currently defaults to 1080p at 60 Hz; adjust the laptop profile for a different monitor.

Local paths must use `$HOME` or XDG variables. Keep private credentials, shell history, generated caches, and machine runtime state out of Git. Pull and inspect changes before editing on the other machine; do not automatically overwrite a dirty checkout.

Repo location:

```sh
~/dotfiles
```

## Install

Install Git and Stow, then the core packages listed in `manifests/desktop.txt`. Optional application shortcuts require their corresponding applications. Oh My Zsh must also exist at `~/.oh-my-zsh` for the current shell configuration.

```sh
sudo pacman -S git stow
```

Clone:

```sh
cd ~
git clone git@github.com:donotdisturb7/dotfiles.git dotfiles
cd ~/dotfiles
```

Preview links:

```sh
stow --target="$HOME" --simulate --verbose .
```

Create links:

```sh
stow --target="$HOME" --verbose .
```

This links files from `~/dotfiles` into the normal places, like:

```sh
~/.config/sway -> ~/dotfiles/.config/sway
~/.config/waybar -> ~/dotfiles/.config/waybar
~/.tmux.conf -> ~/dotfiles/.tmux.conf
~/Scripts -> ~/dotfiles/Scripts
```

Equivalent deployment commands are `bash install/link.sh --preview` and `bash install/link.sh --apply`. Never use Stow's adopt option to overwrite existing configuration without reviewing it.

Run `python3 install/doctor.py` after installation or before sharing changes. It checks core commands, desktop script references, config links, shell syntax, and accidentally tracked runtime files.

## School Session

Super+F1 opens a searchable list of the active Sway keybindings. Escape closes it; choosing a row does not run the command. Resize-mode bindings are marked separately. This lists Sway shortcuts, not application-specific shortcuts.

Obsidian is assigned to workspace 5, separate from communication apps on workspace 3. The existing vault remains in Documents/BRAIN.

`Scripts/sessionizer` selects projects from School, Projects, Work, Git, and BRAIN and opens or switches a tmux session. `Scripts/lock-session` uses standard swaylock; the suspend action proceeds only after locking succeeds. `Scripts/start-idle` starts one swayidle process with a five-minute lock and ten-minute screen-off timeout.

Before trusting a changed lock configuration, test locking and unlocking locally, then test suspend/resume. Do not test suspend while a migration or other important job is running.

Each new lock selects a random JPG, PNG, or WebP from `~/Pictures/Wallpapers` (including subfolders) and fills the screen. If the folder is empty or the selected image cannot load, locking falls back to the configured solid background.

The physical power key is handled by systemd-logind, not a Sway binding. Run `sudo bash install/power-policy.sh` once per machine to install `HandlePowerKey=suspend` and reload logind without ending the session. The active swayidle process locks before sleep. A Sway binding alone does not override logind's default power-off action.

## Screen recording

Install the Arch Linux packages used by the Sway recording and Discord
compression workflow:

```sh
cd ~/dotfiles
sudo pacman -S --needed - < packages/screenrecord.arch
```

The recorder automatically targets the focused Sway output, so the same
configuration works with desktop outputs and laptop panels.
