# dotfiles

my sway dotfiles

Repo location:

```sh
~/dotfiles
```

## Install

Install Git and Stow:

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

## Screen recording

Install the Arch Linux packages used by the Sway recording and Discord
compression workflow:

```sh
cd ~/dotfiles
sudo pacman -S --needed - < packages/screenrecord.arch
```

The recorder automatically targets the focused Sway output, so the same
configuration works with desktop outputs and laptop panels.
