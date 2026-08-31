## 🔀 HTTP Request Smuggling (Contrabando de Requisições HTTP)

### 🧠 O que é HTTP Request Smuggling?

**HTTP Request Smuggling**, também conhecido como **Contrabando de Requisições HTTP**, é uma vulnerabilidade que ocorre quando diferentes componentes da infraestrutura web **interpretam uma mesma requisição HTTP de maneiras diferentes**.

Normalmente, uma aplicação possui vários servidores entre o usuário e a aplicação final:

```text
Usuário
   │
   ▼
Proxy / Load Balancer
   │
   ▼
Servidor Web
   │
   ▼
Aplicação
```

O problema aparece quando o servidor **front-end** e o servidor **back-end** não concordam sobre onde uma requisição termina.

💥 O atacante pode explorar essa diferença para fazer uma requisição adicional ser interpretada pelo back-end de maneira inesperada.

---

## ⚙️ Como acontece

Quando o front-end encaminha requisições para o back-end, várias requisições podem utilizar a mesma conexão HTTP.

Por isso, o servidor precisa saber exatamente:

```text
Onde uma requisição começa?
Onde uma requisição termina?
```

O HTTP possui diferentes mecanismos para determinar o tamanho do corpo da requisição.

Os principais são:

```text
Content-Length
Transfer-Encoding
```

Quando os servidores interpretam esses mecanismos de maneira diferente, pode surgir o **HTTP Request Smuggling**.

---

## 📏 Content-Length

O cabeçalho `Content-Length` informa o tamanho do corpo da requisição em bytes.

Exemplo:

```http
POST /search HTTP/1.1
Host: normal-website.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 11

q=smuggling
```

Nesse caso, o servidor utiliza o valor:

```text
Content-Length: 11
```

para determinar onde termina o corpo da requisição.

---

## 📦 Transfer-Encoding

O cabeçalho `Transfer-Encoding: chunked` permite enviar o corpo da requisição em partes (_chunks_).

```http
POST /search HTTP/1.1
Host: normal-website.com
Content-Type: application/x-www-form-urlencoded
Transfer-Encoding: chunked

b
q=smuggling
0
```

O valor:

```text
b
```

representa o tamanho do bloco em hexadecimal.

O:

```text
0
```

indica o fim da transmissão em chunks.

---

## 💣 Como surge o problema?

O atacante tenta criar uma requisição que seja interpretada de maneira diferente pelos servidores.

Por exemplo:

```text
                 MESMA REQUISIÇÃO
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
        Front-end              Back-end
             │                     │
      interpreta de A       interpreta de B
             │                     │
             └──────────┬──────────┘
                        ▼
             Requisição inesperada
```

Essa diferença pode fazer com que parte dos dados seja interpretada como uma **nova requisição HTTP**.

---

# 📌 Tipos de HTTP Request Smuggling

## CL.TE

No **CL.TE**:

```text
Front-end → Content-Length
Back-end  → Transfer-Encoding
```

O front-end utiliza `Content-Length`, enquanto o back-end utiliza `Transfer-Encoding`.

---

## TE.CL

No **TE.CL**:

```text
Front-end → Transfer-Encoding
Back-end  → Content-Length
```

O front-end utiliza `Transfer-Encoding`, enquanto o back-end utiliza `Content-Length`.

---

## TE.TE

No **TE.TE**, os dois servidores suportam `Transfer-Encoding`, porém o atacante tenta utilizar **ofuscação** para fazer com que um dos servidores processe o cabeçalho de maneira diferente.

```text
Front-end → Transfer-Encoding
Back-end  → Transfer-Encoding
                    │
                    ▼
          interpretação diferente
```

---

# 🧪 Exemplo de requisição

Uma requisição pode conter os dois mecanismos:

```http
POST / HTTP/1.1
Host: example.com
Content-Length: 13
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
Host: example.com
```

⚠️ O comportamento dessa requisição depende da forma como os componentes da infraestrutura processam `Content-Length` e `Transfer-Encoding`.

Em um laboratório controlado, diferenças nessa interpretação podem ser utilizadas para demonstrar o **contrabando de uma segunda requisição**.

---

# 🎯 Possíveis impactos

Dependendo da arquitetura da aplicação, HTTP Request Smuggling pode possibilitar:

```text
→ Bypass de controles de segurança
→ Manipulação de requisições
→ Cache Poisoning
→ Acesso a informações de outras requisições
→ Bypass de autenticação
→ Interferência em requisições de outros usuários
→ XSS em determinados cenários
```

O impacto depende bastante da combinação entre:

```text
Proxy
   +
Servidor Web
   +
Servidor Back-end
   +
Configuração HTTP
```

---

# 🔍 Identificação

Durante um pentest autorizado, é importante analisar aplicações que utilizam:

```text
→ Reverse Proxy
→ Load Balancer
→ CDN
→ WAF
→ Servidor Web
→ Servidor de Aplicação
```

Também é importante observar o comportamento de:

```http
Content-Length
Transfer-Encoding
```

Diferenças entre as respostas ou tempos de processamento podem indicar uma possível inconsistência entre o front-end e o back-end.

---

# 🛠️ Ferramentas

Uma ferramenta utilizada para auxiliar na identificação de HTTP Request Smuggling é o **Smuggler**.

```bash
smuggler
```

O **Burp Suite** também pode ser utilizado para interceptar, modificar e analisar requisições HTTP durante testes autorizados.

---

# 🔐 Como corrigir

A prevenção deve garantir que todos os componentes da infraestrutura **interpretem as requisições HTTP de maneira consistente**.

Algumas medidas:

1. Manter proxy, load balancer e servidores atualizados;
2. Evitar configurações inconsistentes entre front-end e back-end;
3. Validar requisições HTTP antes de encaminhá-las;
4. Evitar aceitar requisições ambíguas;
5. Configurar corretamente o processamento de `Content-Length` e `Transfer-Encoding`;
6. Rejeitar requisições que contenham combinações ou formatos inválidos;
7. Utilizar uma única estratégia consistente para delimitação das requisições.

---

## 🧠 Resumo

```text
HTTP Request Smuggling
        ↓
Front-end interpreta a requisição
        ↓
        ≠
Back-end interpreta a requisição
        ↓
Requisição adicional é interpretada
        ↓
Possível manipulação de outras requisições
```

📌 **Regra de ouro:**

👉 **HTTP Request Smuggling acontece principalmente quando componentes diferentes da infraestrutura HTTP discordam sobre onde uma requisição termina.**