#!/bin/bash 

echo "Удаляем Go..."
sudo rm -rf /usr/local/go
rm -rf ~/go ~/.cache/go-build ~/.config/go
sudo apt remove --purge -y golang-go &>/dev/null
sudo apt autoremove -y &>/dev/null
sudo snap remove go 2>/dev/null || true
sed -i '/\/usr\/local\/go\/bin/d' ~/.profile ~/.bashrc ~/.zshrc 2>/dev/null || true

echo "Устанавливаем Go"
wget https://golang.org/dl/go1.22.1.linux-amd64.tar.gz &>/dev/null
sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz &>/dev/null
rm go1.22.1.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.bashrc
source ~/.profile
echo "Go установлена: $(go version)"
