## 🌐 SSRF — Server-Side Request Forgery

A falha de **SSRF (Server-Side Request Forgery)** ocorre quando uma aplicação permite que um atacante **induza o servidor a realizar requisições em seu nome**.

👉 Em vez de o atacante acessar diretamente um recurso, ele utiliza o **próprio servidor da aplicação como intermediário**.

Isso é especialmente perigoso porque o servidor pode ter acesso a recursos que não estão disponíveis diretamente pela Internet, como:

- sistemas internos;
- painéis administrativos;
- APIs internas;
- outros servidores da rede;
- serviços disponíveis apenas em `localhost`.

---

## ⚙️ Como acontece

Imagine uma aplicação que possui:

```text
/product/stock?stockApi=http://servidor-interno/api
```

O funcionamento esperado seria:

```text
Usuário
   ↓
Aplicação Web
   ↓
API de estoque
```

Porém, se o parâmetro for controlado pelo usuário:

```text
/product/stock?stockApi=http://localhost/admin
```

o fluxo passa a ser:

```text
Atacante
   ↓
Aplicação vulnerável
   ↓
localhost
   ↓
/admin
```

💥 O servidor faz a requisição que o atacante não conseguiria fazer diretamente.

---

# 🔎 Onde procurar SSRF

É interessante procurar funcionalidades nas quais o servidor precisa **buscar ou acessar uma URL fornecida pelo usuário**.

Exemplos:

```text
Importar uma URL
Verificar disponibilidade de um site
Buscar uma imagem
Webhook
Integração com APIs
Leitor de feeds
Gerador de preview
Download através de URL
Consulta de estoque
```

Parâmetros comuns:

```text
url=
uri=
path=
dest=
redirect=
callback=
webhook=
image=
load=
file=
stockApi=
```

📌 O nome do parâmetro não determina se existe SSRF. O importante é descobrir **se o servidor realmente realiza uma requisição usando aquele valor**.

---

# 🧩 Tipos de SSRF

Existem dois cenários bastante comuns:

### 🔹 SSRF básico

A resposta da requisição feita pelo servidor é retornada para o atacante.

```text
Atacante
   ↓
Servidor vulnerável
   ↓
Servidor interno
   ↓
Resposta
   ↓
Atacante
```

Isso facilita bastante a identificação e exploração.

---

### 🔹 Blind SSRF

O servidor realiza a requisição, mas **não devolve o conteúdo da resposta**.

```text
Atacante
   ↓
Servidor vulnerável
   ↓
Servidor interno
```

A resposta não chega ao atacante.

Nesse caso, a confirmação pode depender de outros sinais, como:

- diferenças de comportamento;
- tempo de resposta;
- registros de acesso;
- interação com um servidor controlado no laboratório.

---

# 🎯 SSRF contra o próprio servidor

Uma aplicação pode ser induzida a acessar serviços hospedados no próprio servidor.

Exemplo:

```http
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded

stockApi=http://localhost/admin
```

O servidor recebe:

```text
http://localhost/admin
```

e realiza a requisição.

Fluxo:

```text
Aplicação
    ↓
localhost
    ↓
/admin
```

Isso pode ser particularmente perigoso quando a interface administrativa aceita requisições provenientes apenas do próprio servidor.

---

# 🖥️ SSRF contra outros sistemas internos

O servidor também pode conseguir alcançar outros hosts da rede interna.

Exemplo:

```http
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded

stockApi=http://192.168.0.68/admin
```

Fluxo:

```text
Internet
   ↓
Servidor Web
   ↓
192.168.0.68
   ↓
/admin
```

💥 Nesse cenário, o servidor vulnerável funciona como um **pivô para alcançar outro sistema**.

---

# 🔀 SSRF + Open Redirect

Uma aplicação pode possuir filtros que bloqueiam diretamente:

```text
http://192.168.0.68
```

mas permitem URLs pertencentes ao próprio domínio.

Se existir um **Open Redirect**, pode surgir uma cadeia:

```text
SSRF
  +
Open Redirect
  ↓
Bypass de validação
```

Exemplo:

```http
POST /product/stock HTTP/1.0
Content-Type: application/x-www-form-urlencoded

stockApi=http://weliketoshop.net/product/nextProduct?currentProductId=6&path=http://192.168.0.68/admin
```

A aplicação inicialmente vê:

```text
weliketoshop.net
```

e considera o destino permitido.

Depois, o redirecionamento leva a:

```text
http://192.168.0.68/admin
```

📌 Esse tipo de bypass depende completamente de **como a aplicação valida URLs e segue redirecionamentos**.

---

# 🌐 Protocolos e Schemes

Dependendo da biblioteca utilizada pela aplicação, uma SSRF pode envolver diferentes **URL schemes**:

```text
http://
https://
ftp://
file://
```

Em aplicações ou bibliotecas específicas, outros schemes também podem existir.

Por isso, aceitar qualquer esquema fornecido pelo usuário pode aumentar a superfície de ataque.

---

# 🧪 Exemplos

Em um laboratório, podem existir parâmetros como:

```text
http://testphp.vulnweb.com/?loadimage=8.8.8.8:22
```

ou:

```text
http://testphp.vulnweb.com/?loadimage=file:///etc/passwd
```

⚠️ O fato de um parâmetro aceitar uma string parecida com uma URL **não comprova SSRF**. É necessário verificar se o servidor realmente interpreta e realiza a requisição.

---

# 🔥 Impactos

Uma SSRF pode permitir, dependendo do cenário:

- acesso a serviços internos;
- acesso a interfaces administrativas;
- descoberta de hosts internos;
- interação com APIs internas;
- acesso a serviços restritos ao `localhost`;
- leitura de recursos acessíveis pelo servidor;
- exploração de outras vulnerabilidades internas;
- em determinadas arquiteturas, acesso a metadados de infraestrutura.

Um dos cenários mais conhecidos é o acesso indevido a **serviços de metadados de ambientes cloud**.

---

# 🛡️ Como prevenir

### 1. Usar Allow-list

Em vez de aceitar qualquer destino:

```text
url=http://qualquer-site.com
```

defina quais destinos são realmente permitidos.

```text
API_ESTOQUE → api.exemplo.com
```

---

### 2. Validar o destino

Não valide somente a string da URL.

Também é importante considerar:

```text
Hostname
IP resolvido
Porta
Scheme
Redirecionamentos
```

---

### 3. Restringir Schemes

Permitir somente o necessário:

```text
https://
```

em vez de aceitar indiscriminadamente:

```text
http://
ftp://
file://
...
```

---

### 4. Bloquear redes internas

Dependendo da arquitetura, restringir acesso a:

```text
127.0.0.0/8
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

e outras redes reservadas/especiais.

📌 Mas **não dependa somente de bloquear strings de IP**. DNS e redirecionamentos precisam ser considerados.

---

### 5. Não seguir redirects cegamente

Uma URL inicialmente permitida pode redirecionar para um destino interno.

```text
URL permitida
     ↓
302 Redirect
     ↓
IP interno
```

Portanto, redirecionamentos também precisam ser validados.

---

# 📊 Resumo

|Tipo|Característica|
|---|---|
|**SSRF básico**|Resposta do destino pode ser observada|
|**Blind SSRF**|Requisição ocorre sem resposta direta|
|**SSRF → localhost**|Acessa serviços do próprio servidor|
|**SSRF → rede interna**|Acessa outros sistemas internos|
|**SSRF + Open Redirect**|Pode ajudar a contornar validações frágeis|

---

## 📌 Regra de ouro

👉 **Nunca confie em uma URL fornecida diretamente pelo usuário para determinar para onde o servidor fará uma requisição.**

O fluxo seguro deve ser:

```text
Entrada do usuário
       ↓
Validação
       ↓
Allow-list
       ↓
Validação do destino resolvido
       ↓
Scheme permitido
       ↓
Requisição
```

Enquanto o cenário vulnerável é:

```text
Usuário
   ↓
URL arbitrária
   ↓
Servidor
   ↓
💥 SSRF
   ↓
Sistema interno
```