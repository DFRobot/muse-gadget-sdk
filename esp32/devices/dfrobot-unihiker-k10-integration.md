# K10 integration review

This branch contains the complete existing K10 implementation for review in
the DFRobot fork. It is not an accepted upstream port or a new binary release.

## Source history

- Upstream base: `8e613f77f3a95a63e70cf8be549db9e589105ea0`.
- Existing K10 source: [chunxiaoliu1/muse-unihiker-k10](https://github.com/chunxiaoliu1/muse-unihiker-k10),
  revision `f6926cb04277ed1d07a49ea37e5189b2a5291172`.
- Original SDK base of that implementation:
  `d7e5d22bbd1cb8e6369310f72039247b76942e5a`.

Only the K10 delta was migrated; newer upstream boards, BLE functionality,
power diagnostics and protocol changes were retained. The root SDK overview
and CI files remain in their upstream locations. The K10 user guide is
[`UNIHIKER-K10.md`](../../UNIHIKER-K10.md).

## Included functionality

- Display, avatar, multilingual captions, A/B buttons, microphone, speaker
  and RGB status.
- Muse pairing, Wi-Fi and voice requests.
- Temperature, humidity, light and acceleration through `sensors.read`.
- Device-originated high-humidity messages, including repeat and rearm rules.
- On-demand GC2145 photos through `camera.capture`.
- Optional direct Cartesia PCM streaming speech using the user's key.
- Runtime SDK Token and voice setup over USB, NVS storage, and public-build
  packaging without embedded service credentials.

The [feature map](../components/muse/FEATURES.md) describes module boundaries.

## Validation of this integration

Checked on Windows with ESP-IDF v6.0.1:

- K10 public build and package credential audit: passed. Application image
  `0x301000` bytes in a `0x400000`-byte slot; approximately 25% free.
- AIPI Lite full-UI regression build, in a separate source directory: passed.
  Application image `0x211000` bytes; approximately 48% of its slot free.
- USB JavaScript protocol suite: 18 tests passed.
- K10 Python tests: 10 tests run, 9 passed and 1 skipped because a host C
  compiler was unavailable. The credential, sensor-snapshot and USB-mode C
  harnesses were also skipped for that reason.
- Full upstream Python suite: 406 tests run, 61 errors and 35 skips. This is
  not a passing full-suite result. Errors include missing host compiler/tools,
  unavailable Unix `fcntl`/FIFO APIs, and Windows-specific socket/PPK2 cleanup
  behavior. A Linux/macOS environment with the required dependencies is still
  needed before requesting upstream review.
- New K10 overlay options applied; the empty compile-time SDK Token setting
  is intentionally omitted because the public profile uses runtime-only
  credentials.
- Source publication scan found no non-fixture SDK Tokens, detected API keys,
  or build/log/binary artifacts in the changed files.

On 2026-10-14, the integrated firmware from revision `52d77c8` was flashed to
the K10 on COM10 without erasing NVS. Boot logs confirmed display and audio
initialization, valid temperature/humidity, light and acceleration readings,
and no USB configuration task/driver allocation during configured startup.
The user subsequently reported that functional testing was normal. This is
hardware smoke-test evidence, not a substitute for the pending full host suite.

## Before an upstream contribution

As checked on 2026-10-14, another contributor's
[K10 PR #152](https://github.com/facebookincubator/muse-gadget-sdk/pull/152)
is open. Coordinate scope with its author and the maintainers before
submitting overlapping code. No message or upstream PR is created by this
branch.

A possible review sequence is basic board support, followed by sensors and
events, camera, and optional speech/USB provisioning. This is a proposed
split, not an upstream requirement. Complete the applicable Meta CLA and
validate the submitted scope before requesting upstream review.

Known limitations include camera overexposure/color casts, estimated light
levels, raw acceleration units, no battery gauge, and no integration of the
original offline AI models or TF card. SDK terms and third-party licenses
continue to apply.
