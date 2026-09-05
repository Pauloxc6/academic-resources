# 03 Criando Conexões em MPLS

Nesta etapa configuramos o **MPLS** e o **LDP (Label Distribution Protocol)** nos roteadores que fazem parte do core da operadora.

O objetivo é permitir que os roteadores **PE1, P1 e P2** estabeleçam relações LDP e troquem informações sobre labels.

---

# 🗺️ Topologia

```text
                         CE1
                          │
                          │
                     ┌────┴────┐
                     │   PE1   │
                     │172.0.1.1│
                     └──┬───┬──┘
                        │   │
                     MPLS   MPLS
                        │   │
                 ┌──────┘   └──────┐
                 ▼                 ▼
              ┌─────┐           ┌─────┐
              │ P1  │◄── MPLS ──►│ P2  │
              │.0.1 │           │.0.2 │
              └─────┘           └─────┘
```

Os equipamentos MPLS são:

```text
PE1 → 172.0.1.1
P1  → 172.0.0.1
P2  → 172.0.0.2
```

---

# 🏷️ MPLS

Antes do LDP, habilitamos a capacidade MPLS nas interfaces:

```routeros
/mpls interface add \
    interface=all \
    mpls-mtu=1534
```

### Parâmetros

| Parâmetro       | Função                                   |
| --------------- | ---------------------------------------- |
| `interface=all` | Aplica a configuração MPLS às interfaces |
| `mpls-mtu=1534` | Define a MTU utilizada para tráfego MPLS |

A MTU precisa comportar o cabeçalho adicional introduzido pelo MPLS.

> 💡 Em um ambiente real, não é recomendável simplesmente aplicar MPLS a todas as interfaces. É melhor restringir às interfaces que realmente fazem parte do core MPLS.

---

# 🏷️ O que é LDP?

O **LDP (Label Distribution Protocol)** é utilizado para distribuir informações de labels entre roteadores MPLS.

De forma simplificada:

```text
IP Route
   │
   ▼
OSPF
   │
   ▼
Tabela de roteamento
   │
   ▼
LDP
   │
   ▼
Distribuição de Labels
   │
   ▼
LSP
```

O OSPF continua fornecendo a **conectividade IP** da infraestrutura.

O LDP utiliza essa conectividade para estabelecer os caminhos de labels.

---

# 1. PE1

## Configurando o MPLS

```routeros
/mpls interface add \
    interface=all \
    mpls-mtu=1534
```

---

## Configurando o LDP

```routeros
/mpls ldp add \
    disabled=no \
    lsr-id=172.0.1.1 \
    transport-addresses=172.0.1.1
```

### `lsr-id`

```text
lsr-id=172.0.1.1
```

Identifica o PE1 como um **LSR (Label Switching Router)**.

Neste cenário, utilizamos a loopback:

```text
172.0.1.1/32
```

### `transport-addresses`

```text
transport-addresses=172.0.1.1
```

Define o endereço utilizado como endereço de transporte para as sessões LDP.

---

## Interfaces LDP

PE1 possui dois enlaces com o core:

```routeros
/mpls ldp interface add \
    disabled=no \
    interface=ether2

/mpls ldp interface add \
    disabled=no \
    interface=ether3
```

Ou seja:

```text
ether2 → PE1 ↔ P1
ether3 → PE1 ↔ P2
```

Não configuramos LDP em:

```text
ether1 → PE1 ↔ CE1
```

porque o CE1 está fora do core MPLS.

---

# 2. P1

## MPLS

```routeros
/mpls interface add \
    interface=all \
    mpls-mtu=1534
```

---

## LDP

```routeros
/mpls ldp add \
    disabled=no \
    lsr-id=172.0.0.1 \
    transport-addresses=172.0.0.1
```

> ⚠️ **Correção:** no material original estava:
>
> `lsr-id=172.0.1.1`
>
> Esse endereço pertence ao PE1. O LSR ID do P1 deve ser o seu próprio identificador, neste caso:
>
> `172.0.0.1`

---

## Interfaces LDP

```routeros
/mpls ldp interface add \
    disabled=no \
    interface=ether1

/mpls ldp interface add \
    disabled=no \
    interface=ether2
```

Temos:

```text
ether1 → P1 ↔ PE1
ether2 → P1 ↔ P2
```

Portanto:

```text
             PE1
              │
            LDP
              │
              P1
              │
            LDP
              │
              P2
```

---

# 3. P2

## MPLS

```routeros
/mpls interface add \
    interface=all \
    mpls-mtu=1534
```

---

## LDP

```routeros
/mpls ldp add \
    disabled=no \
    lsr-id=172.0.0.2 \
    transport-addresses=172.0.0.2
```

Neste caso, o LSR ID corresponde à loopback do P2:

```text
172.0.0.2/32
```

---

## Interfaces LDP

```routeros
/mpls ldp interface add \
    disabled=no \
    interface=ether1

/mpls ldp interface add \
    disabled=no \
    interface=ether2
```

Onde:

```text
ether1 → P2 ↔ PE1
ether2 → P2 ↔ P1
```

---

# 🔄 Formação das sessões LDP

Depois das configurações, esperamos aproximadamente:

```text
                 PE1
              172.0.1.1
               /      \
             LDP      LDP
             /          \
            P1──────────P2
         172.0.0.1    172.0.0.2
              \         /
                  LDP
```

As sessões são formadas entre roteadores diretamente conectados e que possuem LDP habilitado no enlace.

---

# 🧠 O papel do LSR ID

Cada roteador MPLS precisa possuir um identificador:

```text
PE1 → 172.0.1.1
P1  → 172.0.0.1
P2  → 172.0.0.2
```

Podemos visualizar:

```text
           LSR ID
              │
       ┌──────┼──────┐
       ▼      ▼      ▼
      PE1     P1     P2
      .1.1    .0.1   .0.2
```

É uma boa prática utilizar uma **loopback**, pois ela permanece disponível independentemente de uma interface física específica, desde que exista conectividade IP até ela.

---

# 📦 Como o MPLS entra no cenário

Antes do MPLS:

```text
IP Packet
   │
   ▼
PE1
   │
   ▼
P1
   │
   ▼
P2
   │
   ▼
IP forwarding
```

Com MPLS/LDP:

```text
IP Packet
   │
   ▼
PE1
   │
   │ PUSH LABEL
   ▼
 P1
   │
   │ SWAP LABEL
   ▼
 P2
   │
   │ POP LABEL
   ▼
Destino
```

O core passa a poder utilizar **labels** para encaminhar o tráfego.

---

# 🔍 Verificando o LDP

Depois de configurar, é importante verificar se as sessões foram estabelecidas.

Exemplos:

```routeros
/mpls ldp neighbor print
```

Para visualizar a configuração:

```routeros
/mpls ldp print
```

E as interfaces:

```routeros
/mpls ldp interface print
```

Também podemos verificar as interfaces MPLS:

```routeros
/mpls interface print
```

---

# 🧪 O que deve ser observado

O objetivo é chegar a uma situação semelhante a:

```text
PE1
 │
 ├── LDP ── P1
 │
 └── LDP ── P2

P1
 │
 └── LDP ── P2
```

E cada roteador deve possuir seu próprio LSR ID:

| Router | LSR ID      |
| ------ | ----------- |
| PE1    | `172.0.1.1` |
| P1     | `172.0.0.1` |
| P2     | `172.0.0.2` |

---

# 🧠 Para memorizar

```text
OSPF
 ↓
Fornece conectividade IP
 ↓
LDP
 ↓
Distribui labels
 ↓
MPLS
 ↓
Cria/usa LSPs
 ↓
Encaminhamento por labels
```

### Função de cada elemento

```text
OSPF → "Como chegar ao destino?"

LDP → "Qual label utilizar?"

MPLS → "Encaminhe usando a label."

LSP → "Caminho formado através da rede MPLS."
```

> ⚠️ **Importante:** habilitar MPLS e LDP não significa que uma VPN MPLS já esteja funcionando. Nesta etapa estamos preparando o **MPLS core**. Tecnologias como **VRF, MP-BGP e MPLS L3VPN** serão configuradas posteriormente.
