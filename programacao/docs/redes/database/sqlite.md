![Status](https://img.shields.io/badge/status-completo-brightgreen)
![Versão](https://img.shields.io/badge/version-1.1-blue)

# 📖 Guia SQLite3 com Bash Scripting e Segurança

Este guia oferece uma introdução completa ao **SQLite3** com foco em integração com **Bash Scripting** e melhores práticas de **segurança**.  
Ideal para administradores de sistemas, analistas de segurança e desenvolvedores que desejam persistência de dados em scripts shell.

---

## 📋 Índice

1. [Introdução ao SQLite3](#-introdução-ao-sqlite3)
2. [Instalação e Configuração](#-instalação-e-configuração)
3. [Operações Básicas via CLI](#-operações-básicas-via-cli)
4. [Integração com Bash Scripting](#-integração-com-bash-scripting)
5. [Segurança em SQLite3 com Bash](#-segurança-em-sqlite3-com-bash)
6. [Transações e Controle de Concorrência](#-transações-e-controle-de-concorrência)
7. [Exemplo Prático: Sistema de Logs](#-exemplo-prático-sistema-de-logs)
8. [Ferramentas e Boas Práticas](#-ferramentas-e-boas-práticas)
9. [Referências](#-referências)

---

## 🚀 Introdução ao SQLite3

SQLite3 é um banco de dados SQL **embutido, leve e autônomo**, ideal para:

- Aplicações locais e dispositivos com recursos limitados
- Prototipagem rápida e armazenamento estruturado
- Scripts em Bash que necessitam de persistência de dados

**Vantagens**:

- ✅ Zero configuração (um único arquivo `.db`)
- ✅ Suporte a transações ACID
- ✅ Compatível com SQL padrão

---

## 🔧 Instalação e Configuração

**Linux (Debian/Ubuntu):**

```
sudo apt update && sudo apt install sqlite3
```

**Windows**:

- Baixe em [sqlite.org](https://sqlite.org/download.html)
- Extraia e adicione ao **PATH**

**Verificação**:

```
sqlite3 --version
```

---

## 💻 Operações Básicas via CLI

**Criar/Conectar a um banco**:

```
sqlite3 meu_banco.db
```

**Comandos úteis**:

```sql
.tables                 -- Lista todas as tabelas
.schema tabela          -- Exibe a estrutura de uma tabela
.mode column            -- Formata a saída em colunas
.headers on             -- Mostra cabeçalhos das colunas
.quit                   -- Sai do terminal
```

**Exemplo de criação de tabela**:

```sql
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT UNIQUE,
    idade INTEGER
);
```

---

## 📝 Integração com Bash Scripting

**Executar query diretamente**:

```
sqlite3 banco.db "SELECT * FROM usuarios;"
```

**Usando variáveis**:

```bash
DB="app.db"
NOME="Carlos"
EMAIL="carlos@email.com"

sqlite3 "$DB" "INSERT INTO usuarios (nome, email) VALUES ('$NOME', '$EMAIL');"
```

**Capturar saída em variável**:

```bash
ULTIMO_ID=$(sqlite3 "$DB" "INSERT INTO usuarios (nome) VALUES ('Maria'); SELECT last_insert_rowid();")
echo "ID do novo registro: $ULTIMO_ID"
```

**Loop em consultas**:

```bash
sqlite3 "$DB" "SELECT nome, idade FROM usuarios;" | while read -r nome idade; do
    echo "Usuário: $nome, Idade: $idade"
done
```

---

## 🔒 Segurança em SQLite3 com Bash

**SQL Injection (NUNCA faça)**:

```bash
# Vulnerável
sqlite3 "$DB" "SELECT * FROM usuarios WHERE nome = '$NOME';"

# Seguro (placeholders):
sqlite3 -cmd ".parameter set @player '$NOME'" "$DB" "SELECT * FROM usuarios WHERE nome = @player;"
```

**Validação de entrada**:

```bash
if [[ ! "$NOME" =~ ^[A-Za-z\s]+$ ]]; then
    echo "Nome inválido!"
    exit 1
fi
```

**Backup automático**:

```bash
DB="app.db"
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"
sqlite3 "$DB" ".backup $BACKUP_DIR/backup_$(date +%Y%m%d).db"
```

**Criptografia com OpenSSL**:

```bash
SENHA_CRIPTOGRAFADA=$(echo "senha_secreta" | openssl enc -aes-256-cbc -salt -a)
sqlite3 "$DB" "INSERT INTO usuarios (nome, senha) VALUES ('joao', '$SENHA_CRIPTOGRAFADA');"
```

---

## 🔄 Transações e Controle de Concorrência

**Transações em lote**:

```sql
sqlite3 "$DB" <<EOF
BEGIN TRANSACTION;
INSERT INTO usuarios (nome) VALUES ('Alice');
INSERT INTO usuarios (nome) VALUES ('Bob');
COMMIT;
EOF
```

**Tratamento de concorrência (SQLITE_BUSY)**:

```bash
for tentativa in {1..3}; do
    sqlite3 "$DB" "INSERT INTO usuarios (nome) VALUES ('Teste');" && break
    sleep 1
done
```

---

## 📊 Exemplo Prático: Sistema de Logs

**Tabela de logs**:

```sql
CREATE TABLE logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mensagem TEXT,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Script de log (log.sh)**:

```bash
#!/bin/bash
DB="app.db"
MENSAGEM="$1"

sqlite3 -cmd ".parameter set @msg '$MENSAGEM'" "$DB" "INSERT INTO logs (mensagem) VALUES (@msg);"
echo "Log registrado: $MENSAGEM"
```

Uso:

```
./log.sh "Usuário admin fez login"
```

---

## 🛠️ Ferramentas e Boas Práticas

    DB Browser for SQLite → sqlitebrowser.org

**EXPLAIN QUERY PLAN para análise de consultas**:

```
sqlite3 "$DB" "EXPLAIN QUERY PLAN SELECT * FROM usuarios WHERE idade > 30;"
```

Compactação com VACUUM:

```
sqlite3 "$DB" "VACUUM;"
```

---

## 📚 Referências

- Documentação Oficial: [sqlite.org/docs.html](https://sqlite.org/docs.html)

- SQLite Tutorial: [sqlitetutorial.net](https://sqlitetutorial.net)

- Bash Guide: [mywiki.wooledge.org/BashGuide](https://mywiki.wooledge.org/BashGuide)

---

## 📜 Licença

[MIT License](../../../../LICENSE) © 2025 Pauloxc6
