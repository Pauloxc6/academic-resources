# 01 Introdução ao MPLS e Setup de Cenário

Este cenário será utilizado para estudar **MPLS (Multiprotocol Label Switching)** em uma topologia com roteadores **PE**, **P** e **CE**.

## 🗺️ Topologia

```text
                    ┌─────────────┐
                    │    CE1      │
                    │ 11.0.0.1/32│
                    └──────┬──────┘
                           │
                    100.0.11.0/30
                           │
                           │
                    ┌──────┴──────┐
                    │     PE1     │
                    │172.0.1.1/32│
                    └───┬─────┬──┘
                        │     │
             192.100.200/30  192.168.220/30
                        │     │
                   ┌────┴─┐ ┌─┴────┐
                   │  P1  │ │  P2  │
                   │172.0│ │172.0 │
                   │.0.1 │ │.0.2  │
                   └──┬──┘ └──┬───┘
                      │        │
                      └────────┘
                    192.100.210/30
```

### Função dos equipamentos

| Equipamento | Função        | Loopback       |
| ----------- | ------------- | -------------- |
| PE1         | Provider Edge | `172.0.1.1/32` |
| P1          | Provider/Core | `172.0.0.1/32` |
| P2          | Provider/Core | `172.0.0.2/32` |
| CE1         | Customer Edge | `11.0.0.1/32`  |

---

# 🧩 Conceitos

## PE — Provider Edge

O **PE** é o roteador da operadora que possui conexão direta com o cliente.

Neste cenário:

```text
CE1
 │
 ▼
PE1
```

O PE1 fará a ligação entre a rede do cliente e a infraestrutura da operadora.

---

## P — Provider/Core

Os roteadores **P** ficam no núcleo da rede da operadora.

```text
PE1 ─── P1 ─── P2
```

Eles normalmente não precisam conhecer as redes dos clientes. No MPLS, o núcleo pode encaminhar o tráfego utilizando **labels**.

---

## CE — Customer Edge

O **CE** pertence à rede do cliente.

Neste cenário:

```text
CE1 ─── PE1
```

O CE1 representa o equipamento localizado no lado do cliente.

---

# 1. PE1 — MikroTik 1

## Loopback

```routeros
/interface bridge add name=lo0

/ip address add \
    address=172.0.1.1/32 \
    interface=lo0
```

A `lo0` funciona como interface lógica para o **Router ID** e pode ser utilizada como endereço estável para protocolos de roteamento.

---

## Interfaces ponto a ponto

### PE1 → CE1

```routeros
/ip address add \
    address=100.0.11.1/30 \
    interface=ether1 \
    comment="PtP->CE1"
```

Rede:

```text
100.0.11.0/30

PE1 → 100.0.11.1
CE1 → 100.0.11.2
```

### PE1 → P1

```routeros
/ip address add \
    address=192.100.200.1/30 \
    interface=ether2 \
    comment="PtP->P1"
```

Rede:

```text
192.100.200.0/30

PE1 → 192.100.200.1
P1  → 192.100.200.2
```

### PE1 → P2

```routeros
/ip address add \
    address=192.168.220.1/30 \
    interface=ether3 \
    comment="PtP->P2"
```

Rede:

```text
192.168.220.0/30

PE1 → 192.168.220.1
P2  → 192.168.220.2
```

---

# 2. OSPF no PE1

```routeros
/routing ospf instance add \
    name=instance00 \
    disabled=no \
    router-id=172.0.1.1 \
    version=2 \
    vrf=main

/routing ospf area add \
    name=backbone \
    area-id=0.0.0.0 \
    disabled=no \
    instance=instance00

/routing ospf interface-template add \
    area=backbone \
    instance-id=0 \
    type=broadcast \
    disabled=no
```

O OSPF será utilizado para fornecer **roteamento IP e alcançar as loopbacks** da infraestrutura.

```text
PE1
 │
 ├── 172.0.1.1/32
 │
 ├── P1 → 172.0.0.1/32
 │
 └── P2 → 172.0.0.2/32
```

> Para um laboratório mais controlado, é melhor restringir o `interface-template` às interfaces/redes realmente utilizadas pelo OSPF, em vez de deixar a correspondência tão ampla.

---

# 3. iBGP no PE1

```routeros
/routing bgp template add \
    name=default \
    as=65000 \
    router-id=172.0.1.1 \
    disabled=no
```

O PE1 pertence ao AS:

```text
65000
```

Como P1 e P2 também estarão no AS `65000`, as sessões serão **iBGP**.

### PE1 → P1

```routeros
/routing bgp connection add \
    name=P1 \
    templates=default \
    remote.address=192.100.200.2 \
    remote.as=65000 \
    local.role=ibgp
```

### PE1 → P2

```routeros
/routing bgp connection add \
    name=P2 \
    templates=default \
    remote.address=192.168.220.2 \
    remote.as=65000 \
    local.role=ibgp
```

> ⚠️ **Correção:** no material original, a sessão PE1 → P1 utilizava `192.168.200.2`, mas o endereço configurado em P1 é `192.100.200.2`.

---

# 4. P1 — MikroTik 2

## Loopback e interfaces

```routeros
/interface bridge add name=lo0

/ip address add \
    address=172.0.0.1/32 \
    interface=lo0

/ip address add \
    address=192.100.200.2/30 \
    interface=ether1 \
    comment="PtP->PE1"

 /ip address add \
    address=192.100.210.1/30 \
    interface=ether2 \
    comment="PtP->P2"
```

Topologia:

```text
PE1
 │
 │ 192.100.200.0/30
 │
P1
 │
 │ 192.100.210.0/30
 │
P2
```

---

## OSPF

```routeros
/routing ospf instance add \
    name=instance00 \
    disabled=no \
    router-id=172.0.0.1 \
    version=2 \
    vrf=main

/routing ospf area add \
    name=backbone \
    area-id=0.0.0.0 \
    disabled=no \
    instance=instance00

/routing ospf interface-template add \
    area=backbone \
    instance-id=0 \
    type=broadcast \
    disabled=no
```

---

## iBGP

```routeros
/routing bgp template add \
    name=default \
    as=65000 \
    router-id=172.0.0.1 \
    disabled=no
```

### P1 → PE1

```routeros
/routing bgp connection add \
    name=PE1 \
    templates=default \
    remote.address=192.100.200.1 \
    remote.as=65000 \
    local.role=ibgp
```

### P1 → P2

```routeros
/routing bgp connection add \
    name=P2 \
    templates=default \
    remote.address=192.100.210.2 \
    remote.as=65000 \
    local.role=ibgp
```

> ⚠️ **Correção:** no material original, P1 utilizava `192.168.200.1` para PE1 e `192.168.210.2` para P2. Esses endereços não correspondem às redes configuradas. O correto, neste cenário, é `192.100.200.1` e `192.100.210.2`.

---

# 5. P2 — MikroTik 3

## Loopback e interfaces

```routeros
/interface bridge add name=lo0

/ip address add \
    address=172.0.0.2/32 \
    interface=lo0

/ip address add \
    address=192.168.220.2/30 \
    interface=ether1 \
    comment="PtP->PE1"

 /ip address add \
    address=192.100.210.2/30 \
    interface=ether2 \
    comment="PtP->P1"
```

---

## OSPF

```routeros
/routing ospf instance add \
    name=instance00 \
    disabled=no \
    router-id=172.0.0.2 \
    version=2 \
    vrf=main

/routing ospf area add \
    name=backbone \
    area-id=0.0.0.0 \
    disabled=no \
    instance=instance00

/routing ospf interface-template add \
    area=backbone \
    instance-id=0 \
    type=broadcast \
    disabled=no
```

O P2 participará do backbone OSPF:

```text
PE1
 │
 ├──────── P1
 │          │
 │          │
 └──────── P2
```

---

# 6. CE1 — MikroTik 4

## Loopback

```routeros
/interface bridge add name=lo0

/ip address add \
    address=11.0.0.1/32 \
    interface=lo0
```

## Interface para PE1

```routeros
/ip address add \
    address=100.0.11.2/30 \
    interface=ether1 \
    comment="PtP->PE1"
```

A conexão fica:

```text
CE1                         PE1
100.0.11.2/30 ─────────── 100.0.11.1/30
```

> ⚠️ No material original havia `interface brigde`. O correto é `interface bridge`.

---

# 🧠 Visão geral do cenário

```text
                    CUSTOMER
                       │
                       │
                 ┌─────┴─────┐
                 │    CE1    │
                 │11.0.0.1/32│
                 └─────┬─────┘
                       │
                 100.0.11.0/30
                       │
                 ┌─────┴─────┐
                 │    PE1    │
                 │172.0.1.1/32│
                 └──┬──────┬─┘
                    │      │
          192.100.200/30  192.168.220/30
                    │      │
                 ┌──┴──┐ ┌─┴──┐
                 │ P1  │ │ P2 │
                 │172.0│ │172.0│
                 │.0.1 │ │.0.2│
                 └──┬──┘ └─┬──┘
                    │      │
                    └──────┘
                 192.100.210/30
```

---

# 🔀 Função de cada protocolo

| Protocolo | Função no cenário                           |
| --------- | ------------------------------------------- |
| **OSPF**  | Roteamento interno da infraestrutura        |
| **iBGP**  | Troca de informações BGP dentro do AS 65000 |
| **MPLS**  | Encaminhamento baseado em labels            |
| **IP**    | Conectividade básica entre os equipamentos  |

A ideia é separar as funções:

```text
             INFRAESTRUTURA
                   │
                 OSPF
                   │
          Alcança os routers
                   │
                   ▼
                 iBGP
                   │
        Troca informações BGP
                   │
                   ▼
                 MPLS
                   │
       Encaminhamento por labels
```

---

# ⚠️ Próxima etapa: MPLS

Até aqui, o cenário possui principalmente **endereçamento, OSPF e iBGP**.

Ainda falta configurar o próprio **MPLS**, incluindo elementos como:

```text
LDP / outro protocolo de distribuição de labels
        │
        ▼
Label bindings
        │
        ▼
LSP
        │
        ▼
PE1 ─── P1 ─── P2
```

O próximo passo natural do laboratório é configurar o **MPLS/LDP nos enlaces PE-P e P-P**, verificar a formação das adjacências e depois observar as labels utilizadas no encaminhamento.
