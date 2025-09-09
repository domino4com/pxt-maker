// Springbot config.ts — maps logical pins to ESP32-S2 GPIOs
// NOTE: Verify LED matrix mapping (conflict: GPIO3 appears in both rows and columns).

// ----- Power & basics -----
const PIN_VCC = 3.3
// GND is implicit

// ----- Edge connector micro:bit-style labels to GPIO -----
const PIN_P0  = 1;   // 0=gpio1
const PIN_P1  = 9;   // 1=gpio9
const PIN_P2  = 18;  // 2=gpio18
// P3 = nc
const PIN_P4  = 0;   // 4=gpio0 (BOOT)
 // P5 = nc
const PIN_P6  = 46;  // 6=gpio46 (also NFC INT)
 // P7 = UART RXD (U0RXD -> GPIO44)
const PIN_P7  = 44;
const PIN_P8  = -1;  // reset (no GPIO)
 // P9..P12 = nc
const PIN_P13 = 36;  // SCK
const PIN_P14 = 37;  // MISO
const PIN_P15 = 35;  // MOSI
const PIN_P16 = 43;  // UART TXD (U0TXD)

// ----- On-board buttons -----
const PIN_BTN_BOOT  = 0;   // physical BOOT/IO0
const PIN_BTN_A     = 11;  // touch T11
const PIN_BTN_B     = 12;  // touch T12
const PIN_BTN_LOGO  = 13;  // touch T13

// ----- Indicators -----
const PIN_LED_RED      = 17; // back red LED
const PIN_NEOPIXEL     = 39; // back NeoPixel (DIN)

// ----- I2C default -----
const PIN_SDA = 5;
const PIN_SCL = 4;

// ----- SPI (shared with SD) -----
const PIN_MISO = 37;
const PIN_MOSI = 35;
const PIN_SCK  = 36;
const PIN_SD_CS = 34;

// ----- UART0 (USB CDC is primary; mapping for blocks/console) -----
const PIN_TX = 43;  // U0TXD
const PIN_RX = 44;  // U0RXD

// ----- Special / UF2 double-tap memory -----
const PIN_UF2_TAP = 2; // “double reset tap” memory helper

// ----- Sensors -----
const PIN_NTC        = 14; // analog
const PIN_PHOTO      = 16; // analog
const PIN_KX022_INT  = 21; // accel interrupt (KX022 @0x1F)
const PIN_NFC_INT    = 46; // NFC interrupt (ST25DV @I2C, int also on 46)

// ----- Audio -----
const PIN_SPEAKER = 15; // buzzer (PWM capable pin recommended)

// ----- 5x5 LED matrix (ROW anodes, COL cathodes — confirm polarity) -----
const LED_ROW1 = 8;
const LED_ROW2 = 40;
const LED_ROW3 = 10;
const LED_ROW4 = 38;
const LED_ROW5 = 33;

const LED_COL1 = 3;
const LED_COL2 = 42;
const LED_COL3 = 41;
const LED_COL4 = 6;
const LED_COL5 = 7;

// If you confirm the intended mapping, I will fix here and in device.d.ts.

// ----- Convenience aliases used by packages -----
const PIN_LED = PIN_LED_RED;
