#!/usr/bin/env bash
# Diagnose schermtoetsenbord op vouw-/convertible-laptops (bijv. HP EliteBook x360)
set -uo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPTS="$CONFIG/big-sur/scripts"
WAYBAR_CFG="$CONFIG/waybar/config.jsonc"

echo "=== Big Sur — convertible diagnose (OSK) ==="
echo "Gebruiker: ${USER:-?}  HOME=$HOME"
echo ""

echo "--- Scripts (~/.config/big-sur/scripts/) ---"
for s in toggle-osk.sh; do
  p="$SCRIPTS/$s"
  if [ -f "$p" ]; then
    if [ -x "$p" ]; then
      echo "  OK  $p (uitvoerbaar)"
    else
      echo "  WAARSCHUWING: $p bestaat maar is niet uitvoerbaar — chmod +x \"$p\""
    fi
  else
    echo "  ONTBREEKT: $p"
    echo "    Oplossing: ./install.sh -y  (in Hyprland-sessie, niet alleen sync)"
  fi
done
echo ""

echo "--- Waybar on-click paden ---"
if [ -f "$WAYBAR_CFG" ]; then
  if grep -q 'big-sur/scripts/toggle-osk.sh' "$WAYBAR_CFG" 2>/dev/null; then
    echo "  OK  config.jsonc verwijst naar toggle-osk.sh"
    if grep -q 'bash -lc.*toggle-osk' "$WAYBAR_CFG" 2>/dev/null; then
      echo "  OK  keyboard on-click gebruikt bash -lc (HOME-expansie)"
    else
      echo "  WAARSCHUWING: keyboard on-click zonder bash -lc — update waybar/config.jsonc"
    fi
  else
    echo "  WAARSCHUWING: waybar/config.jsonc mist pad naar toggle-osk.sh"
    echo "    Herinstalleer: ./install.sh -y"
  fi
else
  echo "  ONTBREEKT: $WAYBAR_CFG"
fi
echo ""

echo "--- Schermtoetsenbord ---"
found=0
for b in wvkbd-deskintl wvkbd-mobintl onboard; do
  if command -v "$b" >/dev/null 2>&1; then
    echo "  OK  $b → $(command -v "$b")"
    found=1
  fi
done
if [ "$found" -eq 0 ]; then
  echo "  Geen OSK-binary gevonden."
  echo "    AUR (aanbevolen): yay -S wvkbd-deskintl"
  echo "    Pacman fallback:  sudo pacman -S onboard"
fi
if pgrep -x wvkbd-deskintl >/dev/null 2>&1 || pgrep -x wvkbd-mobintl >/dev/null 2>&1 || pgrep -x onboard >/dev/null 2>&1; then
  echo "  Proces actief: $(pgrep -ax 'wvkbd-deskintl|wvkbd-mobintl|onboard' 2>/dev/null || true)"
fi
OSK_LOG="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur/osk.log"
if [ -f "$OSK_LOG" ]; then
  echo "  Log (laatste 3 regels): $OSK_LOG"
  tail -n 3 "$OSK_LOG" | sed 's/^/    /'
else
  echo "  Log: $OSK_LOG (nog leeg — klik 󰌌 of run test-osk.sh)"
fi
if [ -x "$SCRIPTS/test-osk.sh" ]; then
  echo "  Test: bash \"$SCRIPTS/test-osk.sh\""
fi
echo ""

echo "--- Waybar proces + config ---"
if pgrep -x waybar >/dev/null 2>&1; then
  echo "  PID: $(pgrep -x waybar | tr '\n' ' ' | sed 's/ $//')"
  pgrep -ax waybar 2>/dev/null | sed 's/^/  /' || true
else
  echo "  Geen waybar-proces actief."
fi
if [ -f "$WAYBAR_CFG" ]; then
  echo "  OK  $WAYBAR_CFG"
else
  echo "  ONTBREEKT: $WAYBAR_CFG  (./install.sh -y)"
fi
echo ""

echo "--- Handmatige test ---"
if [ -x "$SCRIPTS/toggle-osk.sh" ]; then
  echo "  bash \"$SCRIPTS/toggle-osk.sh\""
fi
if [ -x "$SCRIPTS/start-waybar.sh" ]; then
  echo "  Waybar herladen: \"$SCRIPTS/start-waybar.sh\""
fi
echo ""
echo "Klaar."
