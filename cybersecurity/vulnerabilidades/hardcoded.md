## 🧠 Hardcoded Credentials (Credenciais Hardcoded)

A falha de **Hardcoded Credentials** acontece quando **credenciais (usuário, senha, tokens, chaves)** ficam **fixas diretamente no código-fonte**.

👉 Ou seja: ao invés de proteger, o desenvolvedor deixa a senha “escrita no código”.

---

## ⚙️ Como acontece

Durante o desenvolvimento, alguém pode colocar:

- senha de banco de dados
- chave de API
- token de acesso
- login de admin

diretamente no código para facilitar testes — e depois **esquece de remover**.

---

## 📌 Exemplos práticos

### 🔹 1. Senha no código

```python
db_password = "123456"
```

💥 Qualquer pessoa com acesso ao código vê a senha

---

### 🔹 2. Conexão com banco

```txt
mysql://root:senha123@localhost
```

💥 Credenciais expostas diretamente

---

### 🔹 3. Chave de API exposta

```javascript
const API_KEY = "ABCD-1234-SECRET"
```

💥 Pode ser usada por terceiros

---

### 🔹 4. Token de autenticação

```txt
Authorization: Bearer 9f8a7b6c5d
```

💥 Acesso direto ao sistema

---

## 🚨 Impactos

- acesso não autorizado
- vazamento de dados
- comprometimento de APIs
- invasão de sistemas
- uso indevido de serviços (ex: cobrança em APIs)

---

## 🔐 Em pentest

O atacante procura por:

- arquivos `.env` expostos
- código em repositórios (GitHub, GitLab)
- backups esquecidos
- aplicações compiladas (reverse engineering)

👉 Objetivo: encontrar credenciais prontas para uso

---

## 🛡️ Como prevenir

- usar **variáveis de ambiente (.env)**
- armazenar segredos em **cofres seguros (vaults)**
- nunca subir credenciais em repositórios
- rotacionar chaves regularmente
- usar permissões mínimas (least privilege)