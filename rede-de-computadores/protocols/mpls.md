# 🌐 MPLS — Multiprotocol Label Switching

O **MPLS (Multiprotocol Label Switching)** é uma tecnologia utilizada para encaminhamento de pacotes baseada em **rótulos (labels)**.

O MPLS combina características do encaminhamento baseado em **camada 2** com recursos de **camada 3**, permitindo que os pacotes sejam encaminhados através de uma rede utilizando labels em vez de realizar uma decisão de roteamento IP completa em cada salto.

O cabeçalho MPLS possui **32 bits** e é inserido entre o cabeçalho de camada 2 e o cabeçalho de camada 3.

```text
┌──────────────┬────────────────┬──────────────┐
│     L2       │      MPLS      │      L3      │
│   Ethernet   │    32 bits     │      IP      │
└──────────────┴────────────────┴──────────────┘
```

---

# 🏷️ Label MPLS

O cabeçalho MPLS possui quatro campos:

| Campo     | Tamanho | Função                                         |
| --------- | ------: | ---------------------------------------------- |
| **Label** | 20 bits | Identifica o encaminhamento do pacote          |
| **TC**    |  3 bits | Traffic Class; usado para QoS e outras funções |
| **S**     |   1 bit | Indica o fim da pilha de labels                |
| **TTL**   |  8 bits | Time To Live                                   |

Total:

```text
20 + 3 + 1 + 8 = 32 bits
```

### Estrutura

```text
┌────────────────────┬───────┬───┬────────┐
│       Label        │  TC   │ S │  TTL   │
│      20 bits       │ 3 bit │ 1 │ 8 bits │
└────────────────────┴───────┴───┴────────┘
```

> **Importante:** o **label possui 20 bits**, enquanto o **shim header MPLS completo possui 32 bits**.

---

# 📚 Label Stack

Uma das características importantes do MPLS é a possibilidade de utilizar uma **pilha de labels (Label Stack)**.

```text
┌──────────────┐
│    Label 1   │
├──────────────┤
│    Label 2   │
├──────────────┤
│    Label 3   │
├──────────────┤
│     IP       │
└──────────────┘
```

Isso permite implementar diferentes serviços utilizando múltiplos labels.

Exemplos:

* **MPLS Traffic Engineering (MPLS-TE)**
* **L2VPN**
* **L3VPN**
* **Fast Reroute**
* outros mecanismos baseados em labels

---

# 🔄 Label Switching

O encaminhamento MPLS utiliza o conceito de **Label Swapping**.

Em vez de analisar completamente o destino IP em cada roteador, um equipamento MPLS pode utilizar o label recebido para determinar:

1. qual operação realizar;
2. qual será o próximo label;
3. para qual interface o pacote deverá ser encaminhado.

Exemplo:

```text
Entrada                    Saída

Label 100  ─────────────►  Label 200
```

O roteador recebe:

```text
Label = 100
```

e consulta sua tabela MPLS:

```text
100 → 200
```

Então substitui o label:

```text
100 → 200
```

Essa operação é chamada de **SWAP**.

---

# 🗃️ FIB, LFIB e CEF

Em equipamentos Cisco, podemos encontrar diferentes estruturas utilizadas no encaminhamento.

## FIB — Forwarding Information Base

A **FIB** contém informações utilizadas para encaminhar pacotes IP.

```text
Destino IP → Próximo salto / Interface
```

---

## LFIB — Label Forwarding Information Base

A **LFIB** contém informações utilizadas para encaminhar pacotes MPLS com base nos labels.

```text
Label recebido → Operação → Label de saída → Interface
```

Exemplo:

```text
100 → SWAP → 200 → Gi0/1
```

---

## CEF — Cisco Express Forwarding

O **CEF (Cisco Express Forwarding)** é o mecanismo de encaminhamento utilizado em equipamentos Cisco.

De forma simplificada:

```text
Pacote IP
   │
   ▼
  CEF
   │
   ▼
 FIB
   │
   ▼
Próximo salto
```

Para pacotes MPLS, a **LFIB** participa do processo de encaminhamento baseado em labels.

---

# 🔗 LSP — Label Switched Path

O **LSP (Label Switched Path)** é o caminho formado por uma sequência de equipamentos MPLS através dos quais o pacote é encaminhado utilizando labels.

Exemplo:

```text
Ingress
   │
   ▼
  LSR1
   │
   ▼
  LSR2
   │
   ▼
  LSR3
   │
   ▼
Egress
```

Esse caminho pode ser representado como:

```text
Ingress → LSR1 → LSR2 → LSR3 → Egress
```

---

# 🖥️ LSR — Label Switching Router

Um **LSR (Label Switching Router)** é um equipamento capaz de processar labels MPLS.

Podemos dividir os LSRs de acordo com sua posição no caminho.

---

## 🚪 Ingress LSR

É o LSR que **recebe o pacote no domínio MPLS**.

O pacote normalmente chega sem um label MPLS.

O Ingress LSR:

```text
IP
 ↓
Adiciona Label
 ↓
MPLS
```

Exemplo:

```text
Pacote IP
    │
    ▼
Ingress LSR
    │
    ▼
[Label 100][IP]
```

Esse processo pode ser chamado de:

```text
IP → Label
```

---

# 🔄 Intermediate LSR

É um LSR intermediário que recebe um pacote MPLS e realiza uma operação sobre seu label.

A operação mais comum é o **SWAP**.

```text
[Label 100][IP]
       │
       ▼
   Intermediate
       │
       ▼
[Label 200][IP]
```

---

# 🚪 Egress LSR

É o equipamento que realiza a saída do pacote do domínio MPLS.

O label MPLS é removido e o pacote pode continuar seu encaminhamento como um pacote IP.

```text
[Label 200][IP]
       │
       ▼
   Egress LSR
       │
       ▼
      [IP]
```

Esse processo pode ser chamado de:

```text
Label → IP
```

---

# ⚙️ Operações MPLS

Existem três operações principais sobre os labels.

## ➕ PUSH

Adiciona um novo label ao pacote.

```text
Antes:

[IP]

        ↓ PUSH

Depois:

[Label][IP]
```

É comum na **entrada do domínio MPLS**.

---

## 🔄 SWAP

Substitui o label existente por outro.

```text
Antes:

[Label 100][IP]

        ↓ SWAP

Depois:

[Label 200][IP]
```

É a operação característica dos LSRs intermediários.

---

## ➖ POP

Remove o label MPLS.

```text
Antes:

[Label 200][IP]

        ↓ POP

Depois:

[IP]
```

É utilizado na saída do domínio MPLS.

---

# 🚀 PHP — Penultimate Hop Popping

O **PHP (Penultimate Hop Popping)** permite que o label seja removido pelo **penúltimo LSR**, ou seja, pelo equipamento imediatamente anterior ao Egress LSR.

Sem PHP:

```text
LSR1 → LSR2 → Egress

[Label][IP]
          │
          ▼
       Egress
       remove
        label
```

Com PHP:

```text
LSR1 → LSR2 → Egress

       POP
        │
        ▼
      [IP]
        │
        ▼
      Egress
```

O objetivo é evitar que o Egress precise realizar a operação de remoção do label, simplificando o processamento nesse último salto.

---

# 📡 Distribuição de Labels

Para que os roteadores saibam quais labels utilizar, é necessário que essas informações sejam distribuídas entre os equipamentos MPLS.

Alguns protocolos/mecanismos relacionados são:

| Protocolo   | Função                                                                      |
| ----------- | --------------------------------------------------------------------------- |
| **LDP**     | Distribuição de labels                                                      |
| **RSVP-TE** | Distribuição de labels e estabelecimento de LSPs para Traffic Engineering   |
| **TDP**     | Protocolo antigo de distribuição de labels, originalmente associado à Cisco |
| **BGP**     | Pode transportar informações de labels em determinados cenários             |

O **LDP (Label Distribution Protocol)** é um dos protocolos tradicionalmente utilizados para distribuição de labels em MPLS.

---

# 🔗 LDP

No LDP, cada LSR associa localmente determinados **FECs (Forwarding Equivalence Classes)** a labels.

Uma FEC representa um conjunto de pacotes que será tratado da mesma maneira durante o encaminhamento.

De forma simplificada:

```text
FEC
 │
 ▼
Label local
```

O LSR distribui essas informações para seus vizinhos LDP.

Essas informações podem então ser utilizadas para construir as entradas necessárias ao encaminhamento MPLS.

---

# 🧩 Label → IP e Label → Label

Um pacote pode passar por diferentes formas de encaminhamento dentro de uma rede MPLS.

### IP → Label

O pacote entra no domínio MPLS:

```text
[IP]
 ↓
[Label][IP]
```

---

### Label → Label

O pacote permanece dentro do domínio MPLS e seu label é trocado:

```text
[Label 100][IP]
       ↓
[Label 200][IP]
```

---

### Label → IP

O pacote deixa o domínio MPLS:

```text
[Label 200][IP]
       ↓
[IP]
```

---

# 🗺️ Exemplo completo

```text
             Rede MPLS

Cliente
   │
   ▼
┌─────────┐
│ Ingress │
│   LSR   │
└────┬────┘
     │
     │ PUSH
     │ Label 100
     ▼
┌─────────┐
│   LSR   │
│   1     │
└────┬────┘
     │
     │ SWAP
     │ 100 → 200
     ▼
┌─────────┐
│   LSR   │
│   2     │
└────┬────┘
     │
     │ PHP / POP
     ▼
┌─────────┐
│  Egress │
│   LSR   │
└────┬────┘
     │
     ▼
   Destino
```

---

# 🔐 MPLS e VPN

Uma das aplicações importantes do MPLS é a implementação de **VPNs de operadoras**.

Podemos encontrar principalmente:

```text
MPLS
 ├── L2VPN
 └── L3VPN
```

Em redes MPLS VPN, podem existir múltiplos labels na pilha:

```text
┌──────────────┐
│ Label VPN    │ ← Identificação do serviço
├──────────────┤
│ Label LSP    │ ← Encaminhamento pela rede
├──────────────┤
│ IP / Payload │
└──────────────┘
```

Essa utilização de uma **pilha de labels** é uma das características que torna o MPLS bastante flexível.

---

# 🧠 Resumo

```text
MPLS
│
├── Multiprotocol Label Switching
│
├── Label
│   └── 20 bits
│
├── Shim Header
│   └── 32 bits
│
├── LSP
│   └── Caminho através da rede MPLS
│
├── LSR
│   ├── Ingress
│   ├── Intermediate
│   └── Egress
│
├── Operações
│   ├── PUSH
│   ├── SWAP
│   └── POP
│
├── PHP
│   └── Penultimate Hop Popping
│
└── Protocolos
    ├── LDP
    ├── RSVP-TE
    ├── TDP
    └── BGP (em cenários específicos)
```

### 🎯 Para memorizar

```text
INGRESS     → adiciona label
INTERMEDIATE → troca label
EGRESS      → remove label

PUSH → adiciona
SWAP → troca
POP  → remove
```

> **MPLS = encaminhamento baseado em labels.**

> **LSP = caminho percorrido pelo pacote dentro da rede MPLS.**

> **LSR = equipamento que processa os labels MPLS.**
