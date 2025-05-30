#!/bin/bash
sudo apt install whiptail -y

if [ ! -d "/home/user/eth-docker" ]; then
        sudo -u user git clone https://github.com/eth-educators/eth-docker.git /home/user/eth-docker
    else
        echo "Directory '/home/user/eth-docker' already exists."
fi


sudo -u user cp /home/user/eth-docker/default.env /home/user/eth-docker/.env
sudo -u user sed -i 's/COMPOSE_FILE=.*/COMPOSE_FILE=teku-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:el-shared.yml/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/EL_P2P_PORT=.*/EL_P2P_PORT=40303/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/CL_P2P_PORT=.*/CL_P2P_PORT=49000/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/CL_QUIC_PORT=.*/CL_QUIC_PORT=49001/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/GRAFANA_PORT=.*/GRAFANA_PORT=43000/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/EL_RPC_PORT=.*/EL_RPC_PORT=48545/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/EL_WS_PORT=.*/EL_WS_PORT=48546/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/NETWORK=.*/NETWORK=holesky/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/CHECKPOINT_SYNC_URL=.*/CHECKPOINT_SYNC_URL=\"https:\/\/holesky.beaconstate.info\"/g' /home/user/eth-docker/.env
sudo -u user sed -i 's/FEE_RECIPIENT=.*/FEE_RECIPIENT=0xd9264738573E25CB9149de0708b36527d56B59bd/g' /home/user/eth-docker/.env


export COMPOSE_PROJECT_NAME=holesky
sudo -u user /home/user/eth-docker/ethd up
