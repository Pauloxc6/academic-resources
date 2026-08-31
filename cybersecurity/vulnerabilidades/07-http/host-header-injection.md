## 🎯 Host Header Injection

### 🧠 O que é Host Header Injection?

**Host Header Injection** é uma vulnerabilidade que ocorre quando uma aplicação **confia indevidamente no valor do cabeçalho HTTP `Host` enviado pelo cliente**.

O atacante modifica o domínio informado no cabeçalho para fazer a aplicação gerar links, redirecionamentos ou outras respostas utilizando um domínio controlado pelo atacante.

👉 O problema não está no cabeçalho `Host` em si, mas em **como a aplicação utiliza esse valor**.

---

## 🌐 O que é o cabeçalho HTTP `Host`?

O `Host` informa ao servidor **qual domínio/host o cliente deseja acessar**.

Exemplo:

```http
GET /web-security HTTP/1.1
Host: portswigger.net
```

Nesse caso, o cliente está solicitando:

```text
Host → portswigger.net
Path → /web-security
```

---

## 💥 Manipulação do Host

### Original

```http
GET /web-security HTTP/1.1
Host: portswigger.net
```

### Falsificada

```http
GET /web-security HTTP/1.1
Host: hacker.net
```

Se a aplicação confiar nesse valor sem validação, ela pode utilizar `hacker.net` em alguma operação.

---

# 📌 Exemplos de exploração

### 🔹 1. Password Reset Poisoning

Imagine um sistema que envia um e-mail de recuperação de senha.

A aplicação gera:

```text
https://portalsite.com/reset?token=ABC123
```

Porém, se o link for construído utilizando diretamente o `Host`:

```text
https://[Host]/reset?token=ABC123
```

um atacante pode tentar enviar uma requisição com:

```http
Host: hacker.net
```

A aplicação poderia gerar:

```text
https://hacker.net/reset?token=ABC123
```

💥 Se esse link for enviado à vítima, o token de redefinição pode acabar sendo exposto ao domínio controlado pelo atacante.

---

### 🔹 2. Open Redirect

Uma aplicação pode utilizar o `Host` para construir redirecionamentos:

```http
Host: hacker.net
```

e posteriormente gerar:

```http
Location: https://hacker.net/
```

💥 Isso pode transformar uma funcionalidade legítima em um redirecionamento controlado pelo atacante.

---

### 🔹 3. XSS

Em aplicações que utilizam o `Host` diretamente dentro de HTML, JavaScript ou outros contextos, uma entrada inadequadamente tratada pode contribuir para **XSS**.

Exemplo conceitual:

```http
Host: valor-controlado-pelo-atacante
```

Se esse valor for refletido em uma página sem o devido tratamento, pode existir uma segunda vulnerabilidade dependendo do contexto.

---

## 🔎 Teste em Pentest

Durante um teste autorizado, compare:

### Requisição normal

```http
GET / HTTP/1.1
Host: exemplo.com
```

### Requisição modificada

```http
GET / HTTP/1.1
Host: teste.externo
```

Observe se o valor alterado aparece em:

- `Location`;
- links absolutos;
- páginas HTML;
- e-mails;
- URLs de recuperação de senha;
- respostas da aplicação;
- geração de conteúdo.

Também é importante testar o comportamento de **proxies, load balancers e servidores web**, pois diferentes camadas podem interpretar o `Host` de maneiras diferentes.

---

## 🚨 Impactos

Dependendo da aplicação, pode resultar em:

- Password Reset Poisoning;
- Open Redirect;
- XSS;
- Cache Poisoning;
- geração de URLs maliciosas;
- phishing;
- manipulação de links enviados aos usuários.

---

## 🛡️ Como prevenir

- Não confiar cegamente no `Host`;
- Utilizar uma **allow-list de hosts válidos**;
- Configurar corretamente o domínio canônico da aplicação;
- Não utilizar o `Host` para operações sensíveis quando isso puder ser evitado;
- Usar uma URL/base URL configurada no servidor para gerar links;
- Validar o `Host` antes de utilizá-lo em redirecionamentos, e-mails ou links;
- Configurar corretamente proxies reversos e servidores web.

📌 **Regra de ouro:**

> **O cabeçalho `Host` vem do cliente e, portanto, deve ser tratado como entrada não confiável.**

**Resumo:**

```text
Cliente
   │
   │ Host: hacker.net
   ▼
Servidor
   │
   ├── confia no Host ❌
   │
   └── utiliza hacker.net
             │
             ▼
      comportamento manipulado
```