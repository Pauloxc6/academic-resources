## 🧠 Insecure Data Storage (Armazenamento Inseguro de Dados)

A **Insecure Data Storage** acontece quando dados sensíveis são **armazenados sem proteção adequada**, permitindo que sejam acessados, vazados ou roubados.

👉 Ou seja: o problema não é só acessar o sistema, mas **como os dados ficam guardados**.

---

## ⚙️ Como acontece

O sistema armazena informações como:

- senhas
- dados pessoais
- tokens
- informações bancárias

💥 Sem aplicar medidas de segurança como:

- criptografia
- controle de acesso
- proteção de arquivos

---

## 📌 Exemplos práticos

### 🔹 1. Senhas em texto puro (plaintext)

```txt
senha: 123456
```

💥 Se houver vazamento → todas as contas comprometidas

---

### 🔹 2. Banco de dados sem criptografia

- dados sensíveis armazenados diretamente

💥 invasor acessa tudo facilmente

---

### 🔹 3. Dados salvos no dispositivo (cliente)

```txt
localStorage: token=abc123
```

💥 Pode ser roubado via XSS

---

### 🔹 4. Logs com informações sensíveis

```txt
Login: admin | Senha: 123456
```

💥 Dados expostos em arquivos de log

---

### 🔹 5. Backup exposto

```txt
/backup/database.sql
```

💥 Qualquer pessoa pode baixar

---

## 🚨 Impactos

- vazamento de dados
- roubo de contas
- exposição de informações pessoais
- fraude
- danos legais (LGPD)

---

## 🔐 Em pentest

O atacante busca:

- arquivos expostos (backup, logs)
- dados armazenados no frontend
- banco de dados sem proteção
- credenciais salvas de forma insegura

👉 Objetivo: obter dados sensíveis diretamente

---

## 🛡️ Como prevenir

- usar **criptografia** (dados sensíveis)
- armazenar senhas com **hash seguro (bcrypt, Argon2)**
- proteger acessos ao banco
- não armazenar dados sensíveis no cliente
- remover dados sensíveis de logs
- proteger backups