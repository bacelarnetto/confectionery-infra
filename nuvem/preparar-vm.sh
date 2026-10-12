#!/usr/bin/env bash
# Prepara uma VM Ubuntu da Oracle (rodar UMA vez, dentro da VM): Docker, jq, firewall e swap.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y ca-certificates curl git jq
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"

# As imagens Ubuntu da Oracle vêm com iptables bloqueando tudo além do SSH, MESMO com a Security
# List liberada no console. Abre 80/443 antes da regra de REJECT e persiste.
for porta in 80 443; do
  sudo iptables -C INPUT -p tcp --dport "$porta" -j ACCEPT 2>/dev/null || \
    sudo iptables -I INPUT 5 -p tcp --dport "$porta" -j ACCEPT
done
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save

# Swap de 4 GB como folga para o build do Maven.
if ! swapon --show | grep -q /swapfile; then
  sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
  sudo mkswap /swapfile && sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo "Pronto. Saia e entre de novo na VM (para o grupo docker valer) e confira: docker compose version"
