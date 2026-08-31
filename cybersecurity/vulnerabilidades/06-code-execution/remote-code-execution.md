## 🧠 RCE (Remote Code Execution)

A **RCE (Execução Remota de Código)** é uma das falhas mais críticas, onde um atacante consegue **executar código no servidor remotamente**.

👉 Ou seja: o invasor praticamente **ganha controle do sistema**.

---

## ⚙️ Como acontece

Geralmente surge a partir de outras falhas, como:

- **Command Injection** 
- **Upload de arquivos maliciosos**
- **Desserialização insegura**
- **Validação de input falha**

👉 O sistema executa algo que o usuário controla.

---

## 📌 Exemplos práticos

### 🔹 1. Command Injection

```bash
ping 127.0.0.1; whoami
```

💥 O servidor executa comandos extras enviados pelo atacante

---

### 🔹 2. Upload de webshell

```php
<?php system($_GET['cmd']); ?>
```

Acesso:

```txt
/shell.php?cmd=ls
```

💥 Executa comandos direto no servidor

---

### 🔹 3. Execução via parâmetro

```txt
/run?cmd=rm -rf /
```

💥 Sistema executa comando enviado

---

### 🔹 4. Desserialização insegura

- objeto malicioso enviado  
    💥 código executado automaticamente pelo sistema

---

## 🚨 Impactos

- controle total do servidor
- acesso a banco de dados
- instalação de malware/backdoor
- movimentação lateral na rede
- vazamento de dados
- derrubar sistema

---

## 🔐 Em pentest

O atacante tenta:

- injetar comandos
- subir shells
- explorar uploads
- testar parâmetros que executam código

👉 Objetivo: conseguir um **shell no servidor**

---

## 🛡️ Como prevenir

- nunca executar comandos com input do usuário
- validar e sanitizar entradas
- usar listas de comandos permitidos (whitelist)
- desabilitar funções perigosas (ex: `exec`, `system`)
- validar uploads corretamente
- usar permissões restritas no sistema