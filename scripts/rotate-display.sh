#!/usr/bin/env bash
# Cycle primary display rotation: 0° → 90° → 180° → 270° (Hyprland transform 0–3)
# After transform: activate landscape/portrait Waybar config + hard restart (hitbox sync).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.cache}/big-sur"
STATE_FILE="$STATE_DIR/display-rotation"
WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
SETTLE_SEC=1.2
TRANSFORM_WAIT_MAX=25

notify_step() {
  notify-send "Schermrotatie" "$1" 2>/dev/null || true
}

notify_err() {
  notify-send "Schermrotatie" "$1" 2>/dev/null || true
  echo "Schermrotatie: $1" >&2
}

read_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo "0"
  fi
}

write_state() {
  printf '%s\n' "$1" >"$STATE_FILE"
}

# Laptop panel eerst (eDP-*), anders eerste monitor uit hyprctl
detect_monitor() {
  local mon=""

  if command -v hyprctl >/dev/null 2>&1; then
    if command -v jq >/dev/null 2>&1; then
      mon="$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.name | test("^eDP")) | .name' | head -1)"
      if [ -z "$mon" ] || [ "$mon" = "null" ]; then
        mon="$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name // empty')"
      fi
    else
      mon="$(hyprctl monitors 2>/dev/null | awk '
        BEGIN { first = "" }
        /^Monitor / {
          n = $2
          sub(/\(.*/, "", n)
          if (n ~ /^eDP/) { print n; exit }
          if (first == "") first = n
        }
        END { if (first != "") print first }
      ')"
    fi
  fi

  if [ -z "$mon" ] && command -v wlr-randr >/dev/null 2>&1; then
    mon="$(wlr-randr 2>/dev/null | awk '/^[^ ]/ { if ($1 ~ /^eDP/) { print $1; exit } }')"
    if [ -z "$mon" ]; then
      mon="$(wlr-randr 2>/dev/null | awk '/^[^ ]/ { print $1; exit }')"
    fi
  fi

  if [ -z "$mon" ]; then
    notify_err "Geen monitor gevonden (hyprctl / wlr-randr)."
    exit 1
  fi
  echo "$mon"
}

current_transform_hypr() {
  local mon="$1"
  if ! command -v hyprctl >/dev/null 2>&1; then
    return 1
  fi
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .transform // 0'
    return 0
  fi
  hyprctl monitors 2>/dev/null | awk -v want="$mon" '
    /^Monitor / { cur = $2; sub(/\(.*/, "", cur) }
    cur == want && /transform:/ { print $2; exit }
  '
}

# Poll tot Hyprland transform overeenkomt (max ~2.5s)
wait_for_transform() {
  local mon="$1" want="$2"
  local i=0 actual=""

  if ! command -v hyprctl >/dev/null 2>&1; then
    sleep 0.5
    return 0
  fi

  while [ "$i" -lt "$TRANSFORM_WAIT_MAX" ]; do
    actual="$(current_transform_hypr "$mon" 2>/dev/null || echo "")"
    if [ "$actual" = "$want" ]; then
      return 0
    fi
    sleep 0.1
    i=$((i + 1))
  done
  return 1
}

hyprctl_ok() {
  local out="$1"
  [ -n "$out" ] && [[ "$out" != *"error"* ]] && [[ "$out" == *"ok"* ]]
}

# kanshi/shikane overschrijven hyprctl keyword monitor — rotatie lijkt ok maar springt terug
kanshi_conflict() {
  pgrep -x kanshi >/dev/null 2>&1 || pgrep -x shikane >/dev/null 2>&1
}

waybar_template_dir() {
  local d=""
  for d in \
    "$WAYBAR_DIR" \
    "$SCRIPT_DIR/../waybar" \
    "$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)/waybar"; do
    if [ -n "$d" ] && [ -d "$d" ]; then
      if [ -f "$d/config.landscape.jsonc" ] || [ -f "$d/config.portrait.jsonc" ]; then
        echo "$d"
        return 0
      fi
    fi
  done
  return 1
}

# Landscape (0/2) vs portrait (1/3) — volledige config.jsonc vervangen
activate_waybar_config() {
  local transform="$1"
  local tpl_dir src active="$WAYBAR_DIR/config.jsonc"

  tpl_dir="$(waybar_template_dir 2>/dev/null || echo "")"
  if [ -z "$tpl_dir" ]; then
    return 0
  fi

  case "$transform" in
    1 | 3) src="$tpl_dir/config.portrait.jsonc" ;;
    *) src="$tpl_dir/config.landscape.jsonc" ;;
  esac

  if [ ! -f "$src" ]; then
    src="$tpl_dir/config.jsonc"
  fi
  if [ ! -f "$src" ]; then
    return 0
  fi

  mkdir -p "$WAYBAR_DIR"
  cp -f "$src" "$active"
}

# Compositor relayout forceren vóór Waybar opnieuw layer-shell registreert
refresh_hypr_layout() {
  local mon="$1" transform="$2"

  if ! command -v hyprctl >/dev/null 2>&1; then
    return 0
  fi

  hyprctl reload >/dev/null 2>&1 || true
  sleep 0.45

  if command -v jq >/dev/null 2>&1; then
    local scale mode out
    scale="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .scale // 1')"
    mode="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '
      .[] | select(.name == $m) |
      "\(.width)x\(.height)@\(.refreshRate)Hz"
    ')"
    if [ -n "$mode" ] && [ "$mode" != "null" ] && [ -n "$scale" ]; then
      out="$(hyprctl keyword "monitor ${mon},${mode},0x0,${scale},transform,${transform}" 2>&1)" || true
      hyprctl_ok "$out" || true
      sleep 0.2
      out="$(hyprctl keyword "monitor ${mon},transform,${transform}" 2>&1)" || true
      hyprctl_ok "$out" || true
      sleep 0.2
      # Nudge layout (sommige Hyprland-builds updaten input pas na resize)
      local w h
      w="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .width // 0')"
      h="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .height // 0')"
      if [ -n "$w" ] && [ "$w" != "0" ] && [ -n "$h" ] && [ "$h" != "0" ]; then
        hyprctl dispatch resizemonitor "$mon" "$w" "$h" 2>/dev/null || true
      fi
    fi
  fi
}

find_start_waybar() {
  local candidate=""
  for candidate in \
    "$SCRIPT_DIR/start-waybar.sh" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/big-sur/scripts/start-waybar.sh"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

# SIGUSR1/2 herlaadt config, niet input-regio's — pkill -9 + nieuwe layer-shell
restart_waybar_after_rotation() {
  local mon="$1" transform="$2"
  local start_script=""

  notify_step "Wacht op compositor…"
  if ! wait_for_transform "$mon" "$transform"; then
    notify_step "Transform nog niet bevestigd — Waybar-herstart gaat door."
  fi

  notify_step "Waybar-config (${transform})…"
  activate_waybar_config "$transform"

  notify_step "Herstart Waybar (klikzones)…"
  if command -v hyprctl >/dev/null 2>&1; then
    refresh_hypr_layout "$mon" "$transform"
  fi

  sleep "$SETTLE_SEC"

  pkill -9 -x waybar 2>/dev/null || true
  sleep 0.35

  start_script="$(find_start_waybar 2>/dev/null || echo "")"
  if [ -n "$start_script" ]; then
    "$start_script" >/dev/null 2>&1 || true
  elif command -v waybar >/dev/null 2>&1; then
    nohup waybar >/dev/null 2>&1 &
  fi
}

# Hyprland 0.54+: probeer transform-only, dan volledige monitor-regel (regressie-workaround)
apply_hypr() {
  local mon="$1" transform="$2"
  local out scale mode

  out="$(hyprctl keyword "monitor ${mon},transform,${transform}" 2>&1)" || true
  if hyprctl_ok "$out"; then
    sleep 0.15
    if [ "$(current_transform_hypr "$mon" 2>/dev/null || echo -1)" = "$transform" ]; then
      return 0
    fi
  fi

  if command -v jq >/dev/null 2>&1; then
    scale="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .scale // 1')"
    mode="$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '
      .[] | select(.name == $m) |
      "\(.width)x\(.height)@\(.refreshRate)Hz"
    ')"
    if [ -n "$mode" ] && [ "$mode" != "null" ] && [ -n "$scale" ]; then
      out="$(hyprctl keyword "monitor ${mon},${mode},0x0,${scale},transform,${transform}" 2>&1)" || true
      if hyprctl_ok "$out"; then
        sleep 0.15
        if [ "$(current_transform_hypr "$mon" 2>/dev/null || echo -1)" = "$transform" ]; then
          return 0
        fi
      fi
    fi
  fi

  out="$(hyprctl keyword "monitor ${mon},preferred,auto,1,transform,${transform}" 2>&1)" || true
  if hyprctl_ok "$out"; then
    sleep 0.15
    if [ "$(current_transform_hypr "$mon" 2>/dev/null || echo -1)" = "$transform" ]; then
      return 0
    fi
  fi

  notify_err "Rotatie niet toegepast op ${mon}. Controleer kanshi/shikane of: hyprctl keyword monitor ${mon},transform,${transform}"
  return 1
}

# wlr-randr: normal | 90 | 180 | 270
apply_wlr() {
  local mon="$1" transform="$2"
  local mode="normal"
  case "$transform" in
    0) mode="normal" ;;
    1) mode="90" ;;
    2) mode="180" ;;
    3) mode="270" ;;
    *) mode="normal" ;;
  esac
  if ! wlr-randr --output "$mon" --transform "$mode" 2>/dev/null; then
    notify_err "wlr-randr mislukt voor ${mon} (${mode})."
    return 1
  fi
  return 0
}

MONITOR="$(detect_monitor)"
CURRENT="$(read_state)"

# Sync met actuele Hyprland-transform indien beschikbaar
if ACTUAL="$(current_transform_hypr "$MONITOR" 2>/dev/null)" && [ -n "$ACTUAL" ]; then
  case "$ACTUAL" in
    0 | 1 | 2 | 3) CURRENT="$ACTUAL" ;;
  esac
fi

NEXT=$(( (CURRENT + 1) % 4 ))
LABELS=("0° (normaal)" "90°" "180°" "270°")

if command -v hyprctl >/dev/null 2>&1; then
  if ! apply_hypr "$MONITOR" "$NEXT"; then
    exit 1
  fi
elif command -v wlr-randr >/dev/null 2>&1; then
  if ! apply_wlr "$MONITOR" "$NEXT"; then
    exit 1
  fi
else
  notify_err "Installeer Hyprland of wlr-randr (pacman -S hyprland wlr-randr)."
  exit 1
fi

write_state "$NEXT"
restart_waybar_after_rotation "$MONITOR" "$NEXT"

MSG="${MONITOR}: ${LABELS[$NEXT]}"
MSG="$MSG\nWaybar herstart (klikzones + ${SETTLE_SEC}s settle)."
case "$NEXT" in
  1 | 3)
    MSG="$MSG\nPortrait-config actief (config.portrait.jsonc)."
    ;;
  *)
    MSG="$MSG\nLandscape-config actief (config.landscape.jsonc)."
    ;;
esac
if kanshi_conflict; then
  MSG="$MSG\nWaarschuwing: kanshi/shikane actief — kan rotatie overschrijven."
fi
if command -v hyprctl >/dev/null 2>&1 && ! wait_for_transform "$MONITOR" "$NEXT"; then
  MSG="$MSG\nTransform niet bevestigd — probeer hyprctl reload of terug naar 0°."
fi
notify-send "Schermrotatie" "$MSG" 2>/dev/null || true
