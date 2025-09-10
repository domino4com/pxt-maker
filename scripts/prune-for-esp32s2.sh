#!/usr/bin/env bash
set -euxo pipefail

# Toggle connectivity libs quickly from Cloud Build:
#   ENABLE_CONNECTIVITY=1  -> KEEP azureiot/mqtt/net
#   ENABLE_CONNECTIVITY=0  -> DROP them (default)
ENABLE_CONNECTIVITY="${ENABLE_CONNECTIVITY:-0}"

# 1) Remove MCU variants we don't need (RP2040/SAMD/STM32/NRF)
pushd pxt-common-packages/libs
find . -maxdepth 1 -type d \( -name '*---rp2040' -o -name '*---samd' -o -name '*---stm32' -o -name '*---nrf52' \) -print0 | xargs -0 rm -rf || true
rm -rf core---rp2040 core---samd mixer---samd mixer---stm32 mixer---nrf52 || true

# 2) Connectivity libs (soft toggle)
if [ "${ENABLE_CONNECTIVITY}" != "1" ]; then
  rm -rf azureiot mqtt net net-game radio radio-broadcast lora || true
else
  # keep azureiot/mqtt/net; still drop radios we don't use
  rm -rf radio radio-broadcast lora || true
fi
popd

# 3) Keep only v1 allow-list packages from your target if you’ve vendored any libs there.
# (No-op if you only reference libs from pxt-common-packages.)
# Example (uncomment & adjust if you ever copy libs into your target repo):
# pushd pxt-maker/libs
# for d in *; do
#   case "$d" in
#     buttons|touch|ledmatrix|neopixel|serial|i2c|spi|storage|music|sensors) ;; # keep
#     *) rm -rf "$d" ;;
#   esac
# done
# popd

# 4) Prevent Node typings from polluting TS build
rm -rf node_modules/@types/node || true
rm -rf pxt-common-packages/node_modules/@types/node || true
rm -rf pxt/node_modules/@types/node || true

# 5) (Safety) Remove settings overrides that referenced DAL.* in non-ESP targets
# Only if they exist in your checkout; harmless otherwise.
find pxt-common-packages -path '*/settings/targetoverrides.ts' -print0 | xargs -0 rm -f || true

echo "Prune complete. Remaining top-level libs:"
ls -1 pxt-common-packages/libs || true
