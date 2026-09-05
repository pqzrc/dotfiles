#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
case "${1:---preview}" in
    --preview) exec stow --dir="$repo" --target="$HOME" --simulate --verbose . ;;
    --apply) exec stow --dir="$repo" --target="$HOME" --verbose . ;;
    *) echo 'Usage: bash install/link.sh [--preview|--apply]' >&2; exit 2 ;;
esac
