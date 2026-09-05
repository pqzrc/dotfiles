#!/usr/bin/env python3
"""Check rice dependencies and script links without modifying the session."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

repo = Path(__file__).resolve().parents[1]
errors = []
for command in ('sway', 'swaylock', 'swayidle', 'kanshi', 'waybar', 'dunst', 'dunstctl', 'fuzzel', 'kitty', 'ghostty', 'zsh', 'fzf', 'zoxide', 'starship', 'tmux', 'notify-send', 'flock'):
    if not shutil.which(command):
        errors.append(f'Missing command: {command}')
for config in (repo / '.config/sway/config', repo / '.config/waybar/config.jsonc', repo / '.config/swayidle/config'):
    for name in re.findall(r'~/Scripts/([A-Za-z0-9_-]+)', config.read_text()):
        script = repo / 'Scripts' / name
        if not script.is_file() or not script.stat().st_mode & 0o111:
            errors.append(f'Missing or non-executable script: {name}')
for script in ('lock-session', 'start-idle', 'sessionizer', 'powermenu', 'battery-monitor'):
    result = subprocess.run(['bash', '-n', str(repo / 'Scripts' / script)], capture_output=True, text=True)
    if result.returncode:
        errors.append(result.stderr)
json.loads((repo / '.config/waybar/config.jsonc').read_text())
for directory in ('sway', 'swayidle', 'swaylock', 'kanshi', 'rice'):
    target = Path.home() / '.config' / directory
    if target.resolve() != (repo / '.config' / directory).resolve():
        errors.append(f'Config is not linked to this checkout: {target}')
tracked = subprocess.check_output(['git', '-C', str(repo), 'ls-files', '.config/zsh/.zsh_history', '.config/zsh/.zcompdump*'], text=True)
if tracked:
    errors.append('Shell runtime files remain tracked in Git')
for error in errors:
    print(f'FAIL: {error}')
print(f'Rice check: {len(errors)} issue(s).')
sys.exit(bool(errors))
