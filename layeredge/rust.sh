#!/bin/bash

echo "Удаляем Rust and Cargo..."
rustup self uninstall -y 2>/dev/null || true
rm -rf ~/.cargo ~/.rustup
sudo apt remove --purge -y rustc cargo &>/dev/null
sudo apt autoremove -y &>/dev/null
sed -i '/\.cargo\/bin/d' ~/.bashrc ~/.zshrc 2>/dev/null || true

echo "Устанавливаем Rust и Cargo..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
source $HOME/.cargo/env
echo "Rust установлен: $(rustc --version)"
sleep 1
echo "Весь необходимый софт установлен"
