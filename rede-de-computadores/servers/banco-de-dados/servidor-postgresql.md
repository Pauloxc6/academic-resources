# Servidor PostgreSQL

Este guia apresenta a instalação e configuração básica do **PostgreSQL**, um sistema de gerenciamento de banco de dados relacional (RDBMS) de código aberto, conhecido por sua robustez, conformidade com padrões SQL e recursos avançados.

> **Observação:** O PostgreSQL é amplamente utilizado em aplicações web, sistemas corporativos, geoprocessamento (PostGIS), análise de dados e aplicações de alta disponibilidade.

---

# Topologia

```text
              Aplicações / Clientes
                      │
                  TCP Porta 5432
                      │
        +-------------------------------+
        |      PostgreSQL Server        |
        |      192.168.122.100          |
        +-------------------------------+
```

---

# Instalação

## Debian / Ubuntu

Atualize os repositórios:

```bash
sudo apt update
```

Instale o PostgreSQL:

```bash
sudo apt install postgresql postgresql-contrib -y
```

---

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install postgresql-server postgresql-contrib -y
```

Inicialize o banco:

```bash
sudo postgresql-setup --initdb
```

---

# Verificando o Serviço

Habilite e inicie o PostgreSQL:

```bash
sudo systemctl enable --now postgresql
```

Verifique o status:

```bash
sudo systemctl status postgresql
```

---

# Acessando o PostgreSQL

Entre como usuário `postgres`:

```bash
sudo -i -u postgres
```

Abra o console:

```bash
psql
```

Verifique a versão:

```sql
SELECT version();
```

Sair:

```sql
\q
```

---

# Criando um Usuário

```sql
CREATE USER paulo
WITH PASSWORD 'SenhaForte123';
```

Conceder privilégios de criação:

```sql
ALTER USER paulo CREATEDB;
```

Tornar administrador (opcional):

```sql
ALTER USER paulo WITH SUPERUSER;
```

Listar usuários:

```sql
\du
```

---

# Criando um Banco de Dados

```sql
CREATE DATABASE db_teste
OWNER paulo;
```

Listar bancos:

```sql
\l
```

Conectar ao banco:

```sql
\c db_teste
```

---

# Criando uma Tabela

```sql
CREATE TABLE tb_usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    senha VARCHAR(255) NOT NULL
);
```

Visualizar tabelas:

```sql
\dt
```

---

# Inserindo Dados

```sql
INSERT INTO tb_usuario
(nome,email,senha)
VALUES
('Paulo',
'paulo@email.com',
'123456');
```

---

# Consultando Dados

Todos os registros:

```sql
SELECT * FROM tb_usuario;
```

Por ID:

```sql
SELECT * FROM tb_usuario
WHERE id = 1;
```

Por nome:

```sql
SELECT * FROM tb_usuario
WHERE nome='Paulo';
```

---

# Atualizando Dados

```sql
UPDATE tb_usuario

SET nome='Paulo Santos'

WHERE id=1;
```

---

# Removendo Dados

```sql
DELETE FROM tb_usuario

WHERE id=1;
```

---

# Removendo Objetos

Excluir tabela:

```sql
DROP TABLE tb_usuario;
```

Excluir banco:

```sql
DROP DATABASE db_teste;
```

Excluir usuário:

```sql
DROP USER paulo;
```

---

# Permitir Conexões Remotas

Edite:

```text
/etc/postgresql/<versão>/main/postgresql.conf
```

Altere:

```conf
listen_addresses='*'
```

---

## Configurando Clientes Permitidos

Edite:

```text
/etc/postgresql/<versão>/main/pg_hba.conf
```

Adicione:

```conf
host    all    all    192.168.122.0/24    md5
```

ou, para versões recentes:

```conf
host    all    all    192.168.122.0/24    scram-sha-256
```

Reinicie:

```bash
sudo systemctl restart postgresql
```

---

# Firewall

### UFW

```bash
sudo ufw allow 5432/tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-service=postgresql
sudo firewall-cmd --reload
```

---

# Backup

Backup de um banco:

```bash
pg_dump db_teste > backup.sql
```

Backup compactado:

```bash
pg_dump -Fc db_teste > backup.dump
```

---

# Restaurando

Arquivo SQL:

```bash
psql db_teste < backup.sql
```

Arquivo compactado:

```bash
pg_restore -d db_teste backup.dump
```

---

# Comandos Úteis

Entrar:

```bash
sudo -u postgres psql
```

Listar bancos:

```sql
\l
```

Listar tabelas:

```sql
\dt
```

Descrever tabela:

```sql
\d tb_usuario
```

Trocar de banco:

```sql
\c db_teste
```

Sair:

```sql
\q
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start postgresql
```

Parar:

```bash
sudo systemctl stop postgresql
```

Reiniciar:

```bash
sudo systemctl restart postgresql
```

Status:

```bash
sudo systemctl status postgresql
```

Habilitar na inicialização:

```bash
sudo systemctl enable postgresql
```

---

# Logs

Visualizar logs:

```bash
sudo journalctl -u postgresql
```

Monitorar em tempo real:

```bash
sudo journalctl -fu postgresql
```

---

# Arquivos Importantes

```text
/etc/postgresql/
/etc/postgresql/<versão>/main/postgresql.conf
/etc/postgresql/<versão>/main/pg_hba.conf
/var/lib/postgresql/
/var/log/postgresql/
```

---

# Porta

| Porta | Protocolo | Serviço |
|--------|-----------|----------|
| 5432 | TCP | PostgreSQL |

---

# Observações

- O PostgreSQL utiliza, por padrão, a porta **5432/TCP**.
- Para ambientes de produção, utilize autenticação **SCRAM-SHA-256**, disponível nas versões mais recentes, em vez de `md5`.
- Permita conexões remotas apenas para redes confiáveis e proteja o acesso com firewall.
- Realize backups periódicos utilizando `pg_dump` ou `pg_basebackup` para garantir a recuperação dos dados.
- O PostgreSQL possui recursos avançados como replicação, alta disponibilidade, particionamento, JSON/JSONB, funções armazenadas e suporte à extensão **PostGIS** para dados geoespaciais.