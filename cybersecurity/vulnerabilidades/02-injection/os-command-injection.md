## 💻 OS Command Injection (Injeção de Comandos do Sistema Operacional)

A **OS Command Injection**, também conhecida como **Command Injection** ou **Shell Injection**, acontece quando uma aplicação utiliza **dados controlados pelo usuário na construção de comandos do sistema operacional** sem realizar a validação adequada.

👉 O atacante consegue manipular o comando executado pelo servidor e fazer o sistema operacional executar instruções que não faziam parte da intenção original da aplicação.

---

## ⚙️ Como acontece

Imagine uma aplicação que verifica o status de um servidor utilizando:

```python
os.system("ping -c 4 " + ip)
```

A aplicação espera receber:

```text
127.0.0.1
```

E executa:

```bash
ping -c 4 127.0.0.1
```

O problema ocorre quando a entrada do usuário é concatenada diretamente ao comando.

💥 Um atacante pode tentar utilizar operadores do shell para alterar a execução:

```text
127.0.0.1; comando
```

A ideia é fazer com que o shell interprete:

```text
comando original
      +
comando injetado
```

---

## 📌 Operadores importantes

Em ambientes Linux/Unix, alguns operadores frequentemente analisados durante testes são:

```text
;    → executa outro comando
&&   → executa se o anterior funcionar
||   → executa se o anterior falhar
|    → envia a saída para outro comando
&    → execução em background
```

Exemplo em laboratório:

```bash
127.0.0.1; whoami
```

ou:

```bash
127.0.0.1 && whoami
```

💥 Se a aplicação for vulnerável, o segundo comando poderá ser executado pelo sistema operacional.

---

## 🔎 Encontrando a vulnerabilidade

Procure funcionalidades que precisem executar comandos no servidor, como:

- ping
- traceroute
- DNS lookup
- conversão de arquivos
- compactação/descompactação
- processamento de imagens
- ferramentas administrativas
- integração com programas externos

Exemplo:

```http
GET /stockStatus?productID=381&storeID=29
```

Ou:

```http
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded

productID=1&storeID=29
```

Durante um teste autorizado, pode-se testar se um parâmetro influencia a execução de comandos:

```http
productID=1&storeID=29|whoami
```

---

# 🧪 Exploração

Depois de confirmar a vulnerabilidade em um ambiente autorizado, alguns comandos básicos podem ajudar a identificar o ambiente comprometido.

|Objetivo|Linux|Windows|
|---|---|---|
|Usuário atual|`whoami`|`whoami`|
|Sistema operacional|`uname -a`|`ver`|
|Configuração de rede|`ip addr`|`ipconfig /all`|
|Conexões de rede|`ss -an`|`netstat -an`|
|Processos|`ps -ef`|`tasklist`|

📌 Esses comandos são úteis para **identificação do ambiente durante um laboratório/pentest autorizado**.

---

## 👁️ Command Injection Cega

Muitas vulnerabilidades de Command Injection são **blind**.

Isso significa que:

```text
Comando executado
       ↓
Servidor
       ↓
Saída NÃO aparece na resposta HTTP
```

Por exemplo:

```bash
whoami
```

pode ser executado corretamente, mas a aplicação não retorna:

```text
www-data
```

para o navegador.

💥 Nesse caso, é necessário utilizar outros mecanismos para confirmar a execução.

---

## ⏱️ Time-Based Detection

Uma técnica é provocar um **atraso controlado** e observar o tempo de resposta.

Em Linux, por exemplo:

```bash
ping -c 5 127.0.0.1
```

O comando gera uma atividade que demora algum tempo para terminar.

Um teste conceitual poderia utilizar:

```text
& ping -c 10 127.0.0.1 &
```

Se a resposta HTTP apresentar um comportamento temporal diferente e consistente, isso pode indicar que o comando foi executado.

📌 O atraso depende do sistema, da rede e da implementação. Por isso, é importante comparar com o **tempo normal de resposta**.

---

## 📄 Redirecionando a saída

Outra possibilidade, em um laboratório controlado, é redirecionar a saída para um arquivo que possa ser acessado pela aplicação.

Por exemplo:

```bash
& whoami > /var/www/static/whoami.txt &
```

Se `/var/www/static` for realmente servido pelo servidor web, o resultado poderia ser posteriormente acessado:

```text
/whoami.txt
```

Fluxo:

```text
Comando injetado
       ↓
whoami
       ↓
whoami.txt
       ↓
Servidor Web
       ↓
Resposta HTTP
```

💥 Isso transforma uma vulnerabilidade **blind** em uma situação na qual a saída pode ser observada.

⚠️ Em um pentest real, evite gravar arquivos em locais do sistema sem autorização explícita; utilize um diretório de teste controlado.

---

## 🧠 Command Injection × Code Injection

Não confunda:

### Code Injection

Executa código dentro da linguagem da aplicação:

```text
PHP
Python
Java
Ruby
...
```

### Command Injection

Executa comandos do:

```text
Sistema Operacional
       ↓
Shell
       ↓
Comando
```

Por exemplo:

```bash
whoami
```

---

## 🚨 Impactos

Uma OS Command Injection pode ser extremamente grave.

Dependendo das permissões do processo, pode permitir:

- execução arbitrária de comandos
- leitura de arquivos
- alteração de arquivos
- acesso a informações do sistema
- descoberta da rede interna
- acesso a outros serviços
- comprometimento da aplicação
- comprometimento de outros sistemas acessíveis pelo servidor

📌 O impacto depende principalmente das **permissões do usuário que executa a aplicação**.

Por exemplo:

```text
Aplicação
    ↓
usuário www-data
    ↓
Command Injection
    ↓
privilégios de www-data
```

Se a aplicação estiver executando com privilégios excessivos:

```text
Aplicação
    ↓
root
    ↓
Command Injection
    ↓
impacto potencialmente muito maior
```

---

## 🔐 Como prevenir

A melhor defesa é **não utilizar o shell quando ele não é necessário**.

❌ Evite:

```python
os.system("ping " + ip)
```

Também evite:

```python
subprocess.call("ping " + ip, shell=True)
```

✅ Prefira executar o programa diretamente, separando os argumentos:

```python
subprocess.run(
    ["ping", "-c", "4", ip],
    check=True
)
```

Também é importante:

- validar entradas com **allowlist**
- evitar `shell=True`
- não concatenar comando
- utilizar APIs específicas em vez do shell
- executar a aplicação com menor privilégio
- limitar permissões de arquivos
- utilizar sandboxing quando apropriado
- registrar e monitorar comandos sensíveis

📌 **Regra de ouro:**

👉 **Não transforme entrada do usuário em comandos do sistema operacional.**