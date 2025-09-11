#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

prune_dir() {
  local D="$1"
  [ -d "$D" ] || return 0
  echo "Pruning in: $D"

  # 1) Remove all non-ESP cores across families
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

  # 2) Remove board families that trigger other hex caches
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

  # 3) Remove features we don’t want
  rm -rf "$D"/{radio,radio-broadcast,net,net-game,mqtt,azureiot,lora} || true

  # 4) Minimal whitelist
  local keep=(
    accelerometer animation base buttons color controller core core---esp32 core---esp32s2
    datalogger display edge-connector esp32 keyboard lcd light lightsensor matrix-keypad
    microphone mixer mixer---none mouse pixel power proximity pulse screen screen---st7735
    serial servo settings settings---esp32 settings---files storage switch tests
    text-to-speech thermometer touch wifi---esp32
  )

  local pat="$(printf '|%s' "${keep[@]}")"
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

# Prune only the canonical libs tree
prune_dir "$ROOT/pxt-common-packages/libs"

# Use the canonical libs tree
rm -rf "$ROOT/libs" || true
ln -s "$ROOT/pxt-common-packages/libs" "$ROOT/libs"

# (Optional) one-time cleanup here is ok, but we'll also purge in the build step
rm -rf "$ROOT"/node_modules/@types/node \
       "$ROOT"/pxt/node_modules/@types/node \
       "$ROOT"/pxt-common-packages/node_modules/@types/node || true

echo "Linked $ROOT/libs -> pxt-common-packages/libs"
