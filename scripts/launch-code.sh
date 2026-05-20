#!/usr/bin/env bash
# Start Visual Studio Code (Arch: code, code-oss, or VSCodium).
set -euo pipefail

for candidate in code code-oss codium; do
  if command -v "$candidate" >/dev/null 2>&1; then
    exec "$candidate" "$@"
  fi
done

msg="Geen VS Code gevonden. Installeer: sudo pacman -S code  (of code-oss / codium)"
notify-send "Visual Studio Code" "$msg" 2>/dev/null || true
echo "$msg" >&2
exit 1
