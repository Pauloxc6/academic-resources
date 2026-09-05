# 02 Introdução ao MPLS e Setup de Cenário — Parte 2

Nesta etapa, o cenário anterior é expandido para estabelecer **BGP entre o PE1 e o CE1**.

Agora temos:

```text
                    AS 65512
                  ┌──────────┐
                  │   CE1    │
                  │11.0.0.1  │
                  └────┬─────┘
                       │
                 eBGP  │
                       │
                  ┌────┴─────┐
                  │   PE1    │
                  │   AS65000 │
                  └────┬─────┘
                       │
                 AS 65000
                  MPLS Core
                       │
                  ┌────┴─────┐
                  │ P1 / P2  │
                  └──────────┘
```

---

# 🏗️ Arquitetura dos AS

O cenário utiliza dois Sistemas Autônomos:

| Equipamento | Função        |      AS |
| ----------- | ------------- | ------: |
| PE1         | Provider Edge | `65000` |
| P1          | Provider      | `65000` |
| P2          | Provider      | `65000` |
| CE1         | Customer Edge | `65512` |

Portanto:

```text
CE1 AS65512
      │
     eBGP
      │
PE1 AS65000
      │
     iBGP
      │
 P1/P2 AS65000
```

---

# 1. PE1

## Endereçamento

```routeros
/interface bridge add name=lo0

/ip address add \
    address=172.0.1.1/32 \
    interface=lo0

/ip address add \
    address=100.0.11.1/30 \
    interface=ether1 \
    comment="PtP->CE1"

/ip address add \
    address=192.100.200.1/30 \
    interface=ether2 \
    comment="PtP->P1"

/ip address add \
    address=192.168.220.1/30 \
    interface=ether3 \
    comment="PtP->P2"
```

A topologia IP do PE1 é:

```text
                 CE1
                  │
           100.0.11.0/30
                  │
                  ▼
                 PE1
             ┌────┴────┐
             │         │
             ▼         ▼
            P1        P2
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

O OSPF continua sendo responsável pela **conectividade interna da infraestrutura do provedor**.

---

# 3. iBGP no PE1

```routeros
/routing bgp template add \
    name=default \
    as=65000 \
    router-id=172.0.1.1 \
    disabled=no
```

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

Como ambos estão no AS `65000`:

```text
PE1 ───── iBGP ───── P1
 │
 └─────── iBGP ───── P2
```

---

# 4. eBGP entre PE1 e CE1

Essa é a principal novidade desta etapa.

No PE1:

```routeros
/routing bgp connection add \
    name=CE1 \
    templates=default \
    remote.address=100.0.11.2 \
    remote.as=65512 \
    local.role=ebgp
```

Temos:

```text
PE1                           CE1
AS65000                      AS65512
100.0.11.1  ─────────────  100.0.11.2
              eBGP
```

Como os AS são diferentes:

```text
65000 ≠ 65512
```

a sessão é **eBGP**.

---

# 5. P1

## Endereçamento

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

---

# 6. P2

## Endereçamento

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

---

## iBGP

```routeros
/routing bgp template add \
    name=default \
    as=65000 \
    router-id=172.0.0.2 \
    disabled=no
```

### P2 → PE1

```routeros
/routing bgp connection add \
    name=PE1 \
    templates=default \
    remote.address=192.168.220.1 \
    remote.as=65000 \
    local.role=ibgp
```

### P2 → P1

```routeros
/routing bgp connection add \
    name=P1 \
    templates=default \
    remote.address=192.100.210.1 \
    remote.as=65000 \
    local.role=ibgp
```

> ⚠️ Aqui havia um erro no material original: o peer de P2 para P1 estava como `192.168.210.2`, mas o P1 está configurado com `192.100.210.1`. Portanto, o endereço correto do peer é `192.100.210.1`.

---

# 7. CE1

## Endereçamento

```routeros
/interface bridge add name=lo0

/ip address add \
    address=11.0.0.1/32 \
    interface=lo0

/ip address add \
    address=100.0.11.2/30 \
    interface=ether1 \
    comment="PtP->PE1"
```

---

## eBGP

O CE1 pertence ao AS `65512`:

```routeros
/routing bgp template set 0 \
    router-id=11.0.0.1 \
    as=65512
```

Depois criamos a sessão com o PE1:

```routeros
/routing bgp connection add \
    name=CE1 \
    templates=default \
    remote.address=100.0.11.1 \
    remote.as=65000 \
    local.role=ebgp
```

A sessão fica:

```text
┌────────────────┐              ┌────────────────┐
│      CE1       │              │      PE1       │
│                │              │                │
│ AS 65512       │    eBGP      │ AS 65000       │
│ 100.0.11.2     │◄────────────►│ 100.0.11.1     │
└────────────────┘              └────────────────┘
```

---

# 🔀 iBGP × eBGP

Agora o cenário possui os dois tipos de sessão:

```text
                    eBGP
        AS65512  ◄──────────►  AS65000
        CE1                    PE1
                                │
                         ┌──────┴──────┐
                         │    iBGP     │
                         ▼             ▼
                        P1             P2
                     AS65000        AS65000
```

### Diferença

| Tipo     |  AS local | AS remoto | Utilização               |
| -------- | --------: | --------: | ------------------------ |
| **eBGP** | Diferente | Diferente | Entre CE e PE            |
| **iBGP** |     Igual |     Igual | Dentro do AS do provedor |

---

# 🧠 Função de cada protocolo

```text
                     PE1
              ┌───────┼───────┐
              │       │       │
             OSPF    iBGP    eBGP
              │       │       │
              ▼       ▼       ▼
           Infra    P1/P2    CE1
```

### OSPF

Responsável pela **conectividade interna**:

```text
PE1 ↔ P1 ↔ P2
```

### iBGP

Responsável pela troca de informações BGP **dentro do AS 65000**:

```text
PE1 ↔ P1
PE1 ↔ P2
P1  ↔ P2
```

### eBGP

Responsável pela troca de rotas entre o provedor e o cliente:

```text
PE1 AS65000 ↔ CE1 AS65512
```

---

# ⚠️ Correções importantes

Havia alguns endereços inconsistentes no material original.

### PE1 → P1

Original:

```text
192.168.200.2
```

Configurado em P1:

```text
192.100.200.2
```

**Correto:**

```text
192.100.200.2
```

### P1 → PE1

Original:

```text
192.168.200.1
```

**Correto:**

```text
192.100.200.1
```

### P1 → P2

Original:

```text
192.168.210.2
```

**Correto:**

```text
192.100.210.2
```

### P2 → P1

Original:

```text
192.168.210.2
```

**Correto:**

```text
192.100.210.1
```

### CE1

Original:

```text
interface brigde
```

**Correto:**

```routeros
/interface bridge add name=lo0
```

---

# 🔎 Verificação

Depois da configuração, podemos verificar as sessões BGP:

```routeros
/routing bgp connection print
```

Detalhes:

```routeros
/routing bgp connection print detail
```

E as sessões estabelecidas:

```routeros
/routing bgp session print
```

Para OSPF:

```routeros
/routing ospf neighbor print
```

E as rotas:

```routeros
/ip route print
```

---

# 🧠 Visão final

```text
                         AS 65512
                      ┌───────────┐
                      │    CE1    │
                      │11.0.0.1/32│
                      └─────┬─────┘
                            │
                     eBGP   │
                            │
                      100.0.11.0/30
                            │
                      ┌─────┴─────┐
                      │    PE1    │
                      │ AS 65000  │
                      │172.0.1.1  │
                      └──┬─────┬──┘
                         │     │
                       iBGP   iBGP
                         │     │
                     ┌───┴─┐ ┌─┴───┐
                     │ P1  │ │ P2  │
                     │65000│ │65000│
                     └──┬──┘ └──┬──┘
                        │        │
                        └────────┘
                           iBGP

                       AS 65000
                     PROVIDER CORE
```

A partir daqui, o próximo passo é realmente entrar no **MPLS**: configurar a distribuição de labels (por exemplo, **LDP**), formar os **LSPs** entre PE/P/P e verificar como o tráfego deixa de depender apenas do encaminhamento IP para atravessar o core usando labels.
