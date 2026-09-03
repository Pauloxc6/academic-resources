# Instalação do Zabbix 6.4 com MariaDB e Nginx (Debian 11)

Este guia apresenta a instalação do **Zabbix Server 6.4** utilizando **MariaDB**, **Nginx**, **PHP-FPM** e **Zabbix Agent** em sistemas Debian 11.

> **Observação:** Este procedimento é baseado no repositório oficial do Zabbix para Debian 11.

---

# Topologia

```text
                    Clientes
                        │
                Zabbix Agent
                     Porta 10050
                        │
        +--------------------------------+
        |         Zabbix Server          |
        |--------------------------------|
        | Nginx                          |
        | PHP-FPM                        |
        | Zabbix Server                  |
        | Zabbix Agent                   |
        | MariaDB                        |
        +--------------------------------+
                    Porta 8091
```

---

# Pré-requisitos

Atualize o sistema:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# 1. Adicionando o Repositório do Zabbix

Baixe o pacote do repositório:

```bash
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
```

Instale:

```bash
sudo dpkg -i zabbix-release_6.4-1+debian11_all.deb
```

Atualize novamente os repositórios:

```bash
sudo apt update
```

---

# 2. Instalando o Zabbix

```bash
sudo apt install -y \
zabbix-server-mysql \
zabbix-frontend-php \
zabbix-nginx-conf \
zabbix-sql-scripts \
zabbix-agent \
zabbix-web-service
```

---

# 3. Iniciando o Zabbix Web Service

```bash
sudo systemctl restart zabbix-web-service.service
```

Habilite na inicialização:

```bash
sudo systemctl enable zabbix-web-service.service
```

Verifique o status:

```bash
sudo systemctl status zabbix-web-service.service
```

---

# 4. Configurando o Banco de Dados

Acesse o MariaDB:

```bash
sudo mysql -u root -p
```

Crie o banco:

```sql
CREATE DATABASE zabbix_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;
```

Crie o usuário:

```sql
CREATE USER 'zabbix_user'@'localhost'
IDENTIFIED BY 'P@ssw0rd0@123';
```

Conceda permissões:

```sql
GRANT ALL PRIVILEGES
ON zabbix_db.*
TO 'zabbix_user'@'localhost';
```

Habilite a criação de funções durante a importação:

```sql
SET GLOBAL log_bin_trust_function_creators = 1;
```

Atualize as permissões:

```sql
FLUSH PRIVILEGES;
```

Saia:

```sql
EXIT;
```

---

# 5. Importando o Banco do Zabbix

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
mysql \
--default-character-set=utf8mb4 \
-u zabbix_user \
-p \
zabbix_db
```

Após a importação, volte ao MariaDB:

```bash
sudo mysql -u root -p
```

Desabilite novamente a opção (opcional):

```sql
SET GLOBAL log_bin_trust_function_creators = 0;

FLUSH PRIVILEGES;
```

---

# 6. Configurando o Zabbix Server

Edite:

```text
/etc/zabbix/zabbix_server.conf
```

```bash
sudo nano /etc/zabbix/zabbix_server.conf
```

Configure:

```conf
DBName=zabbix_db

DBUser=zabbix_user

DBPassword=P@ssw0rd0@123
```

---

# 7. Configurando o Nginx

Edite:

```text
/etc/zabbix/nginx.conf
```

```bash
sudo nano /etc/zabbix/nginx.conf
```

Exemplo:

```nginx
listen 8091;

server_name zabbix.home.arpa;
```

---

# 8. Reiniciando os Serviços

```bash
sudo systemctl restart \
zabbix-server \
zabbix-agent \
nginx \
php7.4-fpm
```

Habilite os serviços:

```bash
sudo systemctl enable \
zabbix-server \
zabbix-agent \
nginx \
php7.4-fpm
```

> **Observação:** Dependendo da versão do Debian, o serviço pode ser `php7.4-fpm`, `php8.1-fpm` ou outra versão instalada. Verifique com:

```bash
systemctl | grep php
```

---

# 9. Acessando a Interface Web

Abra o navegador:

```text
http://IP_DO_SERVIDOR:8091
```

ou

```text
http://zabbix.home.arpa:8091
```

Durante o assistente de instalação informe:

| Campo | Valor |
|--------|--------|
| Database | zabbix_db |
| User | zabbix_user |
| Password | P@ssw0rd0@123 |

---

# Firewall

Caso utilize UFW:

```bash
sudo ufw allow 8091/tcp
sudo ufw allow 10050/tcp
sudo ufw allow 10051/tcp
```

Recarregue:

```bash
sudo ufw reload
```

---

# Testes

Verifique os serviços:

```bash
sudo systemctl status zabbix-server
```

```bash
sudo systemctl status zabbix-agent
```

```bash
sudo systemctl status nginx
```

```bash
sudo systemctl status php7.4-fpm
```

Verifique se a porta está aberta:

```bash
ss -tlnp | grep 8091
```

---

# Comandos Úteis

Iniciar:

```bash
sudo systemctl start zabbix-server
```

Parar:

```bash
sudo systemctl stop zabbix-server
```

Reiniciar:

```bash
sudo systemctl restart zabbix-server
```

Status:

```bash
sudo systemctl status zabbix-server
```

Logs:

```bash
sudo journalctl -u zabbix-server
```

Logs do Agent:

```bash
sudo journalctl -u zabbix-agent
```

---

# Arquivos Importantes

```text
/etc/zabbix/zabbix_server.conf

/etc/zabbix/nginx.conf

/etc/zabbix/zabbix_agentd.conf

/usr/share/zabbix-sql-scripts/mysql/server.sql.gz
```

---

# Observações

- Utilize sempre o repositório oficial do Zabbix para obter atualizações e correções de segurança.
- O parâmetro `log_bin_trust_function_creators` deve ser habilitado apenas durante a importação do banco quando necessário e, posteriormente, desabilitado para aumentar a segurança.
- Proteja o acesso à interface Web utilizando HTTPS em ambientes de produção.
- As portas padrão do Zabbix são **10050/TCP** (Agent) e **10051/TCP** (Server).
- Antes de colocar o ambiente em produção, altere a senha do banco de dados para uma credencial forte e configure backups periódicos do banco MariaDB.