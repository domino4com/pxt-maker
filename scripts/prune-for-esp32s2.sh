#!/bin/bash
# Keep only ESP32-S2 related boards
BOARDS_DIR="libs"
KEEP_BOARD="springbot"

# Remove all other boards except springbot
find $BOARDS_DIR -mindepth 1 -maxdepth 1 -type d ! -name "$KEEP_BOARD" -exec rm -rf {} +
