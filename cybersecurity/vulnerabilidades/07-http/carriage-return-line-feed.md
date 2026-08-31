## 💉 CRLF Injection (HTTP Response Splitting)

### 🧠 O que é CRLF Injection?

**CRLF Injection** é uma vulnerabilidade que ocorre quando uma aplicação permite que o usuário injete os caracteres especiais:

- **CR (Carriage Return)** → `\r` → ASCII **13**
- **LF (Line Feed)** → `\n` → ASCII **10**

Em uma requisição HTTP, `CRLF` é utilizado para representar a **quebra de linha** entre cabeçalhos.

👉 Quando uma aplicação não valida corretamente uma entrada controlada pelo usuário, um atacante pode inserir `%0D` e `%0A` para manipular a estrutura da mensagem HTTP.

---

## ⚙️ Como acontece

Imagine uma aplicação que utiliza uma entrada do usuário para criar um cabeçalho:

```http
Location: /pagina?nome=USUARIO
```

Se a entrada não for validada, o atacante pode tentar inserir:

```text
%0D%0A
```

Que representa:

```text
\r\n
```

Isso pode permitir a criação de novos cabeçalhos ou, em determinados cenários, a separação prematura da resposta HTTP.

---

## 📌 Exemplos de impacto

### 🔹 1. Injeção de Header

Se o atacante conseguir controlar uma parte de um cabeçalho, pode tentar adicionar outro:

```http
Location: /pagina
X-Test: injected
```

O segundo cabeçalho foi inserido através da quebra de linha.

---

### 🔹 2. Open Redirect / Phishing

A injeção de um cabeçalho `Location` pode permitir manipular o destino de um redirecionamento:

```http
Location: https://site-malicioso.example
```

💥 A vítima pode ser direcionada para um site controlado pelo atacante.

---

### 🔹 3. HTTP Response Splitting

Um **CRLF duplo**:

```text
\r\n\r\n
```

pode indicar o fim dos cabeçalhos HTTP e o início do corpo da resposta.

Em determinados cenários, isso pode permitir que o atacante influencie o conteúdo retornado pelo servidor.

---

### 🔹 4. XSS

Se a aplicação permitir a injeção de conteúdo HTML/JavaScript após o encerramento dos cabeçalhos, pode existir uma combinação de **CRLF + XSS**.

Por exemplo, um payload codificado poderia conter:

```text
%0D%0A%0D%0A
```

seguido de conteúdo HTML.

⚠️ A exploração depende da forma como o servidor, proxy e navegador processam a resposta.

---

## 🔬 Exemplo

Payload:

```text
http://exemple.com/somepage.php?page=%0d%0aContent-Length:%200%0d%0a%0d%0aHTTP/1.1%20200%200k%0d%0aContent-Type:%20text/html%0d%0aContent-Length:%2025%0d%0a%0d%0a%3Cscript%3Ealert(1)%3C/script%3E
```

Os principais elementos são:

```text
%0d → CR
%0a → LF
%0d%0a%0d%0a → fim dos cabeçalhos
%3C → <
%3E → >
```

O trecho:

```html
<script>alert(1)</script>
```

representa o conteúdo que o atacante tenta inserir na resposta.

---

## 🎯 Objetivos

Uma CRLF Injection pode ser utilizada, dependendo do contexto, para:

- Injetar cabeçalhos HTTP;
- Manipular redirecionamentos;
- HTTP Response Splitting;
- Cache Poisoning;
- Phishing;
- XSS;
- Manipulação da resposta HTTP.

---

## 🛡️ Como prevenir

- Nunca inserir entrada do usuário diretamente em cabeçalhos HTTP;
- Validar e sanitizar entradas;
- Rejeitar `CR` (`\r`) e `LF` (`\n`) quando não forem necessários;
- Utilizar APIs/frameworks que façam o tratamento correto de headers;
- Codificar corretamente dados controlados pelo usuário;
- Manter servidores, proxies e frameworks atualizados.

📌 **Regra de ouro:**

👉 **Dados controlados pelo usuário não devem conseguir alterar a estrutura dos cabeçalhos HTTP.**