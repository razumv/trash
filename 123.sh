#!/bin/bash

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo)."
  exit 1
fi

set -e

install_services() {
  echo "Обновление списка пакетов и установка необходимых компонентов..."
  apt-get update
  apt-get install -y xvfb fluxbox x11vnc novnc websockify libnss3 libgbm1 libasound2 libxcomposite1 libxrandr2 libxdamage1 libxshmfence1 unzip wget dbus-x11 tmux || {
    echo "Ошибка при установке пакетов."
    exit 1
  }
  echo "Пакеты успешно установлены."

  echo "Скачивание и установка OpenLedger Node..."
  wget -O openledger-node.zip https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip || {
    echo "Ошибка при загрузке OpenLedger Node."
    exit 1
  }
  unzip -o openledger-node.zip || {
    echo "Ошибка при распаковке архива OpenLedger Node."
    exit 1
  }
  sudo dpkg -i openledger-node-1.0.0.deb || sudo apt-get install -f -y
  echo "OpenLedger Node успешно установлена."
}

start_services() {
  echo "Запуск виртуального дисплея..."
  Xvfb :100 -screen 0 1024x768x16 &
  XVFB_PID=$!
  export DISPLAY=:100
  sleep 2
  if ! ps -p $XVFB_PID > /dev/null; then
    echo "Не удалось запустить Xvfb."
    exit 1
  fi
  echo "Виртуальный дисплей успешно запущен."

  echo "Запуск оконного менеджера..."
  fluxbox &
  FLUXBOX_PID=$!
  sleep 2
  if ! ps -p $FLUXBOX_PID > /dev/null; then
    echo "Не удалось запустить Fluxbox."
    exit 1
  fi
  echo "Оконный менеджер успешно запущен."

  echo "Запуск VNC-сервера..."
  x11vnc -display :100 -forever -nopw -rfbport 5900 &
  X11VNC_PID=$!
  sleep 2
  if ! ps -p $X11VNC_PID > /dev/null; then
    echo "Не удалось запустить x11vnc."
    exit 1
  fi
  echo "VNC-сервер успешно запущен."

  echo "Запуск noVNC..."
  websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5900 &
  WEBSOCKIFY_PID=$!
  sleep 2
  if ! ps -p $WEBSOCKIFY_PID > /dev/null; then
    echo "Не удалось запустить noVNC."
    exit 1
  fi
  echo "noVNC успешно запущен. Интерфейс доступен по адресу: http://$(hostname -I | awk '{print $1}'):6080"

  echo "Запуск OpenLedger Node в tmux..."
  tmux new-session -d -s openledger "openledger-node --no-sandbox --disable-gpu --disable-software-rasterizer"
  sleep 5
  if ! tmux has-session -t openledger 2>/dev/null; then
    echo "Не удалось запустить OpenLedger Node в tmux."
    exit 1
  fi
  echo "OpenLedger Node успешно запущена в tmux. Для просмотра сессии используйте: tmux attach -t openledger"
}

stop_services() {
  echo "Остановка всех запущенных процессов..."
  pkill -f "Xvfb :100" || echo "Xvfb уже остановлен."
  pkill -f "fluxbox" || echo "Fluxbox уже остановлен."
  pkill -f "x11vnc" || echo "x11vnc уже остановлен."
  pkill -f "websockify" || echo "websockify уже остановлен."
  tmux kill-session -t openledger || echo "Сессия tmux openledger уже остановлена."
  echo "Все процессы успешно остановлены."
}

restart_services() {
  stop_services
  start_services
}

case "$1" in
  install)
    install_services
    ;;
  start)
    start_services
    ;;
  stop)
    stop_services
    ;;
  restart)
    restart_services
    ;;
  *)
    echo "Использование: $0 {install|start|stop|restart}"
    exit 1
    ;;
esac
