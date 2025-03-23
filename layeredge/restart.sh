#!/bin/bash

tmux kill-session -t risc_service 2>/dev/null; cd /root/light-node/risc0-merkle-service; tmux new-session -d -s risc_service "cargo build && cargo run"
sleep 15
sudo systemctl restart light-node
