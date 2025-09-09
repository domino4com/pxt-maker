//% color=#4CAF50 weight=100 icon="\uf2db"
declare namespace config {
    const PIN_P0: number;
    const PIN_P1: number;
    const PIN_P2: number;
    const PIN_P4: number;
    const PIN_P6: number;
    const PIN_P7: number;
    const PIN_P13: number;
    const PIN_P14: number;
    const PIN_P15: number;
    const PIN_P16: number;

    const PIN_SDA: number;
    const PIN_SCL: number;

    const PIN_MISO: number;
    const PIN_MOSI: number;
    const PIN_SCK: number;
    const PIN_SD_CS: number;

    const PIN_TX: number;
    const PIN_RX: number;

    const PIN_BTN_BOOT: number;
    const PIN_BTN_A: number;
    const PIN_BTN_B: number;
    const PIN_BTN_LOGO: number;

    const PIN_LED_RED: number;
    const PIN_NEOPIXEL: number;

    const PIN_NTC: number;
    const PIN_PHOTO: number;
    const PIN_KX022_INT: number;
    const PIN_NFC_INT: number;

    const PIN_SPEAKER: number;

    const LED_ROW1: number;
    const LED_ROW2: number;
    const LED_ROW3: number;
    const LED_ROW4: number;
    const LED_ROW5: number;
    const LED_COL1: number;
    const LED_COL2: number;
    const LED_COL3: number;
    const LED_COL4: number;
    const LED_COL5: number;

    // alias
    const PIN_LED: number;
}

// Pin capability types for Springbot
// Expose edge connector pins with common capabilities for blocks
declare interface DigitalInOutPin {}
declare interface PwmPin {}
declare interface AnalogInPin {}
declare interface NeoPixelPin {} // conceptual for blocks

//% fixedInstances
declare const pins: {
    // Edge connector
    P0: AnalogInPin & DigitalInOutPin & PwmPin;
    P1: AnalogInPin & DigitalInOutPin & PwmPin;
    P2: AnalogInPin & DigitalInOutPin & PwmPin;
    P4: DigitalInOutPin & PwmPin;
    P6: DigitalInOutPin & PwmPin; // also NFC INT
    P7: DigitalInOutPin;          // UART RX (avoid PWM/Analog by default)
    P13: DigitalInOutPin & PwmPin; // SCK
    P14: DigitalInOutPin;          // MISO
    P15: DigitalInOutPin & PwmPin; // MOSI
    P16: DigitalInOutPin;          // UART TX

    // I2C default
    SDA: DigitalInOutPin;
    SCL: DigitalInOutPin;

    // SPI / SD
    MOSI: DigitalInOutPin & PwmPin;
    MISO: DigitalInOutPin;
    SCK: DigitalInOutPin & PwmPin;
    SD_CS: DigitalInOutPin;

    // On-board IO
    LED: DigitalInOutPin & PwmPin;     // red LED
    NEOPIXEL: DigitalInOutPin;         // NeoPixel DIN
    BTN_BOOT: DigitalInOutPin;
    BUTTON_A: DigitalInOutPin;         // touch A
    BUTTON_B: DigitalInOutPin;         // touch B
    BUTTON_LOGO: DigitalInOutPin;      // touch Logo

    NTC: AnalogInPin;
    PHOTO: AnalogInPin;
    KX022_INT: DigitalInOutPin;
    NFC_INT: DigitalInOutPin;

    SPEAKER: PwmPin;

    // LED matrix wiring (internal use by matrix driver)
    LED_ROW1: DigitalInOutPin; LED_ROW2: DigitalInOutPin; LED_ROW3: DigitalInOutPin; LED_ROW4: DigitalInOutPin; LED_ROW5: DigitalInOutPin;
    LED_COL1: DigitalInOutPin; LED_COL2: DigitalInOutPin; LED_COL3: DigitalInOutPin; LED_COL4: DigitalInOutPin; LED_COL5: DigitalInOutPin;

    // UART aliases
    TX: DigitalInOutPin;
    RX: DigitalInOutPin;
}

// Built-in buttons for events category
//% fixedInstances
declare const input: {
    buttonA: Button;
    buttonB: Button;
    // You can add Logo as a third logical button if desired:
    logo: Button;
}
