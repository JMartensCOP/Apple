#!/usr/bin/env bash
# Test schermtoetsenbord: toont welke binary gebruikt wordt en voert toggle uit.
set -uo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPTS="$CONFIG/big-sur/scripts"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur/osk.log"
TOGGLE="$SCRIPTS/toggle-osk.sh"

echo "=== Big Sur — test schermtoetsenbord ==="
echo "HOME=$HOME"
echo "Log: $LOG"
echo ""

echo "--- Scriptpad ---"
if [ -x "$TOGGLE" ]; then
  echo "  OK  $TOGGLE"
elif [ -f "$TOGGLE" ]; then
  echo "  WAARSCHUWING: bestaat maar niet uitvoerbaar — chmod +x \"$TOGGLE\""
else
  echo "  ONTBREEKT: $TOGGLE"
  echo "  Oplossing: ./install.sh -y  of  ./scripts/sync-to-linux-home.sh"
fi
echo ""

echo "--- Beschikbare OSK-binaries ---"
chosen=""
for b in wvkbd-deskintl wvkbd-mobintl onboard; do
  if command -v "$b" >/dev/null 2>&1; then
    echo "  OK  $b → $(command -v "$b")"
    [ -z "$chosen" ] && chosen="$b"
  else
    echo "  —   $b (niet gevonden)"
  fi
done
echo ""

if [ -n "$chosen" ]; then
  case "$chosen" in
    wvkbd-deskintl|wvkbd-mobintl)
      echo "Toggle zou starten: $chosen (wvkbd, SIGRTMIN toggle als al actief)"
      ;;
    onboard)
      echo "Toggle zou starten: onboard --layout=Compact (GDK wayland, anders x11)"
      ;;
  esac
else
  echo "Geen OSK geïnstalleerd."
  echo "  yay -S wvkbd-deskintl   # AUR, aanbevolen"
  echo "  sudo pacman -S onboard  # pacman-fallback (install.sh)"
fi
echo ""

if [ -f "$LOG" ]; then
  echo "--- Laatste regels osk.log ---"
  tail -n 8 "$LOG" | sed 's/^/  /'
  echo ""
fi

if [ -x "$TOGGLE" ]; then
  echo "--- Toggle uitvoeren ---"
  bash "$TOGGLE"
  echo ""
  echo "Controleer melding (notify-send) en log:"
  echo "  tail -f \"$LOG\""
else
  exit 1
fi
