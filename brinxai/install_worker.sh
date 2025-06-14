#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
export NODE_UUID="$NODE_UUID"
echo $NODE_UUID
# Removing old installation if exists
echo "Удаляем старую версию brinx.ai (если уже стоит)"
docker rm -f brinxai_worker-worker-1 text-ui stable-diffusion rembg upscaler brinxai_relay 2>/dev/null || true
docker ps -a -q --filter "name=brinxai_worker" | xargs -r docker rm -f > /dev/null 2>&1
docker ps -a -q --filter ancestor=admier/brinxai_nodes-worker | xargs -r docker rm -f && docker rmi admier/brinxai_nodes-worker
#docker image inspect admier/brinxai_nodes-worker >/dev/null 2>&1 && docker rmi admier/brinxai_nodes-worker
docker volume prune -f
docker network prune -f
rm -rf $HOME/brinxai_worker
# removal end


# Update package list and install dependencies
sudo apt-get install -y gnupg lsb-release &>/dev/null

# Check if GPU is available
echo "Проверяем есть ли GPU"
GPU_AVAILABLE=false
if command -v nvidia-smi &> /dev/null; then
    echo "GPU найден. Ставим NVIDIA драйвер."
    GPU_AVAILABLE=true
else
    echo "GPU не найден."
fi

# Prompt user for WORKER_PORT
USER_PORT=5011

mkdir -p $HOME/brinxai_worker
cd $HOME/brinxai_worker

echo "Создаем .env файл"
cat <<EOF > .env
WORKER_PORT=$USER_PORT
NODE_UUID=$NODE_UUID
USE_GPU=$GPU_AVAILABLE
CUDA_VISIBLE_DEVICES=""
EOF

# Create docker-compose.yml file
echo "Создаем docker-compose.yml"
if [ "$GPU_AVAILABLE" = true ]; then
    cat <<EOF > docker-compose.yml
services:
  brinxai_worker:
    image: admier/brinxai_nodes-worker:latest
    restart: unless-stopped
    environment:
      - WORKER_PORT=\${WORKER_PORT:-5011}
      - NODE_UUID=\${NODE_UUID}
      - USE_GPU=\${USE_GPU:-true}
      - CUDA_VISIBLE_DEVICES=\${CUDA_VISIBLE_DEVICES}
    ports:
      - "\${WORKER_PORT:-5011}:\${WORKER_PORT:-5011}"
    volumes:
      - ./generated_images:/usr/src/app/generated_images
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - brinxai-network
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    runtime: nvidia

networks:
  brinxai-network:
    driver: bridge
    name: brinxai-network
EOF
else
    cat <<EOF > docker-compose.yml
services:
  brinxai_worker:
    image: admier/brinxai_nodes-worker:latest
    restart: unless-stopped
    environment:
      - WORKER_PORT=\${WORKER_PORT:-5011}
      - NODE_UUID=\${NODE_UUID}
      - USE_GPU=\${USE_GPU:-false}
      - CUDA_VISIBLE_DEVICES=\${CUDA_VISIBLE_DEVICES}
    ports:
      - "\${WORKER_PORT:-5011}:\${WORKER_PORT:-5011}"
    volumes:
      - ./generated_images:/usr/src/app/generated_images
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - brinxai-network

networks:
  brinxai-network:
    driver: bridge
    name: brinxai-network
EOF
fi

docker compose down --remove-orphans

echo "Скачиваем последнюю версию контейнера BrixAI"
docker pull admier/brinxai_nodes-worker:latest

echo "Запускаем Docker контейнеры"
docker compose up -d

echo "Проверяем статус контейнеров:"
sleep 5 # Wait for container to stabilize
docker ps -a --filter "name=brinxai_worker"


echo ""
echo "Установка завершена"
echo "Проверка логов: "
echo 'docker logs $(docker ps -a -q --filter "name=brinxai_worker")'
