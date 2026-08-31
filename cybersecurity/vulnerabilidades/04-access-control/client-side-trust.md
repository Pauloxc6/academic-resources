## 🧠 Client-Side Trust (Confiança no Lado do Cliente)

A falha de **Client-Side Trust** acontece quando o sistema **confia em dados ou validações feitas no lado do cliente (frontend)**, em vez de validar no servidor.

👉 Ou seja: o sistema acredita no que o usuário envia — o que é perigoso.

---

## ⚙️ Como acontece

Validações feitas no cliente:

- JavaScript no navegador
- campos ocultos (hidden inputs)
- dados enviados via requisição (JSON, URL, etc.)

💥 O problema:  
o usuário pode **alterar tudo isso facilmente** usando:

- DevTools (F12)
- interceptadores (ex: Burp Suite)
- scripts

---

## 📌 Exemplos práticos

### 🔹 1. Campo oculto manipulável

```html
<input type="hidden" name="preco" value="100">
```

Usuário altera para:

```html
value="1"
```

💥 Compra produto por R$1

---

### 🔹 2. Validação só no JavaScript

```javascript
if (idade < 18) {
  bloquear();
}
```

💥 Usuário desativa o JS ou altera o código → bypass total

---

### 🔹 3. Controle de permissão no frontend

```json
{
  "role": "user"
}
```

Usuário altera para:

```json
{
  "role": "admin"
}
```

💥 Se o backend confiar → acesso admin

---

### 🔹 4. Parâmetros manipuláveis

```txt
/compra?valor=100
```

Usuário muda:

```txt
/compra?valor=1
```

💥 Sistema aceita valor alterado

---

## 🚨 Impactos

- fraude (alteração de valores)
- escalonamento de privilégio
- bypass de regras
- acesso indevido
- manipulação de dados

---

## 🔐 Em pentest

Testes comuns:

- alterar parâmetros da requisição
- modificar campos ocultos    
- desativar JavaScript
- interceptar e alterar requisições

👉 Objetivo: provar que o backend **confia no cliente**

---

## 🛡️ Como prevenir

- validar TUDO no **backend**
- nunca confiar no cliente
- ignorar dados críticos vindos do frontend
- recalcular valores no servidor (ex: preço)
- validar permissões no backend

📌 Regra de ouro:  
👉 **o cliente é sempre não confiável**
