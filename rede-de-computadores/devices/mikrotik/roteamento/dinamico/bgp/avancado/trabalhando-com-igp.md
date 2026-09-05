# 🌐 Trabalhando com IGP

## 📚 O que é IGP?

**IGP (Interior Gateway Protocol)** é uma categoria de protocolos de roteamento utilizada para trocar informações de rotas **dentro de um mesmo Sistema Autônomo (AS)**.

Alguns exemplos de IGP:

* **RIP**
* **OSPF**
* **EIGRP**
* **IS-IS**

Neste laboratório utilizaremos o **OSPFv2** como IGP.

```text
                 AS
        ┌──────────────────────┐
        │                      │
        │   R1 ──────── R2     │
        │        OSPF          │
        │                      │
        └──────────────────────┘
                  IGP
```

---

# 🖥️ R1

## Interfaces e endereçamento

Primeiro criamos uma interface `loopback`:

```bash
/interface bridge add name=lo0
```

Depois configuramos os endereços:

```bash
/ip address add address=100.100.100.1/32 interface=lo0

/ip address add address=192.168.122.2/24 \
    interface=ether1 \
    comment="WAN 1"

/ip address add address=100.0.0.1/24 \
    interface=ether2

/ip address add address=10.1.0.1/24 \
    interface=ether4 \
    comment="LAN"
```

A topologia do R1 fica:

```text
                 R1
        ┌───────────────────┐
        │                   │
lo0 ────┤ 100.100.100.1/32  │
        │                   │
ether1 ─┤ 192.168.122.2/24  │
        │                   │
ether2 ─┤ 100.0.0.1/24      │
        │                   │
ether4 ─┤ 10.1.0.1/24       │
        └───────────────────┘
```

---

# ⚙️ Configurando o OSPF no R1

Criamos a instância OSPF:

```bash
/routing ospf instance add \
    name=instance0 \
    router-id=100.100.100.1 \
    version=2 \
    vrf=main \
    routing-table=main \
    disabled=no
```

> **Correção:** no material original, o R1 utilizava `router-id=192.168.122.5`, que é o endereço configurado no R2. Cada roteador deve possuir um **Router ID único**. Como temos uma loopback no R1, utilizamos `100.100.100.1`.

---

## Área Backbone

```bash
/routing ospf area add \
    name=backbone \
    area-id=0.0.0.0 \
    instance=instance0
```

A área:

```text
0.0.0.0
```

é a **Area 0**, também chamada de **Backbone Area**.

---

## Interface-template

```bash
/routing ospf interface-template add \
    area=backbone \
    disabled=no
```

Essa configuração permite que o RouterOS associe interfaces ao OSPF conforme os critérios definidos pelo template.

Para um ambiente de laboratório é possível utilizar um template amplo, mas em uma rede real é melhor especificar quais interfaces realmente participarão do OSPF.

---

# 🖥️ R2

## Interfaces e endereçamento

Criamos a loopback:

```bash
/interface bridge add name=lo0
```

Configuramos os endereços:

```bash
/ip address add address=110.110.110.1/32 interface=lo0

/ip address add address=192.168.122.5/24 \
    interface=ether1 \
    comment="WAN 1"

/ip address add address=10.2.0.1/24 \
    interface=ether2 \
    comment="LAN"
```

Topologia do R2:

```text
                 R2
        ┌───────────────────┐
        │                   │
lo0 ────┤ 110.110.110.1/32  │
        │                   │
ether1 ─┤ 192.168.122.5/24  │
        │                   │
ether2 ─┤ 10.2.0.1/24       │
        └───────────────────┘
```

---

# ⚙️ Configurando o OSPF no R2

```bash
/routing ospf instance add \
    name=instance0 \
    router-id=110.110.110.1 \
    version=2 \
    vrf=main \
    routing-table=main \
    disabled=no
```

Novamente, utilizamos a loopback como Router ID.

Criamos a Area 0:

```bash
/routing ospf area add \
    name=backbone \
    area-id=0.0.0.0 \
    instance=instance0
```

E adicionamos o template:

```bash
/routing ospf interface-template add \
    area=backbone \
    disabled=no
```

---

# 🔗 Rede entre R1 e R2

Os dois roteadores possuem endereços na mesma rede:

```text
192.168.122.0/24
```

```text
R1                                      R2
│                                       │
│ 192.168.122.2/24                      │ 192.168.122.5/24
└───────────────────────────────────────┘
              mesma rede
```

Essa rede pode ser utilizada para estabelecer a **vizinhança OSPF**.

Porém, existe um detalhe importante:

> O fato de os dois IPs estarem na mesma rede **não significa automaticamente que a vizinhança será formada**. As interfaces precisam estar efetivamente associadas ao OSPF pelo `interface-template`, e os parâmetros OSPF precisam ser compatíveis.

---

# 🔄 Funcionamento do OSPF

Depois que R1 e R2 formam uma adjacência:

```text
R1
│
│ Hello
▼
R2
```

Os roteadores passam a trocar informações sobre suas redes.

Por exemplo:

```text
R1 anuncia:

100.100.100.1/32
100.0.0.0/24
10.1.0.0/24
```

R2 anuncia:

```text
110.110.110.1/32
10.2.0.0/24
```

Assim, R1 pode aprender as redes do R2:

```text
R1
 │
 ├── 110.110.110.1/32
 └── 10.2.0.0/24
```

E R2 pode aprender as redes do R1:

```text
R2
 │
 ├── 100.100.100.1/32
 ├── 100.0.0.0/24
 └── 10.1.0.0/24
```

---

# 🔎 Verificando a vizinhança

Para verificar os vizinhos OSPF:

```bash
/routing ospf neighbor print
```

Uma vizinhança estabelecida deve aparecer com um estado como:

```text
Full
```

Também podemos verificar as interfaces OSPF:

```bash
/routing ospf interface print
```

E as rotas aprendidas:

```bash
/routing ospf route print
```

Ou visualizar a tabela geral:

```bash
/ip route print
```

---

# 🧠 Fluxo do OSPF

```text
Interfaces
    ↓
interface-template
    ↓
OSPF Instance
    ↓
Area 0
    ↓
Hello Packets
    ↓
Neighbor
    ↓
Adjacency
    ↓
LSDB
    ↓
SPF
    ↓
Rotas OSPF
```

---

# 📌 Resumo

| Conceito      | Função                                             |
| ------------- | -------------------------------------------------- |
| **IGP**       | Roteamento dentro de um AS                         |
| **OSPF**      | IGP baseado em estado de enlace                    |
| **OSPFv2**    | OSPF para IPv4                                     |
| **Router ID** | Identifica o roteador no OSPF                      |
| **Area 0**    | Área Backbone                                      |
| **Loopback**  | Interface lógica estável, útil para Router ID      |
| **Hello**     | Descoberta/manutenção de vizinhos                  |
| **LSDB**      | Banco de dados da topologia OSPF                   |
| **SPF**       | Algoritmo usado para calcular os melhores caminhos |

## 🧠 Para memorizar

```text
IGP
└── usado dentro do AS

OSPF
└── um dos principais IGPs

Area 0
└── Backbone do OSPF

Router ID
└── identificação do roteador

Neighbor
└── roteador OSPF vizinho

LSDB
└── visão da topologia

SPF
└── calcula os melhores caminhos
```
