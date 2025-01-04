if [ -d "$HOME/.shardeum" ]; then
  cd "$HOME/.shardeum" && docker compose down -v
  cd "$HOME"
  rm -rf "$HOME/.shardeum"
else
  echo "Директория $HOME/.shardeum не существует."
fi

wget -O shardeum.exp https://raw.githubusercontent.com/razumv/trash/refs/heads/main/shardeum/installer.exp && chmod +x shardeum.exp && \
expect shardeum.exp && rm -f shardeum.exp install.sh
