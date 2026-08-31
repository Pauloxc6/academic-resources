## 🧠 Falha de Limitação de Input (Input Validation)

Acontece quando o sistema **não valida corretamente os dados recebidos do usuário**, permitindo entradas inválidas ou maliciosas.

👉 Isso abre brechas para erros, exploração e até invasões.

---

## ⚙️ Como acontece

O sistema deveria controlar:

- **tipo** (número, texto, data)
- **tamanho**
- **formato**
- **conteúdo permitido**

Quando isso não é feito, qualquer valor pode ser aceito.

---

## 📌 Exemplos práticos

### 🔹 1. Campo sem limite de tamanho

```txt
Nome: (usuário cola 1 milhão de caracteres)
```

💥 Pode travar o sistema ou causar **DoS**

---

### 🔹 2. Tipo incorreto

```txt
Idade: "abc"
```

💥 Sistema pode quebrar ou gerar erro interno

---

### 🔹 3. Valor fora do esperado

```txt
Quantidade de produtos: -10
```

💥 Pode gerar:

- saldo errado
- lógica quebrada

---

### 🔹 4. SQL Injection (falta de validação)

```sql
Login: admin' OR '1'='1
Senha: qualquer coisa
```

💥 Pode permitir login sem senha

---

### 🔹 5. XSS (entrada não sanitizada)

```html
<script>alert('hack')</script>
```

💥 Executa código no navegador de outros usuários

---

### 🔹 6. Upload malicioso

```txt
arquivo.php (disfarçado como imagem)
```

💥 Pode permitir execução de código no servidor

---

## 🚨 Impactos

- invasão do sistema
- execução de código malicioso
- vazamento de dados
- quebra da aplicação
- indisponibilidade

---

## 🔐 Em pentest

Atacantes testam:

- valores extremos (999999, -1) 
- inputs inesperados (texto em campo numérico)
- códigos maliciosos
- arquivos perigosos

👉 Objetivo: **ver até onde o sistema aceita entrada inválida**

---

## 🛡️ Como prevenir

- validar no **backend (principal)** e frontend
- usar **whitelist** (aceitar só o permitido)
- limitar tamanho de campos
- validar tipo e formato
- sanitizar entradas
- usar queries preparadas (contra SQL Injection)
- validar uploads (tipo real do arquivo)