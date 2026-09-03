# Servidor Redis

Este guia apresenta a instalação e configuração básica de um **Servidor Redis**, um banco de dados NoSQL em memória utilizado para cache, filas, sessões, armazenamento temporário e sistemas de alta performance.

> **Observação:** O Redis armazena os dados principalmente em memória RAM, oferecendo baixa latência e alta velocidade de leitura e escrita.

---

# Topologia

```text
                  Aplicações
                      │
                TCP Porta 6379
                      │
        +-------------------------------+
        |          Redis Server         |
        |      192.168.122.100          |
        |                               |
        |          redis-server         |
        +-------------------------------+
```

---

# Estrutura do Redis

```text
Redis

├── Key
│
└── Value

Exemplo:

usuario:1000
        │
        ▼
{
 "nome":"Paulo",
 "cargo":"admin"
}
```

---

# Instalação

## Debian / Ubuntu

Atualize os pacotes:

```bash
sudo apt update
sudo apt upgrade -y
```

Instale o Redis:

```bash
sudo apt install redis-server -y
```

---

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install redis -y
```

---

# Iniciando o Serviço

Habilitar inicialização automática:

```bash
sudo systemctl enable redis-server
```

Iniciar:

```bash
sudo systemctl start redis-server
```

Verificar:

```bash
sudo systemctl status redis-server
```

---

# Testando o Redis

Utilize o cliente:

```bash
redis-cli
```

Teste:

```redis
PING
```

Resposta esperada:

```text
PONG
```

---

# Comandos Básicos Redis

## Criar uma chave

```redis
SET nome "Paulo"
```

---

## Consultar valor

```redis
GET nome
```

Resultado:

```text
Paulo
```

---

## Remover chave

```redis
DEL nome
```

---

## Listar chaves

```redis
KEYS *
```

---

## Verificar existência

```redis
EXISTS nome
```

---

# Trabalhando com Expiração

Criar uma chave com tempo:

```redis
SET sessao "usuario1" EX 3600
```

Ver tempo restante:

```redis
TTL sessao
```

Remover expiração:

```redis
PERSIST sessao
```

---

# Tipos de Dados Redis

## Strings

```redis
SET contador 10

INCR contador
```

---

## Listas

Adicionar:

```redis
LPUSH fila "tarefa1"
```

Consultar:

```redis
LRANGE fila 0 -1
```

---

## Sets

Adicionar:

```redis
SADD usuarios paulo
```

Listar:

```redis
SMEMBERS usuarios
```

---

## Hash

Criar objeto:

```redis
HSET usuario:1 nome Paulo idade 20
```

Consultar:

```redis
HGETALL usuario:1
```

---

# Configuração do Redis

Arquivo principal:

```bash
sudo nano /etc/redis/redis.conf
```

---

# Permitindo Acesso Remoto

Por padrão o Redis aceita apenas conexões locais.

Procure:

```conf
bind 127.0.0.1
```

Altere:

```conf
bind 0.0.0.0
```

ou restrinja:

```conf
bind 192.168.122.100
```

---

# Configurando Senha

No arquivo:

```bash
sudo nano /etc/redis/redis.conf
```

Localize:

```conf
# requirepass foobared
```

Altere:

```conf
requirepass SenhaForte123
```

Reinicie:

```bash
sudo systemctl restart redis-server
```

---

# Acessando com Senha

```bash
redis-cli
```

Autenticar:

```redis
AUTH SenhaForte123
```

ou:

```bash
redis-cli -a SenhaForte123
```

---

# Persistência de Dados

O Redis possui dois métodos:

## RDB (Snapshots)

Configuração:

```conf
save 900 1
save 300 10
save 60 10000
```

---

## AOF (Append Only File)

Habilitar:

```conf
appendonly yes
```

Reiniciar:

```bash
sudo systemctl restart redis-server
```

---

# Backup

Criar snapshot manual:

```redis
SAVE
```

Arquivo gerado:

```text
/var/lib/redis/dump.rdb
```

Copiar:

```bash
cp /var/lib/redis/dump.rdb /backup/
```

---

# Firewall

### UFW

```bash
sudo ufw allow 6379/tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd \
--permanent \
--add-port=6379/tcp

sudo firewall-cmd --reload
```

---

# Testando Conexão Remota

Cliente:

```bash
redis-cli \
-h 192.168.122.100 \
-p 6379
```

Com senha:

```bash
redis-cli \
-h 192.168.122.100 \
-a SenhaForte123
```

Teste:

```redis
PING
```

---

# Monitoramento

Ver informações do servidor:

```redis
INFO
```

Memória utilizada:

```redis
INFO memory
```

Clientes conectados:

```redis
CLIENT LIST
```

Monitorar comandos:

```redis
MONITOR
```

---

# Comandos Úteis

Ver versão:

```bash
redis-server --version
```

Teste rápido:

```bash
redis-cli ping
```

Ver processos:

```bash
ps aux | grep redis
```

Ver porta:

```bash
ss -tlnp | grep 6379
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start redis-server
```

Parar:

```bash
sudo systemctl stop redis-server
```

Reiniciar:

```bash
sudo systemctl restart redis-server
```

Status:

```bash
sudo systemctl status redis-server
```

Habilitar:

```bash
sudo systemctl enable redis-server
```

---

# Arquivos Importantes

```text
/etc/redis/redis.conf
/var/lib/redis/
/var/log/redis/redis-server.log
```

---

# Porta

| Porta | Protocolo | Serviço |
|--------|-----------|---------|
| 6379 | TCP | Redis |

---

# Casos de Uso

- Cache de aplicações Web
- Armazenamento de sessões
- Filas de processamento
- Sistemas de ranking
- Contadores em tempo real
- Rate limiting
- Pub/Sub
- Caches para APIs

---

# Observações

- O Redis é extremamente rápido por trabalhar principalmente em memória RAM.
- Em ambientes de produção, nunca deixe o Redis exposto diretamente na Internet.
- Sempre utilize autenticação, firewall e restrição de rede.
- Para ambientes críticos, utilize Redis Sentinel ou Redis Cluster para alta disponibilidade.
- Configure persistência (`RDB` ou `AOF`) caso os dados precisem sobreviver a reinicializações.