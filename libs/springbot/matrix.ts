// Springbot 5x5 LED matrix driver (hardware multiplexing)
// Assumes: rows = active HIGH, columns = active LOW (flip constants if reversed)

// --- POLARITY (flip if your board is opposite) ---
const ACTIVE_ROW = 1;  // drive row HIGH to enable
const INACTIVE_ROW = 0;
const ACTIVE_COL = 0;  // drive column LOW to sink current
const INACTIVE_COL = 1;

// --- pin lists from config.ts ---
const __ROWS = [LED_ROW1, LED_ROW2, LED_ROW3, LED_ROW4, LED_ROW5];
const __COLS = [LED_COL1, LED_COL2, LED_COL3, LED_COL4, LED_COL5];

namespace led {
    let started = false;
    let bright = 255;              // 0..255 global brightness (duty within scan slot)
    const W = 5, H = 5;
    // frame stores per-pixel brightness 0..255 (micro:bit-compatible semantics)
    const frame = pins.createBuffer(W * H);

    function idx(x: number, y: number) { return (y | 0) * W + (x | 0); }
    function clamp01(v: number) { return v <= 0 ? 0 : (v >= 255 ? 255 : v | 0); }

    function gpioSetup() {
        // Initialize rows/cols as outputs and set to inactive
        for (let r = 0; r < 5; r++) {
            pins.digitalWritePin(__ROWS[r], INACTIVE_ROW);
        }
        for (let c = 0; c < 5; c++) {
            pins.digitalWritePin(__COLS[c], INACTIVE_COL);
        }
    }

    // One scan of a single row: light the active pixels in that row
    function driveRow(r: number) {
        // Prepare columns for this row
        // We scale per-pixel against global bright by time slicing within the row slot.
        // To keep it simple/efficient, we threshold against global brightness for now.
        for (let c = 0; c < 5; c++) {
            const v = frame[idx(c, r)];
            // lit if pixel brightness > 0
            pins.digitalWritePin(__COLS[c], v > 0 ? ACTIVE_COL : INACTIVE_COL);
        }
        // Enable row
        pins.digitalWritePin(__ROWS[r], ACTIVE_ROW);
        // Hold time (row dwell). Tune for brightness vs. ghosting; ~300–500 µs works well.
        control.waitMicros(400);
        // Disable row
        pins.digitalWritePin(__ROWS[r], INACTIVE_ROW);
        // Reset columns to inactive to reduce ghosting
        for (let c = 0; c < 5; c++) pins.digitalWritePin(__COLS[c], INACTIVE_COL);
    }

    function start() {
        if (started) return;
        started = true;
        gpioSetup();
        control.inBackground(function () {
            // Simple stable scanner; ~5 * 400us = 2ms per frame => ~500 fps hardware refresh
            while (true) {
                for (let r = 0; r < 5; r++) driveRow(r);
                // If you want to apply global brightness via frame skipping, do it here.
                // (Keeping it steady for now; micro:bit "brightness" maps to pixel intensities too.)
            }
        });
    }

    // --- micro:bit-like API ---

    /**
     * Turn on the LED at (x,y)
     */
    //% blockId=springbot_led_plot block="plot x %x y %y"
    //% group="LED" weight=100
    export function plot(x: number, y: number): void {
        if (x < 0 || x >= W || y < 0 || y >= H) return;
        frame[idx(x, y)] = bright;
        start();
    }

    /**
     * Turn off the LED at (x,y)
     */
    //% blockId=springbot_led_unplot block="unplot x %x y %y"
    //% group="LED" weight=99
    export function unplot(x: number, y: number): void {
        if (x < 0 || x >= W || y < 0 || y >= H) return;
        frame[idx(x, y)] = 0;
        start();
    }

    /**
     * Check if LED at (x,y) is on
     */
    //% blockId=springbot_led_point block="point x %x y %y"
    //% group="LED" weight=98
    export function point(x: number, y: number): boolean {
        if (x < 0 || x >= W || y < 0 || y >= H) return false;
        return frame[idx(x, y)] > 0;
    }

    /**
     * Toggle LED at (x,y)
     */
    //% blockId=springbot_led_toggle block="toggle x %x y %y"
    //% group="LED" weight=97
    export function toggle(x: number, y: number): void {
        if (point(x, y)) unplot(x, y); else plot(x, y);
    }

    /**
     * Set global LED brightness (0-255). Default 255.
     */
    //% blockId=springbot_led_brightness block="set brightness %value"
    //% value.min=0 value.max=255
    //% group="LED" weight=96
    export function brightness(value: number): void {
        bright = clamp01(value);
        start();
    }

    /**
     * Clear all LEDs.
     */
    //% blockId=springbot_led_clear block="clear"
    //% group="LED" weight=95
    export function clear(): void {
        for (let i = 0; i < frame.length; i++) frame[i] = 0;
        start();
    }

    // --- Simple text/number rendering using MakeCode Images ---

    function blitImage(img: Image, ox: number = 0) {
        // Map image pixels (0..255) onto our 5x5 frame (clipped)
        for (let y = 0; y < H; y++) {
            for (let x = 0; x < W; x++) {
                const v = img.pixel(x - ox, y); // non-zero if lit in the image
                if (x >= 0 && x < W && v > 0)
                    frame[idx(x, y)] = bright;
                else if (x >= 0 && x < W)
                    frame[idx(x, y)] = 0;
            }
        }
    }

    /**
     * Show a number on the 5x5 display
     */
    //% blockId=springbot_led_show_number block="show number %n"
    //% group="LED" weight=80
    export function showNumber(n: number): void {
        start();
        const s = n.toString();
        for (let i = 0; i < s.length; i++) {
            const img = images.createImageFromString(s.charAt(i)); // uses built-in 5x5 font
            blitImage(img, 0);
            basic.pause(500);
            clear();
            basic.pause(50);
        }
    }

    /**
     * Show a string on the 5x5 display (scrolling)
     * @param text text to scroll
     * @param delay time per character (ms), eg: 150
     */
    //% blockId=springbot_led_show_string block="show string %text||with delay (ms) %delay"
    //% delay.defl=150
    //% group="LED" weight=79
    export function showString(text: string, delay: number = 150): void {
        start();
        for (let i = 0; i < text.length; i++) {
            const ch = text.charAt(i);
            const img = images.createImageFromString(ch);
            // Scroll left across 5 columns (img is 5x5), 1 col per tick
            for (let ox = -W; ox <= 0; ox++) {
                blitImage(img, ox);
                basic.pause(Math.max(20, delay / 5));
            }
            // small gap
            clear();
            basic.pause(20);
        }
    }
}
