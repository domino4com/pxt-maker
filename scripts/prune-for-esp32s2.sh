#!/usr/bin/env bash
set -euxo pipefail

# 1) Drop non-ESP MCUs (rp2040/samd/stm32/nrf52) so PXT won’t try to build their caches
pushd pxt-common-packages/libs
find . -maxdepth 1 -type d \( -name '*---rp2040' -o -name '*---samd' -o -name '*---stm32' -o -name '*---nrf52' \) -print0 | xargs -0 rm -rf || true
rm -rf core---rp2040 core---samd mixer---samd mixer---stm32 mixer---nrf52 || true

# 2) Always remove connectivity stacks for now (we’ll re-enable later):
#    azureiot, mqtt, net (and radios we don’t use)
rm -rf azureiot mqtt net net-game radio radio-broadcast lora || true
popd

# 3) Prevent Node typings from polluting TS build
rm -rf node_modules/@types/node || true
rm -rf pxt-common-packages/node_modules/@types/node || true
rm -rf pxt/node_modules/@types/node || true

# 4) Remove settings overrides that reference non-ESP DAL constants (harmless if absent)
find pxt-common-packages -path '*/settings/targetoverrides.ts' -print0 | xargs -0 rm -f || true

echo "Prune complete. Remaining libs:"
ls -1 pxt-common-packages/libs || true
