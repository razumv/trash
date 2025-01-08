#!/bin/bash

# Установка зависимостей
echo "Installing jq and expect..."
sudo apt install -y jq expect
echo "jq and expect installed successfully."

docker rm -f `docker ps | grep rivalz | awk '{print $1}'`

# Путь к файлам
PROXY_FILE="$HOME/proxy.txt"
WALLET_FILE="$HOME/evm.txt"

echo $PROXY > $PROXY_FILE
echo $WALLET > $WALLET_FILE

echo $PROXY
echo $WALLET

# Проверка наличия файлов
if [[ ! -f "$PROXY_FILE" ]] || [[ ! -f "$WALLET_FILE" ]]; then
    echo "Файлы proxy.txt или evm.txt не найдены!"
    exit 1
fi

# Цикл по строкам в файлах proxy.txt и evm.txt
while IFS=: read -r PROXY_IP PROXY_PORT PROXY_USER PROXY_PASS && IFS= read -r WALLET_ADDRESS <&3; do

    echo "Запуск с прокси: $PROXY_IP:$PROXY_PORT и кошельком: $WALLET_ADDRESS"

    # Проверка наличия директории
    if [ ! -d "rivalz-docker" ]; then
        mkdir rivalz-docker
        echo "Directory rivalz-docker created."
    fi

    # Переход в директорию
    cd rivalz-docker || exit

    # Инициализация переменных прокси
    proxy_type="http-connect"
    
    # Получение последней версии rivalz-node-cli
    version=$(curl -s https://be.rivalz.ai/api-v1/system/rnode-cli-version | jq -r '.data')
    if [ -z "$version" ]; then
        version="latest"
        echo "Could not fetch the version. Defaulting to latest."
    fi

    # Создание Dockerfile
    cat <<EOL > Dockerfile
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl redsocks iptables iproute2 jq nano expect
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \\
    apt-get install -y nodejs
RUN npm install -g npm
RUN npm install -g rivalz-node-cli@$version

# Копируем скрипт для автоматического запуска
COPY auto_run.sh /usr/local/bin/auto_run.sh
RUN chmod +x /usr/local/bin/auto_run.sh
EOL

    # Создание скрипта auto_run.sh
    cat <<'EOL' > auto_run.sh
#!/usr/bin/expect -f

set timeout -1

spawn rivalz run

expect "Enter wallet address (EVM):"
send -- "$env(WALLET_ADDRESS)\r"

expect "Select drive you want to use:"
send -- "overlay\r"

expect "Enter Disk size of overlay"
send -- "10\r"

expect "Pinging master node with"
# Завершаем выполнение
expect eof
EOL

    # Добавление конфигурации прокси, если требуется
    if [[ -n "$PROXY_IP" ]]; then
        cat <<EOL >> Dockerfile
COPY redsocks.conf /etc/redsocks.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EOL

        cat <<EOL > redsocks.conf
base {
    log_debug = off;
    log_info = on;
    log = "file:/var/log/redsocks.log";
    daemon = on;
    redirector = iptables;
}

redsocks {
    local_ip = 127.0.0.1;
    local_port = 12345;
    ip = $PROXY_IP;
    port = $PROXY_PORT;
    type = $proxy_type;
EOL

        if [[ -n "$PROXY_USER" ]]; then
            cat <<EOL >> redsocks.conf
    login = "$PROXY_USER";
EOL
        fi

        if [[ -n "$PROXY_PASS" ]]; then
            cat <<EOL >> redsocks.conf
    password = "$PROXY_PASS";
EOL
        fi

        cat <<EOL >> redsocks.conf
}
EOL

        cat <<EOL > entrypoint.sh
#!/bin/sh
echo "Starting redsocks..."
redsocks -c /etc/redsocks.conf &
sleep 5
echo "Configuring iptables..."
iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports 12345
exec "\$@"
EOL
    fi

    # Добавление общей CMD инструкции для запуска auto_run.sh
    cat <<EOL >> Dockerfile
CMD ["bash", "-c", "export WALLET_ADDRESS=$WALLET_ADDRESS; /usr/local/bin/auto_run.sh"]
EOL

    # Определение имени контейнера
    existing_instances=$(docker ps -a --filter "name=rivalz-docker-" --format "{{.Names}}" | grep -Eo 'rivalz-docker-[0-9]+' | grep -Eo '[0-9]+' | sort -n | tail -1)
    if [ -z "$existing_instances" ]; then
        instance_number=1
    else
        instance_number=$((existing_instances + 1))
    fi
    container_name="rivalz-docker-$instance_number"

    # Сборка Docker-образа
    docker build -t $container_name .

    # Запуск Docker-контейнера
    if [[ -n "$PROXY_IP" ]]; then
        docker run --restart always -d --cap-add=NET_ADMIN --name $container_name $container_name
    else
        docker run --restart always -d --name $container_name $container_name
    fi

    # Пауза перед следующим запуском
    sleep 2

    # Возврат в исходную директорию
    cd ..

done < "$PROXY_FILE" 3< "$WALLET_FILE"

rm -f $PROXY_FILE $WALLET_FILE
echo "Все задачи выполнены!"
