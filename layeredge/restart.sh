#!/bin/bash
export TERM=xterm

# Проверяем доступность порта 3001
if ! nc -z 127.0.0.1 3001; then
    echo "[INFO] Порт 3001 недоступен. Запускаем risc_service..."
    tmux new-session -d -s risc_service 'cd /root/light-node/risc0-merkle-service; /root/.cargo/bin/cargo build && /root/.cargo/bin/cargo run'
else
    echo "[OK] Порт 3001 доступен. Ничего не делаем."
fi

# Рандомная пауза от 1 до 60 минут перед рестартом light-node
sleep_time=$((RANDOM % 60 + 1))
echo "Спим $sleep_time минут(ы) перед systemctl restart..."
sleep "${sleep_time}m"

# Рестарт сервиса
sudo systemctl restart light-node
