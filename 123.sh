#!/bin/bash

set -e

install_services() {
  mkdir -p $HOME/openledger/
  cd $HOME/openledger/
  echo "Создание Dockerfile..."
  cat <<EOF > Dockerfile
# Используем базовый образ Ubuntu
FROM ubuntu:22.04

# Установка временной зоны для автоматической конфигурации tzdata
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Установка зависимостей
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    xvfb fluxbox x11vnc novnc websockify libnss3 libgbm1 libasound2 libxcomposite1 \
    libxrandr2 libxdamage1 libxshmfence1 unzip wget dbus-x11 tmux xclip xsel \
    docker.io curl desktop-file-utils \
    libgtk-3-0 libnotify4 xdg-utils libatspi2.0-0 libsecret-1-0 apt-utils && apt-get clean

# Скачиваем и устанавливаем OpenLedger Node
RUN wget -O openledger-node.zip https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip && \
    unzip -o openledger-node.zip && \
    dpkg -i openledger-node-1.0.0.deb || apt-get install -f -y && \
    rm -rf openledger-node.zip

# Устанавливаем рабочую директорию
WORKDIR /opt/openledger

# Копируем скрипт для запуска
COPY start_services.sh /usr/local/bin/start_services.sh
RUN chmod +x /usr/local/bin/start_services.sh

# Указываем команду по умолчанию
CMD ["start_services.sh"]
EOF

  echo "Создание скрипта запуска..."
  cat <<EOF > start_services.sh
#!/bin/bash

set -e

# Запуск виртуального дисплея
Xvfb :100 -screen 0 1024x768x16 &
export DISPLAY=:100
sleep 2

# Запуск оконного менеджера
fluxbox &

# Запуск VNC-сервера
x11vnc -display :100 -forever -nopw -rfbport 5900 &

# Запуск noVNC
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5900 &

# Запуск OpenLedger Node
openledger-node --no-sandbox --disable-gpu --disable-software-rasterizer
EOF

  chmod +x start_services.sh

  echo "Сборка Docker-образа..."
  docker build -t openledger-container .
  echo "Docker-образ успешно создан."
  if [ ! -f /etc/machine-id.bk ]; then
    echo "Файл /etc/machine-id.bk отсутствует. Выполняю команды..."
    
    # Генерация нового machine-id
    dbus-uuidgen > $HOME/openledger/machine-id
    
    # Создание резервной копии текущего machine-id
    sudo cp /etc/machine-id /etc/machine-id.bk
    
    echo "Резервная копия machine-id создана: /etc/machine-id.bk"
    sudo cp $HOME/openledger/machine-id /etc/machine-id 
  else
    echo "Файл /etc/machine-id.bk уже существует. Пропускаю выполнение."
  fi
}

start_services() {
  echo "Запуск Docker-контейнера..."
  docker run -d \
    --name openledger \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.config/opl/:/root/.config/opl/ \
    -v $HOME/.config/OpenLedger\ Node/:/root/.config/OpenLedger\ Node/ \
    -v $HOME/openledger/logs/:/var/log/opl/ \
    -v $HOME/.local/bin/:/root/.local/bin/ \
    -v $HOME/openledger/machine-id:/etc/machine-id:ro \
    openledger-container
  echo "Контейнер успешно запущен. Интерфейс доступен по адресу: http://$(hostname -I | awk '{print $1}'):6080"
}

stop_services() {
  echo "Остановка Docker-контейнера..."
  docker stop openledger || echo "Контейнер уже остановлен."
  docker rm openledger || echo "Контейнер уже удален."
  echo "Контейнер успешно остановлен и удален."
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
