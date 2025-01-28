#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка майнера Hemi Network"
echo "-----------------------------------------------------------------------------"

grep -qxF 'fs.inotify.max_user_watches=524288' /etc/sysctl.conf || echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

DIR="$HOME/heminetwork"

if [ ! -d "$DIR" ]; then
    echo "Директория $DIR не найдена, загружаем и создаем..."
    cd $HOME
    wget https://github.com/hemilabs/heminetwork/releases/download/v0.11.1/heminetwork_v0.11.1_linux_amd64.tar.gz
    tar -xvf heminetwork_v0.11.1_linux_amd64.tar.gz
    rm heminetwork_v0.11.1_linux_amd64.tar.gz
    mv heminetwork_v0.11.1_linux_amd64 heminetwork
fi

echo "-----------------------------------------------------------------------------"
echo "Создание кошелька"
echo "-----------------------------------------------------------------------------"

# Определение пути к файлу
FILE="$HOME/heminetwork/popm-address.json"

# Проверка наличия файла
if [ ! -f "$FILE" ]; then
    echo "Файл $FILE не найден, создаем..."
    cd $HOME/heminetwork
    ./keygen -secp256k1 -json -net="testnet" > $FILE
fi

# Извлечение приватного ключа из файла JSON
PRIVATE_KEY=$(cat $FILE | jq -r ".private_key")

echo "-----------------------------------------------------------------------------"
echo "Запуск майнера"
echo "-----------------------------------------------------------------------------"

sudo tee /etc/systemd/system/hemi.service > /dev/null <<EOF
[Unit]
Description=Hemi miner
After=network.target

[Service]
User=$USER
Environment="POPM_BTC_PRIVKEY=$PRIVATE_KEY"
Environment="POPM_STATIC_FEE=4000"
Environment="POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public"
WorkingDirectory=$HOME/heminetwork
ExecStart=$HOME/heminetwork/popmd
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable hemi &>/dev/null
sudo systemctl daemon-reload
sudo systemctl start hemi

sleep 15

echo "Ваш адрес кошелька. Для работы майнера вам необходимо запросить токены в дискорде"
PUBLIC_ADDRESS=$(journalctl -n 100 -u hemi -o cat | grep -oP '(?<=address )[^\s]+')
echo "$PUBLIC_ADDRESS" > $HOME/heminetwork/wallet.txt

echo "-----------------------------------------------------------------------------"
echo "Hemi майнер успешно запущен"
echo "-----------------------------------------------------------------------------"
echo "Проверка логов"
echo "journalctl -n 100 -f -u hemi -o cat"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
