## 🧩 HTML Injection (HTMLi)

A falha de **HTML Injection** acontece quando uma aplicação permite que um usuário forneça conteúdo que é posteriormente **interpretado como HTML pelo navegador**, sem uma validação ou sanitização adequada.

👉 O atacante pode conseguir inserir elementos HTML como **links, imagens, iframes, formulários e outros elementos** dentro da página.

📌 HTML Injection é semelhante ao XSS, mas existe uma diferença importante: **HTML Injection, por si só, não significa necessariamente execução de JavaScript**. Quando a injeção permite executar JavaScript, o problema passa a se enquadrar como **XSS**.

---

## ⚙️ Como acontece

A vulnerabilidade geralmente aparece quando a aplicação pega uma entrada do usuário:

- parâmetros da URL
- campos de formulário
- cadastro de usuários
- comentários
- mensagens
- nomes de perfil

e coloca o conteúdo diretamente no HTML.

Por exemplo:

```php
<p>Olá, <?php echo $_GET['name']; ?></p>
```

Uma entrada normal:

```text
?name=Paulo
```

gera:

```html
<p>Olá, Paulo</p>
```

Mas uma entrada contendo HTML:

```html
<img src="imagem.png">
```

pode fazer o navegador interpretar o conteúdo como um elemento HTML.

💥 O problema é que **dados fornecidos pelo usuário deixam de ser tratados apenas como texto e passam a ser interpretados como marcação HTML**.

---

## 📌 Exemplos práticos

### 🔹 1. HTML Injection através da URL

Imagine:

```text
http://exemplo.com/page.php?page=conteudo
```

A aplicação utiliza o parâmetro diretamente na página.

Um atacante pode tentar inserir:

```html
<img src="https://exemplo.com/imagem.png">
```

💥 Se a aplicação não sanitizar a entrada, a imagem poderá ser incorporada à página.

---

### 🔹 2. Inserção de iframe

Em um ambiente vulnerável:

```html
<iframe src="https://exemplo.com"></iframe>
```

💥 O atacante pode conseguir inserir outro conteúdo dentro da página.

📌 A possibilidade de carregar conteúdo externo também depende de políticas como **CSP** e das restrições do navegador.

---

### 🔹 3. HTML Injection em cadastro de usuário

Imagine um formulário:

```text
Nome:
[ Paulo ]

Descrição:
[ Estudante de segurança ]
```

A aplicação exibe:

```html
<h2>Paulo</h2>
<p>Estudante de segurança</p>
```

Se o sistema não realizar o escaping corretamente, alguém poderia cadastrar:

```html
<b>Paulo</b>
```

Resultado:

```html
<h2><b>Paulo</b></h2>
```

💥 O nome passa a ser interpretado como HTML em vez de texto.

---

### 🔹 4. HTML Injection armazenado

Nesse caso, o conteúdo malicioso é **salvo no servidor**.

Fluxo:

```text
Atacante
   ↓
Cadastro / comentário
   ↓
HTML armazenado
   ↓
Banco de dados
   ↓
Outro usuário acessa
   ↓
HTML é renderizado
```

Exemplo:

```html
<img src="imagem.png">
```

Se armazenado e posteriormente renderizado sem sanitização, todos os usuários que visualizarem aquele conteúdo poderão receber a alteração.

👉 Esse tipo é chamado de **Stored HTML Injection**.

---

### 🔹 5. HTML Injection refletido

O conteúdo não precisa ser armazenado.

Fluxo:

```text
URL / parâmetro
      ↓
Servidor
      ↓
Resposta HTML
      ↓
Navegador
```

Exemplo conceitual:

```text
/page.php?name=<b>Paulo</b>
```

Se o servidor inserir diretamente o valor:

```html
<p>Olá, <b>Paulo</b></p>
```

💥 O HTML fornecido pelo usuário é refletido imediatamente na resposta.

👉 Esse tipo é chamado de **Reflected HTML Injection**.

---

## 🧠 HTML Injection × XSS

Essa diferença é importante:

### HTML Injection

```text
Entrada
   ↓
HTML
   ↓
Alteração da página
```

Exemplo:

```html
<b>Texto</b>
```

### XSS

```text
Entrada
   ↓
HTML
   ↓
JavaScript
   ↓
Execução no navegador
```

Exemplo:

```html
<script>
alert(document.domain);
</script>
```

👉 Portanto, **XSS pode ser consequência de uma injeção de HTML**, mas nem toda HTML Injection resulta em XSS.

---

## 🔎 Em pentest

Durante um pentest, procure entradas que sejam refletidas ou armazenadas em HTML:

- parâmetros da URL
- campos de cadastro
- comentários
- mensagens
- nomes de usuário
- descrições
- parâmetros de busca

Primeiro, teste se HTML básico é interpretado:

```html
<b>teste</b>
```

Depois:

```html
<i>teste</i>
```

E:

```html
<img src="imagem.png">
```

Se o navegador interpretar esses elementos em vez de exibi-los como texto, existe um possível ponto de **HTML Injection**.

👉 Depois deve-se avaliar se é possível evoluir o impacto para uma vulnerabilidade mais grave, como **XSS**.

---

## 🚨 Impactos

Dependendo do contexto, pode ocorrer:

- alteração da aparência da página
- inserção de conteúdo falso
- phishing dentro da aplicação
- alteração da interface
- inserção de imagens ou links
- inserção de iframes
- manipulação da experiência do usuário
- em determinados cenários, evolução para XSS

📌 O impacto depende principalmente de **onde o HTML é inserido e de quais elementos o navegador permite interpretar**.

---

## 🛡️ Como prevenir

A principal defesa é realizar **output encoding/escaping** corretamente.

Em aplicações PHP:

❌ Evite:

```php
echo $_GET['name'];
```

✅ Prefira:

```php
echo htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');
```

Isso transforma caracteres especiais em entidades HTML.

Por exemplo:

```text
< → &lt;
> → &gt;
" → &quot;
```

Assim:

```html
<b>Paulo</b>
```

será exibido como texto, em vez de ser interpretado como HTML.

Também é importante:

- utilizar escaping contextual
- sanitizar HTML quando HTML realmente for permitido
- validar entradas
- utilizar frameworks com escaping automático
- implementar CSP como camada adicional
- evitar inserir dados diretamente no HTML

---

📌 **Regra de ouro:**

👉 **Entrada do usuário deve ser tratada como texto por padrão, nunca como HTML confiável.**