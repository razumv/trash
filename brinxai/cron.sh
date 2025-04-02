#!/bin/bash

# Массив с именами контейнеров
containers=("text-ui" "stable-diffusion" "rembg" "upscaler")
images=(
  "admier/brinxai_nodes-text-ui:latest"
  "admier/brinxai_nodes-stabled:latest"
  "admier/brinxai_nodes-rembg:latest"
  "admier/brinxai_nodes-upscaler:latest"
)
ports=("5000:5000" "5050:5050" "7000:7000" "3030:3030")
cpu_limits=("4" "8" "2" "2")
mem_limits=("4096m" "8192m" "2048m" "2048m")

# Определяем текущий день в цикле (0-3)
day_index=$(( ($(date +%j) - 1) % 4 ))

# Определяем индекс предыдущего контейнера (цикл по модулю 4)
previous_index=$(( (day_index + 3) % 4 ))

# Получаем имена текущего и предыдущего контейнера
current_container=${containers[$day_index]}
previous_container=${containers[$previous_index]}

# Получаем образ, порты, лимиты ресурсов для текущего контейнера
current_image=${images[$day_index]}
current_port=${ports[$day_index]}
current_cpu=${cpu_limits[$day_index]}
current_mem=${mem_limits[$day_index]}

echo "[$(date)] Удаляем предыдущий контейнер: $previous_container"
docker rm -f text-ui stable-diffusion rembg upscaler 2>/dev/null

echo "[$(date)] Обновляем образ: $current_image"
docker pull $current_image

echo "[$(date)] Запускаем контейнер: $current_container"
docker run -d --name $current_container \
  --network brinxai-network \
  --cpus=$current_cpu --memory=$current_mem \
  -p 127.0.0.1:$current_port \
  --restart unless-stopped $current_image

echo "[$(date)] Запуск завершен: $current_container" | tee -a /var/log/docker_cron.log
