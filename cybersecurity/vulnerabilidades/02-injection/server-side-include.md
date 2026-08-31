## 🧩 Server-Side Include Injection (SSI Injection)

A **SSI Injection** acontece quando uma aplicação permite que dados controlados pelo usuário sejam interpretados pelo servidor web como **diretivas Server-Side Include (SSI)**.

Os **SSI (Server-Side Includes)** são mecanismos utilizados por alguns servidores web para inserir conteúdo dinâmico em páginas HTML **antes que elas sejam enviadas ao navegador**.

👉 O problema surge quando a aplicação permite que uma entrada fornecida pelo usuário seja incorporada a uma página processada por SSI sem a devida validação.

---

## ⚙️ Como acontece

O fluxo normal é:

```text
Página HTML
    ↓
Servidor Web
    ↓
Processamento das diretivas SSI
    ↓
Página final
    ↓
Navegador
```

Em uma aplicação vulnerável:

```text
Entrada do usuário
       ↓
Página HTML
       ↓
Servidor interpreta como SSI
       ↓
Diretiva é processada
       ↓
Resultado enviado ao navegador
```

💥 Assim, uma entrada que deveria ser apenas **texto** pode acabar sendo interpretada como uma **instrução do servidor**.

---

## 📌 Sintaxe SSI

As diretivas SSI normalmente possuem a estrutura:

```html
<!--#diretiva parâmetro="valor" -->
```

Por exemplo:

```html
<!--#echo var="DOCUMENT_NAME" -->
```

O servidor processa a diretiva e substitui seu conteúdo antes de entregar a página.

---

## 🔎 Encontrando SSI Injection

Durante um pentest autorizado, procure funcionalidades que:

- geram páginas dinamicamente
- permitem inserir conteúdo HTML
- processam templates
- utilizam arquivos `.shtml`, `.shtm` ou `.stm`
- recebem conteúdo que posteriormente aparece em uma página

Extensões tradicionalmente associadas a SSI:

```text
.stm
.shtm
.shtml
```

📌 A ausência dessas extensões **não significa que a aplicação esteja protegida**. O comportamento depende da configuração do servidor.

---

## 🧪 Testando a interpretação de SSI

Uma forma de identificar possíveis pontos de SSI Injection é verificar se caracteres utilizados na sintaxe SSI são aceitos e posteriormente interpretados.

Por exemplo:

```text
< ! # = / . " -
```

O teste deve começar com entradas **inofensivas**, procurando evidências de que o servidor está processando SSI.

Por exemplo:

```html
<!--#echo var="DOCUMENT_NAME" -->
```

Se o resultado da página mudar e demonstrar que a diretiva foi processada pelo servidor:

```text
Entrada
   ↓
SSI
   ↓
Servidor processou
   ↓
Resultado diferente
```

💥 existe um forte indício de **SSI Injection**.

---

# 📌 Diretivas SSI

### 🔹 `echo`

Pode exibir variáveis do ambiente SSI.

```html
<!--#echo var="DOCUMENT_NAME" -->
```

Também pode ser utilizado para exibir:

```html
<!--#echo var="DOCUMENT_URI" -->
```

---

### 🔹 `config`

Permite alterar configurações utilizadas pelo processamento SSI.

Exemplo:

```html
<!--#config errmsg="Erro ao processar arquivo" -->
```

Também é possível configurar o formato de data:

```html
<!--#config timefmt="A %B %d %Y %r" -->
```

---

### 🔹 `fsize`

Pode exibir o tamanho de um arquivo:

```html
<!--#fsize file="ssi.shtml" -->
```

📌 A disponibilidade e o comportamento dessas diretivas dependem do servidor e de sua configuração.

---

# 💻 SSI e execução de comandos

Algumas implementações/configurações de SSI oferecem uma diretiva `exec`, capaz de executar comandos no servidor.

Exemplo:

```html
<!--#exec cmd="ls" -->
```

Em Windows:

```html
<!--#exec cmd="dir" -->
```

💥 Se uma aplicação permitir que um atacante injete e execute uma diretiva `exec`, o impacto pode ser extremamente grave, pois o comando será executado com os **privilégios do processo do servidor web**.

Fluxo:

```text
SSI Injection
      ↓
#exec
      ↓
Sistema operacional
      ↓
Comando
      ↓
Resultado
```

⚠️ Por esse motivo, `exec` deve ser desabilitado quando não for necessário.

---

## 🚨 Impactos

Dependendo da configuração do servidor, SSI Injection pode permitir:

- alteração do conteúdo das páginas
- exposição de informações
- leitura de arquivos
- manipulação de conteúdo
- execução de comandos
- comprometimento da aplicação
- comprometimento do servidor

O impacto depende diretamente das **permissões do processo do servidor web**.

Por exemplo:

```text
SSI
 ↓
Servidor Web
 ↓
usuário www-data
 ↓
comando executado com privilégios de www-data
```

---

# 🧠 SSI Injection × XSS

É importante diferenciar as duas vulnerabilidades.

### XSS

O código é executado no:

```text
Navegador do usuário
```

### SSI Injection

A diretiva é processada no:

```text
Servidor Web
```

Fluxos:

```text
XSS
Entrada → HTML → Navegador → JavaScript
```

```text
SSI Injection
Entrada → HTML → Servidor → SSI → Resultado
```

👉 Portanto, **SSI Injection é uma vulnerabilidade do lado do servidor**, enquanto XSS normalmente afeta o lado do cliente.

---

# 🧪 Exemplo conceitual

Imagine uma aplicação que recebe:

```text
/page?name=Paulo
```

e gera:

```html
<html>
<body>
Olá, Paulo
</body>
</html>
```

Se a aplicação estiver configurada para processar SSI e o valor for inserido diretamente:

```html
<html>
<body>
Olá, <!--#echo var="DOCUMENT_NAME" -->
</body>
</html>
```

o servidor pode interpretar a diretiva antes de enviar a página.

💥 O que deveria ser simplesmente:

```text
texto fornecido pelo usuário
```

passou a ser:

```text
diretiva interpretada pelo servidor
```

---

## 🔐 Como prevenir

A principal defesa é impedir que **entrada não confiável seja interpretada como SSI**.

Medidas:

- desabilitar SSI quando não for necessário
- desabilitar `exec`
- não permitir SSI em conteúdo controlado pelo usuário
- realizar output encoding adequado
- validar entradas
- separar conteúdo dinâmico de templates executáveis
- utilizar permissões mínimas para o servidor web
- manter servidor e componentes atualizados
- configurar corretamente o mecanismo de SSI

📌 Especialmente importante:

```text
Entrada do usuário
       ↓
NÃO deve ser
       ↓
interpretada como diretiva SSI
```

---

## 🕰️ Exemplo histórico — IIS

Existiram vulnerabilidades históricas relacionadas ao processamento de SSI em versões antigas do IIS.

Um exemplo é o **CVE-2001-0506**, associado ao IIS 4.0/5.0 e ao componente `ssinc.dll`.

Esse tipo de vulnerabilidade é diferente de uma **SSI Injection comum**: nesse caso, trata-se de uma vulnerabilidade específica do software que processava SSI, e não simplesmente de uma aplicação que permitia a injeção de uma diretiva.

📌 Para estudar vulnerabilidades históricas, é importante separar:

```text
SSI Injection
→ configuração/validação insegura da aplicação

CVE de SSI
→ vulnerabilidade específica do servidor/componente
```

---

## 🛡️ Regra de ouro

👉 **Nunca permita que conteúdo controlado pelo usuário seja interpretado pelo servidor como uma diretiva SSI.**