# Deploy na Oracle Cloud (VM ARM Always Free)

Tudo sobe na mesma VM com Docker Compose. Só o Caddy fica exposto (80/443, HTTPS automático).

## 0. Pré-requisitos (uma vez)

1. DuckDNS: criar dois subdomínios apontando para o IP público da VM, por ex.
   `confeitaria.duckdns.org` (app) e `confeitaria-auth.duckdns.org` (login).
2. VM no console da Oracle: shape VM.Standard.A1.Flex (4 OCPU / 24 GB), Ubuntu 24.04, chave SSH
   baixada. Em Rede > Security List da subnet, liberar entrada TCP 80 e 443 (origem 0.0.0.0/0).
3. Os três repositórios acessíveis pela VM (git clone) ou copiados com rsync.

## 1. Preparar a VM (uma vez)

    ssh -i ~/chave.key ubuntu@IP_DA_VM
    mkdir -p ~/work/confectionery-suite && cd ~/work/confectionery-suite
    git clone <url confectionery>            # branch main
    git clone <url confectionery-web-dashboard> && git -C confectionery-web-dashboard checkout nuvem
    git clone <url confectionery-infra> && git -C confectionery-infra checkout nuvem
    ./confectionery-infra/nuvem/preparar-vm.sh
    exit    # entrar de novo para o grupo docker valer

Sem acesso git na VM: da sua máquina, `rsync -av --exclude node_modules --exclude target
--exclude .git ~/work/confectionery-suite/ ubuntu@IP_DA_VM:~/work/confectionery-suite/`.

## 2. Configurar e subir

    cd ~/work/confectionery-suite/confectionery-infra
    cp .env.example .env && nano .env   # senhas NOVAS e fortes; APP_DOMAIN e AUTH_DOMAIN; APP_PUSH_MOCK etc.
    ./nuvem/subir-nuvem.sh

O primeiro build leva alguns minutos (Maven + Vite). O Caddy emite os certificados sozinho se os
dois domínios já apontam para o IP e as portas 80/443 estão abertas.

Atenção ao `.env` da nuvem: o banco da nuvem começa vazio, então use senhas diferentes das locais,
e `CONFECTIONERY_SERVER_CLIENT_SECRET` deve ser o secret do client `confectionery-server` do realm.

## 3. Conferir

- `https://APP_DOMAIN` abre o app e o login redireciona para `https://AUTH_DOMAIN`.
- `docker compose -f docker-compose.yaml -f docker-compose.nuvem.yaml ps` com tudo saudável.
- Portas 5432, 8080 e 8180 NÃO respondem de fora (`nc -vz IP_DA_VM 5432`).

## 4. Console admin do Keycloak

Bloqueado na internet de propósito. Da sua máquina:

    ssh -i ~/chave.key -L 8180:127.0.0.1:8180 ubuntu@IP_DA_VM

Como o hostname público está fixo, o console redireciona para o domínio e cai no bloqueio. Para
administrar, remova temporariamente o bloco `@bloqueado` do `nuvem/Caddyfile`, rode
`docker compose ... restart caddy`, faça o que precisa e recoloque.

## 5. Backup

    crontab -e
    30 3 * * * /home/ubuntu/work/confectionery-suite/confectionery-infra/nuvem/backup-banco.sh

Guarde também uma cópia fora da VM (`scp`/`rsync` para sua máquina) de vez em quando.

## 6. Atualizar versão

    cd ~/work/confectionery-suite && git -C confectionery pull && git -C confectionery-web-dashboard pull && git -C confectionery-infra pull
    cd confectionery-infra && ./nuvem/subir-nuvem.sh

## Limitações conhecidas

- Keycloak segue em `start-dev` com H2 em volume (mesma decisão do ambiente local, ver
  doc/adr-persistir-keycloak.md). Migrar para `start` com Postgres é o próximo endurecimento.
- Não testado ainda em VM real: o primeiro deploy é o teste.
