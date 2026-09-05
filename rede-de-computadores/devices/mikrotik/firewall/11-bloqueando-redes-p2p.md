# 11 — Bloqueando redes P2P

**P2P (Peer-to-Peer)** é um modelo no qual os dispositivos podem se comunicar diretamente entre si, sem depender necessariamente de um servidor central para toda a comunicação.

Um exemplo conhecido é o **BitTorrent**, utilizado para distribuição de arquivos através de uma rede de peers.

Neste exemplo vamos utilizar recursos do Firewall do MikroTik para tentar identificar e bloquear tráfego relacionado a torrents.

> ⚠️ **Importante:** as técnicas apresentadas aqui são principalmente didáticas e legadas. O uso de `layer7-protocol` e `content` para identificar BitTorrent não é uma forma robusta de bloquear P2P moderno. Tráfego criptografado, HTTPS, QUIC e mecanismos de evasão podem impedir que o conteúdo esperado seja identificado.

---

# 🧩 Layer 7

O RouterOS possui o recurso:

```routeros
/ip/firewall/layer7-protocol
```

Ele permite criar expressões regulares para tentar identificar padrões no conteúdo dos pacotes.

Exemplo:

```routeros
/ip/firewall/layer7-protocol
add name=torrentsites regexp="..."
```

Depois podemos utilizar esse protocolo em uma regra de Firewall Filter:

```routeros
/ip/firewall/filter
add chain=forward \
    action=drop \
    layer7-protocol=torrentsites \
    src-address-list=list-permitidos-1 \
    comment="Bloqueia tráfego identificado como torrent"
```

A lógica é:

```text
Cliente
   │
   ▼
Firewall
   │
   ├── corresponde ao padrão?
   │        │
   │       SIM
   │        ▼
   │       DROP
   │
   └── NÃO → continua processamento
```

---

# 🌐 Regex para sites relacionados a torrents

O material utiliza uma expressão regular contendo palavras associadas a sites de torrent:

```routeros
/ip/firewall/layer7-protocol
add name=torrentsites regexp="..."
```

A intenção é procurar determinados padrões dentro do tráfego HTTP.

A expressão contém termos como:

```text
torrent
thepiratebay
isohunt
demonoid
btjunkie
btscene
bitunity
bittoxic
bitnova
bitsoup
meganova
fenopy
```

A ideia é:

```text
HTTP
  │
  ▼
Layer 7
  │
  ├── encontra padrão relacionado a torrent
  │
  ▼
corresponde ao protocolo "torrentsites"
```

---

# 🚫 Bloqueando o tráfego identificado

A primeira regra:

```routeros
/ip/firewall/filter
add action=drop \
    chain=forward \
    comment="Bloqueia download de torrents da rede LAN" \
    layer7-protocol=torrentsites \
    src-address-list=list-permitidos-1
```

pode ser interpretada como:

> Se um pacote encaminhado tiver correspondência com o padrão Layer 7 `torrentsites` e sua origem estiver na `list-permitidos-1`, descarte o tráfego.

O:

```text
chain=forward
```

é utilizado porque estamos controlando tráfego que atravessa o roteador.

---

# 📡 Bloqueando DNS

O material também possui:

```routeros
/ip/firewall/filter
add action=drop \
    chain=forward \
    comment="dropDNS" \
    dst-port=53 \
    layer7-protocol=torrentsites \
    protocol=udp \
    src-address-list=list-permitidos-1
```

Essa regra procura:

```text
UDP
porta 53
```

associado ao padrão Layer 7.

A porta:

```text
UDP/53
```

é tradicionalmente utilizada pelo DNS.

### ⚠️ Limitação

Bloquear UDP/53 dessa maneira **não é uma forma confiável de bloquear DNS ou torrents**.

Clientes modernos podem utilizar:

```text
DNS over HTTPS (DoH)
DNS over TLS (DoT)
```

ou outros mecanismos para resolver nomes sem utilizar DNS tradicional diretamente.

---

# 🔎 `content=`

O material utiliza várias regras com:

```routeros
content=
```

Esse parâmetro procura uma sequência de texto no conteúdo que o firewall consegue inspecionar.

Por exemplo:

```routeros
/ip/firewall/filter
add chain=forward \
    action=drop \
    content=torrent \
    src-address-list=list-permitidos-1 \
    comment="Bloqueia conteúdo relacionado a torrent"
```

A ideia é procurar:

```text
torrent
```

no conteúdo do pacote.

---

# 📌 Palavras utilizadas no exemplo

### `torrent`

```routeros
content=torrent
```

Procura a palavra:

```text
torrent
```

---

### `tracker`

```routeros
content=tracker
```

O termo `tracker` aparece em contextos relacionados ao funcionamento do BitTorrent.

---

### `getpeers`

```routeros
content=getpeers
```

Procura o termo:

```text
getpeers
```

---

### `info_hash`

```routeros
content=info_hash
```

O `info_hash` está relacionado à identificação de torrents em determinados protocolos/implementações.

---

### `announce_peers`

```routeros
content=announce_peers
```

Procura esse padrão no conteúdo observado.

---

# 🧱 Regras completas do exemplo

Organizando as regras:

```routeros
/ip/firewall/filter

add action=drop \
    chain=forward \
    comment="Bloqueia download de torrents da rede LAN" \
    layer7-protocol=torrentsites \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia DNS associado ao padrão" \
    dst-port=53 \
    layer7-protocol=torrentsites \
    protocol=udp \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia keyword torrent" \
    content=torrent \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia tracker" \
    content=tracker \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia getpeers" \
    content=getpeers \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia info_hash" \
    content=info_hash \
    src-address-list=list-permitidos-1

add action=drop \
    chain=forward \
    comment="Bloqueia announce_peers" \
    content=announce_peers \
    src-address-list=list-permitidos-1
```

---

# ⚠️ Limitações do método

Essa é a parte mais importante para entender.

## 1. Tráfego criptografado

Se o conteúdo estiver criptografado, o firewall pode não conseguir enxergar palavras como:

```text
torrent
tracker
info_hash
```

Portanto:

```text
conteúdo visível
      │
      ▼
   content=
      │
      ▼
pode identificar


conteúdo criptografado
      │
      ▼
   content=
      │
      ▼
pode não identificar
```

---

## 2. HTTPS

O HTTPS protege o conteúdo da comunicação.

Assim, uma regra:

```routeros
content=torrent
```

não deve ser interpretada como:

> "Bloqueia qualquer site de torrent."

Ela significa algo mais próximo de:

> "Descarta pacotes cujo conteúdo inspecionável contenha a sequência `torrent`."

São coisas bem diferentes.

---

## 3. BitTorrent não depende de um único padrão

O BitTorrent possui diferentes mecanismos de comunicação e pode utilizar diferentes portas e formas de descoberta de peers.

Portanto:

```text
"bloquear uma porta"
```

não é suficiente para bloquear todo BitTorrent.

---

# 🧠 Layer 7 x Content

São mecanismos parecidos na finalidade, mas diferentes na forma de configuração.

### Layer 7

Utiliza uma **expressão regular**:

```routeros
layer7-protocol=torrentsites
```

A expressão é definida previamente:

```routeros
/ip/firewall/layer7-protocol
add name=torrentsites regexp="..."
```

---

### Content

Procura diretamente uma sequência:

```routeros
content=torrent
```

Comparação:

| Método            | Como identifica                    |
| ----------------- | ---------------------------------- |
| `layer7-protocol` | Expressão regular                  |
| `content`         | Texto/padrão procurado no conteúdo |

---

# ⚡ Impacto no desempenho

Inspecionar conteúdo e utilizar expressões regulares pode ser mais custoso para o roteador do que regras simples baseadas em:

```text
IP
porta
protocolo
interface
connection-state
```

Em redes maiores, isso pode gerar impacto de CPU.

Por isso, deve-se evitar utilizar Layer 7 indiscriminadamente.

---

# 🔐 Abordagens modernas

Para controlar P2P em redes atuais, normalmente é melhor combinar mecanismos diferentes, dependendo da versão do RouterOS e da arquitetura da rede:

```text
Controle de tráfego
       │
       ├── Firewall Filter
       ├── Address Lists
       ├── DNS Policy
       ├── QoS
       ├── identificação de aplicações
       └── políticas nos endpoints
```

A estratégia depende do objetivo.

Se a intenção for **controle corporativo**, por exemplo, pode ser mais eficiente aplicar políticas no endpoint ou utilizar soluções específicas de controle de aplicações, em vez de tentar inspecionar todo o conteúdo no roteador.

---

# 🔍 Verificando as regras

Visualizar protocolos Layer 7:

```routeros
/ip/firewall/layer7-protocol/print
```

Visualizar regras:

```routeros
/ip/firewall/filter/print
```

Visualizar estatísticas:

```routeros
/ip/firewall/filter/print stats
```

Os contadores de pacotes e bytes podem ajudar a verificar se uma regra está realmente correspondendo ao tráfego.

---

# 🧠 Resumo

### Layer 7

```text
Expressão regular
       ↓
Layer 7 Protocol
       ↓
Firewall Filter
       ↓
ACCEPT / DROP
```

### Content

```text
content=torrent
       ↓
procura texto no conteúdo inspecionável
       ↓
corresponde?
       ↓
DROP
```

### Principais limitações

```text
HTTPS
  ↓
conteúdo protegido

Criptografia
  ↓
inspeção limitada

Protocolos modernos
  ↓
padrões podem mudar

Layer 7
  ↓
pode consumir CPU
```

---

# 🧩 Para memorizar

```text
P2P
 ↓
Peer-to-Peer

Layer 7
 ↓
Procura padrões no conteúdo

content=
 ↓
Procura uma sequência específica

chain=forward
 ↓
Tráfego atravessando o roteador

action=drop
 ↓
Descarta o pacote
```

> **Importante:** bloquear `torrent` por `content=` ou por uma expressão Layer 7 não equivale a bloquear todo BitTorrent. É uma técnica de inspeção de conteúdo, útil para laboratório e para entender o funcionamento do RouterOS, mas insuficiente como mecanismo moderno e completo de controle de P2P.
