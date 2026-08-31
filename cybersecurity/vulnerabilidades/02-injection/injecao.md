## 💉 Falhas de Injeção (Injection)

As **falhas de injeção** acontecem quando uma aplicação envia **dados não confiáveis para um interpretador** como parte de um comando, consulta ou estrutura de dados.

👉 O problema surge quando o interpretador não consegue distinguir corretamente entre **dados** e **instruções**.

A injeção pode atingir diferentes tecnologias, como:

- SQL
- HTML
- JavaScript
- comandos do sistema operacional
- LDAP
- XML
- logs
- caminhos de arquivos

💥 Dependendo do contexto, o atacante pode conseguir **executar comandos, acessar dados não autorizados, manipular informações ou alterar o comportamento da aplicação**.

---

## ⚙️ Como acontece

O fluxo básico é:

```text
Entrada não confiável
        ↓
Aplicação
        ↓
Interpretador
        ↓
Dados + instruções
        ↓
Interpretação inesperada
```

Por exemplo:

```text
Usuário → parâmetro HTTP → aplicação → banco de dados
```

Se a aplicação utilizar o parâmetro diretamente na consulta:

```sql
SELECT * FROM users WHERE id = 'ENTRADA';
```

a entrada pode acabar influenciando a estrutura do comando.

📌 **Regra principal:**

👉 O sistema deve tratar entradas externas como **dados não confiáveis**, mesmo quando elas vêm de fontes consideradas "internas", como bancos de dados.

---

# 📌 Principais tipos de Injeção

### 🔹 SQL Injection

Manipulação de consultas SQL.

```text
Entrada
   ↓
Aplicação
   ↓
Consulta SQL
   ↓
Banco de dados
```

Pode resultar em:

- vazamento de informações
- leitura de dados
- alteração de dados
- exclusão de dados
- bypass de determinadas verificações
- acesso a informações não autorizadas

Exemplo de parâmetro:

```http
https://exemple.com/cat.php?id=1
```

---

### 🔹 Code Injection

A **Code Injection** ocorre quando um atacante consegue fazer com que código fornecido por ele seja **interpretado e executado pela aplicação**.

O problema pode acontecer quando uma entrada controlada pelo usuário é utilizada em um contexto que permite avaliação de código.

Exemplo conceitual:

```text
Entrada do usuário
       ↓
Aplicação
       ↓
Interpretador
       ↓
Código executado
```

💥 Dependendo da tecnologia e dos privilégios da aplicação, o impacto pode ser extremamente alto.

📌 **XSS é diferente:** quando o código é executado no navegador do usuário, normalmente estamos falando de **Cross-Site Scripting**, e não de Code Injection no servidor.

---

### 🔹 Command Injection

A **Command Injection** acontece quando uma aplicação utiliza entrada controlada pelo usuário na execução de comandos do sistema operacional.

Exemplo conceitual:

```text
Entrada
   ↓
Aplicação
   ↓
Comando do SO
   ↓
Sistema operacional
```

Imagine uma aplicação que executa:

```python
os.system("ping " + ip)
```

Se a entrada não for devidamente tratada:

```text
ip = entrada_do_usuario
```

💥 caracteres de controle podem alterar o comando que será executado.

📌 É importante diferenciar **Command Injection** de **Code Injection**:

```text
Code Injection
→ código da linguagem da aplicação

Command Injection
→ comandos do sistema operacional
```

---

### 🔹 Log Injection

A **Log Injection** ocorre quando dados controlados pelo usuário são gravados em logs sem tratamento adequado.

Imagine:

```php
sprintf("Falha na tentativa de login por %s", $username);
```

Se o usuário fornecer uma entrada contendo caracteres de quebra de linha e conteúdo que imite uma entrada legítima, o log poderá ficar semelhante a:

```text
Failed login attempt by atacante
Successful login by admin
```

💥 Isso pode dificultar a análise dos registros e permitir que um atacante **disfarce ou manipule eventos registrados**.

Os objetivos podem incluir:

- esconder atividades
- falsificar registros
- confundir analistas
- manipular ferramentas de análise
- inserir conteúdo malicioso em interfaces de logs
- explorar vulnerabilidades em sistemas que processam os logs

📌 Logs também devem tratar entradas externas como **dados não confiáveis**.

---

### 🔹 Path Traversal

**Path Traversal**, também conhecido como **Directory Traversal**, ocorre quando um atacante consegue manipular um caminho de arquivo utilizado pela aplicação.

Exemplo:

```text
/download?file=manual.pdf
```

Se a aplicação não validar corretamente o caminho:

```text
file = entrada_do_usuario
```

o atacante pode tentar navegar para diretórios que não deveriam estar acessíveis.

Fluxo:

```text
Entrada
   ↓
Caminho do arquivo
   ↓
Sistema de arquivos
   ↓
Arquivo não autorizado
```

💥 Pode resultar em **leitura de arquivos sensíveis** e, em determinados cenários, contribuir para outras vulnerabilidades.

---

### 🔹 XML Injection

A **XML Injection** acontece quando dados controlados pelo usuário são inseridos em estruturas XML sem tratamento adequado.

XML é utilizado em tecnologias como:

- SOAP
- RSS
- Atom
- RDF
- APIs
- sistemas de integração

O problema ocorre quando a entrada consegue alterar a estrutura XML esperada.

```text
Entrada
   ↓
Documento XML
   ↓
Parser XML
   ↓
Interpretação inesperada
```

---

### 🔹 XML External Entity (XXE)

A **XXE (XML External Entity)** ocorre quando um parser XML permite a utilização insegura de **entidades externas**.

Um documento XML pode conter referências a recursos externos:

```xml
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///arquivo">
]>
```

Quando o parser está configurado de maneira insegura, ele pode tentar resolver essa entidade.

💥 Dependendo do ambiente, XXE pode resultar em:

- leitura de arquivos
- requisições HTTP feitas pelo servidor
- SSRF
- exposição de informações
- negação de serviço

📌 A exploração depende principalmente da **configuração do parser XML**.

---

## 💣 Expansão de Entidades XML

### 🔹 Entity Expansion

Alguns parsers XML permitem que entidades sejam expandidas durante o processamento.

Um atacante pode abusar desse comportamento para fazer o parser consumir grandes quantidades de:

- memória
- CPU
- processamento

💥 Isso pode resultar em **Denial of Service (DoS)**.

---

### 🔹 Expansão Recursiva

Na expansão recursiva, entidades são definidas de forma que uma expansão gere outra expansão.

Conceitualmente:

```text
Entidade A
   ↓
Entidade B
   ↓
Entidade C
   ↓
Entidade D
   ↓
Grande quantidade de dados
```

Isso pode causar uma expansão exponencial.

Esse ataque é conhecido como:

**XML Bomb / Billion Laughs**

💥 O objetivo normalmente é consumir recursos do servidor e provocar **negação de serviço**.

---

### 🔹 Expansão de Entidade Remota

Em determinados parsers, entidades podem apontar para recursos externos.

Fluxo:

```text
XML malicioso
      ↓
Parser
      ↓
Recurso externo
      ↓
Requisição realizada pelo servidor
```

Esse comportamento está diretamente relacionado a problemas de **XXE** e pode permitir que o servidor faça requisições que o atacante não deveria conseguir realizar diretamente.

---

## 🚨 Impactos

As falhas de injeção podem resultar em:

- vazamento de informações
- execução de código
- execução de comandos
- alteração de dados
- acesso não autorizado
- manipulação de logs
- leitura de arquivos
- SSRF
- bypass de controles
- negação de serviço
- comprometimento da aplicação

📌 O impacto depende do **interpretador envolvido**, das permissões da aplicação e de como a entrada é processada.

---

## 🔎 Em pentest

Durante um pentest autorizado, procure entradas controladas pelo usuário em:

```text
URL
Formulários
Headers
Cookies
JSON
XML
Upload de arquivos
Parâmetros
Logs
```

E identifique **qual interpretador processa essa entrada**:

```text
Entrada
   ↓
Qual contexto?
   ↓
HTML?
SQL?
Sistema operacional?
XML?
Arquivo?
Log?
   ↓
Testar separadamente
```

👉 O objetivo é descobrir se a aplicação consegue diferenciar corretamente **dados fornecidos pelo usuário** de **instruções para o interpretador**.

---

## 🛡️ Como prevenir

A defesa depende do tipo de injeção, mas algumas medidas são comuns:

- utilizar **Prepared Statements** para SQL
- evitar concatenação de comandos
- utilizar APIs seguras para execução de processos
- validar entradas com **allowlist**
- realizar escaping contextual
- configurar parsers XML de forma segura
- desabilitar entidades externas quando não necessária
- impedir acesso a diretórios fora do esperado
- sanitizar dados antes de registrá-los em logs
- aplicar o princípio do menor privilégio
- utilizar bibliotecas e frameworks atualizados
- implementar testes de segurança

📌 **Regra de ouro:**

👉 **Nunca permita que dados não confiáveis sejam interpretados como instruções.**