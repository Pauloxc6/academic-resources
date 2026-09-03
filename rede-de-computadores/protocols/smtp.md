# 📧 SMTP — Simple Mail Transfer Protocol

**SMTP (Simple Mail Transfer Protocol)**, em português **Protocolo Simples de Transferência de Correio**, é um protocolo da **camada de aplicação** utilizado principalmente para **envio e transferência de mensagens de e-mail** entre clientes e servidores de correio e entre servidores de correio.

A especificação original do SMTP foi definida na **RFC 821 (1982)**. Atualmente, a especificação histórica foi substituída por RFCs mais recentes, principalmente a **RFC 5321**.

> **SMTP é utilizado principalmente para enviar e transferir e-mails.**
> Para receber mensagens, normalmente são utilizados **POP3** ou **IMAP**.

---

# 🌐 Funcionamento

O envio de um e-mail pode ser representado de forma simplificada:

```text
┌──────────┐       SMTP       ┌──────────────┐
│  Cliente │ ───────────────► │ Servidor SMTP│
│  de e-mail│                 │ do remetente │
└──────────┘                  └──────┬───────┘
                                     │
                                     │ SMTP
                                     ▼
                              ┌──────────────┐
                              │ Servidor SMTP│
                              │ do destinat. │
                              └──────┬───────┘
                                     │
                                     │ IMAP/POP3
                                     ▼
                              ┌──────────────┐
                              │   Cliente    │
                              │ destinatário │
                              └──────────────┘
```

### Exemplo

Paulo envia:

```text
paulo@exemplo.com
```

para:

```text
joao@empresa.com
```

O servidor de e-mail de Paulo pode utilizar SMTP para entregar a mensagem ao servidor responsável pelo domínio `empresa.com`.

---

# 🔌 Portas SMTP

|       Porta | Uso                                                           |
| ----------: | ------------------------------------------------------------- |
|  **25/TCP** | SMTP tradicional, principalmente comunicação entre servidores |
| **587/TCP** | Submission — envio autenticado por clientes                   |
| **465/TCP** | SMTP Submission com TLS implícito                             |

### 📌 Atenção

A porta **25** não significa necessariamente que existe autenticação ou criptografia.

Já a **587** é normalmente utilizada para **envio autenticado de mensagens por clientes**.

A **465** é utilizada para SMTP com **TLS implícito**.

---

# 📜 Comandos SMTP

O SMTP possui comandos utilizados pelo cliente para controlar a comunicação com o servidor.

| Comando     | Função                                        |
| ----------- | --------------------------------------------- |
| `HELO`      | Inicia uma sessão SMTP básica                 |
| `EHLO`      | Inicia uma sessão ESMTP e solicita extensões  |
| `MAIL FROM` | Define o remetente da transação               |
| `RCPT TO`   | Define o destinatário                         |
| `DATA`      | Inicia o envio do conteúdo da mensagem        |
| `RSET`      | Reinicia a transação atual                    |
| `QUIT`      | Encerra a conexão                             |
| `HELP`      | Solicita informações de ajuda                 |
| `AUTH`      | Realiza autenticação                          |
| `VRFY`      | Solicita a verificação de um usuário/endereço |
| `NOOP`      | Mantém a sessão ativa/testa a resposta        |
| `STARTTLS`  | Solicita a mudança da conexão para TLS        |

---

# 🔄 Exemplo de comunicação SMTP

Uma sessão SMTP simplificada pode ser:

```text
Servidor → 220 mail.exemplo.com SMTP

Cliente  → EHLO client.exemplo.com

Servidor → 250-mail.exemplo.com
           250-STARTTLS
           250-AUTH ...

Cliente  → STARTTLS

Servidor → 220 Ready to start TLS

       [Negociação TLS]

Cliente  → MAIL FROM:<paulo@exemplo.com>

Servidor → 250 OK

Cliente  → RCPT TO:<joao@empresa.com>

Servidor → 250 OK

Cliente  → DATA

Servidor → 354 Start mail input

Cliente  → From: paulo@exemplo.com
           To: joao@empresa.com
           Subject: Teste

           Olá João!

           .

Servidor → 250 OK

Cliente  → QUIT

Servidor → 221 Bye
```

---

# 🔐 SMTP e TLS

SMTP originalmente pode trabalhar em **texto claro**.

Para proteger a comunicação, existem duas abordagens comuns:

### STARTTLS

A conexão começa normalmente e depois é atualizada para TLS:

```text
Conexão TCP
    ↓
SMTP
    ↓
EHLO
    ↓
STARTTLS
    ↓
TLS
    ↓
SMTP protegido
```

### TLS implícito

A conexão já começa protegida por TLS.

É o modelo associado à porta:

```text
465/TCP
```

---

# 🔑 SMTP AUTH

O comando:

```text
AUTH
```

é utilizado para autenticar o cliente no servidor SMTP.

Exemplo conceitual:

```text
Cliente
   │
   │ AUTH
   ▼
Servidor SMTP
   │
   ├── Usuário
   └── Senha
```

A autenticação é especialmente comum em servidores de **submission**, como na porta `587`.

---

# 🔎 VRFY

O comando:

```text
VRFY
```

pode ser utilizado para solicitar ao servidor a verificação de determinado usuário.

Exemplo:

```text
VRFY paulo
```

Dependendo da configuração, o servidor pode responder indicando se o usuário é reconhecido.

Por questões de segurança e anti-enumeração, muitos servidores modernos **desabilitam ou limitam o `VRFY`**.

---

# 🕵️ SMTP em Pentest

Durante um pentest autorizado, o SMTP pode fornecer informações úteis sobre o servidor.

Primeiro, podemos verificar se a porta está aberta:

```bash
nmap -sV -p25 <IP>
```

Para verificar várias portas relacionadas:

```bash
nmap -sV -p25,465,587 <IP>
```

Também é possível utilizar scripts do Nmap:

```bash
nmap -p25 --script smtp-commands <IP>
```

Para verificar suporte a métodos de autenticação e outras informações:

```bash
nmap -p25 --script smtp-commands,smtp-ntlm-info <IP>
```

> A disponibilidade e o resultado dos scripts dependem da implementação e configuração do servidor.

---

# 👤 Enumeração de usuários

O SMTP pode, em determinadas configurações, permitir **enumeração de usuários**.

Uma ferramenta conhecida para isso é:

```bash
smtp-user-enum
```

Exemplo utilizando `VRFY`:

```bash
smtp-user-enum -M VRFY -U <userlist> -t <IP>
```

Fluxo:

```text
Userlist
   │
   ├── admin
   ├── suporte
   ├── joao
   └── maria
          │
          ▼
     SMTP Server
          │
       VRFY
          │
          ▼
 Usuário encontrado?
```

Porém:

> `VRFY` não é uma técnica garantida. Muitos servidores desabilitam o comando ou retornam respostas genéricas para impedir enumeração.

---

# ⚠️ Brute Force

O SMTP também pode possuir autenticação e, em um teste autorizado, pode ser avaliada a resistência contra tentativas de autenticação.

Entretanto, o comando mostrado originalmente:

```bash
hydra ... ssh://<IP>
```

é **SSH, não SMTP**.

Para SSH:

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://<IP> -t 6 -V
```

E depois:

```bash
ssh <user>@<IP>
```

ou:

```bash
ssh -l <user> <IP>
```

Isso pertence à enumeração/ataque do **serviço SSH**, e não ao SMTP.

---

# 🧪 Telnet

Para testes simples de SMTP, pode-se estabelecer uma conexão TCP:

```bash
telnet <IP> 25
```

Depois:

```text
EHLO teste
```

O servidor pode retornar as extensões SMTP disponíveis.

Em ambientes modernos, para serviços que exigem TLS, ferramentas como `openssl s_client` são mais apropriadas para testar a negociação TLS.

Exemplo:

```bash
openssl s_client -connect <IP>:465
```

Para STARTTLS:

```bash
openssl s_client -starttls smtp -connect <IP>:587
```

---

# 🛡️ Principais riscos de segurança

Uma configuração inadequada de SMTP pode permitir:

* enumeração de usuários;
* autenticação fraca;
* transmissão sem criptografia;
* credenciais expostas;
* **Open Relay**;
* abuso para envio de spam;
* spoofing dependendo de outros controles do domínio;
* informações sobre o software e configuração do servidor.

---

# 🚨 Open Relay

Um **Open Relay** ocorre quando um servidor SMTP permite que terceiros não autorizados utilizem o servidor para encaminhar mensagens.

Exemplo problemático:

```text
Atacante
   │
   │ SMTP
   ▼
Servidor SMTP
   │
   │ Relay permitido
   ▼
Qualquer destinatário
```

Um servidor corretamente configurado normalmente restringe quem pode utilizar o relay.

---

# 🧠 SMTP × POP3 × IMAP

| Protocolo | Função principal                          |
| --------- | ----------------------------------------- |
| **SMTP**  | Enviar/transferir e-mails                 |
| **POP3**  | Baixar e-mails do servidor                |
| **IMAP**  | Acessar e sincronizar e-mails no servidor |

Uma forma simples de memorizar:

```text
SMTP → Envia 📤
POP3 → Baixa 📥
IMAP → Sincroniza 📥🔄
```

---

# 🧠 Para memorizar

### Portas

```text
25  → SMTP tradicional / servidor-servidor
587 → Submission autenticado
465 → SMTP com TLS implícito
```

### Principais comandos

```text
HELO/EHLO → inicia comunicação
MAIL FROM → remetente
RCPT TO   → destinatário
DATA      → conteúdo da mensagem
AUTH      → autenticação
VRFY      → verificar usuário
STARTTLS  → iniciar TLS
RSET      → reiniciar transação
QUIT      → encerrar
```

### Pentest

```text
25/465/587
     ↓
Identificar SMTP
     ↓
Enumerar comandos/extensões
     ↓
Verificar TLS
     ↓
Verificar autenticação
     ↓
Testar enumeração de usuários
     ↓
Verificar Open Relay
     ↓
Avaliar vulnerabilidades
```

> **SMTP = envio e transferência de e-mails.**
> **Porta 25 = comunicação SMTP tradicional.**
> **587 = envio autenticado (Submission).**
> **465 = SMTP com TLS implícito.**
