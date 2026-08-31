## 🧪 Null Byte Injection (Injeção de Byte Nulo)

A **Null Byte Injection**, também conhecida como **Null Bytes Poisoning**, é uma técnica que utiliza o caractere **byte nulo (`NULL byte`)** para tentar alterar a forma como diferentes componentes de uma aplicação interpretam uma entrada.

O byte nulo é representado por:

```text
%00
```

ou, em hexadecimal:

```text
0x00
```

👉 Historicamente, algumas linguagens e bibliotecas utilizavam `\0` como **terminador de strings**. Quando componentes diferentes interpretavam a mesma entrada de maneiras diferentes, isso podia permitir **bypass de validações e filtros**.

---

## ⚙️ Como acontece

Imagine uma aplicação que recebe:

```text
arquivo=imagem.jpg
```

e verifica a extensão através de uma validação simples.

Em sistemas vulneráveis, uma entrada contendo um byte nulo poderia ser interpretada de maneiras diferentes:

```text
imagem.php%00.jpg
```

Um componente poderia interpretar:

```text
imagem.php%00.jpg
```

enquanto outro poderia considerar apenas:

```text
imagem.php
```

💥 Essa diferença de interpretação pode fazer com que a validação e o processamento do arquivo **discordem sobre qual é o verdadeiro nome ou conteúdo da entrada**.

---

## 📌 Representações

O byte nulo pode aparecer de diferentes formas:

```text
\0
```

```text
%00
```

```text
0x00
```

Em uma URL:

```text
https://exemplo.com/download?file=teste%00.txt
```

📌 `%00` é a representação **URL-encoded** do byte `0x00`.

---

## 🔎 Exemplos práticos

### 🔹 1. Bypass de extensão

Uma aplicação pode verificar:

```text
arquivo.jpg
```

e aceitar somente arquivos `.jpg`.

Em implementações antigas/vulneráveis, poderia ser testado:

```text
arquivo.php%00.jpg
```

O objetivo seria explorar uma diferença entre:

```text
Validação
    ↓
.jpg

Processamento
    ↓
.php
```

💥 Se diferentes componentes interpretarem o byte nulo de maneiras diferentes, pode ocorrer um bypass.

---

### 🔹 2. Path Traversal

O Null Byte Injection também pode aparecer combinado com vulnerabilidades de **Path Traversal** em aplicações antigas.

Exemplo conceitual:

```text
../../arquivo%00.txt
```

A ideia é explorar diferenças na maneira como:

```text
filtro
   ↓
biblioteca
   ↓
sistema operacional
```

interpretam o caminho.

📌 Atualmente, muitas linguagens e bibliotecas modernas rejeitam bytes nulos em caminhos de arquivos, reduzindo bastante a eficácia dessa técnica.

---

### 🔹 3. Inclusão de arquivos

Em aplicações vulneráveis, o byte nulo também foi historicamente utilizado para tentar interferir em operações como:

```php
include($arquivo);
```

Por exemplo:

```text
arquivo.php%00
```

A intenção era fazer diferentes componentes interpretarem o final da string de maneira diferente.

💥 Novamente, esse comportamento é principalmente relevante para **implementações antigas ou APIs vulneráveis**.

---

## 🧠 Por que funciona?

O problema clássico está na **diferença de interpretação entre componentes**.

Imagine:

```text
Entrada:
arquivo.php%00.jpg
        ↓
      Decodifica
        ↓
arquivo.php\0.jpg
```

Um componente poderia interpretar:

```text
arquivo.php
```

Enquanto outro poderia interpretar:

```text
arquivo.php.jpg
```

Temos então:

```text
┌─────────────┐
│   Filtro    │ → interpretação A
└─────────────┘
       ↓
┌─────────────┐
│  Biblioteca │ → interpretação B
└─────────────┘
       ↓
┌─────────────┐
│ Aplicação   │
└─────────────┘
```

💥 Essa **inconsistência de parsing** é o principal conceito por trás do Null Byte Injection.

---

## 🚨 Impactos

Dependendo da aplicação e das bibliotecas utilizadas, pode contribuir para:

- bypass de filtros
- bypass de validação de extensão
- Path Traversal
- Directory Traversal
- inclusão de arquivos
- problemas no processamento de arquivos
- em cenários específicos, execução de código

📌 O Null Byte Injection normalmente **não é uma vulnerabilidade independente que garante execução de código**. Ele é uma **técnica de bypass** que pode ser utilizada para explorar outras vulnerabilidades.

---

## 🔎 Em pentest

Durante um pentest autorizado, procure entradas relacionadas a:

```text
arquivos
caminhos
uploads
downloads
includes
parâmetros de URL
```

Teste representações como:

```text
%00
```

```text
\0
```

e observe se existe alguma diferença entre:

```text
entrada enviada
      ↓
entrada decodificada
      ↓
entrada validada
      ↓
entrada processada
```

👉 O objetivo é descobrir se diferentes componentes da aplicação **interpretam o mesmo dado de maneiras diferentes**.

---

## 🛡️ Como prevenir

- rejeitar bytes nulos nas entradas quando eles não forem necessários
- utilizar APIs modernas de manipulação de arquivos
- realizar validação após a normalização/canonicalização da entrada
- não confiar somente na extensão fornecida pelo usuário
- validar caminhos usando APIs seguras
- evitar concatenar caminhos diretamente
- manter linguagens, frameworks e bibliotecas atualizados
- garantir que todos os componentes utilizem a mesma interpretação dos dados

📌 Para upload de arquivos, por exemplo, **não confie apenas no nome ou extensão**:

```text
arquivo.jpg
```

não significa necessariamente que o conteúdo seja realmente uma imagem JPEG.

---

📌 **Regra de ouro:**

👉 **Normalize e valide a entrada antes de utilizá-la, e nunca permita que diferentes componentes interpretem a mesma entrada de maneiras inconsistentes.**