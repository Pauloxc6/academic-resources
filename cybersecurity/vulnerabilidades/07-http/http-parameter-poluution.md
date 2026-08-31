## 💉 HTTP Parameter Pollution (HPP)

### 🧠 O que é HPP?

**HTTP Parameter Pollution (HPP)** é uma vulnerabilidade que ocorre quando uma aplicação **processa parâmetros HTTP de maneira ambígua ou insegura**, principalmente quando o mesmo parâmetro aparece mais de uma vez ou quando parâmetros controlados pelo usuário são incorporados em URLs.

No **Client-Side HPP**, o problema ocorre quando a aplicação utiliza uma entrada fornecida pelo usuário para **construir URLs, links ou formulários** sem tratá-la corretamente.

👉 Um atacante pode criar uma URL especialmente preparada e induzir outro usuário a acessá-la. A aplicação pode então gerar uma nova URL contendo parâmetros adicionais ou modificar parâmetros existentes.

---

## ⚙️ Como acontece

Imagine uma aplicação que gera um link:

```text
https://example.com/invite?email=user@example.com
```

Se a aplicação incorporar entradas controladas pelo usuário diretamente na URL, um atacante pode tentar adicionar outro parâmetro:

```text
https://example.com/invite?email=attacker@example.com&email=victim@example.com
```

O comportamento dependerá de como a aplicação interpreta parâmetros duplicados.

Por exemplo:

```text
email=primeiro
email=segundo
```

Algumas aplicações podem utilizar:

```text
primeiro
```

ou:

```text
segundo
```

ou até:

```text
["primeiro", "segundo"]
```

💥 Essa diferença de interpretação pode ser explorada quando diferentes componentes da aplicação processam os parâmetros de maneiras diferentes.

---

# 🔎 Client-Side HPP

No **Client-Side HPP**, o atacante cria uma URL que modifica os parâmetros presentes nos links ou formulários gerados pela aplicação.

Fluxo:

```text
Atacante
   │
   │ URL manipulada
   ▼
Aplicação
   │
   │ gera URL modificada
   ▼
Navegador da vítima
   │
   ▼
Link/Formulário alterado
```

---

## 📌 Exemplo

Uma aplicação possui:

```text
http://example.com/invite?email=victim@example.com
```

Um atacante pode tentar adicionar outro parâmetro:

```text
http://example.com/invite?email=victim@example.com&email=attacker@example.com
```

Se a aplicação utilizar esses valores de maneira inadequada, o formulário ou link produzido poderá utilizar um destinatário diferente daquele esperado.

💥 O impacto depende da funcionalidade afetada.

---

## 🧪 Exploração

Exemplo de laboratório:

```text
http://127.0.0.1/hpp/params.php?p=valid&pp=12?pp="><img src=a onerror="alert(window.location.href)">
```

Nesse exemplo, o objetivo é testar se o parâmetro fornecido pelo usuário consegue **alterar a estrutura da URL e influenciar o conteúdo gerado pela aplicação**.

⚠️ Se a entrada também for refletida em HTML sem escaping adequado, pode haver uma segunda vulnerabilidade, como **XSS**.

---

## 🎯 Possíveis impactos

Dependendo da aplicação, HPP pode permitir:

- alteração de parâmetros;
- substituição de valores;
- manipulação de links;
- manipulação de formulários;
- alteração de destinatários;
- bypass de determinadas validações;
- comportamento inesperado em funcionalidades;
- em alguns cenários, combinação com XSS ou outras vulnerabilidades.

---

## 🔐 Como prevenir

- Validar parâmetros recebidos;
- Definir explicitamente quais parâmetros são aceitos;
- Rejeitar parâmetros duplicados quando não forem necessários;
- Utilizar APIs de parsing de URL adequadas;
- Não concatenar entrada do usuário diretamente em URLs;
- Fazer encoding correto dos parâmetros;
- Aplicar **output encoding** de acordo com o contexto;
- Garantir que diferentes componentes da aplicação interpretem parâmetros de forma consistente.

📌 **Regra de ouro:**

👉 **Não confie na estrutura de uma URL fornecida pelo usuário. Parâmetros devem ser validados, normalizados e codificados antes de serem reutilizados.**