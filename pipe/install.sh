#!/bin/bash
set -e

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update -y &>/dev/null
sudo apt install gawk bison build-essential manpages-dev ca-certificates -y &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка ноды"
echo "-----------------------------------------------------------------------------"

USERNAME="popcache"
LOGROTATE_FILE="/etc/logrotate.d/popcache"

if ! id "$USERNAME" &>/dev/null; then
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "Пользователь '$USERNAME' создан."
else
    echo "Пользователь '$USERNAME' уже существует."
fi
sudo usermod -aG sudo "$USERNAME"

sudo tee /etc/sysctl.d/99-popcache.conf > /dev/null << "EOL"
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOL

sudo sysctl --system &>/dev/null

sudo tee /etc/security/limits.d/popcache.conf > /dev/null << "EOL"
*    hard nofile 65535
*    soft nofile 65535
EOL

sudo mkdir -p /opt/popcache
cd /opt/popcache

ldd_version=$(ldd --version | head -n1 | awk '{print $NF}')

if [[ "$ldd_version" == "2.39" ]]; then
    url="https://download.pipe.network/static/pop-v0.3.1-linux-x64.tar.gz"
    wget "$url" &>/dev/null
    tar -xf "$(basename "$url")" &>/dev/null
    chmod +x pop
    pop_cmd="/opt/popcache/pop"
else
    echo "Билдим нужную версию glibc (2.39) - время ожидания 3-5 минут"
    mkdir -p /opt/glibc-build
    cd /opt/glibc-build
    rm -rf glibc-2.39-build glibc-2.39-install

    wget http://ftp.gnu.org/gnu/libc/glibc-2.39.tar.gz &>/dev/null
    tar -xf glibc-2.39.tar.gz &>/dev/null
    mkdir glibc-2.39-build glibc-2.39-install
    cd glibc-2.39-build
    ../glibc-2.39/configure --prefix=/opt/glibc-build/glibc-2.39-install &>/dev/null
    make -j$(nproc) &>/dev/null
    make install &>/dev/null

    sudo chown -R root:root /opt/glibc-build
    chmod -R a+rx /opt/glibc-build

    cd /opt/popcache
    wget https://download.pipe.network/static/pop-v0.3.1-linux-x64.tar.gz &>/dev/null
    tar -xf pop-v0.3.1-linux-x64.tar.gz &>/dev/null
    chmod +x pop

    pop_cmd="/opt/glibc-build/glibc-2.39-install/lib/ld-linux-x86-64.so.2 --library-path \"/opt/glibc-build/glibc-2.39-install/lib:/usr/lib/x86_64-linux-gnu/\" /opt/popcache/pop"
fi

# read -rp "Введите Solana public key: " solana_addr
# read -rp "Введите инвайт код: " invite_code
# read -rp "Введите Pop Name (имя): " pop_name
# read -rp "Введите Pop Location (страна): " pop_location

cat > /opt/popcache/config.json <<EOF
{
  "pop_name": "$pop_name",
  "pop_location": "$pop_location",
  "invite_code": "$invite_code",
  "server": {
    "host": "0.0.0.0",
    "port": 443,
    "http_port": 80,
    "workers": 40
  },
  "cache_config": {
    "memory_cache_size_mb": 4096,
    "disk_cache_path": "./cache",
    "disk_cache_size_gb": 100,
    "default_ttl_seconds": 86400,
    "respect_origin_headers": true,
    "max_cacheable_size_mb": 1024
  },
  "api_endpoints": {
    "base_url": "https://dataplane.pipenetwork.com"
  },
  "identity_config": {
    "node_name": "your-node-name",
    "name": "Your Name",
    "email": "your.email@example.com",
    "website": "https://your-website.com",
    "discord": "your_discord_username",
    "telegram": "your_telegram_handle",
    "solana_pubkey": "$solana_addr"
  }
}
EOF

sudo mkdir -p /opt/popcache/logs
sudo chown -R popcache:popcache /opt/popcache

SERVICE_NAME="popcache.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

if systemctl list-units --type=service --all | grep -q "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
    echo "Существующий $SERVICE_NAME удален."
fi

echo "Создаем systemd сервис popcache."

sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=POP Cache Node
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/popcache
ExecStart=$pop_cmd
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:/opt/popcache/logs/stdout.log
StandardError=append:/opt/popcache/logs/stderr.log
Environment=POP_CONFIG_PATH=/opt/popcache/config.json
Environment=POP_INVITE_CODE=$invite_code

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable popcache
sudo service popcache start
echo "Сервис создан и запущен."

sudo tee "$LOGROTATE_FILE" > /dev/null <<EOL
/opt/popcache/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 popcache popcache
    sharedscripts
    postrotate
        systemctl reload popcache >/dev/null 2>&1 || true
    endscript
}
EOL

sudo mkdir -p /opt/popcache/logs
sudo chown -R "$USER:$GROUP" /opt/popcache/logs
echo "Ротация логов настроена."

echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "tail -f /opt/popcache/logs/stdout.log"
echo "sudo journalctl -u popcache -f"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
