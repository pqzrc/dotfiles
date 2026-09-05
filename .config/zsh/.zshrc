# Clean Oh My Zsh setup
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

ZSH_THEME=""

plugins=(
  git
  sudo
)

source "$ZSH/oh-my-zsh.sh"

# Environment
export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"
export VISUAL=nvim
export TERMINAL=kitty
export MANPAGER="nvim +Man!"
export MPD_HOST="/run/user/$(id -u)/mpd/socket"

# PATH
#path=(
 # "$HOME/.local/bin"
  #"$HOME/dev-tools/flutter/bin"
  #"$HOME/.pub-cache/bin"
  #$path
#)
typeset -U path

# Tools
if [[ -o interactive && -o zle ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)" 2>/dev/null
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


if [[ -o interactive ]] && command -v rxfetch >/dev/null 2>&1; then
  rxfetch
fi

# Functions
sessionizer() {
  "$HOME/Scripts/sessionizer"
}

y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
  yazi "$@" --cwd-file="$tmp"
  if [[ -r "$tmp" ]]; then
    cwd="$(<"$tmp")"
    if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
  fi
  rm -f -- "$tmp"
}

flutter-watch() {
  local pid_file="/tmp/tf1.pid"
  touch "$pid_file"
  tmux send-keys "flutter run $* --pid-file=$pid_file" Enter \; \
    split-window -v \; \
    send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter \; \
    resize-pane -y 5 -t 1 \; \
    select-pane -t 0 \;
}

android-studio-wayland() {
  GDK_BACKEND=x11 android-studio "$@"
}

if [[ -o interactive && -o zle ]]; then
  sessionizer-widget() {
    zle -I
    sessionizer
  }
  zle -N sessionizer-widget
  bindkey '^K' sessionizer-widget
fi

# Listing
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -1 --icons=auto'
  alias l='eza -lh --icons=auto'
  alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
  alias ld='eza -lhD --icons=auto'
  alias lt='eza --icons=auto --tree'
  alias ltt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
else
  alias ls='ls --color=auto'
  alias l='ls -lh'
  alias ll='ls -lha'
  alias ld='ls -lhd -- */'
fi

# Navigation
alias cd='z'
alias cdd='builtin cd'
alias ..='cd ..'
alias ...='cd ../..'

# Editors
alias n='nvim'
alias zed='zeditor'
alias c='code .'

# Config files
alias bfile='nvim ~/.bashrc'
alias ffile='nvim ~/.config/zsh/.zshrc'

# File managers & terminals
alias zz='yazi'
alias open='thunar .'

# Search & history
alias h='history | grep'

# Dev tools
alias nd='npm run dev'
alias mr='make run'
alias mp='makepkg -si'
alias lg='lazygit'
alias d='docker'
alias gits='git status'
alias ghp='gh repo create --public $(basename "$PWD") --source=. --description="desc" --push'

# Mobile & Android
alias emu='QT_QPA_PLATFORM=xcb ~/Android/Sdk/emulator/emulator -avd Pixel_9 &'

# Media
alias rip='yt-dlp -x --audio-format="mp3"'

# TTY fonts
alias bigfont='setfont ter-132b'
alias regfont='setfont default8x16'

# Safety wrappers
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias tar='tar -xvf'

# System
alias last-updated='grep -i "full system upgrade" /var/log/pacman.log | tail -n 1'
alias pwreset='faillock --reset --user dnd'
alias pg='ping -c 10 google.com'
alias cache='du -sh /var/cache/pacman/pkg .cache/paru'
alias folders='du -h --max-depth=1'

# Package management
alias pp='paru -Slq | fzf --multi --preview "paru -Sii {1}" --preview-window=down:55% | xargs -ro paru -S'
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
alias mirrorfix='sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist'
alias cleanc='sudo pacman -Sc && yay -Sc'

# Shell switching
alias tobash='chsh $USER -s /usr/bin/bash && echo "Log out and log back in for change to take effect."'
alias tofish='chsh $USER -s /usr/bin/fish && echo "Log out and log back in for change to take effect."'
alias tozsh='chsh $USER -s /usr/bin/zsh && echo "Log out and log back in for change to take effect."'

# Tmux
alias tmuxk='tmux kill-session'

# Misc
alias chx='chmod +x'
alias x='exit'

# Pi
export PATH="$HOME/.npm-global/bin:$PATH"
