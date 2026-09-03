# 🌐 Códigos de Status das Respostas HTTP

Os **códigos de status HTTP** indicam o resultado de uma requisição HTTP realizada por um cliente a um servidor.

Os códigos são divididos em **cinco classes**, identificadas pelo primeiro dígito:

| Classe     |   Faixa | Descrição               |
| ---------- | ------: | ----------------------- |
| 🟦 **1xx** | 100–199 | Respostas de informação |
| 🟩 **2xx** | 200–299 | Respostas de sucesso    |
| 🟨 **3xx** | 300–399 | Redirecionamentos       |
| 🟥 **4xx** | 400–499 | Erros do cliente        |
| 🟪 **5xx** | 500–599 | Erros do servidor       |

---

## 📋 Principais códigos

| Código | Nome                  | Descrição                                                                         |
| -----: | --------------------- | --------------------------------------------------------------------------------- |
|  `100` | Continue              | A requisição foi recebida e o cliente pode continuar.                             |
|  `200` | OK                    | A requisição foi processada com sucesso.                                          |
|  `201` | Created               | Um novo recurso foi criado com sucesso.                                           |
|  `204` | No Content            | A requisição foi processada, mas não há conteúdo para retornar.                   |
|  `301` | Moved Permanently     | O recurso foi movido permanentemente para outra URL.                              |
|  `302` | Found                 | O recurso está temporariamente disponível em outra URL.                           |
|  `304` | Not Modified          | O recurso não foi modificado desde a última requisição.                           |
|  `400` | Bad Request           | A requisição possui uma sintaxe ou informação inválida.                           |
|  `401` | Unauthorized          | É necessário realizar autenticação.                                               |
|  `403` | Forbidden             | O servidor entendeu a requisição, mas recusou o acesso.                           |
|  `404` | Not Found             | O recurso solicitado não foi encontrado.                                          |
|  `405` | Method Not Allowed    | O método HTTP utilizado não é permitido para o recurso.                           |
|  `408` | Request Timeout       | O servidor aguardou a requisição, mas ocorreu um timeout.                         |
|  `409` | Conflict              | A requisição entra em conflito com o estado atual do recurso.                     |
|  `410` | Gone                  | O recurso não está mais disponível e provavelmente foi removido permanentemente.  |
|  `429` | Too Many Requests     | O cliente realizou muitas requisições em determinado período.                     |
|  `500` | Internal Server Error | Ocorreu um erro interno no servidor.                                              |
|  `502` | Bad Gateway           | Um servidor atuando como gateway recebeu uma resposta inválida de outro servidor. |
|  `503` | Service Unavailable   | O servidor está temporariamente indisponível.                                     |
|  `504` | Gateway Timeout       | Um gateway ou proxy não recebeu uma resposta a tempo do servidor upstream.        |

---

# 🟩 Respostas de sucesso — 2xx

Os códigos **2xx** indicam que a requisição foi recebida, compreendida e processada com sucesso.

### `200 OK`

Indica que a requisição foi processada corretamente.

Exemplo:

```http
GET /index.html HTTP/1.1
```

Resposta:

```http
HTTP/1.1 200 OK
```

---

### `201 Created`

Indica que um novo recurso foi criado.

É muito utilizado em APIs após uma requisição `POST`.

```http
POST /usuarios HTTP/1.1
```

Resposta:

```http
HTTP/1.1 201 Created
```

---

### `204 No Content`

A requisição foi processada com sucesso, mas o servidor não possui conteúdo para retornar no corpo da resposta.

É comum em operações como `DELETE`.

```http
DELETE /usuarios/10 HTTP/1.1
```

Resposta:

```http
HTTP/1.1 204 No Content
```

---

# 🔄 Redirecionamentos — 3xx

Os códigos **3xx** indicam que o cliente precisa realizar alguma ação adicional para concluir a requisição, geralmente seguindo outra URL.

### `301 Moved Permanently`

Indica que o recurso foi movido **permanentemente** para outro endereço.

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/
```

É bastante utilizado quando um site muda permanentemente de URL.

---

### `302 Found`

Indica que o recurso está temporariamente disponível em outro endereço.

```http
HTTP/1.1 302 Found
Location: /login
```

---

### `304 Not Modified`

Indica que o recurso **não foi modificado** desde a última versão armazenada pelo cliente.

É utilizado para mecanismos de **cache**.

---

# 🟥 Erros do cliente — 4xx

Os códigos **4xx** indicam que o problema está relacionado à requisição realizada pelo cliente.

### `400 Bad Request`

A requisição possui informações inválidas ou uma sintaxe incorreta.

```http
HTTP/1.1 400 Bad Request
```

---

### `401 Unauthorized`

Indica que a requisição exige autenticação ou que as credenciais fornecidas não são válidas.

```http
HTTP/1.1 401 Unauthorized
```

> Apesar do nome, `401` está relacionado principalmente à **autenticação**.

---

### `403 Forbidden`

O servidor recebeu e entendeu a requisição, porém **recusou o acesso** ao recurso.

```http
HTTP/1.1 403 Forbidden
```

> Diferente do `401`, o `403` normalmente indica que a identidade do cliente não é suficiente para permitir o acesso.

---

### `404 Not Found`

O servidor não encontrou o recurso solicitado.

```http
GET /admin/painel HTTP/1.1
```

Resposta:

```http
HTTP/1.1 404 Not Found
```

É um dos códigos mais comuns durante a navegação na Web.

---

### `405 Method Not Allowed`

Indica que o método HTTP utilizado não é permitido para aquele recurso.

Por exemplo, um endpoint pode aceitar:

```http
GET /usuarios
```

mas não:

```http
DELETE /usuarios
```

Nesse caso, o servidor pode retornar:

```http
HTTP/1.1 405 Method Not Allowed
```

---

### `429 Too Many Requests`

Indica que o cliente realizou muitas requisições em um determinado intervalo de tempo.

É frequentemente utilizado em mecanismos de **Rate Limiting**.

```http
HTTP/1.1 429 Too Many Requests
```

---

# 🟪 Erros do servidor — 5xx

Os códigos **5xx** indicam que o servidor encontrou um problema ao tentar processar uma requisição aparentemente válida.

### `500 Internal Server Error`

Indica um erro interno inesperado no servidor.

```http
HTTP/1.1 500 Internal Server Error
```

É um código genérico e não informa exatamente qual foi o problema.

---

### `502 Bad Gateway`

Indica que um servidor atuando como **gateway ou proxy** recebeu uma resposta inválida de outro servidor.

```text
Cliente
   │
   ▼
Proxy/Gateway
   │
   ▼
Servidor
```

Se o servidor de destino responder de forma inválida, o gateway pode retornar:

```http
HTTP/1.1 502 Bad Gateway
```

---

### `503 Service Unavailable`

Indica que o servidor está temporariamente indisponível.

Pode ocorrer devido a:

* manutenção;
* sobrecarga;
* falta de recursos;
* indisponibilidade temporária de um serviço.

```http
HTTP/1.1 503 Service Unavailable
```

---

### `504 Gateway Timeout`

Ocorre quando um gateway ou proxy não recebe uma resposta do servidor upstream dentro do tempo esperado.

```text
Cliente
   │
   ▼
Gateway
   │
   ▼
Servidor upstream
   │
   ✕
 Timeout
```

Resposta:

```http
HTTP/1.1 504 Gateway Timeout
```

---

# 📌 Métodos HTTP e respostas

Os códigos de status também podem ser relacionados ao método utilizado na requisição.

| Método    | Finalidade                           | Exemplo de sucesso           |
| --------- | ------------------------------------ | ---------------------------- |
| `GET`     | Obter um recurso                     | `200 OK`                     |
| `POST`    | Criar/enviar dados                   | `200 OK` ou `201 Created`    |
| `PUT`     | Criar ou substituir um recurso       | `200 OK` ou `204 No Content` |
| `PATCH`   | Alterar parcialmente um recurso      | `200 OK` ou `204 No Content` |
| `DELETE`  | Remover um recurso                   | `204 No Content`             |
| `HEAD`    | Obter apenas os cabeçalhos           | `200 OK`                     |
| `OPTIONS` | Consultar métodos/opções disponíveis | `200 OK`                     |
| `TRACE`   | Diagnóstico da requisição            | `200 OK`                     |

> **Importante:** o código de status não é determinado exclusivamente pelo método HTTP. O servidor escolhe o status de acordo com o resultado do processamento da requisição.

---

# 🔎 Exemplo completo

Uma requisição:

```http
GET /admin HTTP/1.1
Host: example.com
```

Pode receber:

```http
HTTP/1.1 403 Forbidden
Content-Type: text/html
```

Nesse caso:

* `GET` → método utilizado;
* `/admin` → recurso solicitado;
* `403` → código de status;
* `Forbidden` → descrição do status;
* `Content-Type` → informa o tipo do conteúdo retornado.

---

# 🧠 Resumo

```text
1xx → Informação
2xx → Sucesso
3xx → Redirecionamento
4xx → Erro do cliente
5xx → Erro do servidor
```

### Códigos importantes para lembrar

```text
200 → OK
201 → Created
204 → No Content

301 → Moved Permanently
302 → Found
304 → Not Modified

400 → Bad Request
401 → Unauthorized
403 → Forbidden
404 → Not Found
405 → Method Not Allowed
429 → Too Many Requests

500 → Internal Server Error
502 → Bad Gateway
503 → Service Unavailable
504 → Gateway Timeout
```
