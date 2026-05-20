#!/usr/bin/env bash
# Diagnose schermtoetsenbord + rotatie op vouw-/convertible-laptops (bijv. HP EliteBook x360)
set -uo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPTS="$CONFIG/big-sur/scripts"
WAYBAR_CFG="$CONFIG/waybar/config.jsonc"

echo "=== Big Sur — convertible diagnose ==="
echo "Gebruiker: ${USER:-?}  HOME=$HOME"
echo ""

echo "--- Scripts (~/.config/big-sur/scripts/) ---"
for s in toggle-osk.sh rotate-display.sh; do
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
  if grep -q 'big-sur/scripts/toggle-osk.sh' "$WAYBAR_CFG" 2>/dev/null \
    && grep -q 'big-sur/scripts/rotate-display.sh' "$WAYBAR_CFG" 2>/dev/null; then
    echo "  OK  config.jsonc verwijst naar big-sur/scripts/*.sh"
    if grep -q 'bash -lc.*toggle-osk' "$WAYBAR_CFG" 2>/dev/null; then
      echo "  OK  keyboard on-click gebruikt bash -lc (HOME-expansie)"
    else
      echo "  WAARSCHUWING: keyboard on-click zonder bash -lc — update waybar/config.jsonc"
    fi
  else
    echo "  WAARSCHUWING: waybar/config.jsonc mist paden naar toggle-osk / rotate-display"
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

echo "--- Schermrotatie ---"
if command -v hyprctl >/dev/null 2>&1; then
  echo "  hyprctl monitors (naam + transform):"
  hyprctl monitors 2>/dev/null | grep -E '^Monitor |transform:' || hyprctl monitors
  if command -v jq >/dev/null 2>&1; then
    echo "  JSON (eerste eDP of [0]):"
    hyprctl monitors -j 2>/dev/null | jq -r '.[] | "\(.name) transform=\(.transform) \(.width)x\(.height)@\(.refreshRate)Hz scale=\(.scale)"' | head -5
  else
    echo "  Tip: sudo pacman -S jq  (betere monitor-detectie in rotate-display.sh)"
  fi
else
  echo "  hyprctl niet gevonden (geen Hyprland-sessie?)"
fi
if command -v wlr-randr >/dev/null 2>&1; then
  echo "  wlr-randr outputs:"
  wlr-randr 2>/dev/null | awk '/^[^ ]/ { print "   ", $0 }' | head -6
fi
if command -v kanshi >/dev/null 2>&1 || command -v shikane >/dev/null 2>&1; then
  echo "  WAARSCHUWING: kanshi/shikane gedetecteerd — kan hyprctl rotatie overschrijven."
fi
echo ""

echo "--- Handmatige test ---"
if [ -x "$SCRIPTS/rotate-display.sh" ]; then
  echo "  bash \"$SCRIPTS/rotate-display.sh\""
else
  echo "  (rotate-display.sh ontbreekt — eerst install.sh)"
fi
if [ -x "$SCRIPTS/toggle-osk.sh" ]; then
  echo "  bash \"$SCRIPTS/toggle-osk.sh\""
fi
  echo "  Waybar herladen: \"$SCRIPTS/start-waybar.sh\" (rotate-display.sh doet dit automatisch na rotatie)"
echo ""
echo "Klaar."
