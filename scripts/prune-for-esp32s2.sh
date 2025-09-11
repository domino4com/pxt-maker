#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

prune_dir() {
  local D="$1"
  [ -d "$D" ] || return 0
  echo "Pruning in: $D"

  # 1) Remove non-ESP variants
  find "$D" -maxdepth 1 -type d \( \
      -name '*---samd'  -o \
      -name '*---samd21' -o \
      -name '*---samd51' -o \
      -name '*---stm32' -o \
      -name '*---nrf52' -o \
      -name '*---rp2040' -o \
      -name '*---linux' -o \
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
      -name 'brain-*'    -o \
      -name 'stitchkit'  -o \
      -name 'machachi'   -o \
      -name 'jacdac-*'   \
    \) -print0 | xargs -0 rm -rf || true

  # 3) Features we don't need in the web ESP32-S2 build
  rm -rf "$D"/{radio,radio-broadcast,net,net-game,mqtt,azureiot,lora} || true

  # 4) Keep a minimal whitelist
  keep=(
    accelerometer animation base buttons color controller core core---esp32 core---esp32s2
    datalogger display edge-connector esp32 keyboard lcd light lightsensor matrix-keypad
    microphone mixer mixer---none mouse pixel power proximity pulse screen screen---st7735
    serial servo settings settings---esp32 settings---files storage switch tests
    text-to-speech thermometer touch wifi---esp32 tsconfig.json
  )

  pat="$(printf '|%s' "${keep[@]}")"
  pat="^($(echo "${pat:1}")|tsconfig\.json)$"

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

# Prune common-packages libs
prune_dir "$ROOT/pxt-common-packages/libs"

# Make project-level libs point at common-packages (we’ll create the symlink later in the build)
rm -rf "$ROOT/libs" || true

# Remove @types/node everywhere to prevent TS type pollution
rm -rf "$ROOT"/node_modules/@types/node \
       "$ROOT"/pxt/node_modules/@types/node \
       "$ROOT"/pxt-common-packages/node_modules/@types/node || true
