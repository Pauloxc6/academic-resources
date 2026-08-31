## 🧠 Broken Authentication (Autenticação Quebrada)

A **Broken Authentication** acontece quando o sistema possui falhas no processo de **login, autenticação ou gerenciamento de sessão**, permitindo que um atacante **se passe por outro usuário**.

👉 Em resumo: o sistema falha em garantir que você é realmente quem diz ser.

---

## ⚙️ Como acontece

Pode ocorrer por vários problemas, como:

- senhas fracas ou mal protegidas
- falha no controle de sessão
- tokens previsíveis
- falta de expiração de sessão
- validação incorreta de login

---

## 📌 Exemplos práticos

### 🔹 1. Senhas fracas

```txt
Senha: 123456
```

💥 Fácil de adivinhar (ataque de força bruta)

---

### 🔹 2. Falta de limite de tentativas

```txt
Login: admin
Tentativas infinitas de senha
```

💥 Permite brute force até acertar

---

### 🔹 3. Sessão não expira

- usuário faz login
- nunca desloga automaticamente

💥 Qualquer pessoa com acesso ao dispositivo entra na conta

---

### 🔹 4. Session ID previsível

```txt
SessionID: user123
```

💥 Atacante pode adivinhar sessões de outros usuários

---

### 🔹 5. Session Hijacking (sequestro de sessão)

- atacante rouba cookie de sessão

💥 Acessa conta sem precisar de senha

---

### 🔹 6. Falha no logout

- usuário clica em sair
- sessão continua válida

💥 Conta ainda pode ser acessada

---

## 🚨 Impactos

- acesso não autorizado
- roubo de contas
- vazamento de dados pessoais
- fraude
- comprometimento total do sistema

---

## 🔐 Em pentest

Testes comuns:

- brute force (testar senhas)
- verificar expiração de sessão
- analisar cookies
- tentar reutilizar sessões
- testar previsibilidade de tokens

👉 Objetivo: assumir contas de usuários

---

## 🛡️ Como prevenir

- exigir **senhas fortes**
- implementar **limite de tentativas (rate limit)**
- usar **autenticação multifator (MFA)**
- gerar **tokens seguros e aleatórios**
- expirar sessões automaticamente
- invalidar sessão no logout
- usar HTTPS (proteger cookies)
