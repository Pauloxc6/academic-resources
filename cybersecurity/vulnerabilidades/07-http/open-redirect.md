## 🔀 Open Redirect (Redirecionamento Aberto)

### 🧠 O que é Open Redirect?

**Open Redirect**, também conhecido como **Unvalidated Redirects and Forwards**, é uma vulnerabilidade que ocorre quando uma aplicação aceita **URLs ou destinos controlados pelo usuário** e utiliza esses valores para redirecioná-lo sem uma validação adequada.

👉 O problema acontece quando o servidor confia em um parâmetro como `url`, `next`, `redirect` ou `returnUrl` e permite que ele aponte para **qualquer domínio externo**.

---

## ⚙️ Como acontece

Imagine uma aplicação que possui:

```text
https://example.com/Login.php?ReturnUrl=/admin.php
```

Depois do login, o usuário é redirecionado para:

```text
https://example.com/admin.php
```

O problema aparece quando o parâmetro pode receber uma URL externa:

```text
https://example.com/Login.php?ReturnUrl=https://attacker.example
```

Após realizar o login:

```text
example.com
     │
     │ Login
     ▼
Redirecionamento
     │
     ▼
attacker.example
```

💥 O usuário acredita que está acessando um link legítimo de `example.com`, mas acaba sendo direcionado para outro domínio.

---

## 🎣 Open Redirect + Phishing

Esse é um dos usos mais comuns da vulnerabilidade.

Um atacante pode enviar:

```text
https://example.com/Login.php?ReturnUrl=https://attacker.example
```

O início da URL parece legítimo:

```text
https://example.com/
```

Isso pode aumentar a confiança da vítima antes do redirecionamento.

⚠️ O Open Redirect **não é, por si só, um mecanismo para roubar credenciais**. O impacto de phishing depende do conteúdo e do fluxo que o atacante coloca no destino.

---

## 📌 Parâmetros comuns

Durante um pentest, procure parâmetros como:

```text
?url=
?next=
?redirect=
?redirect_url=
?return=
?returnUrl=
?continue=
?dest=
?destination=
```

Por exemplo:

```text
https://example.com/login?next=/dashboard
```

Teste autorizado:

```text
https://example.com/login?next=https://attacker.example
```

Se a aplicação aceitar diretamente o domínio externo, existe um forte indício de **Open Redirect**.

---

## 💻 Exemplo de código vulnerável

O problema pode aparecer em um código semelhante a:

```php
<?php

class LoginController extends Controller
{
    public function postLogin(Request $request)
    {
        // processo de autenticação

        return redirect()->to($request->get('next'));
    }
}
```

Aqui:

```php
$request->get('next')
```

é controlado pelo usuário.

E:

```php
redirect()->to(...)
```

utiliza esse valor como destino.

💥 Se não houver validação, o atacante pode controlar para onde o usuário será enviado.

---

## 🧪 Payload

O payload abaixo é um exemplo de **redirecionamento via HTML**, mas é importante diferenciar isso de um Open Redirect no servidor:

```html
<meta http-equiv="refresh" content="0; url=http://google.com:80/">
```

Ele faz o navegador navegar para outro endereço através de uma tag HTML.

👉 Em um **Open Redirect**, normalmente o próprio servidor gera uma resposta HTTP de redirecionamento, por exemplo:

```http
HTTP/1.1 302 Found
Location: https://attacker.example
```

---

## 🎯 Impactos

Dependendo do contexto:

- Phishing;
- Redirecionamento para páginas maliciosas;
- Abuso de fluxos de autenticação;
- Bypass de determinadas validações baseadas em URL;
- Encadeamento com outras vulnerabilidades;
- Manipulação de links legítimos.

📌 **Importante:** Open Redirect geralmente não permite, sozinho, "bypassar o Access Control". O impacto depende de como o redirecionamento está integrado às demais funcionalidades da aplicação.

---

## 🔐 Como prevenir

### ❌ Evite:

```php
return redirect()->to($request->get('next'));
```

### ✅ Prefira allow-list ou destinos internos

Por exemplo, permitir somente caminhos locais:

```text
/dashboard
/profile
/settings
```

E rejeitar:

```text
https://attacker.example
//attacker.example
javascript:...
```

Também é importante:

- validar o destino no servidor;
- preferir identificadores internos em vez de URLs fornecidas pelo usuário;
- usar allow-list de domínios quando URLs externas forem realmente necessárias;
- normalizar e validar a URL antes do redirecionamento.

📌 **Regra de ouro:**

👉 **Nunca permita que um parâmetro controlado pelo usuário determine livremente o destino de um redirecionamento.**