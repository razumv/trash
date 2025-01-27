#!/bin/bash

docker pull privasea/acceleration-node-beta
mkdir -p  /privasea/config && cd /privasea
expect <(curl -s https://raw.githubusercontent.com/razumv/trash/refs/heads/main/privasea/generate_key.exp)
mv config/UTC--* config/wallet_keystore
