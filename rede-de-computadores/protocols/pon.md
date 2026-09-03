# 🌐 PON — EPON — GPON

## 🔌 PON — Passive Optical Network

**PON (Passive Optical Network)** é uma arquitetura de rede de acesso baseada em **fibra óptica**, na qual a distribuição entre a **OLT** e as **ONU/ONTs** utiliza componentes passivos.

Isso significa que, no trecho de distribuição óptica, normalmente não são necessários equipamentos alimentados eletricamente para realizar o encaminhamento do sinal.

### 🏗️ Estrutura básica

```text
                    Rede da operadora
                           │
                           │
                          OLT
                    Optical Line Terminal
                           │
                           │ Fibra
                           ▼
                    ┌─────────────┐
                    │ Splitter    │
                    │   Óptico    │
                    └──────┬──────┘
                       ┌───┼───┐
                       │   │   │
                       ▼   ▼   ▼
                     ONU ONU ONU
                       │   │   │
                       ▼   ▼   ▼
                    Clientes
```

### 📌 Principais componentes

| Componente   | Função                                                                             |
| ------------ | ---------------------------------------------------------------------------------- |
| **OLT**      | Equipamento localizado na operadora, responsável pela comunicação com as ONUs/ONTs |
| **Splitter** | Divide o sinal óptico para vários clientes                                         |
| **ONU**      | Equipamento que termina a rede óptica no lado do cliente                           |
| **ONT**      | Tipo de terminal óptico utilizado para entregar o serviço ao cliente               |

---

# 💡 Características das redes PON

As redes PON apresentam algumas vantagens:

* utilização de **fibra óptica**;
* ausência de equipamentos ativos no trecho de distribuição;
* maior imunidade a **interferências eletromagnéticas**;
* possibilidade de atender vários clientes utilizando uma única fibra de distribuição;
* grande escalabilidade;
* altas taxas de transmissão;
* menor necessidade de equipamentos ativos no acesso.

As redes PON podem ser utilizadas para:

* acesso à Internet;
* VoIP;
* IPTV;
* serviços corporativos;
* conexão de estações rádio-base;
* hotspots Wi-Fi;
* sistemas de distribuição de antenas (DAS).

---

# 🟦 EPON

**EPON (Ethernet Passive Optical Network)** é uma tecnologia PON baseada no padrão **Ethernet**.

Sua especificação original está associada ao **IEEE 802.3ah**.

### 📋 Características

* utiliza **Ethernet** para transportar os dados;
* baseada no padrão **IEEE 802.3ah**;
* possui uma arquitetura bastante próxima das redes Ethernet tradicionais;
* utiliza quadros Ethernet;
* taxa nominal de linha de aproximadamente **1,25 Gb/s em downstream e 1,25 Gb/s em upstream**;
* normalmente utiliza divisão óptica de até **1:32 ou 1:64**, dependendo da implementação e do projeto da rede.

### 📦 Ethernet

Como a EPON utiliza Ethernet, os dados são transportados utilizando o formato de quadro Ethernet.

```text
┌──────────────┬──────────────┬─────────────┐
│ Ethernet     │ Dados        │ FCS         │
│ Header       │ Payload      │             │
└──────────────┴──────────────┴─────────────┘
```

O tamanho máximo tradicional de um quadro Ethernet é **1518 bytes**, sem considerar extensões como VLAN.

---

# 🟩 GPON

**GPON (Gigabit-capable Passive Optical Network)** é uma tecnologia PON padronizada pela **ITU-T**, principalmente na família **G.984**.

Diferentemente da EPON, o GPON utiliza o **GEM (GPON Encapsulation Method)** para transportar diferentes tipos de tráfego.

### 📋 Características

* padronizado pela **ITU-T G.984**;
* utiliza **GEM (GPON Encapsulation Method)**;
* suporta diferentes tipos de serviços;
* permite transportar tráfego Ethernet/IP e outros serviços;
* possui maior flexibilidade para serviços multisserviço;
* taxa típica de **2,488 Gb/s no downstream**;
* taxa típica de **1,244 Gb/s no upstream**;
* pode utilizar diferentes razões de divisão óptica, como **1:32, 1:64 e 1:128**, dependendo da classe óptica e do projeto.

---

# 📦 GEM — GPON Encapsulation Method

O **GEM** é o mecanismo utilizado pelo GPON para encapsular e transportar diferentes tipos de tráfego pela rede óptica.

De forma simplificada:

```text
┌───────────────────────┐
│ Ethernet              │
├───────────────────────┤
│ IP                    │
├───────────────────────┤
│ VoIP                  │
├───────────────────────┤
│ Outros serviços       │
└───────────┬───────────┘
            │
            ▼
       GEM / GPON
            │
            ▼
       Rede óptica
```

Isso permite que o GPON seja utilizado para transportar diferentes serviços através da mesma infraestrutura.

---

# ⚖️ EPON x GPON

| Característica  | EPON                    | GPON                      |
| --------------- | ----------------------- | ------------------------- |
| Padrão          | IEEE 802.3ah            | ITU-T G.984               |
| Tecnologia base | Ethernet                | GPON/GEM                  |
| Downstream      | ~1,25 Gb/s              | ~2,488 Gb/s               |
| Upstream        | ~1,25 Gb/s              | ~1,244 Gb/s               |
| Encapsulamento  | Ethernet                | GEM                       |
| Serviços        | Principalmente Ethernet | Multisserviço             |
| Divisão óptica  | Depende do projeto      | Depende da classe/projeto |
| Arquitetura     | PON                     | PON                       |

---

# 🚦 Downstream e Upstream

É importante entender esses dois termos:

### ⬇️ Downstream

É o tráfego que vai da **OLT para o cliente**.

```text
OLT
 │
 ▼
Splitter
 │
 ├──► ONU
 ├──► ONU
 └──► ONU
```

### ⬆️ Upstream

É o tráfego que vai do **cliente para a OLT**.

```text
ONU
 │
 ▼
Splitter
 │
 ▼
OLT
```

---

# 📊 Velocidades

### EPON

```text
Downstream ≈ 1,25 Gb/s
Upstream   ≈ 1,25 Gb/s
```

Portanto, a taxa nominal de linha é aproximadamente **simétrica**.

### GPON

```text
Downstream ≈ 2,488 Gb/s
Upstream   ≈ 1,244 Gb/s
```

Nesse sentido, o GPON possui uma capacidade nominal **assimétrica**, com maior capacidade no downstream.

> ⚠️ Essas são **taxas da interface/rede PON**, não necessariamente a velocidade disponível individualmente para cada cliente.

---

# ✂️ Splitter Óptico

O **splitter** é um componente passivo que divide o sinal óptico entre vários clientes.

Exemplo:

```text
             OLT
              │
              │
              ▼
        ┌───────────┐
        │  Splitter │
        └─────┬─────┘
          ┌───┼───┬───┐
          ▼   ▼   ▼   ▼
         ONU ONU ONU ONU
```

Uma única porta PON da OLT pode atender vários clientes.

Exemplo de divisão:

```text
1:8
1:16
1:32
1:64
1:128
```

A quantidade máxima depende da **tecnologia, classe óptica, orçamento óptico, distância e projeto da rede**.

---

# 📡 Comunicação na PON

A comunicação possui características diferentes dependendo da direção.

## Downstream

A OLT transmite para várias ONUs/ONTs através da árvore óptica.

```text
                 OLT
                  │
                  ▼
              Splitter
             /    |    \
            /     |     \
           ▼      ▼      ▼
         ONU     ONU    ONU
```

Cada ONU recebe o sinal e processa os dados destinados a ela.

---

## Upstream

As ONUs compartilham o meio óptico.

Por isso, é necessário um mecanismo de controle para evitar que várias ONUs transmitam simultaneamente.

```text
ONU 1 ──┐
ONU 2 ──┼──► Splitter ──► OLT
ONU 3 ──┘
```

No GPON, isso é controlado através de mecanismos de **TDMA (Time Division Multiple Access)**.

---

# 🔐 Segurança

Como o downstream é compartilhado entre várias ONUs, mecanismos de segurança podem ser utilizados para impedir que uma ONU tenha acesso indevido aos dados destinados a outras ONUs.

No GPON, por exemplo, existe suporte a **AES para criptografia do tráfego downstream**.

---

# 🧠 Resumo

```text
PON
│
├── Passive Optical Network
│
├── OLT
│   └── Equipamento da operadora
│
├── Splitter
│   └── Divide o sinal óptico
│
└── ONU / ONT
    └── Equipamento do cliente
```

### EPON

```text
EPON
│
├── IEEE 802.3ah
├── Ethernet
├── ~1,25 Gb/s ↓
└── ~1,25 Gb/s ↑
```

### GPON

```text
GPON
│
├── ITU-T G.984
├── GEM
├── ~2,488 Gb/s ↓
└── ~1,244 Gb/s ↑
```

---

# 🎯 Para memorizar

> **PON** → rede óptica passiva.

> **OLT** → equipamento que concentra a rede na operadora.

> **Splitter** → divide o sinal óptico.

> **ONU/ONT** → termina a conexão óptica no cliente.

> **EPON** → PON baseada em Ethernet.

> **GPON** → PON baseada em GEM e voltada a uma arquitetura multisserviço.

> **Downstream** → OLT → cliente.

> **Upstream** → cliente → OLT.
