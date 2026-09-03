# Servidor MongoDB

Este guia apresenta a instalação e configuração básica de um **Servidor MongoDB**, um banco de dados NoSQL orientado a documentos, utilizado em aplicações modernas que necessitam de alta flexibilidade e escalabilidade.

> **Observação:** Diferente dos bancos relacionais tradicionais, o MongoDB armazena dados em documentos BSON (Binary JSON), organizados em coleções.

---

# Topologia

```text
                  Aplicações
                      │
                 TCP Porta 27017
                      │
        +-------------------------------+
        |        MongoDB Server         |
        |      192.168.122.100          |
        |                               |
        |          mongod               |
        +-------------------------------+
```

---

# Estrutura do MongoDB

```text
MongoDB
│
├── Database
│
├── Collection
│
└── Document
        │
        ├── Campo
        ├── Valor
        └── Dados BSON
```

Exemplo:

```json
{
    "nome": "Paulo",
    "idade": 20,
    "email": "paulo@email.com"
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

Instale dependências:

```bash
sudo apt install gnupg curl -y
```

---

# Adicionando o Repositório MongoDB

Importe a chave GPG:

```bash
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server.gpg \
--dearmor
```

Adicione o repositório:

```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

Atualize:

```bash
sudo apt update
```

---

# Instalando MongoDB

```bash
sudo apt install mongodb-org -y
```

---

# Iniciando o Serviço

Habilite:

```bash
sudo systemctl enable mongod
```

Inicie:

```bash
sudo systemctl start mongod
```

Verifique:

```bash
sudo systemctl status mongod
```

---

# Acessando o MongoDB Shell

```bash
mongosh
```

Ver versão:

```javascript
db.version()
```

Sair:

```javascript
exit
```

---

# Criando Banco de Dados

Selecionar ou criar banco:

```javascript
use db_teste
```

Ver bancos:

```javascript
show dbs
```

---

# Criando uma Collection

```javascript
db.createCollection("usuarios")
```

Listar collections:

```javascript
show collections
```

---

# Inserindo Documentos

Inserir um documento:

```javascript
db.usuarios.insertOne(
{
    nome: "Paulo",
    idade: 20,
    email: "paulo@email.com"
}
)
```

Inserir vários:

```javascript
db.usuarios.insertMany(
[
    {
        nome:"Maria",
        idade:25
    },
    {
        nome:"João",
        idade:30
    }
]
)
```

---

# Consultando Dados

Todos os documentos:

```javascript
db.usuarios.find()
```

Formato JSON:

```javascript
db.usuarios.find().pretty()
```

Buscar por campo:

```javascript
db.usuarios.find(
{
    nome:"Paulo"
}
)
```

---

# Atualizando Documentos

Atualizar um documento:

```javascript
db.usuarios.updateOne(
{
    nome:"Paulo"
},
{
    $set:
    {
        idade:21
    }
}
)
```

---

# Removendo Documentos

Remover um documento:

```javascript
db.usuarios.deleteOne(
{
    nome:"Paulo"
}
)
```

Remover vários:

```javascript
db.usuarios.deleteMany({})
```

---

# Criando Usuário Administrador

Acesse:

```bash
mongosh
```

Selecione:

```javascript
use admin
```

Crie usuário:

```javascript
db.createUser(
{
    user:"admin",
    pwd:"SenhaForte123",
    roles:
    [
        {
            role:"root",
            db:"admin"
        }
    ]
}
)
```

---

# Habilitando Autenticação

Edite:

```bash
sudo nano /etc/mongod.conf
```

Localize:

```yaml
security:
```

Adicione:

```yaml
security:
  authorization: enabled
```

Reinicie:

```bash
sudo systemctl restart mongod
```

---

# Acessando com Usuário

```bash
mongosh \
-u admin \
-p SenhaForte123 \
--authenticationDatabase admin
```

---

# Permitindo Acesso Remoto

Edite:

```bash
sudo nano /etc/mongod.conf
```

Altere:

```yaml
net:
  bindIp: 0.0.0.0
  port: 27017
```

Ou restrinja para uma rede:

```yaml
net:
  bindIp: 192.168.122.100
```

Reinicie:

```bash
sudo systemctl restart mongod
```

---

# Firewall

### UFW

```bash
sudo ufw allow 27017/tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd \
--permanent \
--add-port=27017/tcp

sudo firewall-cmd --reload
```

---

# Backup

Backup completo:

```bash
mongodump \
--out /backup/mongodb
```

Backup de um banco:

```bash
mongodump \
--db db_teste \
--out /backup/
```

---

# Restaurando Backup

```bash
mongorestore /backup/mongodb
```

Banco específico:

```bash
mongorestore \
--db db_teste \
/backup/db_teste
```

---

# Comandos Úteis

Status:

```bash
sudo systemctl status mongod
```

Logs:

```bash
sudo journalctl -u mongod
```

Ver processos:

```bash
ps aux | grep mongod
```

Ver porta:

```bash
ss -tlnp | grep 27017
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start mongod
```

Parar:

```bash
sudo systemctl stop mongod
```

Reiniciar:

```bash
sudo systemctl restart mongod
```

Habilitar:

```bash
sudo systemctl enable mongod
```

---

# Arquivos Importantes

```text
/etc/mongod.conf
/var/lib/mongodb/
/var/log/mongodb/mongod.log
```

---

# Porta

| Porta | Protocolo | Serviço |
|--------|-----------|---------|
| 27017 | TCP | MongoDB |

---

# Observações

- O MongoDB utiliza documentos BSON em vez de tabelas e linhas como bancos relacionais.
- Sempre habilite autenticação em ambientes de produção.
- Evite expor a porta 27017 diretamente na Internet.
- Utilize firewall e restrição de IP para conexões externas.
- Realize backups utilizando `mongodump` regularmente.
- Para ambientes críticos, utilize Replica Sets para alta disponibilidade e recuperação automática.