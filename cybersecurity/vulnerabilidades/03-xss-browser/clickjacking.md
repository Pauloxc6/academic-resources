## 🖱️ Clickjacking

**Clickjacking** (sequestro de clique) é uma técnica na qual um atacante faz a vítima **clicar em um elemento diferente daquele que ela acredita estar clicando**.

👉 O atacante utiliza elementos sobrepostos, geralmente um **`iframe` transparente**, para colocar uma página ou botão legítimo por cima de um conteúdo falso.

---

## 🧠 Como funciona

Imagine uma página maliciosa mostrando:

```text
┌─────────────────────────────┐
│                             │
│     🎁 VOCÊ GANHOU!         │
│                             │
│     [ PEGAR MEU IPHONE ]    │
│                             │
└─────────────────────────────┘
```

Por baixo desse botão pode existir um elemento de uma página legítima:

```text
┌─────────────────────────────┐
│                             │
│     Página falsa            │
│          ↓                  │
│     [ botão real ]          │
│                             │
└─────────────────────────────┘
```

A vítima acredita estar clicando no botão falso, mas o clique é recebido pelo elemento da página legítima.

---

## ⚙️ O `iframe`

O elemento mais comum nesse cenário é:

```html
<iframe src="https://vulnerable.com"></iframe>
```

O `<iframe>` permite incorporar outra página dentro da página atual.

No Clickjacking, o atacante tenta posicionar esse conteúdo de forma que um elemento da página incorporada fique **sobreposto** ao conteúdo visual apresentado à vítima.

---

## 🎨 Exemplo conceitual

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        #alvo {
            position: relative;
            width: 500px;
            height: 300px;
            opacity: 0.00001;
            z-index: 2;
        }

        #conteudo {
            width: 500px;
            height: 300px;
            z-index: 1;
        }
    </style>
</head>

<body>

    <div id="conteudo">
        <h1>🎁 Você ganhou um prêmio!</h1>
        <button>Pegar meu prêmio</button>
    </div>

    <iframe
        id="alvo"
        src="https://alvo.com">
    </iframe>

</body>
</html>
```

📌 Os valores de `width` e `height` são apenas exemplos. Em um teste real, o posicionamento depende da interface que está sendo analisada.

---

# 🔍 Entendendo o CSS

### `opacity`

```css
opacity: 0.00001;
```

Controla a transparência do elemento.

```text
1       → totalmente visível
0.5     → parcialmente transparente
0       → totalmente transparente
```

No Clickjacking, o atacante pode tentar tornar o `iframe` praticamente invisível para a vítima.

---

### `z-index`

```css
z-index: 2;
```

Define a ordem de empilhamento dos elementos.

Por exemplo:

```text
z-index: 2
    ↓
┌─────────────┐
│   elemento  │
└─────────────┘

z-index: 1
    ↓
┌─────────────┐
│   elemento  │
└─────────────┘
```

👉 O elemento com maior `z-index` tende a ficar acima, desde que os elementos estejam em contextos de empilhamento compatíveis.

---

### `position`

```css
position: relative;
```

Permite posicionar o elemento e, em determinados contextos, participar do controle de empilhamento através do `z-index`.

---

# 🎯 Objetivo do ataque

O objetivo não é necessariamente roubar dados diretamente.

O atacante tenta **induzir a vítima a realizar uma ação que ela não pretendia realizar**.

Possíveis ações:

- clicar em botões
- alterar configurações
- confirmar operações
- excluir conteúdo
- aceitar permissões
- realizar ações dentro de uma aplicação

💥 O impacto depende principalmente de **qual ação o usuário autenticado pode executar**.

---

# 🧪 Em um pentest

Uma demonstração básica pode verificar se uma aplicação pode ser incorporada em um `iframe` de outra origem.

Por exemplo:

```html
<iframe src="https://alvo.com"></iframe>
```

Se a página carregar normalmente dentro do `iframe`, existe um indício de que ela **pode ser enquadrada (framed)**.

📌 Porém, **ser possível carregar uma página em um iframe não significa automaticamente que existe um Clickjacking explorável**.

É necessário avaliar se existe uma ação sensível que pode ser induzida através da sobreposição.

---

# 🚨 Impactos

Dependendo da funcionalidade vulnerável:

- execução de ações sem intenção
- alteração de configurações
- exclusão de dados
- mudança de preferências
- ações administrativas
- fraude

---

# 🛡️ Como prevenir

As principais proteções são os mecanismos que impedem que a aplicação seja incorporada por sites não autorizados.

### 🔹 `Content-Security-Policy`

Uma proteção moderna é:

```http
Content-Security-Policy: frame-ancestors 'none';
```

Ou permitindo apenas origens específicas:

```http
Content-Security-Policy: frame-ancestors 'self';
```

---

### 🔹 `X-Frame-Options`

Também pode ser utilizado:

```http
X-Frame-Options: DENY
```

ou:

```http
X-Frame-Options: SAMEORIGIN
```

📌 `Content-Security-Policy: frame-ancestors` é a abordagem mais flexível para controlar quem pode enquadrar a página.

---

## 🧠 Clickjacking vs XSS

São vulnerabilidades diferentes:

```text
XSS
↓
Atacante injeta JavaScript
↓
Código executado no navegador
```

```text
Clickjacking
↓
Atacante manipula a interface/posição dos elementos
↓
Vítima clica em algo diferente do que imagina
```

👉 Clickjacking explora principalmente **a interação do usuário com a interface**.

---

## 📌 Regra de ouro

👉 **Uma aplicação que contém ações sensíveis deve impedir que páginas não autorizadas a incorporem em `iframe`.**

Em um Bug Bounty, uma evidência simples de que uma página sensível pode ser enquadrada pode ser útil, mas o impacto fica muito mais forte quando você demonstra **qual ação sensível pode ser induzida** sem causar dano real.