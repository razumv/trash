#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"


echo "Установка проекта"

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    CLIENT_URL="https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar"
elif [[ "$ARCH" == "aarch64" ]]; then
    CLIENT_URL="https://cdn.app.multiple.cc/client/linux/arm64/multipleforlinux.tar"
else
    echo -e "Неподдерживаемая архитектура системы: $ARCH"
    exit 1
fi

wget $CLIENT_URL -O multipleforlinux.tar

tar -xvf multipleforlinux.tar
rm -rf multipleforlinux.tar

cd multipleforlinux
chmod +x ./multiple-cli
chmod +x ./multiple-node

echo "PATH=\$PATH:$(pwd)" >> $HOME/.bash_profile
source $HOME/.bash_profile

sudo tee /etc/systemd/system/multiple.service > /dev/null << EOF
[Unit]
Description=Multiple Network node client on a Linux Operating System
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/multipleforlinux/multiple-node
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable multiple
sudo systemctl start multiple

echo "-----------------------------------------------------------------------"
echo -e "Команда для проверки статуса ноды:"
echo -e "\$HOME/multipleforlinux/multiple-cli status"
echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
