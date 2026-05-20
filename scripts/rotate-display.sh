#!/usr/bin/env bash
# Cycle primary display rotation: 0° → 90° → 180° → 270° (Hyprland transform 0–3)
set -uo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.cache}/big-sur"
STATE_FILE="$STATE_DIR/display-rotation"
mkdir -p "$STATE_DIR"

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

hyprctl_ok() {
  local out="$1"
  [ -n "$out" ] && [[ "$out" != *"error"* ]] && [[ "$out" == *"ok"* ]]
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
notify-send "Schermrotatie" "${MONITOR}: ${LABELS[$NEXT]}" 2>/dev/null || true
