#!/bin/bash

set -euo pipefail

DRIA_SERVICE_PATH="/etc/systemd/system/dria.service"
WATCHDOG_SERVICE_PATH="/etc/systemd/system/dria-watchdog.service"
WATCHDOG_SCRIPT="/usr/local/bin/dria-watchdog.sh"
LAUNCHER_BIN="/usr/local/bin/dkn-compute-launcher"

echo "[+] Starting Dria systemd service installation..."

# --- Install dria launcher if missing ---
if [[ ! -x "$LAUNCHER_BIN" ]]; then
    echo "[!] Dria launcher not found at $LAUNCHER_BIN"
    echo "[+] Installing Dria launcher..."
    curl -fsSL https://dria.co/launcher | bash

    if [[ ! -x "$LAUNCHER_BIN" ]]; then
        echo "[✗] Installation failed or binary still missing."
        exit 1
    fi

    echo "[✓] Dria launcher installed successfully."
fi

# --- Create dria.service ---
cat > "$DRIA_SERVICE_PATH" <<EOF
[Unit]
Description=Dria compute launcher
After=network.target

[Service]
Type=simple
ExecStart=$LAUNCHER_BIN start
Restart=always
RestartSec=5
User=root
WorkingDirectory=/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Created $DRIA_SERVICE_PATH"

# --- Create watchdog script ---
cat > "$WATCHDOG_SCRIPT" <<'EOF'
#!/bin/bash

journalctl -fu dria | while read line; do
    echo "$line" | grep -q "Node has not received any pings" && {
        echo "[dria-watchdog] Triggered restart due to ping timeout"
        systemctl restart dria
    }
done
EOF

chmod +x "$WATCHDOG_SCRIPT"
echo "[+] Created watchdog script at $WATCHDOG_SCRIPT"

# --- Create dria-watchdog.service ---
cat > "$WATCHDOG_SERVICE_PATH" <<EOF
[Unit]
Description=Watchdog for dria service
After=dria.service
Requires=dria.service

[Service]
ExecStart=$WATCHDOG_SCRIPT
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Created $WATCHDOG_SERVICE_PATH"

# --- Reload systemd and enable services ---
echo "[+] Reloading systemd daemon..."
systemctl daemon-reexec
systemctl daemon-reload

echo "[+] Enabling and starting services..."
systemctl enable --now dria.service
systemctl enable --now dria-watchdog.service

echo "[✓] Dria and watchdog installed and running."
