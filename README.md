# confectionery-infra

Infraestrutura do ConfectioneryEase: `docker-compose.yaml`, realm/tema do Keycloak e os scripts de
subir/derrubar. Só orquestra — os `Dockerfile`s continuam nos repos de cada aplicação.

## Pré-requisitos

- Docker + Docker Compose v2 (`--wait`), Docker rodando.
- Repositórios irmãos na mesma pasta: `confectionery` (API) e `confectionery-web-dashboard` (frontend).
- Segredos: `cp .env.example .env` e preencha. **O `.env` nunca vai para o git.**

## Uso

```bash
./subir.sh       # builda e sobe postgres, keycloak, api e frontend; só sai 0 se os 4 ficarem healthy
./derrubar.sh    # para e remove os containers
```

Os dois scripts funcionam de qualquer diretório e usam o `.env` desta pasta.

## Avisos

- **Nunca mude `name: confectionery` no compose.** O volume do banco é
  `confectionery_datavolume_confectionery_postgres`; o prefixo vem do `name:`. Mudar o nome faz o
  Docker criar volumes vazios e o banco parece zerado.
- O estado do Keycloak fica no volume `confectionery_datavolume_confectionery_keycloak`, e o
  `derrubar.sh` não o apaga.
- **Mudanças no `keycloak/realm-export.json` só valem num volume novo do Keycloak.** Com um realm já
  existente, o import é ignorado. Para aplicar no dia a dia, use o console (`http://localhost:8180`) ou a
  Admin API.
- Para "zerar só o Keycloak": `./derrubar.sh && docker volume rm confectionery_datavolume_confectionery_keycloak && ./subir.sh`.
  Isso apaga todos os usuários do Keycloak (será preciso religá-los). Nunca faça isso com o volume do Postgres.
- **Nunca rode `docker compose down -v`, `docker volume rm/prune` nem `docker system prune`.**
