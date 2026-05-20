#!/usr/bin/env bash
# Start Spotify (Arch AUR: spotify or spotify-launcher).
set -euo pipefail

for candidate in spotify spotify-launcher; do
  if command -v "$candidate" >/dev/null 2>&1; then
    exec "$candidate" "$@"
  fi
done

msg="Geen Spotify gevonden. Installeer via AUR: yay -S spotify  (of: yay -S spotify-launcher)"
notify-send "Spotify" "$msg" 2>/dev/null || true
echo "$msg" >&2
exit 1
