#!/usr/bin/env bash
# Sobe o sistema na VM (rodar DENTRO da VM). Gera o realm da nuvem e sobe com o override.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
./nuvem/gerar-realm.sh
docker compose -f docker-compose.yaml -f docker-compose.nuvem.yaml up -d --build --wait --wait-timeout 900
docker compose -f docker-compose.yaml -f docker-compose.nuvem.yaml ps
