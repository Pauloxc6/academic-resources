## 📥 Local File Download (Download de Arquivo Local)

A falha de **Local File Download (LFD)** ocorre quando uma aplicação permite que o usuário **baixe arquivos armazenados no próprio servidor** por meio de um parâmetro controlado pelo usuário, sem validar corretamente o caminho solicitado.

👉 É semelhante ao **LFI**, mas o objetivo principal aqui é **obter o arquivo para download**, e não necessariamente fazer com que a aplicação o interprete ou inclua.

---

## ⚙️ Como acontece

Imagine uma aplicação que disponibiliza arquivos através de:

```text
/download.php?file=manual.pdf
```

O código pode ser algo como:

```php
<?php

$file = $_GET['file'];

readfile($file);

?>
```

A aplicação espera:

```text
/download.php?file=manual.pdf
```

Mas o usuário pode tentar alterar o caminho:

```text
/download.php?file=../../config.php
```

💥 Se não houver validação adequada, o servidor pode entregar um arquivo que deveria permanecer protegido.

---

## 📌 Exemplo prático

URL legítima:

```text
http://localhost/download.php?file=manual.pdf
```

Tentativa de acessar outro arquivo:

```text
http://localhost/download.php?file=/etc/hosts
```

Ou utilizando **Path Traversal**:

```text
http://localhost/download.php?file=../../../../etc/hosts
```

Em um laboratório, também podem ser testados arquivos como:

```text
/etc/hosts
/etc/passwd
/proc/version
```

📌 O sucesso depende das permissões do processo e de como a aplicação manipula o caminho.

---

## 🔀 LFD × LFI × Path Traversal

Essas vulnerabilidades podem parecer iguais, mas existe uma diferença importante:

|Vulnerabilidade|Objetivo|
|---|---|
|**LFD**|Baixar/obter um arquivo local|
|**LFI**|Incluir/ler um arquivo através da aplicação|
|**Path Traversal**|Manipular o caminho para acessar outro diretório/arquivo|

Um cenário pode combinar as três:

```text
Path Traversal
      ↓
../../../../etc/passwd
      ↓
Local File Download
      ↓
arquivo retornado ao usuário
```

---

## 🧪 Exemplo com PHP

Código vulnerável:

```php
<?php

$file = $_GET['file'];

header('Content-Disposition: attachment; filename="' . basename($file) . '"');

readfile($file);

?>
```

Requisição:

```text
/download.php?file=manual.pdf
```

O problema surge quando o servidor aceita um caminho arbitrário:

```text
/download.php?file=../../config.php
```

---

## 🎯 Impactos

Dependendo dos arquivos acessíveis:

- exposição de configurações;
- vazamento de credenciais;
- exposição de código-fonte;
- vazamento de chaves e tokens;
- exposição de informações do sistema;
- divulgação de dados de outros usuários.

Um caso particularmente interessante é conseguir baixar **arquivos de configuração ou código-fonte**, pois eles podem revelar outras vulnerabilidades.

---

## 🔎 Arquivos interessantes em laboratório

### Sistema

```text
/etc/hosts
/etc/passwd
/etc/os-release
/proc/version
```

### Aplicação

```text
config.php
.env
database.php
settings.php
```

### Código-fonte

```text
index.php
login.php
config.php
```

⚠️ O acesso real depende das permissões e da estrutura da aplicação.

---

## 🛡️ Como prevenir

### ❌ Evite

```php
$file = $_GET['file'];

readfile($file);
```

### ✅ Utilize uma whitelist

```php
$files = [
    'manual' => '/var/www/files/manual.pdf',
    'guia'   => '/var/www/files/guia.pdf'
];

$file = $_GET['file'] ?? '';

if (!isset($files[$file])) {
    http_response_code(404);
    exit;
}

readfile($files[$file]);
```

Assim, o usuário fornece:

```text
?file=manual
```

e **não um caminho arbitrário**.

---

## 📌 Regra de ouro

```text
Entrada do usuário
       ↓
Identificador permitido
       ↓
Whitelist
       ↓
Arquivo definido pelo servidor
       ↓
Download
```

👉 **Nunca permita que o usuário controle diretamente o caminho de um arquivo que será disponibilizado pelo servidor.**