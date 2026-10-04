#!/usr/bin/env bash
# Sobe o sistema inteiro (postgres, keycloak, api, frontend) com build e espera todos ficarem saudáveis.
# Uso: ~/work/confectionery-suite/confectionery-infra/subir.sh   (de qualquer diretório)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f .env ]; then
  echo "ERRO: $(pwd)/.env não encontrado. Copie .env.example para .env e preencha os segredos." >&2
  exit 1
fi

docker compose up -d --build --wait --wait-timeout 600
docker compose ps
