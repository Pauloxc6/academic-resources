## 📂 LFI — Local File Inclusion

A **LFI (Local File Inclusion)** é uma vulnerabilidade que ocorre quando uma aplicação permite que o usuário **influencie o arquivo que será incluído ou lido pelo servidor**, sem realizar uma validação adequada.

Ela aparece com frequência em aplicações que utilizam parâmetros para escolher páginas, templates ou arquivos.

👉 O problema não é simplesmente o uso de `include`; o problema é permitir que **entrada controlada pelo usuário determine um caminho de arquivo sem controles adequados**.

---

## ⚙️ Como acontece

Imagine uma aplicação:

```php
<?php

$pagina = $_GET['param'];

include($pagina);

?>
```

A aplicação espera algo como:

```text
/index.php?param=home.php
```

Mas o usuário consegue fornecer outro caminho:

```text
/index.php?param=/etc/passwd
```

Fluxo:

```text
Entrada do usuário
       ↓
Parâmetro GET
       ↓
include()
       ↓
Caminho controlado pelo usuário
       ↓
Arquivo local
```

💥 Se não houver proteção adequada, um atacante pode conseguir acessar arquivos que deveriam permanecer fora da área pública.

---

# 🧪 Exploração básica

Em um **laboratório autorizado**, alguns arquivos Linux normalmente utilizados para demonstrar LFI são:

```text
/etc/issue
/etc/passwd
/etc/group
/etc/hosts
/proc/version
/proc/cmdline
```

Exemplo:

```text
http://localhost:80/index.php?param=/etc/issue
```

```text
http://localhost:80/index.php?param=/etc/passwd
```

```text
http://localhost:80/index.php?param=/etc/hosts
```

```text
http://localhost:80/index.php?param=/proc/version
```

```text
http://localhost:80/index.php?param=/proc/cmdline
```

📌 O resultado depende das permissões do processo e de como a aplicação utiliza o arquivo.

---

# 📁 Path Traversal + LFI

Uma situação muito comum é quando a aplicação espera arquivos dentro de um diretório específico.

Por exemplo:

```text
/var/www/images/
```

A aplicação pode fazer algo conceitualmente semelhante a:

```php
include("/var/www/images/" . $_GET['param']);
```

O atacante tenta sair desse diretório utilizando **Path Traversal**:

```text
../
```

Por exemplo:

```text
../../../../etc/passwd
```

Conceitualmente:

```text
/var/www/images/
        ↓
../
        ↓
/var/www/
        ↓
../
        ↓
/var/
        ↓
../
        ↓
/
        ↓
/etc/passwd
```

---

# 🔀 LFI com Path Traversal

Exemplo do laboratório:

```text
http://localhost:80/index.php?param=/var/www/images/../../../../etc/passwd
```

Aqui temos duas técnicas relacionadas:

```text
Path Traversal
      +
Local File Inclusion
      ↓
LFI
```

📌 **Path Traversal** é a técnica de manipular o caminho para acessar um local diferente.

**LFI** é a vulnerabilidade que permite que a aplicação inclua/leia um arquivo local controlado pelo atacante.

Os conceitos se sobrepõem bastante, mas não são exatamente a mesma coisa.

---

# 🧪 Double URL Encoding

Algumas aplicações possuem filtros que procuram diretamente por:

```text
../
```

Uma tentativa de contornar filtros mal implementados pode envolver **dupla codificação de URL**.

Por exemplo:

```text
../
```

pode ser codificado como:

```text
..%2f
```

e, em determinados cenários, novamente codificado:

```text
..%252f
```

Exemplo de laboratório:

```text
http://localhost:80/index.php?param=..%252f..%252f..%252fetc/passwd
```

O fluxo pode ser:

```text
..%252f
   ↓
decodificação
   ↓
..%2f
   ↓
segunda decodificação
   ↓
../
```

⚠️ Isso só funciona quando existe uma combinação específica de **decodificação múltipla + filtro inadequado**.

---

# 🔒 Null Byte

Historicamente, aplicações vulneráveis também podiam ser exploradas através de **Null Byte** (`%00`) para tentar interferir no processamento do nome do arquivo.

Exemplo encontrado em ambientes antigos:

```text
..%252f..%252f..%252fetc/passwd%001.png
```

O conceito era:

```text
/etc/passwd%00
             ↓
terminador NUL
             ↓
.png ignorado em determinados ambientes
```

📌 **Importante:** essa técnica é principalmente histórica. Versões modernas de linguagens e bibliotecas geralmente não permitem esse comportamento da mesma maneira.

---

# 🧩 LFI ≠ RFI

É importante diferenciar:

### LFI

**Local File Inclusion**

```text
Aplicação
   ↓
arquivo LOCAL
   ↓
servidor
```

Exemplo:

```text
/etc/passwd
```

### RFI

**Remote File Inclusion**

```text
Aplicação
   ↓
arquivo REMOTO
   ↓
servidor
```

Exemplo conceitual:

```text
http://servidor-atacante/exemplo.php
```

📌 RFI depende do suporte/configuração da aplicação para inclusão remota e é menos comum em configurações modernas.

---

# 💥 Impactos

Dependendo do contexto, uma LFI pode permitir:

- leitura de arquivos locais;
- exposição de informações sensíveis;
- descoberta da configuração do sistema;
- exposição de credenciais armazenadas em arquivos;
- descoberta de variáveis de ambiente;
- reconhecimento da infraestrutura;
- em determinadas condições, combinação com outras vulnerabilidades para obter execução de código.

⚠️ **LFI não significa automaticamente RCE.**

Para chegar à execução de código, normalmente é necessária uma condição adicional ou uma segunda vulnerabilidade.

---

# 🧠 Arquivos interessantes em laboratório

### Informações do sistema

```text
/etc/issue
/etc/hostname
/etc/os-release
/proc/version
/proc/cmdline
```

### Rede

```text
/etc/hosts
/etc/resolv.conf
```

### Usuários

```text
/etc/passwd
/etc/group
```

### Processos

```text
/proc/self/environ
```

📌 No seu exemplo há um pequeno erro de digitação:

```text
/proc/self/envirion
```

O caminho correto é:

```text
/proc/self/environ
```

---

# 🔎 LFI em aplicações PHP

Um exemplo vulnerável:

```php
<?php

$file = $_GET['page'];

include($file);

?>
```

Requisição legítima:

```text
/index.php?page=home.php
```

Requisição problemática:

```text
/index.php?page=/etc/passwd
```

---

# 🛡️ Como prevenir

### 1. Não utilizar entrada do usuário diretamente

Evite:

```php
include($_GET['page']);
```

---

### 2. Usar uma lista de arquivos permitidos

```php
$pages = [
    'home' => 'home.php',
    'about' => 'about.php',
    'contact' => 'contact.php'
];

$page = $_GET['page'] ?? 'home';

if (!isset($pages[$page])) {
    http_response_code(404);
    exit;
}

include($pages[$page]);
```

Agora o usuário fornece:

```text
?page=home
```

e não um caminho arbitrário.

---

### 3. Separar identificador de caminho

Melhor:

```text
?page=home
```

do que:

```text
?page=/var/www/html/home.php
```

O cliente escolhe um **identificador lógico**, enquanto o servidor decide qual arquivo corresponde a ele.

---

### 4. Princípio do menor privilégio

O processo do servidor web deve possuir somente as permissões necessárias.

Assim, mesmo que ocorra uma LFI:

```text
LFI
 ↓
arquivo solicitado
 ↓
permissões do processo
 ↓
acesso limitado
```

Isso reduz o impacto.

---

# 📊 Resumo

|Técnica|Conceito|
|---|---|
|**LFI**|Inclusão/leitura de arquivo local|
|**RFI**|Inclusão de recurso remoto|
|**Path Traversal**|Manipulação de caminhos usando `../`|
|**Double Encoding**|Codificação múltipla para contornar filtros frágeis|
|**Null Byte**|Técnica histórica envolvendo `%00`|

---

## 📌 Regra de ouro

👉 **Nunca permita que uma entrada controlada pelo usuário determine diretamente um caminho de arquivo.**

Prefira:

```text
Usuário
   ↓
Identificador permitido
   ↓
Whitelist
   ↓
Arquivo definido pelo servidor
```

em vez de:

```text
Usuário
   ↓
Caminho arbitrário
   ↓
include()
   ↓
💥 LFI
```