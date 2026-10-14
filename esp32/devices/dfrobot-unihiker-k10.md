# DFRobot UNIHIKER K10

Muse firmware for the UNIHIKER K10: ESP32-S3, 16 MB flash, 8 MB octal PSRAM,
and a 2.8-inch 240x320 display. Hold **A** to speak, release to send, and read
Muse's reply on the animated screen. Optional Cartesia streaming speech can
read the reply aloud.

- Hardware and purchase: [DFRobot store](https://www.dfrobot.com/product-2904.html).
- Local purchasing options: [global distributors](https://www.unihiker.com/distributors).
- [DFRobot Muse walkthrough](https://www.unihiker.com/wiki/K10/Playground/muse_unihiker_k10)
  (publication pending).
- Hardware references: [schematic V1.2](https://img.dfrobot.com.cn/wikicn/5cabf4771804207b131ae8cb/36b61e6635492b977df87d55fe5dca4e.pdf)
  and [DFRobot Arduino sources](https://github.com/DFRobot/framework-arduinounihiker).

## Features

| Feature | Behavior |
|---|---|
| Voice requests | Hold A and release to send to Muse |
| Display | Animated avatar, connection status and multilingual captions, including Chinese |
| Speech replies | Optional direct Cartesia TLS WebSocket, streamed 16 kHz mono PCM; requires a personal API Key |
| Sensors | AHT20 temperature/humidity, LTR303 estimated light and SC7A20H raw three-axis acceleration; native `sensors.read` |
| Sensor events | High-humidity messages to Muse with repeat and rearm rules |
| Camera | Muse requests a fresh 640x480 GC2145 JPEG through `camera.capture` |
| USB setup | Single HTML file for SDK Token, optional voice settings and clearing user settings |
| RGB LEDs | Setup, connection, recording, thinking, camera and error status |

No Cartesia key is needed for text replies. Cartesia is disabled until configured.
Speech synthesis sends reply text to Cartesia and uses the user's service
credits. The firmware does not run a computer-side TTS proxy.

## Build and flash

Use **ESP-IDF v6.0.1**, as required by the SDK. Commands below run from
`esp32/`. Connect K10 with its included USB data cable. Native USB Serial/JTAG
is `303a:1001`; it is shared by other ESP32 boards and does not identify K10
on its own. When several boards are attached, specify the verified port.

For a development build, set your SDK Token in the ignored build config,
as described in [the SDK build instructions](../README.md), then use:

```sh
tools/muse/board.sh build k10
tools/muse/board.sh flash k10 YOUR_PORT
```

For distributable firmware with no embedded SDK Token, activate IDF and run:

```sh
idf.py -B build-muse-k10-public -DIDF_TARGET=esp32s3 \
  -DSDKCONFIG=build-muse-k10-public/sdkconfig \
  -DSDKCONFIG_DEFAULTS="sdkconfig.defaults;devices/sdkconfig.muse;devices/sdkconfig.muse-dfrobot-unihiker-k10;devices/sdkconfig.muse-k10-public" build
python tools/muse/package_k10_public.py build-muse-k10-public
```

The audited package is written to `build-muse-k10-public/release/`.
On Windows, the activated IDF PowerShell also supports:

```powershell
./tools/muse/k10.ps1 -Action build
./tools/muse/k10-public.ps1 -Action flash -Port COM10
```

Replace COM10 with your verified port. The scripts require an activated IDF
environment or `IDF_PATH`; they do not assume a particular installation path.
For flashing the four BIN files on Windows, macOS or Linux, see the
[package guide](../tools/muse/K10_PUBLIC_RELEASE.md). Muse uses its own flash
layout. Reflashing Muse preserves NVS; changing from vendor firmware can
require backing up data and clearing the previous layout.

## First-time setup

1. Release BOOT and press RESET once after flashing.
2. Open `release/usb-config/k10-usb-config.html` in desktop Chrome or Edge.
3. Connect K10 and enter your own [Muse Gadgets SDK Token](https://gadgets.muse.ai/settings/sdk-tokens).
   Optionally enter your Cartesia key, Voice ID and language.
4. Choose **Save all settings**. K10 restarts after all entered settings are
   confirmed saved.
5. Enable Developer mode in the phone's Muse app, add K10, press A to confirm,
   and configure Wi-Fi.

Without a valid-format SDK Token, K10 keeps the animated avatar and displays
`USB` / `Set SDK Token first.`. USB setup stays available until restart.
With a token configured, normal startup creates no USB setup task, request
queue or driver buffers. To change settings, press B to open the menu, use B
to select **USB mode**, then press A. Its page stays locked until restart;
background network and speech services continue. Physical buttons are ignored
while USB setup is active. The web page does not toggle DTR/RTS.

Blank Token/Key fields preserve saved settings. Connecting fills the stored
Voice ID and language, without returning the key. Changing either requires
reentering the key. Local validation checks format; Muse verifies the token
during pairing. After clearing all user settings, remove the old device in the
Muse app before adding it again. See the [USB protocol guide](../tools/muse/usb-config/README.md).

## Sensors and events

Hold A and ask, for example, "Read the temperature and humidity from my K10."
Muse invokes `sensors.read`; the firmware returns cached values with units and
`age_s`. Missing, failed or older-than-10-second readings are null. With no
valid readings, the command returns `no_readings`. Measurements run in a
background task, outside the command handler. For local readings, use the
**Sensors** menu page.

Temperature can be affected by board heat. Light is an estimate in lux using
the vendor coefficients. Acceleration is signed raw 12-bit X/Y/Z, not
calibrated g. Ordinary readings are queried on demand.

Humidity events are automatic: above 70% RH, K10 sends a message to Muse
including the value. If it remains above 70%, another reminder is due 15
minutes after the previous successful acknowledgement. At or below 65%,
the initial alert is rearmed. The 65–70% band suppresses sends without
resetting the timer. Only fresh readings are used; reconnecting checks the
current humidity rather than replaying old readings. Failed sends retry after
60 seconds; restart rearms the rule. These messages do not play a local alarm
or take over a voice turn. Rules and additional drivers live in the
[sensor module](../components/muse/sensors/README.md).

## Camera and speech

Point K10 at an object, hold A and ask, "Look at this object and tell me what
it is." Muse decides whether to invoke `camera.capture`; voice uploads do not
automatically include a photo. Keep the camera aimed until capture finishes.
The result contains `data_base64`, `format`, `mime_type`, `width`, `height` and
`bytes`. Capture runs in a worker, then stops the camera and frees its RGB/DMA
buffers. No continuous video is sent. Bright windows can cause overexposure
and a green cast; image-quality tuning remains incomplete. The camera can be
disabled with `CONFIG_MUSE_K10_CAMERA=n`.

Optional speech uses a bounded PCM buffer, prebuffering, cancellation and
verified TLS. No key is embedded in the firmware. If disabled or unavailable,
text captions remain usable. It can be excluded with
`CONFIG_MUSE_K10_CARTESIA=n`. See the [camera](../components/muse/camera/README.md)
and [streaming TTS](../components/muse/tts/README.md) guides.

## Controls and hardware

A confirms pairing, records during normal operation and selects menu items.
B opens/navigates the menu. BOOT is for flashing: GPIO0 is an I2S clock.
Screen sleep can be woken by A/B. Power Off uses deep sleep and requires
RESET to restart. Backlight control is on/off; percentages do not provide PWM
dimming. There is no battery gauge, TF-card support or original offline AI.

RGB: breathing amber for setup/offline, breathing blue for pairing/connecting,
green for ready, blue for recording, breathing purple for thinking/capture,
and breathing red for an error.

| Device | Wiring |
|---|---|
| ILI9341 SPI LCD | MOSI21, SCLK12, CS14, DC13; no touch |
| XL9535 | I2C SDA47/SCL48, address 0x20 |
| Backlight / camera reset | Expander bits 0 / 1 |
| A / B | Expander bits 12 / 2, active low |
| ES7243E ADC | MCLK3, BCLK0, WS38, DIN39; address probed in 0x10–0x17 |
| NS4168 speaker | Shared I2S clocks, DOUT45 |
| WS2812 LEDs | GPIO46, three LEDs, GRB |
| GC2145 camera | D0–D7: 8/10/11/9/18/16/15/6; XCLK7, VSYNC4, HREF5, PCLK17; shared I2C |
| Sensors | AHT20 0x38, LTR303 0x29, SC7A20H 0x19 on the shared I2C bus |

The [feature map](../components/muse/FEATURES.md) lists module boundaries.
Serial diagnostics require USB mode on K10: `>sensors`, `>sensors.muse`,
`>humidity.alert.selftest`, `>sensors.registry.selftest`, and `>camera.capture`.
The corresponding tools are `tools/muse/sensors.py` and `tools/muse/camera.py`.

## Validation

Built with ESP-IDF v6.0.1 and tested on K10 hardware for startup, pairing,
conversation, sensors, camera, streaming speech and USB setup. AIPI Lite was
also rebuilt to check the shared UI changes. Automated coverage includes
sensor freshness, humidity timing, credential storage/error handling,
USB resource lifecycle, command registration, Web Serial and public packaging.
See the checks on the proposed commit for the current CI results.
