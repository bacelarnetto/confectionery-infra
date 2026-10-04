#!/usr/bin/env bash
# Para e remove os containers do sistema. NÃO apaga volumes (os dados do banco ficam).
# Uso: ~/work/confectionery-suite/confectionery-infra/derrubar.sh   (de qualquer diretório)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down
