## 🧠 Mass Assignment

A **falha de Mass Assignment** acontece quando o sistema permite que o usuário **envie vários campos (atributos) e eles sejam automaticamente atribuídos ao objeto no backend**, sem controle adequado.

👉 Ou seja: o usuário consegue **alterar campos que não deveria ter acesso**.

---

## ⚙️ Como acontece

Em frameworks (tipo APIs REST), é comum receber dados assim:

```json
{
  "nome": "João",
  "email": "joao@email.com"
}
```

O problema ocorre quando o backend faz algo como:

- pegar todos os campos enviados
- e salvar direto no banco

💥 Sem filtrar o que é permitido

---

## 📌 Exemplos práticos

### 🔹 1. Elevação de privilégio

```json
{
  "nome": "João",
  "email": "joao@email.com",
  "isAdmin": true
}
```

💥 Se o sistema não filtrar:

- usuário comum vira admin    

---

### 🔹 2. Alteração de dados sensíveis

```json
{
  "saldo": 1000000
}
```

💥 Usuário pode alterar o próprio saldo

---

### 🔹 3. Manipulação de status

```json
{
  "status": "aprovado"
}
```

💥 Pode aprovar algo sem autorização

---

### 🔹 4. Alteração de ID ou dono

```json
{
  "user_id": 1
}
```

💥 Usuário pode assumir recursos de outra pessoa

---

## 🚨 Impactos

- escalonamento de privilégio
- acesso indevido
- fraude
- alteração de dados críticos
- comprometimento total da aplicação

---

## 🔐 Em pentest

O atacante:

- envia campos extras no JSON
- testa nomes comuns como:
    - `isAdmin`
    - `role`
    - `status`
    - `balance`
    - `user_id`

👉 Objetivo: ver se o sistema aceita e salva esses campos

---

## 🛡️ Como prevenir

- usar **whitelist de campos permitidos**
- ignorar campos desconhecidos
- validar permissões no backend
- usar DTOs (objetos específicos para entrada)
- não confiar nos dados enviados pelo usuário

📌 Regra de ouro:  
👉 **só aceitar o que for explicitamente permitido**
