# 🧠 User Enumeration (Enumeração de Usuários)

A **User Enumeration** (Enumeração de Usuários) acontece quando um sistema permite que um atacante **descubra quais usuários ou contas existem** em uma aplicação, serviço ou sistema.

O problema ocorre quando o comportamento do sistema permite diferenciar, direta ou indiretamente, um **usuário existente** de um **usuário inexistente**.

👉 A enumeração não significa necessariamente que o atacante conseguiu acessar uma conta. Ela consiste na **obtenção de informações sobre quais contas existem**, podendo ser utilizada como etapa para outros ataques.

---

## ⚙️ Como acontece

Um sistema pode revelar a existência de usuários através de:

- mensagens de erro diferentes;
- códigos HTTP diferentes;
- respostas de APIs;
- formulários de login;
- recuperação de senha;
- cadastro de usuários;
- serviços de rede;
- protocolos como SMTP;
- diferenças de tempo nas respostas;
- informações expostas em páginas ou arquivos.

💥 O principal problema acontece quando existe uma diferença observável entre uma conta válida e uma conta inexistente.

Por exemplo:

```txt
Usuário existente:
"Usuário encontrado"

Usuário inexistente:
"Usuário não encontrado"
```

O atacante pode utilizar essa diferença para construir uma lista de usuários válidos.

---

## 📌 Exemplos práticos

### 🔹 1. Login

Uma aplicação pode retornar mensagens diferentes:

```txt
Usuário: admin
Senha: senhaerrada

Resposta:
"Senha incorreta"
```

Enquanto:

```txt
Usuário: usuario_inexistente
Senha: senhaerrada

Resposta:
"Usuário não encontrado"
```

💥 A diferença permite descobrir que `admin` existe.

---

### 🔹 2. Recuperação de senha

Um sistema pode informar:

```txt
E-mail cadastrado:
"Um link de recuperação foi enviado."
```

E para um endereço inexistente:

```txt
"E-mail não cadastrado."
```

💥 Isso permite enumerar contas através da funcionalidade de recuperação de senha.

---

### 🔹 3. Cadastro

Durante um cadastro, o sistema pode informar:

```txt
Nome de usuário:
admin

Resposta:
"Este usuário já está em uso."
```

💥 O atacante descobre que `admin` é uma conta existente.

---

### 🔹 4. API

Uma API também pode revelar a existência de usuários:

```http
GET /api/users/admin
```

Resposta:

```json
{
    "status": "active",
    "user": "admin"
}
```

Enquanto:

```http
GET /api/users/inexistente
```

retorna:

```json
{
    "error": "user_not_found"
}
```

💥 A diferença nas respostas permite identificar usuários válidos.

---

### 🔹 5. Diferença de tempo

Mesmo quando as mensagens são iguais, o sistema pode apresentar diferenças no tempo de resposta.

```txt
Usuário existente    → 320 ms
Usuário inexistente  → 80 ms
```

💥 Essa diferença pode ser analisada automaticamente para identificar contas válidas.

---

# 📡 User Enumeration através de SMTP

A enumeração também pode ocorrer em **serviços de rede**, como servidores SMTP.

O protocolo **SMTP (Simple Mail Transfer Protocol)** possui comandos que, dependendo da configuração do servidor, podem revelar informações sobre usuários.

Entre eles estão:

```txt
VRFY
EXPN
```

---

## 🔎 VRFY

O comando `VRFY` pode ser utilizado para verificar um usuário ou endereço.

Exemplo:

```txt
VRFY admin
```

Um servidor configurado de maneira permissiva pode responder:

```txt
252 2.0.0 admin
```

Enquanto:

```txt
VRFY usuario_inexistente
```

pode retornar:

```txt
550 5.1.1 User unknown
```

💥 Como as respostas são diferentes, é possível inferir que `admin` existe.

---

## 🔎 EXPN

O comando `EXPN` pode ser utilizado para expandir aliases ou listas de distribuição.

Exemplo:

```txt
EXPN admins
```

Dependendo da configuração, o servidor pode retornar informações como:

```txt
250 user1@example.com
250 user2@example.com
250 user3@example.com
```

💥 Isso pode revelar usuários ou endereços associados ao servidor.

---

# 🛠️ Ferramenta própria

Para automatizar os testes de SMTP, podemos utilizar uma ferramenta de enumeração desenvolvida em **Bash**.

Exemplo:

```bash
bash smtp-user-enum.sh enum \
    -ip 192.168.1.10 \
    -p 25 \
    -w users.txt \
    -m VRFY
```

A ferramenta utiliza uma wordlist:

```txt
root
admin
administrator
user
test
guest
support
```

E testa cada usuário contra o serviço SMTP:

```txt
VRFY root
VRFY admin
VRFY administrator
VRFY user
VRFY test
```

As respostas são analisadas para identificar possíveis usuários válidos.

---

## 🔬 Reconhecimento

A ferramenta também pode verificar se o servidor responde aos métodos de enumeração:

```txt
VRFY
EXPN
```

Exemplo:

```txt
[*] Testando o modo: VRFY
[+] O servidor tem o modo VRFY HABILITADO

[*] Testando o modo: EXPN
[-] O servidor tem o modo EXPN DESABILITADO
```

Isso permite identificar rapidamente quais mecanismos podem ser utilizados durante o teste.

---

# 🧰 Outras ferramentas

A User Enumeration pode ser realizada utilizando diferentes ferramentas, dependendo do alvo.

### 🔹 Nmap

```bash
nmap -sV -p 25,465,587 <IP>
```

Pode ser utilizado para identificar serviços SMTP e realizar verificações adicionais através de scripts NSE.

---

### 🔹 Netcat

```bash
nc <IP> 25
```

Permite interagir diretamente com o serviço SMTP:

```txt
EHLO teste.local
VRFY admin
QUIT
```

---

### 🔹 Burp Suite

Em aplicações web, o **Burp Suite** pode ser utilizado para enviar várias requisições e comparar:

- códigos HTTP;
- mensagens;
- tamanho das respostas;
- headers;
- tempo de resposta.

Isso é útil para identificar diferenças entre usuários existentes e inexistentes.

---

# 🚨 Impactos

A User Enumeration pode permitir:

- descoberta de contas válidas;
- identificação de contas administrativas;
- coleta de endereços de e-mail;
- preparação de ataques de força bruta;
- password spraying;
- engenharia social;
- ataques direcionados;
- aumento das informações disponíveis durante o reconhecimento.

💥 A gravidade aumenta quando a enumeração pode ser combinada com outras vulnerabilidades.

Por exemplo:

```txt
User Enumeration
       ↓
Descoberta de usuários
       ↓
Password Spraying
       ↓
Credencial válida
       ↓
Acesso à conta
```

---

# 🔐 Em Pentest

Durante um teste de segurança, o profissional procura diferenças que permitam determinar se uma conta existe.

São analisados:

- login;
- cadastro;
- recuperação de senha;
- APIs;
- páginas públicas;
- serviços de rede;
- SMTP;
- códigos de resposta;
- mensagens de erro;
- tamanho das respostas;
- tempo de processamento.

👉 O objetivo é determinar se o sistema **vaza informações que permitam identificar usuários válidos**.

---

# 🛡️ Como prevenir

Para reduzir o risco de User Enumeration:

- utilizar mensagens genéricas;
- retornar respostas semelhantes para usuários existentes e inexistentes;
- evitar informações desnecessárias nas APIs;
- proteger funcionalidades de recuperação de senha;
- implementar rate limiting;
- monitorar tentativas repetitivas;
- restringir informações de serviços de rede;
- desabilitar funcionalidades de enumeração desnecessárias;
- evitar diferenças significativas no tempo de resposta.

No caso de SMTP, quando possível:

- restringir `VRFY`;
- restringir `EXPN`;
- evitar respostas que revelem a existência de contas;
- configurar corretamente o servidor SMTP;
- utilizar mecanismos de proteção contra tentativas automatizadas.

---

# 📌 Resumo

```txt
                 USER ENUMERATION
                        │
        ┌───────────────┼───────────────┐
        │               │               │
      Web              API            Rede
        │               │               │
     Login          /users/         SMTP
     Cadastro       endpoints       │
     Reset                          ├── VRFY
                                    └── EXPN
        │               │               │
        └───────────────┼───────────────┘
                        ↓
               Descoberta de contas
                        ↓
              Informações para ataques
```

👉 **User Enumeration é uma técnica de reconhecimento que pode ocorrer em diversos tipos de sistemas. SMTP é apenas um dos meios pelos quais essa informação pode ser obtida.**