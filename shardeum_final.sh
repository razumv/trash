if [ -d "$HOME/.shardeum" ]; then
  cd "$HOME/.shardeum" && docker compose down -v
  cd "$HOME"
  rm -rf "$HOME/.shardeum"
else
  echo "Директория $HOME/.shardeum не существует."
fi

wget https://gist.githubusercontent.com/razumv/80865f45508e85a648abb863ced48394/raw/b65a6bab3c454daa6413ff67de6669baa933124e/shardeum.exp && chmod +x shardeum.exp && \
expect shardeum.exp && rm -f shardeum.exp install.sh
