#!/bin/bash

# Убиваем tmux сессию
tmux kill-session -t risc_service 2>/dev/null || true

# Переходим в директорию
cd /root/light-node/risc0-merkle-service

# Запускаем сборку и запуск в tmux
tmux new-session -d -s risc_service "cargo build && cargo run"

# Рандомная пауза от 1 до 60 минут перед рестартом light-node
sleep_time=$((RANDOM % 60 + 1))
echo "Спим $sleep_time минут(ы) перед systemctl restart..."
sleep "${sleep_time}m"

# Рестарт сервиса
sudo systemctl restart light-node
