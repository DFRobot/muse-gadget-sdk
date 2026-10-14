"""Print K10 sensor snapshots without resetting it: sensors.py COM10 [seconds]."""
import json
import argparse
import time
import serial

parser = argparse.ArgumentParser(description='Read K10 sensors in USB mode without resetting the device.')
parser.add_argument('port', help='verified K10 serial port')
parser.add_argument('seconds', type=float, nargs='?', default=10)
args = parser.parse_args()
with serial.Serial() as console:
    console.port, console.baudrate, console.timeout = args.port, 115200, 0.3
    console.dtr = console.rts = False
    console.open()
    console.write(b'>sensors\n')
    end = time.monotonic() + args.seconds
    pending = bytearray()
    while time.monotonic() < end:
        pending.extend(console.read(4096))
        while b'\n' in pending:
            raw, _, rest = pending.partition(b'\n')
            pending = bytearray(rest)
            if raw.startswith(b'@sensors '):
                try:
                    print(json.dumps(json.loads(raw[9:]), ensure_ascii=False), flush=True)
                except (ValueError, UnicodeError):
                    pass
