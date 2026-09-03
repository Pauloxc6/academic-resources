# 🌐 RIP e OSPF

Os **protocolos de roteamento dinâmico** permitem que os roteadores troquem informações sobre as redes disponíveis e atualizem automaticamente suas tabelas de roteamento.

Eles são utilizados para determinar os melhores caminhos para encaminhar pacotes entre diferentes redes.

---

# 🧭 Classificação dos protocolos

| Protocolo | Tipo                     | Algoritmo/Métrica   | Uso principal                   |
| --------- | ------------------------ | ------------------- | ------------------------------- |
| **RIP**   | Distance Vector          | Número de hops      | Redes pequenas                  |
| **OSPF**  | Link-State               | Custo               | Redes corporativas/empresariais |
| **IS-IS** | Link-State               | Custo               | Grandes redes de provedores     |
| **EIGRP** | Advanced Distance Vector | Métrica composta    | Principalmente ambientes Cisco  |
| **BGP**   | Path Vector              | Atributos/Políticas | Internet e sistemas autônomos   |

---

# 1. 🔵 RIP

**RIP (Routing Information Protocol)** é um protocolo de roteamento do tipo **Distance Vector**.

Ele utiliza o **número de saltos (hops)** como métrica para determinar o caminho.

```text
Roteador A
    │
    ▼
Roteador B
    │
    ▼
Roteador C
    │
    ▼
Destino

Métrica = 2 hops
```

## 📏 Limite de Hops

O RIP possui um limite máximo de **15 hops**.

```text
1 → 2 → 3 → ... → 15
```

Uma rota com **16 hops é considerada inalcançável**.

Esse limite ajuda a evitar que rotas inválidas permaneçam circulando indefinidamente na rede.

---

## 🔄 Funcionamento

Os roteadores RIP trocam periodicamente informações sobre suas tabelas de roteamento.

```text
R1 ───── R2 ───── R3
 │        │        │
 └──── informações ────┘
       de rotas
```

Cada roteador informa aos vizinhos quais redes conhece e a distância até elas.

---

## 🛡️ Prevenção de loops

O RIP utiliza mecanismos para reduzir problemas de loops de roteamento, como:

* **Split Horizon**
* **Route Poisoning**
* **Hold-down**
* **Triggered Updates**

---

## 📡 Transporte

O RIP utiliza **UDP**.

```text
RIP
 ↓
UDP
 ↓
IP
```

A porta tradicionalmente utilizada pelo RIP é:

```text
UDP/520
```

> O **RIPng**, utilizado para IPv6, utiliza **UDP/521**.

---

## 📋 Versões

### RIPv1

* classful;
* não transporta a máscara de sub-rede nas atualizações;
* utiliza broadcast.

### RIPv2

* classless;
* transporta a máscara de sub-rede;
* suporta VLSM e CIDR;
* utiliza multicast `224.0.0.9`.

### RIPng

* versão do RIP para IPv6;
* utiliza UDP/521;
* utiliza multicast IPv6.

---

# 2. 🟢 OSPF

**OSPF (Open Shortest Path First)** é um protocolo de roteamento do tipo **Link-State**.

Ele constrói uma representação da topologia da rede e utiliza o algoritmo **SPF (Shortest Path First)**, baseado no algoritmo de **Dijkstra**, para calcular os melhores caminhos.

```text
        R2
       /  \
      /    \
    R1      R4
      \    /
       \  /
        R3
```

Cada roteador possui informações sobre os links da área e pode calcular sua própria árvore de caminhos mais curtos.

---

# ⚙️ Funcionamento do OSPF

De forma simplificada:

```text
Descoberta de vizinhos
        ↓
Troca de informações de estado
        ↓
Construção da LSDB
        ↓
Algoritmo SPF
        ↓
Tabela de roteamento
```

### LSDB

A **LSDB (Link-State Database)** contém informações sobre o estado dos links conhecidos pelo OSPF dentro de uma área.

Os roteadores de uma mesma área possuem uma visão consistente da topologia.

---

# 📏 Métrica

O OSPF utiliza o conceito de **custo (Cost)** para determinar o melhor caminho.

De forma simplificada:

```text
Caminho A
R1 → R2 → R4
Custo = 20

Caminho B
R1 → R3 → R4
Custo = 40
```

O OSPF escolherá o caminho de menor custo.

---

# 📡 Transporte

Diferentemente do RIP, o OSPF **não utiliza TCP ou UDP**.

Ele é transportado diretamente sobre IP.

```text
OSPF
 ↓
IP
```

O protocolo OSPF utiliza o número de protocolo IP:

```text
IP Protocol 89
```

O OSPF utiliza multicast para determinadas comunicações:

```text
224.0.0.5 → All OSPF Routers
224.0.0.6 → All OSPF Designated Routers
```

---

# 🏢 Áreas OSPF

Uma das principais características do OSPF é a possibilidade de dividir a rede em **áreas**.

A área principal é:

```text
Area 0
```

Também chamada de **Backbone Area**.

Exemplo:

```text
          Area 1
        ┌─────────┐
        │         │
        ▼         ▼
       R1         R2
        │         │
        └────┬────┘
             │
          Area 0
             │
        ┌────┴────┐
        ▼         ▼
       R3         R4
        │         │
        └─────────┘
          Area 2
```

A utilização de áreas ajuda a melhorar a **escalabilidade** do OSPF.

---

# 3. 🟠 EIGRP

**EIGRP (Enhanced Interior Gateway Routing Protocol)** é um protocolo desenvolvido pela Cisco.

É geralmente classificado como um protocolo de **Advanced Distance Vector**.

Ele utiliza o algoritmo **DUAL (Diffusing Update Algorithm)**.

### Características

* convergência rápida;
* suporte a VLSM e CIDR;
* utiliza atualizações incrementais;
* mantém informações sobre caminhos sucessores e sucessores viáveis;
* utiliza uma métrica composta.

A métrica pode considerar:

* largura de banda;
* atraso;
* confiabilidade;
* carga.

Na configuração padrão moderna, principalmente **bandwidth + delay** são utilizados no cálculo.

---

# 4. 🟣 IS-IS

**IS-IS (Intermediate System to Intermediate System)** é um protocolo de roteamento **Link-State**.

Assim como o OSPF, ele constrói uma visão da topologia e utiliza o conceito de **Shortest Path First**.

É bastante utilizado em **grandes redes de provedores de Internet**.

### Características

* Link-State;
* alta escalabilidade;
* utilizado em redes de operadoras;
* suporta IPv4 e IPv6;
* utiliza uma estrutura hierárquica de níveis.

Os principais níveis são:

```text
Level 1
↓
Roteamento dentro de uma área

Level 2
↓
Roteamento entre áreas
```

Pode existir também um roteador:

```text
Level 1-2
```

que participa dos dois níveis.

---

# 5. 🔴 BGP

**BGP (Border Gateway Protocol)** é o principal protocolo utilizado para **roteamento entre Sistemas Autônomos (AS)** na Internet.

Ele é classificado como **Path Vector**.

Diferentemente de RIP e OSPF, o BGP não tem como objetivo simplesmente encontrar o caminho com menor quantidade de saltos.

Ele utiliza **atributos e políticas de roteamento** para determinar o melhor caminho.

---

## 🌎 Sistema Autônomo

Um **AS (Autonomous System)** é um conjunto de redes administradas por uma mesma organização e que possui uma política de roteamento comum.

Exemplo:

```text
             Internet
                │
       ┌────────┴────────┐
       │                 │
      AS 100            AS 200
       │                 │
    Provedor A        Provedor B
       │                 │
      Redes             Redes
```

O BGP é utilizado para trocar informações de roteamento entre esses sistemas.

---

# 🔗 eBGP e iBGP

Existem duas formas principais de utilização do BGP:

### eBGP — External BGP

Utilizado entre **Sistemas Autônomos diferentes**.

```text
AS 100 ───── eBGP ───── AS 200
```

### iBGP — Internal BGP

Utilizado entre roteadores BGP dentro do **mesmo AS**.

```text
AS 100

R1 ───── iBGP ───── R2
```

---

# 📊 Comparação

| Característica | RIP             | OSPF               | EIGRP           | IS-IS      | BGP                 |
| -------------- | --------------- | ------------------ | --------------- | ---------- | ------------------- |
| Tipo           | Distance Vector | Link-State         | Advanced DV     | Link-State | Path Vector         |
| Métrica        | Hops            | Cost               | Composta        | Cost       | Atributos/Políticas |
| Algoritmo      | Bellman-Ford*   | Dijkstra/SPF       | DUAL            | SPF        | Path Vector         |
| Escalabilidade | Baixa           | Alta               | Alta            | Alta       | Muito alta          |
| Uso            | Redes pequenas  | Redes corporativas | Ambientes Cisco | Provedores | Internet/AS         |
| TCP/UDP        | UDP 520         | Não                | IP Protocol 88  | Não        | TCP 179             |

* O RIP é tradicionalmente associado ao algoritmo de **Bellman-Ford / vetor de distância**, embora sua implementação prática possua mecanismos adicionais para evitar loops.

---

# 🧠 Classificação rápida

```text
ROTEAMENTO DINÂMICO
│
├── Distance Vector
│   └── RIP
│
├── Advanced Distance Vector
│   └── EIGRP
│
├── Link-State
│   ├── OSPF
│   └── IS-IS
│
└── Path Vector
    └── BGP
```

---

# 🎯 Para memorizar

### RIP

> **RIP = quantidade de Hops**

```text
Máximo = 15 hops
UDP = 520
```

### OSPF

> **OSPF = topologia + menor custo**

```text
Link-State
Dijkstra / SPF
IP Protocol 89
```

### EIGRP

> **EIGRP = DUAL + métrica composta**

```text
Advanced Distance Vector
Cisco
```

### IS-IS

> **IS-IS = Link-State para redes grandes**

```text
Level 1
Level 2
```

### BGP

> **BGP = roteamento entre Sistemas Autônomos**

```text
Path Vector
TCP 179
Internet
```
