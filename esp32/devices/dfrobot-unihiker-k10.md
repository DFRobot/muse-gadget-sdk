# DFRobot UNIHIKER K10

Basic board support for the UNIHIKER K10: ESP32-S3, 16 MB flash, 8 MB octal
PSRAM and a 2.8-inch 240x320 ILI9341 display. This port uses the SDK's existing
pairing, Wi-Fi, voice-input, reply-caption and menu flows.

- [Official product and purchase](https://www.dfrobot.com/product-2904.html)
- [Global distributors](https://www.unihiker.com/distributors)
- [DFRobot Arduino sources](https://github.com/DFRobot/framework-arduinounihiker)
- [Hardware schematic](https://www.unihiker.com/wiki/K10/HardwareReference/img/hardwarereference_onboard/UnihikerK10Schematic.pdf)

## Included functionality

- Phone pairing and Wi-Fi through the Muse app.
- Animated display and text replies.
- A-button voice input and pairing confirmation; B-button menu controls.
- ES7243E microphone and NS4168 speaker drivers using the existing audio path.
- Three RGB LEDs for setup, connection, recording, thinking and errors.

The [full-feature branch](https://github.com/DFRobot/muse-gadget-sdk/tree/muse-unihiker-k10-full)
adds sensors, humidity events, camera capture, optional streaming TTS and USB
credential setup. Its [Muse walkthrough](https://www.unihiker.com/wiki/K10/Playground/muse_unihiker_k10)
describes those additional features. They are not part of this basic port.

## Build, token and flashing

Use ESP-IDF v6.0.1 and run commands from `esp32/`. The included USB data cable
connects to the ESP32-S3's native USB Serial/JTAG (`303a:1001`). Several ESP32
boards share that ID; verify the board and port before flashing.

On Linux or macOS, use the existing helper:

```sh
tools/muse/board.sh build k10
tools/muse/board.sh flash k10 YOUR_PORT
```

On Windows, run this command on one line in an activated IDF PowerShell:

```powershell
idf.py -B build-muse-dfrobot-unihiker-k10 -DIDF_TARGET=esp32s3 -DSDKCONFIG=build-muse-dfrobot-unihiker-k10/sdkconfig "-DSDKCONFIG_DEFAULTS=sdkconfig.defaults;devices/sdkconfig.muse;devices/sdkconfig.muse-dfrobot-unihiker-k10" build
```

This basic port uses the SDK's existing compile-time Token configuration.
Set `CONFIG_GADGET_SDK_TOKEN` in the ignored build-directory `sdkconfig`, or
run the same `idf.py` command with `menuconfig` in place of `build`, and rebuild.
Get your own Token from [Muse Gadgets](https://gadgets.muse.ai/settings/sdk-tokens).
Keep it out of the board overlay and commits. There is no USB Token setup page
in this branch. A build without a Token emits the SDK's standard warning;
configure one before attempting pairing.

For manual flashing, run the same `idf.py` arguments with `-p YOUR_PORT flash`
in place of `build`. If the device does not enter the bootloader, hold BOOT,
press RESET, then release BOOT. After flashing, release BOOT and press RESET
once to boot normally. Flashing from another firmware may require backing up
its data and clearing its previous partition layout. Reflashing Muse preserves
NVS. See the [SDK flashing instructions](../README.md).

## Use

Enable Developer mode in the Muse phone app, add K10, press A to confirm,
and configure Wi-Fi. Hold A while speaking and release it to send. Muse's
reply appears as text. B opens or advances the menu; A selects its item.
The stock speaker path can play the SDK's existing audio cues and diagnostics;
this basic port does not synthesize spoken replies.

RGB: breathing amber for setup/offline, breathing blue for pairing/connecting,
green for ready, blue for recording, breathing purple for thinking, and
breathing red for errors.

## Hardware and limits

| Device | Wiring |
|---|---|
| ILI9341 LCD | SPI MOSI21, SCLK12, CS14, DC13; no touch |
| XL9535 | I2C SDA47/SCL48, address 0x20 |
| Backlight / unused camera reset | Expander bits 0 / 1 |
| A / B | Expander bits 12 / 2, active low |
| ES7243E ADC | MCLK3, BCLK0, WS38, DIN39; address probed in 0x10–0x17 |
| NS4168 speaker | Shared I2S clocks, DOUT45 |
| WS2812 RGB | GPIO46, three LEDs, GRB |

BOOT/GPIO0 is an I2S clock, so use A for talking. Backlight control is on/off;
brightness percentages do not provide PWM dimming. Screen sleep can be woken
by A/B. Power Off enters deep sleep and requires RESET to restart. There is no
battery gauge. Sensors, camera, TF card and original offline AI models are
not integrated in this profile.

The board driver derives from the K10 adapter exercised on hardware in the
full-feature firmware. This basic profile was also built and flashed to K10;
runtime USB status confirmed the board identity and retained pairing settings.
End-to-end pairing and voice conversation have not yet been retested for this
reduced profile.
