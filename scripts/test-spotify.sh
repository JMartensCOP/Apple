#!/usr/bin/env bash
# Test Spotify-launcher: toont welke client gebruikt wordt en start via launch-spotify.sh.
set -uo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPTS="$CONFIG/big-sur/scripts"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur/spotify.log"
LAUNCH="$SCRIPTS/launch-spotify.sh"

echo "=== Big Sur — test Spotify ==="
echo "HOME=$HOME"
echo "Log: $LOG"
echo ""

echo "--- Scriptpad ---"
if [ -x "$LAUNCH" ]; then
  echo "  OK  $LAUNCH"
elif [ -f "$LAUNCH" ]; then
  echo "  WAARSCHUWING: bestaat maar niet uitvoerbaar — chmod +x \"$LAUNCH\""
else
  echo "  ONTBREEKT: $LAUNCH"
  echo "  Oplossing: ./install.sh -y  of  ./scripts/sync-to-linux-home.sh"
fi
echo ""

echo "--- Beschikbare Spotify-clients ---"
chosen=""
for b in spotify spotify-launcher; do
  if command -v "$b" >/dev/null 2>&1; then
    echo "  OK  $b → $(command -v "$b")"
    [ -z "$chosen" ] && chosen="$b"
  else
    echo "  —   $b (niet in PATH)"
  fi
done
if [ -x /usr/bin/spotify ]; then
  echo "  OK  /usr/bin/spotify"
  [ -z "$chosen" ] && chosen="/usr/bin/spotify"
else
  echo "  —   /usr/bin/spotify (ontbreekt)"
fi
if command -v flatpak >/dev/null 2>&1; then
  if flatpak info com.spotify.Client >/dev/null 2>&1; then
    echo "  OK  flatpak com.spotify.Client"
    [ -z "$chosen" ] && chosen="flatpak"
  else
    echo "  —   flatpak com.spotify.Client (niet geïnstalleerd)"
  fi
else
  echo "  —   flatpak (niet gevonden)"
fi
if command -v pacman >/dev/null 2>&1; then
  for pkg in spotify spotify-launcher; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      echo "  OK  pacman -Q $pkg (pakket geïnstalleerd)"
    fi
  done
fi
echo ""

if [ -n "$chosen" ]; then
  echo "Launcher zou gebruiken: $chosen"
else
  echo "Geen Spotify-client gevonden."
  echo "  yay -S spotify              # AUR (aanbevolen)"
  echo "  yay -S spotify-launcher     # alternatief"
  echo "  flatpak install flathub com.spotify.Client"
fi
echo ""

if [ -f "$LOG" ]; then
  echo "--- Laatste regels spotify.log ---"
  tail -n 8 "$LOG" | sed 's/^/  /'
  echo ""
fi

if [ -x "$LAUNCH" ]; then
  echo "--- Launch uitvoeren ---"
  bash "$LAUNCH"
  echo ""
  echo "Controleer melding (notify-send) en log:"
  echo "  tail -f \"$LOG\""
else
  exit 1
fi
