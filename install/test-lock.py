#!/usr/bin/env python3
"""Verify suspend gating using mocks; never lock or suspend the real session."""
import os
from pathlib import Path
import subprocess
import tempfile

script = Path(__file__).resolve().parents[1] / 'Scripts/lock-session'
mock = '''#!/usr/bin/env bash
case "${0##*/}" in
pgrep) exit "${PGREP_RESULT:-1}" ;;
swaylock)
    echo lock >> "$EVENTS"
    printf '%s\\0' "$@" >> "$LOCK_ARGS"
    if [[ ${IMAGE_FAIL:-0} == 1 && " $* " == *' --image '* ]]; then exit 1; fi
    exit "${LOCK_RESULT:-0}"
    ;;
systemctl) echo "$*" >> "$EVENTS" ;;
notify-send) exit 0 ;;
esac
'''
with tempfile.TemporaryDirectory(prefix='rice-lock-test-') as directory:
    root = Path(directory)
    for name in ('pgrep', 'swaylock', 'systemctl', 'notify-send'):
        path = root / name
        path.write_text(mock)
        path.chmod(0o700)
    cases = [('lock', '1', '0', 0, ['lock']), ('suspend', '1', '0', 0, ['lock', 'suspend']), ('suspend', '1', '1', 1, ['lock']), ('suspend', '0', '0', 0, ['suspend'])]
    for index, (action, running, lock_result, code, expected) in enumerate(cases):
        events = root / f'events-{index}'
        env = dict(os.environ, HOME=directory, PATH=f'{root}:/usr/bin', XDG_RUNTIME_DIR=directory, EVENTS=str(events), LOCK_ARGS=str(root / f'args-{index}'), PGREP_RESULT=running, LOCK_RESULT=lock_result)
        result = subprocess.run([str(script), action], env=env, capture_output=True, text=True)
        actual = events.read_text().splitlines() if events.exists() else []
        assert result.returncode == code and actual == expected, (index, result, actual)
    images = root / 'actual-wallpapers'
    images.mkdir()
    (root / 'Pictures').mkdir()
    (root / 'Pictures/Wallpapers').symlink_to(images, target_is_directory=True)
    image = images / 'a wallpaper.JPG'
    image.touch()
    (images / 'README.md').touch()
    for fail_image in ('0', '1'):
        events = root / f'image-events-{fail_image}'
        args_path = root / f'image-args-{fail_image}'
        env.update(EVENTS=str(events), LOCK_ARGS=str(args_path), PGREP_RESULT='1', LOCK_RESULT='0', IMAGE_FAIL=fail_image)
        result = subprocess.run([str(script), 'suspend'], env=env, capture_output=True, text=True)
        expected = ['lock', 'suspend'] if fail_image == '0' else ['lock', 'lock', 'suspend']
        assert result.returncode == 0 and events.read_text().splitlines() == expected
        assert args_path.read_bytes().split(b'\0')[:5] == [b'-f', b'--image', os.fsencode(root / 'Pictures/Wallpapers' / image.name), b'--scaling', b'fill']
print('6 lock tests passed, including symlinked wallpapers and image-failure fallback; no real session actions performed.')
