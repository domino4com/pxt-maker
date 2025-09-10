#!/usr/bin/env bash
set -euxo pipefail

# Only keep ESP32/ESP32-S2 relevant libs and your Springbot board
pushd pxt-common-packages/libs

# Remove MCU-specific libs we don't need
# (rp2040 / samd / stm32 / nrf52 variants and their mixers/cores)
rm -rf core---rp2040 core---samd mixer---samd mixer---stm32 mixer---nrf52 \
       screen---st7735 2>/dev/null || true

# If you don’t use these in your first release, drop them to avoid crypto/settings errors + cache build:
rm -rf azureiot mqtt radio radio-broadcast lora net net-game 2>/dev/null || true

# Keep generics + ESP32 bits; delete other MCU variants of any package if present
find . -maxdepth 1 -type d -name '*---rp2040' -o -name '*---samd' -o -name '*---stm32' -o -name '*---nrf52' \
  -print0 | xargs -0 rm -rf || true

popd

# Remove Node typings so the TS compiler won’t parse them
rm -rf node_modules/@types/node || true

# Optional: if @types/node sneaks in under pxt-common-packages, drop it there too
rm -rf pxt-common-packages/node_modules/@types/node || true

# Sanity: show what remains for visibility
echo "Remaining libs:"
ls -1 pxt-common-packages/libs
