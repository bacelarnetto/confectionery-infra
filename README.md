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
- **Nunca rode `docker compose down -v`, `docker volume rm/prune` nem `docker system prune`.**
