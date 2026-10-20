# Connect UNIHIKER K10 to Muse

Turn your UNIHIKER K10 into a Muse desktop companion that can talk with you, sense its surroundings, and look at objects.

Once setup is complete, hold the **A button** to speak, then release it to send your question to Muse. Replies appear on the screen. With the optional speech service configured, K10 can also read them aloud. You can ask Muse to read K10's temperature, humidity, light, and acceleration sensors, or use its camera to take a photo and identify an object.

This guide covers the **Muse K10 full firmware**. If it is already installed on your device, start with [Set up your SDK Token](#3-set-up-your-sdk-token).

For the minimal board port, see the [basic branch guide](https://github.com/DFRobot/muse-gadget-sdk/blob/muse-unihiker-k10-basic/esp32/devices/dfrobot-unihiker-k10.md). Build instructions, hardware wiring, and module details are available in the [developer reference](#13-developer-reference) below.

## 1. Before you start

For usage instructions and demonstrations on the UNIHIKER website, see the [K10 Muse walkthrough](https://www.unihiker.com/wiki/K10/Playground/muse_unihiker_k10/).

### What you need

| Item | Details |
|---|---|
| UNIHIKER K10 | The firmware in this guide is for K10 only |
| USB data cable | Included with K10; used for flashing, setup, and power |
| Computer | Windows, macOS, or Linux; use desktop Chrome or Edge for USB setup |
| Phone with the Muse app | You need a working Muse account and access to Developer mode |
| Wi-Fi | A 2.4 GHz network that can reach Muse services; a computer hotspot also works if set to 2.4 GHz |
| Muse Gadgets SDK Token | Required; obtain one through your own account |
| Cartesia API Key | Optional; needed only if you want K10 to read replies aloud |

Where to buy K10: [DFRobot store](https://www.dfrobot.com/product-2904.html) · [Global distributors](https://www.unihiker.com/distributors).

Before setting up K10, send a message in the Muse app on your phone and check that your account receives a reply.

### What you can do

| Feature | How to use it |
|---|---|
| Voice input | Hold A to speak, then release to send |
| On-screen replies | View the Muse avatar, connection status, and reply text |
| Spoken replies | Configure Cartesia to read Muse's text replies aloud |
| Temperature and humidity | Ask for K10's current temperature and humidity readings |
| Light readings | Ask for the ambient light level measured by K10 |
| Acceleration readings | Ask for K10's three-axis acceleration readings |
| Humidity reminders | K10 automatically sends Muse a message when humidity exceeds the threshold |
| Camera recognition | Point at an object and ask, "Use K10's camera and tell me what this is" |
| USB setup | Use one HTML file to configure credentials and speech, or clear settings |
| Device settings | Adjust volume, speaker, and sleep settings; view sensors and connection status |

## 2. Download and flash the firmware

### 2.1 Download the full firmware package

Open the [K10 full firmware release page](https://github.com/DFRobot/muse-gadget-sdk/releases/tag/k10-full-v0.1.0) and download this file under **Assets**:

**`unihiker-k10-muse-full-firmware-v0.1.0.zip`**

Extract the ZIP before continuing. It contains:

```text
firmware/
  bootloader.bin
  partition-table.bin
  ota_data_initial.bin
  muse-gadget.bin
usb-config/
  k10-usb-config.html
README.md
SHA256SUMS.txt
licenses/
```

The four BIN files in `firmware/` are used for flashing. Use `k10-usb-config.html` to configure your device afterward. The remaining files contain instructions, checksums, and licenses; you do not flash them to K10.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/ae153dc452d736b2f25a6255251a332e.png" alt="GitHub release assets with the UNIHIKER K10 Muse full firmware v0.1.0 download highlighted." width="1000" />
</p>

### 2.2 Put K10 into download mode

1. Connect K10 to your computer with the USB data cable.
2. Hold **BOOT**.
3. While holding BOOT, press **RESET** once.
4. Release BOOT.

K10 is now in download mode and ready to flash. On Windows, check Device Manager for its serial port, such as `COM10`. Use the port shown on your own computer.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/3c3d5f78b1bd6a411e30d17fc63afd0e.png" alt="Back of UNIHIKER K10 with the USB connector and A, B, BOOT, and RST buttons outlined." width="500" />
</p>

### 2.3 Firmware files and flash addresses

The full firmware package contains four BIN files. Flash all four at their corresponding addresses:

| File | Address |
|---|---|
| `firmware/bootloader.bin` | `0x0` |
| `firmware/partition-table.bin` | `0x10000` |
| `firmware/ota_data_initial.bin` | `0x1D000` |
| `firmware/muse-gadget.bin` | `0x20000` |

**Make sure each file is assigned to the correct address.** Both flashing methods below use these same addresses.

### 2.4 Choose a flashing method

**Option 1: Windows graphical tool**

Use Espressif's [Flash Download Tools](https://www.espressif.com/en/support/download/other-tools). Select **ESP32-S3**, add the four files and addresses from the table above, and check all four rows.

Set **SPI MODE: DIO** and **SPI SPEED: 80 MHz**. Select K10's serial port, choose a baud rate such as `1152000`, and start flashing.

Do not flash `muse-gadget.bin` by itself at `0x0`. Before switching from the factory firmware to Muse, back up any programs or files you want to keep. A full flash erase deletes existing data and settings. Later updates to Muse firmware usually do not require a full erase.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/6c301520f8ef6755a4daad95d0037710.png" alt="ESP Flash Download Tool with four K10 firmware files and offsets, DIO, 80 MHz selected, and DoNotChgBin enabled." width="500" />
</p>

**Option 2: Command line on Windows, macOS, or Linux**

If Python is installed, open a terminal and install esptool:

```sh
python -m pip install esptool
```

List the available serial ports:

```sh
python -m serial.tools.list_ports
```

Open a terminal in the extracted firmware package folder. Run the following as one line, replacing `YOUR_PORT` with K10's actual serial port:

```sh
python -m esptool --chip esp32s3 --port YOUR_PORT --baud 460800 write-flash --flash-mode dio --flash-freq 80m --flash-size 16MB 0x0 firmware/bootloader.bin 0x10000 firmware/partition-table.bin 0x1d000 firmware/ota_data_initial.bin 0x20000 firmware/muse-gadget.bin
```

A Windows port might be `COM10`. On macOS, look for `/dev/cu.usbmodem…`; on Linux, it is often `/dev/ttyACM0`. If your system uses `python3`, replace `python` with `python3` in these commands.

### 2.5 Start K10 normally

After flashing, **press RESET once**.

On first startup, the screen displays the Muse avatar with `USB` and `Set SDK Token first.` at the top.

This means the firmware is running and waiting for you to configure your own SDK Token.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/4efc1c365e8de01e4a89fc3aa2bbc1d4.png" alt="K10 first-start screen showing the Muse avatar and the USB prompt: Set SDK Token first." width="500" />
</p>

## 3. Set up your SDK Token

### 3.1 Get your own SDK Token

Sign in to [Muse Gadgets](https://gadgets.muse.ai) with your Muse account. Go to **Account → SDK tokens**, create a token, and copy it.

The token starts with `mgst_`. It is separate from the optional Cartesia API Key described later. Enter each credential in its corresponding field. Do not use a token from a tutorial screenshot or someone else's account.

### 3.2 Open the USB setup tool

1. Keep K10 connected to your computer over USB.
2. Open `usb-config/k10-usb-config.html` from the downloaded package in desktop **Chrome or Edge**.
3. Click **Connect K10**.
4. Select K10 in the browser's serial port chooser and connect.

This is a standalone HTML file. You can usually open it directly without running a server. First close any flashing tool, serial monitor, or other setup page that is using K10's serial port.

If your browser blocks serial access from a local file, open a terminal in the `usb-config` folder and run:

```sh
python -m http.server 8766 --bind 127.0.0.1
```

Then open `http://localhost:8766/k10-usb-config.html` in Chrome or Edge. Keep the terminal running during setup; you can close it afterward.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/29e9f82ec14890089e7e0f1f5e215c25.png" alt="K10 USB setup page with the Connect K10 button highlighted to open the serial port chooser." width="500" />
</p>

### 3.3 Save and restart

Paste your token into **2 · SDK Token**.

For your first setup, you can skip **3 · Voice replies (optional)** and start with text replies. To enable spoken replies, follow [Have K10 read replies aloud](#7-have-k10-read-replies-aloud-optional).

Click **Save all settings** at the bottom of the page. K10 automatically restarts after all the settings you entered have been saved successfully. It is normal for the page to disconnect during the restart.

Your token is saved on the device and remains stored after a restart or power loss. An empty token field afterward does not mean it was erased; reconnect to check the configuration status.

After a successful initial setup, K10 displays `SET UP WI-FI` and `MuseGadget-XXXXXX` at the top of the screen. The suffix varies by device.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/877b13e81a8a504ca61668770fb077fd.png" alt="Save all settings button highlighted at the bottom of the K10 USB setup page." width="500" />
</p>

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/efebffac10281d60669e063dad4ba541.png" alt="K10 displaying SET UP WI-FI and device name MuseGadget-A7EA4C above the Muse avatar, ready for app setup." width="500" />
</p>

## 4. Pair in the Muse app and connect to Wi-Fi

1. Enable Bluetooth on your phone and grant the Bluetooth or nearby-device permissions requested by Muse.
2. In the Muse app, go to **Settings → Devices** and enable **Developer mode**.
3. Select **Add Device** or the **+** button in the upper-right corner.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/b31b16894ed52cf4bfd5efdc585e8808.png" alt="Muse app Devices screen with Developer Mode enabled and the add-device plus button highlighted." width="500" />
</p>

4. Select `MuseGadget-XXXXXX` from the list. Match its suffix to the name at the top of K10's screen.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/9588bf1fccad21f2605764418b70df5d.png" alt="Muse app Connect a Device screen listing MuseGadget-A7EA4C with a Connect button." width="500" />
</p>

5. When the app or K10 asks for confirmation, **press K10's A button once**.

<p align="center">
  <img src="https://dfimg.dfrobot.com/60191ece025a892c98c6b90b/wikien/d42930577c144714b0533f575c76916d.png" alt="Muse app pairing prompt for MuseGadget-A7EA4C asking for a button press on the device; press A on K10." width="500" />
</p>

6. Follow the app's prompts to select a 2.4 GHz Wi-Fi network, enter its password, and wait for K10 to connect.

Once connected, K10's RGB LEDs are normally green and the screen shows `READY`. You can now start a conversation.

**If you previously cleared all settings on K10, remove the old K10 device from the Muse app before adding it again.** Clearing only the device's settings can leave an old record in the app and cause pairing to get stuck on connecting.

## 5. Start a voice conversation

1. **Hold K10's A button**.
2. Say, "Introduce yourself in one sentence."
3. **Release A** when you finish speaking to send the question.
4. Wait for Muse's reply and read it on the screen.

If spoken replies are configured, K10 reads the answer aloud once the audio is ready. During normal operation, pressing A while audio is playing interrupts playback and lets you start a new question.

You do not need to press B or open a menu first. Voice input uses push-to-talk; a wake word alone does not start recording.

After setup, you do not need to keep any companion program running on your computer. K10 can continue working as long as it has power, a network connection, and access to Muse services.

## 6. Use the sensors

### 6.1 Ask Muse directly

Hold A to ask a question, then release to send. Try:

> "Read K10's sensors and tell me the current temperature and humidity."
>
> "Use K10's light sensor to check how bright it is here."
>
> "Read K10's three-axis acceleration."

Muse requests sensor data from K10 as needed and uses the readings in its answer. Include "read K10's sensors" if you want to make clear that it should use actual measurements.

| Reading | What it means |
|---|---|
| Temperature | Measured in °C; heat from the board can affect the reading |
| Humidity | Measured in % RH, or relative humidity |
| Light | Measured in lux; useful for observing changes in ambient light |
| Acceleration | Raw X, Y, and Z readings, not calibrated values in g |

Invalid or expired readings are not supplied to Muse as valid measurements. If no readings are available, try again shortly.

### 6.2 View readings on K10

You can also view the local sensor page without asking Muse online:

1. Press **B** to open the menu.
2. Keep pressing **B** until **Sensors** is selected.
3. Press **A** to open the readings page.
4. Press **A or B** to return to the menu. Select **Close menu** to return to the main screen.

### 6.3 Automatic high-humidity reminders

K10 monitors humidity in the background using these rules:

| Humidity condition | Behavior |
|---|---|
| Above 70% RH | Send Muse a high-humidity message with the measured value |
| Still above 70% RH | Remind again 15 minutes after the last successfully delivered reminder |
| At or below 65% RH | Rearm the initial reminder, so the next rise above 70% can trigger it immediately |
| Above 65% and at or below 70% RH | Pause reminders without rearming the initial reminder |

You do not need to ask a question to trigger this feature, but K10 must be online and connected to Muse. It sends a message to Muse; **it does not automatically sound a local alarm on K10**. Phone notifications also depend on the Muse app and your phone's notification settings.

These rules are built into the firmware. The HTML tool currently cannot change the thresholds or reminder interval. Restarting K10 starts the rule again. Do not spray water on the board or cause condensation to test humidity. Covering the temperature and humidity sensor at K10's upper-right corner with a finger can quickly raise its reading.

This feature demonstrates how a device can proactively report events to an agent. With AI coding tools such as Muse Code or Codex, you can also adapt the source code to add more sensors or event rules.

## 7. Have K10 read replies aloud (optional)

### 7.1 Get a Cartesia API Key and Voice ID

K10 uses the online Cartesia service for speech synthesis. Without it, voice questions and on-screen text replies still work.

1. Sign in to [Cartesia](https://play.cartesia.ai/keys) and create your own key on the API Keys page.
2. Preview voices in Cartesia's voice library or Playground.
3. Choose a voice that supports your target language and copy its **Voice ID**.

The API Key authorizes access to the service; the Voice ID selects the voice. They are not interchangeable. The HTML tool includes this default Voice ID, which you can replace with your preferred voice:

```text
db6b0ed5-d5d3-463d-ae85-518a07d3c2b4
```

Check your Cartesia account for current credits, voice access, and pricing.

### 7.2 Save speech settings in the HTML tool

If you have already configured K10's SDK Token:

1. Press **B** on K10 to open the menu.
2. Use **B** to select **USB mode**, then press **A** to enter.
3. Wait until the screen shows **USB mode: On**.
4. Open the HTML tool on your computer and click **Connect K10**.

You do not need to enter **2 · SDK Token** again. Go directly to **3 · Voice replies (optional)** and fill in:

| Field | What to enter |
|---|---|
| Cartesia API Key | Your own Cartesia API Key |
| Voice ID | A voice that supports your target language; you can try the prefilled value first |
| Reply language | The language Muse actually uses in its replies |

**Reply language must match the language Muse uses, and the selected Voice ID must support that language. A mismatch can prevent voice playback.** For English replies, select **English** and use a voice that supports English.

Click **Save all settings** and wait for K10 to restart automatically. Then hold A to ask a question and check that the answer appears on the screen and is read aloud.

K10 receives and plays the audio as a stream directly from the online service. No computer-side TTS service is required. Muse generates the reply before Cartesia synthesizes it, so there can still be a delay before speech starts. Network fluctuations can also cause pauses.

Enabling this feature sends Muse's reply text to Cartesia and uses your service credits.

### 7.3 Test, change, or disable speech

- **Test speech:** After saving and restarting, make sure K10 is online and **Speaker** is enabled. Enter USB mode again, connect the HTML tool, and click **Test voice**. Testing uses Cartesia credits. Click **Refresh status** to check the result. The built-in test sentence is in English; if you configure Chinese, also test an actual Chinese conversation.
- **Change the voice or language:** Enter your Cartesia API Key again, change the Voice ID or Reply language, and click **Save all settings**.
- **Disable speech:** Click **Disable voice replies**, then **Restart device** to apply the change. Text replies remain available.

## 8. Identify objects with the camera

1. Point **K10's camera** at the object.
2. Hold **A** and ask, "Can you look at this and tell me what it is?"
3. Release A to send your question and keep the camera pointed at the object.
4. Wait for Muse to request a photo, receive the image, and answer.

The process is:

**You ask a question → Muse requests an image when needed → K10 takes and uploads a photo → Muse analyzes it and replies.**

Voice questions do not automatically include a photo. If the answer does not use a current image, explicitly ask, "Use K10's camera to take a new photo." Muse decides whether to request a capture.

The current firmware captures single **640 × 480** images. It does not provide a live viewfinder or continuous video. Keep K10 and the object still, and use even indoor lighting. Avoid pointing directly at bright windows or strong light sources: the current version can produce overexposed or color-shifted images in these conditions, affecting recognition.

## 9. Buttons, menu, and RGB status LEDs

### Button reference

| Situation | Action |
|---|---|
| Ask a question from the main screen | Hold A to record, then release to send |
| Confirm pairing | Press A once |
| Open the menu or move to the next item | Press B |
| Activate a menu item | Press A |
| Return to the main screen | Select Close menu, then press A |
| Leave USB mode | Save settings to restart automatically, press RESET, or click Restart device |
| Enter download mode for flashing | Hold BOOT, press RESET once, then release BOOT |

Common menu items:

| Item | Purpose |
|---|---|
| Volume | Adjust volume; press A to cycle through the levels |
| Sensors | View temperature, humidity, light, and acceleration |
| USB mode | Enter USB setup |
| Speaker | Turn the speaker on or off |
| Mic gain | Adjust microphone gain |
| Auto-sleep | Change the automatic screen-off delay |
| Wi-Fi | Turn Wi-Fi on or off |
| Status | View connection status and other information |
| Reset pairing | Clear Wi-Fi and app pairing, then restart; SDK Token and TTS settings are kept |
| Screen off | Turn off the screen; press a button to wake it |
| Power off | Enter a low-power off state; press RESET to start again |
| Close menu | Return to the main screen |

The **Brightness** setting does not provide continuous brightness adjustment in the current K10 firmware. The **Battery** page also does not provide a valid battery level.

### RGB LED reference

| LED pattern | Usually means |
|---|---|
| Breathing amber | Waiting for setup or offline |
| Breathing blue | Pairing or connecting |
| Green | Ready for a conversation |
| Blue | Recording |
| Breathing purple | Waiting for processing or capturing a photo |
| Breathing red | An error occurred |

Use the LEDs together with the screen messages and Muse app status to understand what is happening.

## 10. Change settings or switch accounts

### Reopen USB setup

Once an SDK Token has been saved, K10 starts in normal operating mode. To change settings, enter **USB mode** from K10's menu before connecting the HTML tool.

Entering USB mode **does not automatically restart K10**. The screen stays on the USB page, and the buttons are temporarily unavailable for other actions. Network and speech services may continue in the background. Clicking **Disconnect** in the page does not leave USB mode; restart K10 to exit.

### HTML tool buttons

| Button | Purpose |
|---|---|
| Connect K10 | Select a serial port and connect to K10 |
| Disconnect | Release the serial port used by the page |
| Refresh status | Read the current configuration and speech status again; does not save your entries or restart K10 |
| Restart device | Restart K10 to apply pending changes or leave USB mode |
| Save all settings | Save the SDK Token and speech settings you entered, then restart automatically once all saves succeed |

Leaving the SDK Token or API Key field blank keeps the corresponding settings already saved on K10. It does not delete them. If TTS is already configured, changing the voice or language still requires entering the API Key again.

### Clear settings

Expand **Clear settings or switch accounts** in the HTML tool:

| Option | Result |
|---|---|
| Clear SDK Token only | Clear only the SDK Token, effective after a restart; keep Wi-Fi, pairing, and speech settings |
| Clear all user settings | Clear the SDK Token, Wi-Fi, Muse pairing, and Cartesia settings, then request a restart |

Before switching Muse accounts or giving K10 to someone else, choose **Clear all user settings** and remove the old device from the original Muse app. Then configure and pair it using the new user's own token.

Clearing a token from K10 does not revoke it on the website. Simply reflashing Muse firmware does not automatically clear existing settings either.

## 11. Troubleshooting

### The HTML tool cannot connect to K10

Use desktop Chrome or Edge and the USB cable included with K10. If using another cable, make sure it supports data transfer. Select the correct serial port and close other serial tools or connected setup pages.

If an SDK Token is already configured, enter **USB mode** first. If you just flashed the firmware, release BOOT and press RESET once to leave download mode before connecting the HTML tool.

### The page disconnects after saving

K10 automatically restarts after successfully saving all settings, so a disconnect is expected. With a token configured, enter USB mode again after the restart to reconnect the setup page.

### The Muse app stays on connecting or K10 cannot join Wi-Fi

Check Developer mode, your phone's Bluetooth permissions, pairing confirmation with K10's A button, and the 2.4 GHz Wi-Fi network name and password. If you cleared K10's settings, remove the old device from the app before adding it again. Keep computer hotspots enabled and prevent the computer from sleeping and turning the hotspot off.

### The Muse app says it disconnected Muse to protect your information

Follow the app's instructions to submit a recovery ticket through the official support entry point. Make sure Muse can chat normally on your phone before troubleshooting K10. Reflashing K10 cannot fix a Muse account service or account-linking issue.

### Replies appear on the screen, but there is no sound

This is expected if Cartesia is not configured. If it is configured, check that:

- **Speaker** is enabled and **Volume** is above 0.
- The API Key is valid, and the Cartesia account has available credits and access to the selected voice.
- **Reply language** matches Muse's reply language, and the Voice ID supports it.
- Settings have been saved and K10 has restarted, and K10 can reach Cartesia services.

Try a short reply first. Text replies remain available if speech fails.

### Can I disable speech by deleting the text in the API Key field?

No. Leaving the field blank preserves saved settings. Click **Disable voice replies**, then restart K10.

### Camera recognition is inaccurate, or no photo is taken

Explicitly ask Muse to use K10's camera to take a photo. Keep the camera pointed at the object and avoid obstructions, movement, and strong backlighting. If no photo is requested, Muse may answer using only the text. If the image is overexposed or color-shifted, try again under even indoor lighting.

### Humidity is above 70%, but reminders are not sent continuously

K10 must be online and connected to Muse. While humidity remains high, it does not send a message for every sensor sample: reminders are spaced 15 minutes after the last successful delivery, and are sent only while humidity is above 70%. Humidity must drop to 65% or below to rearm a new initial reminder.

### Do I need to set up K10 again after a power loss?

Normally, no. The SDK Token, Wi-Fi, Muse pairing, and Cartesia configuration are retained. The humidity reminder timing starts again after a restart.

### Does K10 need to stay connected to a computer?

No. The computer is needed only for flashing and USB setup. Afterward, close the HTML tool, power K10 from a suitable USB supply, and keep it connected to the network. Speech does not require a computer-side proxy either.

### Can I still use K10's original offline AI or TF card features?

This Muse firmware provides the functions described above. It does not include the factory firmware's offline AI or TF card features. To use those features, follow K10's instructions to restore the factory firmware, and back up any data you want to keep first.

## 12. Links

- [K10 Muse full firmware download](https://github.com/DFRobot/muse-gadget-sdk/releases/tag/k10-full-v0.1.0)
- [K10 Muse full firmware source](https://github.com/DFRobot/muse-gadget-sdk/tree/muse-unihiker-k10-full)
- [Muse Gadgets SDK Token management](https://gadgets.muse.ai/settings/sdk-tokens)
- [Cartesia API Key management](https://play.cartesia.ai/keys)
- [K10 Muse Wiki](https://www.unihiker.com/wiki/K10/Playground/muse_unihiker_k10/)
- [K10 product page](https://www.dfrobot.com/product-2904.html)
- [Global distributors](https://www.unihiker.com/distributors)

## 13. Developer reference

K10 uses an ESP32-S3 with 16 MB flash, 8 MB octal PSRAM, and a 2.8-inch 240x320 display.

Hardware references: [English schematic](https://www.unihiker.com/wiki/K10/HardwareReference/img/hardwarereference_onboard/UnihikerK10Schematic.pdf) and [DFRobot Arduino sources](https://github.com/DFRobot/framework-arduinounihiker).

### Build and flash


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

### Sensors and events


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

### Camera and speech


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

### Controls and hardware


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

### USB configuration behavior

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

### Validation record


Built with ESP-IDF v6.0.1 and tested on K10 hardware for startup, pairing,
conversation, sensors, camera, streaming speech and USB setup. AIPI Lite was
also rebuilt to check the shared UI changes. Automated coverage includes
sensor freshness, humidity timing, credential storage/error handling,
USB resource lifecycle, command registration, Web Serial and public packaging.
