## 💉 Header Injection (Injeção de Cabeçalho HTTP)

### 🧠 O que é Header Injection?

**HTTP Header Injection** ocorre quando uma aplicação utiliza **dados controlados pelo usuário diretamente na construção de cabeçalhos HTTP**, sem realizar uma validação adequada.

O problema acontece quando o atacante consegue inserir caracteres especiais, principalmente **CR (`\r`) e LF (`\n`)**, permitindo manipular a estrutura da resposta HTTP.

👉 Por isso, **Header Injection e CRLF Injection estão diretamente relacionados**, embora Header Injection seja o conceito mais amplo.

---

## ⚙️ Como acontece

Imagine uma aplicação que utiliza um parâmetro controlado pelo usuário:

```http
Location: /page1
```

O atacante tenta inserir:

```text
/page1%0D%0ALocation:https://vulnweb.com
```

Onde:

```text
%0D → CR (\r)
%0A → LF (\n)
```

Se a aplicação processar esses caracteres de forma insegura, o atacante pode tentar adicionar um novo cabeçalho:

```http
Location: /page1
Location: https://vulnweb.com
```

💥 O navegador pode interpretar o cabeçalho injetado e realizar um redirecionamento.

---

# 🔹 Injeção de Header Refletida

Nesse cenário, o valor enviado pelo atacante é **refletido imediatamente na resposta HTTP**.

Exemplo:

```text
http://example.com/page1%0d%0aLocation:https://vulnweb.com
```

O servidor poderia gerar uma resposta semelhante a:

```http
HTTP/1.1 302 Found
Location: /page1
Location: https://vulnweb.com
```

Dependendo do servidor, navegador e demais componentes envolvidos, isso pode resultar em um redirecionamento.

### 🎯 Possíveis impactos

- Open Redirect;
- Phishing;
- Manipulação de cabeçalhos;
- HTTP Response Splitting;
- Cache Poisoning;
- Em alguns cenários, XSS.

---

# 🔹 Injeção de Header Armazenada

É semelhante à injeção refletida, mas existe uma diferença importante:

👉 **o payload é armazenado pela aplicação antes de ser utilizado em uma resposta HTTP.**

Por exemplo:

```text
Atacante
   ↓
Entrada maliciosa
   ↓
Banco de dados
   ↓
Resposta HTTP
   ↓
Outros usuários
```

Imagine um sistema que armazena o nome fornecido pelo usuário:

```text
Nome: Paulo
```

Um atacante poderia tentar armazenar uma entrada contendo caracteres de controle HTTP.

Posteriormente, se esse valor for utilizado diretamente na construção de um header, a aplicação poderá gerar uma resposta manipulada.

💥 A vulnerabilidade é potencialmente mais grave porque **o valor armazenado pode afetar outros usuários**, dependendo do fluxo da aplicação.

---

## 📌 Refletida × Armazenada

|Tipo|Funcionamento|
|---|---|
|**Refletida**|Entrada → resposta imediatamente|
|**Armazenada**|Entrada → armazenamento → resposta para usuários|

A armazenada tende a ser mais perigosa quando consegue atingir múltiplos usuários.

---

## 🔎 Teste em Pentest

Durante um teste autorizado, procure parâmetros utilizados para gerar headers, principalmente:

```http
Location:
Set-Cookie:
Content-Type:
Content-Disposition:
```

E verifique se entradas controladas pelo usuário conseguem alterar a resposta.

Exemplo conceitual:

```text
normal
```

versus:

```text
normal%0D%0AHeader-Test: injected
```

Se a segunda entrada resultar em um novo cabeçalho na resposta, existe um forte indício de **Header/CRLF Injection**.

---

## 🚨 Impactos

Dependendo do contexto e da infraestrutura:

- Redirecionamento para sites maliciosos;
- Phishing;
- Manipulação de cookies;
- HTTP Response Splitting;
- Cache Poisoning;
- XSS;
- Manipulação de respostas HTTP.

---

## 🛡️ Como prevenir

- **Nunca** confiar diretamente em dados fornecidos pelo usuário;
- Não permitir `CR` e `LF` em valores utilizados em headers;
- Validar entradas de acordo com o contexto;
- Utilizar APIs/frameworks que façam o tratamento correto dos cabeçalhos;
- Evitar construir headers HTTP manualmente;
- Aplicar allow-list quando possível.

📌 **Regra de ouro:**

👉 **Entrada do usuário não deve conseguir controlar a estrutura dos cabeçalhos HTTP.**

**Resumo:**  
**CRLF Injection** é uma das principais técnicas que podem resultar em **Header Injection**. A diferença prática é que _Header Injection_ descreve o impacto de conseguir manipular cabeçalhos, enquanto _CRLF Injection_ descreve uma técnica comum para inserir novas linhas e cabeçalhos.