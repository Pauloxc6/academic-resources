## 🛡️ CSRF — Cross-Site Request Forgery

O **CSRF (Cross-Site Request Forgery)** é uma vulnerabilidade que permite que um atacante faça o navegador da vítima **enviar uma requisição para uma aplicação na qual ela já está autenticada**, tentando induzir a vítima a executar uma ação que não pretendia.

👉 O ataque explora principalmente a forma como **cookies de autenticação são enviados automaticamente pelo navegador**.

---

## ⚙️ Como funciona

O cenário clássico:

```text
Vítima
  ↓
Login no banco
  ↓
Servidor envia cookie de sessão
  ↓
Navegador armazena o cookie
```

A partir daí:

```text
Navegador
    │
    ├── banco.com → cookie de autenticação
    │
    └── atacante.com
```

A vítima continua autenticada no banco mesmo quando acessa outro site.

💥 Se o banco aceitar uma requisição sensível sem exigir uma prova adicional de que ela foi realmente iniciada pelo próprio site, o atacante pode tentar induzir o navegador a enviá-la.

---

# 🎯 Cenário clássico

### 1. A vítima faz login

```text
https://banco.exemplo/login
```

O servidor responde com um cookie:

```http
Set-Cookie: session=abc123
```

O navegador passa a enviar esse cookie automaticamente nas requisições destinadas ao domínio correspondente.

---

### 2. A vítima acessa um site malicioso

Por exemplo:

```text
https://site-atacante.exemplo
```

A página contém uma requisição direcionada ao banco.

---

### 3. Formulário forjado

```html
<form
    id="meuForm"
    action="https://banco.exemplo/transferir"
    method="POST">

    <input type="hidden" name="para" value="Kennedy">
    <input type="hidden" name="valor" value="100">

</form>
```

O formulário tenta reproduzir uma requisição legítima da aplicação.

---

### 4. Envio automático

```javascript
document.getElementById("meuForm").submit();
```

O navegador envia a requisição para o banco.

Se as condições para CSRF estiverem presentes, o navegador pode incluir automaticamente os cookies aplicáveis ao domínio de destino.

---

# 🔄 Fluxo do ataque

```text
┌──────────────┐
│    Vítima    │
└──────┬───────┘
       │
       │ Login
       ▼
┌──────────────┐
│ Banco        │
└──────┬───────┘
       │
       │ Cookie
       ▼
┌──────────────┐
│ Navegador    │
└──────┬───────┘
       │
       │ acessa site externo
       ▼
┌──────────────┐
│ Site atacante│
└──────┬───────┘
       │
       │ requisição forjada
       ▼
┌──────────────┐
│ Banco        │
└──────────────┘
```

---

# 🧠 Por que os cookies são importantes?

O navegador normalmente gerencia os cookies automaticamente.

Imagine:

```http
Cookie: session=abc123
```

A aplicação utiliza esse cookie para identificar a sessão autenticada.

O problema ocorre quando o servidor aceita uma requisição apenas porque ela possui uma sessão válida:

```text
Requisição
    +
Cookie válido
    ↓
Servidor
    ↓
Executa ação
```

Nesse cenário, o servidor pode não saber se a requisição foi realmente iniciada pelo usuário dentro da interface legítima.

👉 **Ter uma sessão autenticada não deveria ser a única prova de intenção para operações sensíveis.**

---

# 💉 Exemplo de requisição

Uma requisição legítima poderia ser:

```http
POST /transferir HTTP/1.1
Host: banco.exemplo
Content-Type: application/x-www-form-urlencoded
Cookie: session=abc123

para=Kennedy&valor=100
```

Em um cenário vulnerável, uma página externa poderia tentar induzir o navegador a enviar parâmetros semelhantes.

---

# 🔐 CSRF Token

Uma das principais defesas é utilizar um **CSRF Token**.

A aplicação gera um valor aleatório:

```html
<input
    type="hidden"
    name="csrf_token"
    value="8f3a91c2...">
```

O servidor espera receber esse token:

```text
Requisição
   ↓
Cookie de sessão
+
CSRF Token
   ↓
Servidor
```

Se o token estiver ausente ou inválido:

```text
❌ Requisição rejeitada
```

💡 O atacante não deve conseguir simplesmente reproduzir uma requisição válida sem conhecer o token associado à sessão.

---

# 🧪 Exemplo

### Página legítima

```html
<form method="POST" action="/alterar-email">

    <input type="email" name="email">

    <input
        type="hidden"
        name="csrf_token"
        value="abc123xyz">

    <button>Alterar</button>

</form>
```

O servidor verifica:

```text
CSRF Token recebido
       ↓
Token esperado?
       ↓
   ┌───┴───┐
  SIM     NÃO
   ↓       ↓
Aceita   Rejeita
```

---

# 🍪 SameSite Cookie

Outra proteção importante é o atributo `SameSite` dos cookies.

Exemplo:

```http
Set-Cookie: session=abc123; Secure; HttpOnly; SameSite=Lax
```

Valores comuns:

```text
SameSite=Strict
SameSite=Lax
SameSite=None
```

### `Strict`

Restringe bastante o envio do cookie em contextos cross-site.

### `Lax`

Permite determinados cenários cross-site, mas restringe muitos contextos de envio.

### `None`

Permite envio cross-site, normalmente exigindo:

```text
Secure
```

📌 A configuração adequada depende do funcionamento da aplicação.

---

# 🛡️ Outras defesas

Além do CSRF Token e `SameSite`, aplicações podem utilizar:

- verificar `Origin`
- verificar `Referer` quando apropriado
- exigir reautenticação para operações críticas
- utilizar autenticação adicional para ações sensíveis
- não utilizar métodos GET para operações que alteram estado

Por exemplo, evite:

```http
GET /delete-account
```

Prefira um método apropriado:

```http
POST /delete-account
```

e proteja a operação contra CSRF.

---

# ⚠️ CSRF ≠ XSS

São vulnerabilidades diferentes.

### CSRF

```text
Site atacante
      ↓
induz navegador
      ↓
requisição para site legítimo
      ↓
ação executada
```

### XSS

```text
Aplicação vulnerável
      ↓
JavaScript injetado
      ↓
executado no navegador
```

📌 Um **XSS pode, em determinadas situações, contornar mecanismos de proteção contra CSRF**, porque o código malicioso passa a executar dentro do contexto da aplicação vulnerável.

---

# 🧪 Em pentest

Procure principalmente funcionalidades que **alteram estado**, como:

- alteração de e-mail
- alteração de senha
- alteração de endereço
- mudança de configurações
- criação/exclusão de recursos
- ações administrativas

Verifique se a requisição possui mecanismos como:

```text
CSRF Token
Origin
Referer
SameSite
```

E, principalmente, se o servidor **realmente valida essas proteções**.

---

## 🚨 Impactos

Dependendo da funcionalidade vulnerável:

- alteração de dados
- alteração de configurações
- criação de recursos
- exclusão de recursos
- ações administrativas
- fraude
- alteração de informações da conta

O impacto depende diretamente dos **privilégios da vítima**.

---

## 📌 Regra de ouro

👉 **Uma requisição autenticada não deve ser considerada automaticamente uma requisição autorizada pelo usuário.**

Para operações sensíveis, o servidor deve exigir uma **prova adicional de intenção**, como um CSRF Token, além de configurar corretamente os cookies e as políticas de origem.