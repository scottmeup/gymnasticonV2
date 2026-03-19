#!/usr/bin/env bash
cleanup() {
  echo "[start.sh] Cleanup: restarting bluetooth..."
  systemctl unmask bluetooth 2>/dev/null || true
  systemctl start bluetooth 2>/dev/null || true
}
trap cleanup EXIT

echo "[start.sh] Ensuring bluetooth is running to initialise adapter..."
systemctl unmask bluetooth 2>/dev/null || true
systemctl start bluetooth
sleep 3

echo "[start.sh] Stopping bluetooth..."
systemctl stop bluetooth

echo "[start.sh] Waiting for bluetoothd to fully exit..."
for i in $(seq 1 10); do
  if ! pgrep bluetoothd > /dev/null 2>&1; then
    echo "[start.sh] bluetoothd gone after ${i}s"
    break
  fi
  echo "[start.sh] waiting... ${i}s"
  sleep 1
done
sleep 1

#echo "[start.sh] Bringing hci0 down..."
#hciconfig hci0 down
#sleep 1

echo "[start.sh] Starting Gymnasticon..."
export HCI_CHANNEL_USER=1
export NOBLE_HCI_DEVICE_ID=0
export GYMNASTICON_NOBLE_PROBE_DISABLED=1
export GYMNASTICON_SKIP_SCAN_PROBE=1
exec /usr/bin/node /opt/gymnasticon/src/app/cli.js --config /etc/gymnasticon.json
