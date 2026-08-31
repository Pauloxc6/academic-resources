## 🗄️ Banco de Dados NoSQL

Os bancos de dados **NoSQL (Not Only SQL)** são bancos de dados que utilizam modelos diferentes do modelo relacional tradicional dos bancos SQL.

👉 Eles são muito utilizados em aplicações que precisam trabalhar com **grandes volumes de dados, estruturas flexíveis e escalabilidade horizontal**.

O termo NoSQL ganhou popularidade principalmente a partir do final dos anos 2000.

---

## 📌 Tipos de bancos NoSQL

Os principais modelos são:

|Key-Value|Document|Column-Family|Graph|
|---|---|---|---|
|Redis|MongoDB|Cassandra|Neo4j|
|Memcached|CouchDB|HBase|OrientDB|

Cada modelo organiza os dados de uma maneira diferente.

### 🔹 Key-Value

Armazena dados no formato:

```text
chave → valor
```

Exemplo:

```text
usuario:123 → Paulo
```

Exemplos:

- Redis
- Memcached

---

### 🔹 Document

Armazena dados como documentos, geralmente utilizando estruturas semelhantes a JSON.

```json
{
  "username": "paulo",
  "idade": 20
}
```

Exemplos:

- MongoDB
- CouchDB

---

### 🔹 Column-Family

Organiza os dados em famílias de colunas.

Exemplos:

- Cassandra
- HBase

---

### 🔹 Graph

Representa informações através de **nós e relacionamentos**.

```text
Paulo
  ↓ amigo
João
  ↓ trabalha_com
Maria
```

Exemplos:

- Neo4j
- OrientDB

---

## ⚙️ Principais diferenças entre SQL e NoSQL

### SQL

Normalmente utiliza:

```text
Tabelas
   ↓
Linhas
   ↓
Colunas
```

Exemplo:

```text
users
----------------------
id | username | email
1  | paulo    | ...
```

### NoSQL

Pode utilizar documentos:

```json
{
  "_id": 1,
  "username": "paulo",
  "email": "paulo@example.com"
}
```

Algumas características comuns do NoSQL:

- modelo de dados não relacional
- esquema mais flexível
- possibilidade de escalabilidade horizontal
- diferentes modelos de armazenamento
- documentos podem possuir estruturas diferentes
- não depende necessariamente de SQL

📌 **Importante:** dizer que NoSQL significa simplesmente "sem linguagem de consulta" é incorreto. Alguns bancos NoSQL possuem **suas próprias linguagens ou APIs de consulta**.

---

# 🍃 MongoDB

O **MongoDB** é um dos bancos NoSQL mais conhecidos e utiliza o modelo baseado em **documentos**.

Um documento pode ser representado como:

```json
{
  "username": "paulo",
  "email": "paulo@example.com",
  "idade": 20
}
```

Uma coleção pode conter vários documentos:

```text
users
 ├── documento 1
 ├── documento 2
 └── documento 3
```

👉 Por ser muito utilizado, o MongoDB é frequentemente usado como exemplo para estudar **NoSQL Injection**.

---

# 💉 NoSQL Injection

A **NoSQL Injection** acontece quando dados controlados pelo usuário conseguem modificar a **estrutura ou lógica da consulta NoSQL**.

Fluxo:

```text
Entrada do usuário
       ↓
Aplicação
       ↓
Consulta NoSQL
       ↓
Banco de dados
```

Se a aplicação confiar diretamente na entrada:

```text
usuário → consulta
```

💥 o atacante pode tentar introduzir operadores ou estruturas que alterem a consulta original.

---

## 🔎 Encontrando a Injeção

Primeiro, identifique onde a aplicação interage com o banco.

Locais comuns:

- formulários de autenticação
- formulários de pesquisa
- filtros
- parâmetros GET/POST
- JSON
- cookies
- headers
- APIs

Exemplo:

```http
GET /posts?author=paulo
```

A aplicação pode utilizar:

```text
author = "paulo"
```

para construir uma consulta.

---

## 🧪 Teste de entradas

Durante um teste autorizado, tente identificar como a aplicação reage a caracteres e estruturas especiais:

```text
'
"
\
;
{
}
(
)
```

💥 Uma alteração no comportamento, erro ou resposta pode indicar que a entrada está chegando ao mecanismo de consulta de maneira inadequada.

📌 Nem todo erro significa NoSQL Injection. É necessário analisar o comportamento da aplicação e o banco utilizado.

---

# 🧠 Injeção de JavaScript em consultas

Algumas aplicações legadas ou configurações específicas podem utilizar **JavaScript na lógica das consultas**.

Por exemplo, uma aplicação poderia gerar uma condição equivalente a:

```javascript
this.hidden == false && this.author == 'paulo'
```

Uma entrada especialmente manipulada poderia alterar a lógica:

```text
' || '' == '
```

resultando conceitualmente em:

```javascript
this.hidden == false && this.author == ''
|| '' == ''
```

Como:

```text
'' == '' → verdadeiro
```

a condição pode acabar sendo sempre verdadeira.

💥 Em uma aplicação vulnerável, isso poderia resultar no retorno de registros que não deveriam ser retornados.

📌 Esse tipo de exploração depende da utilização de **JavaScript dentro do mecanismo de consulta** e não representa o comportamento normal de todas as aplicações MongoDB.

---

# 🚨 NoSQL Injection em autenticação

Um cenário bastante conhecido ocorre em formulários de login.

Aplicação:

```json
{
  "username": "admin",
  "password": "senha"
}
```

Uma aplicação vulnerável pode aceitar operadores NoSQL onde deveria receber apenas uma string.

Por exemplo:

```json
{
  "username": "admin",
  "password": {
    "$ne": ""
  }
}
```

`$ne` significa:

```text
Not Equal
↓
Diferente de
```

A lógica pode acabar sendo equivalente a:

```text
password != ""
```

💥 Se a aplicação não validar corretamente o tipo e a estrutura dos dados recebidos, isso pode contribuir para um **bypass de autenticação**.

---

## 🔹 Operadores NoSQL comuns

Alguns operadores do MongoDB que devem ser conhecidos durante o estudo:

```text
$eq      → igual
$ne      → diferente
$gt      → maior que
$gte     → maior ou igual
$lt      → menor que
$lte     → menor ou igual
$in      → está dentro de
$nin     → não está dentro
$regex   → expressão regular
```

Exemplo:

```json
{
  "username": {
    "$eq": "admin"
  }
}
```

---

# 💥 Negação de Serviço

Algumas implementações vulneráveis podem permitir que entradas provoquem processamento excessivo.

Um exemplo histórico envolve consultas que executam JavaScript:

```text
';while(1);
```

💥 Se uma aplicação realmente avaliar esse JavaScript dentro da consulta, um loop infinito pode consumir recursos do servidor.

📌 Esse cenário é **específico de mecanismos/configurações que permitem execução de JavaScript** e não deve ser generalizado para todo MongoDB.

---

# 🧪 Payloads de teste

Em um **laboratório autorizado**, alguns exemplos para estudar diferentes comportamentos são:

### 🔹 Operador `$ne`

```json
{
  "username": "admin",
  "password": {
    "$ne": ""
  }
}
```

### 🔹 `$regex`

```json
{
  "username": {
    "$regex": "^m"
  }
}
```

### 🔹 `$eq`

```json
{
  "username": {
    "$eq": "admin"
  }
}
```

📌 Payloads como:

```text
'||11//
```

estão associados a cenários específicos de **injeção em consultas JavaScript** e não devem ser tratados como payload universal de MongoDB.

---

## 🔎 Em pentest

A metodologia pode ser organizada assim:

```text
1. Encontrar entrada
       ↓
2. Identificar o tipo de banco
       ↓
3. Observar comportamento normal
       ↓
4. Alterar tipo/estrutura da entrada
       ↓
5. Testar operadores
       ↓
6. Comparar respostas
       ↓
7. Confirmar impacto
```

Ferramentas como **NoSQLMap** podem auxiliar na identificação automatizada de alguns cenários.

👉 Porém, aplicações modernas frequentemente exigem **análise manual, revisão do código e compreensão de como o backend constrói a consulta**.

---

## 🚨 Impactos

Dependendo da implementação, NoSQL Injection pode permitir:

- bypass de autenticação
- acesso a registros não autorizados
- manipulação de consultas
- exposição de informações
- alteração de dados
- execução de operações não previstas
- negação de serviço em determinados cenários

---

## 🛡️ Como prevenir

- validar **tipo e estrutura** dos dados recebidos
- aceitar somente os campos esperados
- bloquear operadores NoSQL onde não são necessários
- não permitir que o usuário controle diretamente objetos de consulta
- utilizar APIs/ORMs de forma segura
- evitar execução de JavaScript em consultas quando não necessária
- aplicar autenticação e autorização no servidor
- limitar privilégios do usuário do banco
- manter o MongoDB e bibliotecas atualizados

📌 Um ponto especialmente importante:

```text
"password": "senha"
```

é diferente de:

```json
"password": {
  "$ne": ""
}
```

👉 O backend deve garantir que `password` seja realmente uma **string**, e não permitir que o usuário transforme esse campo em um **objeto contendo operadores de consulta**.

---

📌 **Regra de ouro:**

👉 **Nunca permita que o usuário controle diretamente a estrutura da consulta NoSQL.**