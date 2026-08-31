## 🔐 IDOR — Insecure Direct Object Reference

O **IDOR (Insecure Direct Object Reference)** é uma vulnerabilidade de **controle de acesso** que ocorre quando uma aplicação utiliza um identificador fornecido pelo usuário para acessar diretamente um recurso **sem verificar se aquele usuário tem permissão para acessá-lo**.

👉 Em outras palavras: o servidor recebe um `ID`, confia nele e entrega o objeto correspondente sem validar a autorização.

> Atualmente, o conceito de IDOR costuma ser tratado dentro de **Broken Access Control**. Além disso, nem todo IDOR precisa ser numérico ou aparecer diretamente na URL.

---

## ⚙️ Como acontece

Imagine uma aplicação que utiliza:

```text
https://site.exemplo/perfil?user_id=1234
```

O usuário autenticado possui o ID:

```text
user_id=1234
```

Ao alterar:

```text
user_id=1233
```

se o servidor retornar o perfil de outro usuário **sem verificar a autorização**, temos uma falha de controle de acesso.

Fluxo vulnerável:

```text
Usuário
   ↓
user_id=1233
   ↓
Servidor
   ↓
Busca usuário 1233
   ↓
❌ Não verifica autorização
   ↓
Dados do usuário 1233
```

---

# 📌 Exemplo

URL original:

```text
https://site.exemplo/perfil?user_id=1234
```

Alteração:

```text
https://site.exemplo/perfil?user_id=1233
```

Se o servidor permitir:

```text
Usuário 1234 → acessa recurso 1233
```

💥 Temos um possível IDOR.

---

## 🛑 O problema não é o ID

Um erro comum é pensar:

> "Se eu criptografar o ID, o IDOR desaparece."

Não necessariamente.

Por exemplo:

```text
/user?id=1234
```

pode virar:

```text
/user?id=a7f3c91...
```

Se o servidor simplesmente decodificar o valor e continuar fazendo:

```text
buscar_recurso(id)
```

sem verificar a autorização, **a falha de controle de acesso continua existindo**.

📌 **A autorização deve ser feita no servidor.**

---

# 💻 Código PHP vulnerável

```php
<?php

$user_id = $_GET['uid'];

$user_info = get_user_info($user_id);

?>
```

O problema é que o servidor está utilizando diretamente um valor controlado pelo cliente.

---

# 🛡️ Implementação mais segura

Uma abordagem é obter a identidade do usuário através da sessão e verificar a autorização no backend:

```php
<?php

$user_id = $_SESSION['uid'];

$user_info = get_user_info($user_id);

?>
```

Para recursos que podem pertencer a outros usuários, é necessário verificar explicitamente a autorização:

```php
<?php

$user_id = $_SESSION['uid'];
$requested_id = $_GET['uid'];

if (!user_can_access($user_id, $requested_id)) {
    http_response_code(403);
    exit('Forbidden');
}

$user_info = get_user_info($requested_id);

?>
```

👉 O ponto principal é:

```text
Identificação ≠ Autorização
```

Saber **quem é o usuário** não significa que ele pode acessar **qualquer recurso**.

---

# 🔎 Onde procurar IDOR

Durante um pentest autorizado, procure identificadores em:

- URLs
- parâmetros GET
- parâmetros POST
- JSON
- cookies
- headers
- IDs de usuários
- IDs de pedidos
- IDs de documentos
- IDs de mensagens
- IDs de arquivos
- UUIDs
- identificadores codificados

Exemplos:

```text
/profile?id=100
/order?id=500
/download?file=123
/api/users/100
/api/orders/500
```

---

# 🧪 Teste manual

Suponha que você esteja autenticado como:

```text
Usuário A
```

e tenha acesso a:

```http
GET /api/profile/100
```

Você pode testar, **dentro do laboratório autorizado**, outro identificador:

```http
GET /api/profile/101
```

Resultado esperado:

```http
403 Forbidden
```

ou:

```http
404 Not Found
```

Se retornar os dados do usuário 101:

```json
{
    "id": 101,
    "name": "Outro Usuário",
    "email": "..."
}
```

💥 Existe um possível problema de controle de acesso.

---

# 🧪 Nível 1 — IDOR simples

No seu laboratório:

```text
https://lab.exemplo/?codinome=24
```

Altere:

```text
codinome=23
```

Depois:

```text
codinome=22
```

E assim sucessivamente.

Se cada identificador retornar o recurso correspondente sem verificar autorização:

```text
24 → recurso A
23 → recurso B
22 → recurso C
21 → recurso D
```

💥 O laboratório demonstra um IDOR baseado em identificadores previsíveis.

---

# 🤖 Automatizando com Burp Suite

O **Burp Suite Intruder** pode automatizar testes de vários identificadores.

### 1. Interceptar a requisição

Exemplo:

```http
GET /?codinome=24 HTTP/1.1
Host: lab.exemplo
```

### 2. Enviar para o Intruder

Marque o parâmetro:

```http
GET /?codinome=§24§ HTTP/1.1
```

### 3. Payload

Configure uma sequência:

```text
1
2
3
4
...
27
```

O Intruder enviará as diferentes requisições e você poderá comparar:

- status HTTP
    
- tamanho da resposta
    
- conteúdo
    
- códigos de erro
    

📌 Diferenças nas respostas podem indicar que diferentes objetos estão sendo acessados.

---

# 🔐 Nível 2 — Identificador codificado

Uma aplicação pode utilizar algo como:

```text
POST /perfil
```

com:

```text
codinome=...
```

O valor pode estar codificado em Base64:

```text
MTAxMQ==
```

Decodificando:

```bash
echo 'MTAxMQ==' | base64 -d
```

Resultado:

```text
1011
```

⚠️ **Base64 não é criptografia.**

É apenas uma codificação.

---

## 🔢 MD5 também não é criptografia reversível

Se o laboratório utilizar:

```text
1011
```

e armazenar:

```text
MD5(1011)
```

isso não significa que o valor esteja protegido contra enumeração.

Em um cenário de laboratório, você pode gerar hashes:

```bash
echo -n "1010" | md5sum
echo -n "1011" | md5sum
echo -n "1012" | md5sum
```

E testar os valores correspondentes.

📌 O problema continua sendo o **controle de autorização no backend**, não o algoritmo utilizado para representar o ID.

---

# 📡 IDOR com POST

IDOR não depende do método HTTP.

Pode acontecer com:

### GET

```http
GET /profile?id=123
```

### POST

```http
POST /profile
Content-Type: application/x-www-form-urlencoded

id=123
```

### JSON

```http
POST /api/profile
Content-Type: application/json

{
    "id": 123
}
```

### REST API

```http
GET /api/users/123
```

---

# 🧩 IDOR não precisa ser numérico

Também pode ocorrer com:

### UUID

```text
/api/document/550e8400-e29b-41d4-a716-446655440000
```

### Nome de arquivo

```text
/download?file=relatorio-paulo.pdf
```

### Identificador codificado

```text
/download?id=MTIz
```

### Identificador complexo

```text
/api/invoices/INV-2026-000123
```

O fato de o identificador ser difícil de adivinhar **não substitui uma verificação de autorização**.

---

# ⚠️ Impactos

Dependendo do recurso exposto, um IDOR pode permitir:

- leitura de dados de outros usuários
- alteração de informações
- acesso a documentos
- acesso a pedidos
- exclusão de recursos
- exposição de informações financeiras
- acesso a informações administrativas
- ações realizadas em nome de outro usuário

A gravidade depende principalmente de **qual recurso pode ser acessado e quais ações podem ser realizadas**.

---

# 🛡️ Como prevenir

### 1. Verificar autorização no backend

```text
Usuário autenticado
        ↓
Qual recurso ele solicitou?
        ↓
Ele possui permissão?
     ↙       ↘
   SIM       NÃO
    ↓         ↓
 Permitir   403/404
```

### 2. Não confiar no identificador enviado pelo cliente

```php
$id = $_GET['id'];
```

não deve significar automaticamente:

```text
"o usuário pode acessar esse objeto"
```

### 3. Usar controle de acesso centralizado

As regras de autorização devem ser aplicadas de forma consistente em todas as rotas e endpoints.

### 4. Aplicar princípio do menor privilégio

Cada usuário deve conseguir acessar somente os recursos necessários para sua função.

---

# 🧠 IDOR vs Autenticação

É importante diferenciar:

```text
Autenticação
     ↓
"Quem é você?"
```

de:

```text
Autorização
     ↓
"O que você pode acessar?"
```

Um IDOR geralmente acontece quando:

```text
✅ usuário autenticado
        +
❌ autorização ausente/incorreta
        ↓
acesso ao recurso de outro usuário
```

---

## 📌 Regra de ouro

👉 **Não importa se o ID é `123`, `1011`, Base64, MD5 ou UUID.**

Se o servidor recebe um identificador e não verifica se o usuário **tem autorização para acessar aquele objeto**, existe potencial para **Broken Access Control/IDOR**.