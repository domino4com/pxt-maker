# Springbot (ESP32-S2)

Springbot is a micro:bit-style board based on **ESP32-S2** with:
- **5×5 LED matrix**
- **Touch buttons**: A (T11/GPIO11), B (T12/GPIO12), Logo (T13/GPIO13)
- **Back LEDs**: Red (GPIO17), NeoPixel DIN (GPIO39)
- **Buzzer**: GPIO15
- **I²C** devices:
  - KX022 accelerometer @ `0x1F` (INT -> GPIO21)
  - SSD1306 128×64 OLED @ `0x3C`
  - ST25DV04K NFC (INT -> GPIO46)
- **SPI (SD card)**: MOSI=GPIO35, MISO=GPIO37, SCK=GPIO36, CS=GPIO34
- **UART0**: TX=GPIO43, RX=GPIO44
- **UF2 bootloader** with **WebUSB** for one-click flashing in Chrome.

**I²C defaults:** SDA=GPIO5, SCL=GPIO4

> To flash from the browser:
> 1. Use Chrome/Edge (desktop/Android/Chromebook).
> 2. Click **Pair device** and select Springbot.
> 3. Click **Download** to program via WebUSB.
