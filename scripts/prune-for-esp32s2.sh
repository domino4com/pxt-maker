#!/usr/bin/env bash
set -euo pipefail

# Run from repo root (/workspace in Cloud Build)
ROOT="$(pwd)"

echo "Pruning to ESP32-S2 only..."

prune_dir() {
  local D="$1"
  [ -d "$D" ] || return 0
  echo "Pruning in: $D"

  # 1) Remove non-ESP platform variants
  find "$D" -maxdepth 1 -type d \( \
      -name '*---samd'   -o \
      -name '*---samd21' -o \
      -name '*---samd51' -o \
      -name '*---stm32'  -o \
      -name '*---nrf52'  -o \
      -name '*---rp2040' -o \
      -name '*---linux'  -o \
      -name '*---vm' \
    \) -print0 | xargs -0 rm -rf || true

  # 2) Remove board families that trigger other toolchains/hex caches
  find "$D" -maxdepth 1 -type d \( \
      -name 'adafruit-*' -o \
      -name 'arduino-*'  -o \
      -name 'sparkfun-*' -o \
      -name 'nucleo-*'   -o \
      -name 'rpi-pico'   -o \
      -name 'xinabox-*'  -o \
      -name 'jacdac-*'   -o \
      -name 'stitchkit'  -o \
      -name 'machachi'   -o \
      -name 'brain-*' \
    \) -print0 | xargs -0 rm -rf || true

  # 3) Remove features we don’t ship on ESP32-S2 web build
  rm -rf "$D"/{radio,radio-broadcast,net,net-game,mqtt,azureiot,lora} || true

  # 4) Whitelist the minimal set we keep; remove everything else
  local -a keep=(
    accelerometer animation base buttons color controller core core---esp32 core---esp32s2
    datalogger display edge-connector esp32 keyboard lcd light lightsensor matrix-keypad
    microphone mixer mixer---none mouse pixel power proximity pulse screen screen---st7735
    serial servo settings settings---esp32 settings---files storage switch tests
    text-to-speech thermometer touch wifi---esp32 tsconfig.json
  )

  # Build a pattern like ^(a|b|c|tsconfig\.json)$
  local pat
  pat="$(printf '|%s' "${keep[@]}")"
  pat="^($(echo "${pat:1}")$)"

  for dir in "$D"/*; do
    [ -d "$dir" ] || continue
    base="$(basename "$dir")"
    if ! [[ "$base" =~ $pat ]]; then
      rm -rf "$dir"
    fi
  done

  echo "Remaining in $D:"
  ls -1 "$D" || true
}

# Prune both repos’ libs folders
prune_dir "$ROOT/pxt-common-packages/libs"

# If the root has a libs folder separate from common-packages, prune it too
if [ -d "$ROOT/libs" ] && [ ! -L "$ROOT/libs" ]; then
  prune_dir "$ROOT/libs"
fi

echo "Prune complete."
