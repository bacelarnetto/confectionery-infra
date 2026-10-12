#!/usr/bin/env bash
# Gera keycloak/realm-nuvem.json a partir do realm-export.json, trocando as URLs localhost do
# cliente confectionery-web pelas do domínio público (APP_DOMAIN do .env). O original não é tocado.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
[ -f .env ] || { echo "ERRO: .env não encontrado em $(pwd)" >&2; exit 1; }
APP_DOMAIN="$(grep -E '^APP_DOMAIN=' .env | head -1 | cut -d= -f2- | tr -d '"' || true)"
[ -n "$APP_DOMAIN" ] || { echo "ERRO: defina APP_DOMAIN no .env" >&2; exit 1; }
jq --arg d "$APP_DOMAIN" '
  (.clients[] | select(.clientId == "confectionery-web")) |=
    (.redirectUris = ["https://\($d)/*"] | .webOrigins = ["https://\($d)"])
' keycloak/realm-export.json > keycloak/realm-nuvem.json
echo "OK: keycloak/realm-nuvem.json gerado para https://$APP_DOMAIN"
