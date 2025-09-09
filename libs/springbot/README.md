# Springbot board (ESP32-S2)

This folder defines the Springbot board for MakeCode Maker:
- `boardhd.svg`  → source SVG for Board Designer
- `board.svg`    → minified SVG used by the editor
- `board.json`   → pin/part positions (generated)
- `config.ts`    → GPIO mapping and aliases
- `device.d.ts`  → pin capabilities and fixed instances
- `pxt.json`     → board metadata and card

**Notes**
- LED matrix row/col mapping has a reported conflict (GPIO3 listed in both); fix in `config.ts` once confirmed.
- Place a 90×90 thumbnail at `docs/static/libs/springbot.jpg` to show in the board picker.
