## 🔐 Falha de Identificação e Autenticação (Identification and Authentication Failures)

A falha de **Identification and Authentication Failures** acontece quando um sistema possui problemas para **identificar corretamente quem é o usuário e verificar se ele realmente possui as credenciais necessárias para acessar uma conta**.

👉 Em outras palavras: o sistema **não consegue garantir de forma adequada que a pessoa que está tentando acessar uma conta é realmente quem afirma ser**.

---

## ⚙️ Como acontece

A autenticação pode envolver:

- usuário e senha
- tokens de sessão
- cookies
- códigos de verificação
- autenticação multifator (MFA)
- recuperação de senha
- gerenciamento de sessões

💥 O problema aparece quando esses mecanismos são implementados de forma insegura.

Exemplos:

- senhas fracas permitidas
- ausência de proteção contra tentativas repetidas
- sessões mal protegidas
- recuperação de senha insegura
- tokens previsíveis
- autenticação mal implementada
- ausência de MFA em operações críticas

---

## 📌 Exemplos práticos

### 🔹 1. Senhas fracas

A aplicação permite uma senha como:

```text
123456
```

💥 Um atacante pode tentar utilizar senhas comuns ou comprometidas para obter acesso à conta.

---

### 🔹 2. Ausência de proteção contra tentativas

Imagine um formulário:

```text
POST /login

username=admin
password=senha
```

O servidor permite tentativas ilimitadas.

💥 Isso pode facilitar ataques de **brute force** e **credential stuffing**.

---

### 🔹 3. Recuperação de senha insegura

A aplicação fornece:

```text
/recuperar-senha?user=paulo
```

e utiliza apenas o nome de usuário para permitir a alteração da senha.

💥 Se não houver uma verificação adequada de identidade, um atacante pode tentar assumir a conta.

---

### 🔹 4. Sessão mal protegida

Após o login, o sistema cria:

```http
Set-Cookie: session=abc123
```

Se o cookie não possuir proteções adequadas, como:

```text
HttpOnly
Secure
SameSite
```

💥 dependendo do cenário, a sessão pode ficar mais exposta a ataques.

---

### 🔹 5. Autenticação diferente da autorização

É importante diferenciar:

```text
Autenticação
↓
"Quem é você?"

Autorização
↓
"O que você pode fazer?"
```

Um usuário pode estar corretamente autenticado, mas ainda assim não deveria possuir acesso a determinadas funcionalidades.

👉 Problemas de **autorização** são tratados principalmente em outra categoria de falhas.

---

## 🚨 Impactos

Dependendo da vulnerabilidade, pode ocorrer:

- acesso não autorizado
- comprometimento de contas
- roubo de sessões
- brute force
- credential stuffing
- escalonamento de privilégios
- acesso a informações privadas
- alteração de dados
- tomada de contas (**Account Takeover**)

📌 O impacto pode ser grave porque a autenticação normalmente é uma das principais barreiras entre o atacante e os recursos protegidos.

---

## 🔎 Em pentest

Durante um pentest, é comum verificar:

- política de senhas
- tentativas de login
- mecanismos de bloqueio
- recuperação de senha
- gerenciamento de sessões
- expiração de sessões
- cookies de autenticação
- MFA
- tokens
- fluxos de autenticação

Exemplo de teste:

```text
Login
  ↓
Falha
  ↓
Tentativa novamente
  ↓
Falha
  ↓
...
```

👉 O objetivo é verificar se o sistema possui **controles suficientes para impedir tentativas abusivas de autenticação**.

---

## 🛡️ Como prevenir

- exigir senhas fortes
- bloquear ou limitar tentativas de login
- implementar MFA quando apropriado
- utilizar HTTPS
- proteger cookies de sessão
- gerar tokens seguros e imprevisíveis
- implementar recuperação de senha segura
- invalidar sessões adequadamente
- evitar mensagens que revelem se uma conta existe
- monitorar tentativas de autenticação
- utilizar mecanismos seguros de armazenamento de senhas

📌 **Senhas nunca devem ser armazenadas em texto puro.** Devem ser armazenadas utilizando mecanismos adequados de hashing de senhas.

---

## 🧠 Autenticação × Identificação

Uma forma simples de entender:

```text
Identificação
    ↓
"Eu sou o Paulo."

Autenticação
    ↓
"Prove que você é o Paulo."

Autorização
    ↓
"Agora vamos verificar o que você pode fazer."
```

👉 **Identificação diz quem você afirma ser.  
Autenticação verifica essa identidade.  
Autorização determina quais ações você pode realizar.**

📌 **Regra de ouro:**

👉 **Nunca presuma que quem apresenta uma identidade é realmente o proprietário dela — a aplicação precisa verificar isso de forma segura.**