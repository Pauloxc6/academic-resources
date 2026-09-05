# 07 — MPLS com ISP e PPPoE

Nesta etapa vamos integrar:

```text
                 BGP
        R1 ◄────────────► R2
                          │
                       MPLS/LDP
                      ┌───┴───┐
                      │       │
                     R3      R4
                      │       │
                    VPLS    VPLS
                      │       │
                    PPPoE   PPPoE
```

A ideia é transportar serviços **PPPoE** através de uma infraestrutura **MPLS/VPLS**.

---

# 🧠 Visão geral

Cada tecnologia possui uma função diferente:

| Tecnologia | Função                                            |
| ---------- | ------------------------------------------------- |
| **BGP**    | Troca informações de roteamento entre R1 e R2     |
| **OSPF**   | IGP utilizado para alcançar os roteadores do core |
| **MPLS**   | Encaminhamento baseado em labels                  |
| **LDP**    | Distribuição das labels MPLS                      |
| **VPLS**   | Criação de um serviço Ethernet virtual sobre MPLS |
| **PPPoE**  | Criação das sessões PPP dos clientes              |

O fluxo geral é:

```text
Cliente
   │
   │ PPPoE
   ▼
VPLS
   │
   │ Ethernet sobre MPLS
   ▼
MPLS / LDP
   │
   ▼
R2
   │
   ▼
ISP
```

---

# 🗺️ Topologia

```text
                         ISP
                          │
                         R1
                    AS 65500
                          │
                    eBGP /30
                          │
                         R2
                    AS 65501
                     /       \
                  OSPF       OSPF
                   /           \
                 R3             R4
              172.0.0.2     172.0.0.3
```

No R2 existem dois serviços VPLS:

```text
PPPoE-LocalA → R3
PPPoE-LocalB → R4
```

---

# 1. R1 — ISP

## Loopback

```routeros
/interface bridge add name=lo0

/ip address
add address=10.10.10.10/32 interface=lo0
add address=20.20.20.20/32 interface=lo0
add address=30.30.30.30/32 interface=lo0
add address=40.40.40.40/32 interface=lo0
add address=50.50.50.50/32 interface=lo0
```

As interfaces `lo0` são utilizadas como interfaces lógicas para os endereços de loopback.

Exemplo:

```text
10.10.10.10/32
20.20.20.20/32
...
```

> 💡 Como são endereços de loopback, o prefixo normalmente utilizado é `/32`.

---

## Enlace com R2

```routeros
/ip address add \
    address=200.0.0.1/30 \
    interface=ether1
```

A rede fica:

```text
200.0.0.0/30

R1 → 200.0.0.1
R2 → 200.0.0.2
```

---

# 🌎 BGP no R1

```routeros
/routing bgp template
set 0 \
    address-families=ip \
    as=65500 \
    disabled=no \
    output.redistribute=ospf \
    router-id=10.10.10.10 \
    routing-table=main \
    vrf=main
```

O R1 pertence ao:

```text
AS 65500
```

e utiliza:

```text
router-id=10.10.10.10
```

---

## eBGP com R2

```routeros
/routing bgp connection
add name=R2 \
    templates=default \
    remote.address=200.0.0.2 \
    remote.as=65501 \
    local.role=ebgp
```

Temos:

```text
R1
AS 65500
  │
  │ eBGP
  │
R2
AS 65501
```

Como os ASNs são diferentes, trata-se de **eBGP**.

---

# 2. R2 — Core / Concentrador PPPoE

## Loopback

```routeros
/interface bridge add name=lo0

/ip address
add address=172.0.0.1/32 interface=lo0
```

---

## Interfaces

```routeros
/ip address
add address=200.0.0.2/30 interface=ether1
add address=192.168.1.1/30 interface=ether2
add address=192.168.2.1/30 interface=ether3
```

Topologia:

```text
R1
 │
 │ 200.0.0.0/30
 │
R2
├── ether2 → R3
│
└── ether3 → R4
```

---

# 🌎 BGP no R2

```routeros
/routing bgp template
set 0 \
    address-families=ip \
    as=65501 \
    disabled=no \
    output.redistribute=ospf \
    router-id=172.0.0.1 \
    routing-table=main \
    vrf=main
```

O R2 pertence ao:

```text
AS 65501
```

---

## eBGP com R1

```routeros
/routing bgp connection
add name=R1 \
    templates=default \
    remote.address=200.0.0.1 \
    remote.as=65500 \
    local.role=ebgp
```

Assim:

```text
AS 65500              AS 65501
   R1 ───── eBGP ───── R2
```

> ⚠️ No material original estava `local.role=ebg`. O correto é `local.role=ebgp`.

---

# 🛰️ OSPF no R2

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=172.0.0.1 \
    routing-table=main \
    version=2 \
    vrf=main
```

Área backbone:

```routeros
/routing ospf area
add name=backbone \
    area-id=0.0.0.0 \
    instance=instance0 \
    disabled=no \
    type=default
```

Template:

```routeros
/routing ospf interface-template
add disabled=no \
    area=backbone \
    instance-id=0 \
    type=broadcast
```

O OSPF fornece a conectividade IP necessária dentro do core.

---

# 🏷️ MPLS no R2

```routeros
/mpls interface
add disabled=no \
    interface=all \
    mpls-mtu=1512
```

O MPLS é habilitado nas interfaces.

> 💡 Em produção, é melhor limitar o MPLS às interfaces que realmente participam do core.

---

# 📦 LDP no R2

```routeros
/mpls ldp
add disabled=no \
    lsr-id=172.0.0.1 \
    transport-addresses=172.0.0.1
```

O R2 utiliza:

```text
LSR ID = 172.0.0.1
```

---

## Interfaces LDP

```routeros
/mpls ldp interface
add disabled=no interface=ether2
add disabled=no interface=ether3
```

Portanto:

```text
R2
├── ether2 → R3 → LDP
└── ether3 → R4 → LDP
```

---

# 🌐 Criando os VPLS no R2

Agora entramos na parte principal do laboratório.

```routeros
/interface vpls
add name=PPPoE-LocalA \
    disabled=no \
    peer=172.0.0.2 \
    vpls-id=1:1

add name=PPPoE-LocalB \
    disabled=no \
    peer=172.0.0.3 \
    vpls-id=1:2
```

Temos dois serviços:

```text
VPLS 1:1
R2 ↔ R3

VPLS 1:2
R2 ↔ R4
```

O VPLS cria uma espécie de **ponte Ethernet virtual** entre os equipamentos através da rede MPLS.

---

# 🔌 Pool dos clientes PPPoE

```routeros
/ip pool
add name=pool1 \
    ranges=172.16.0.1-172.16.0.25
```

Esse pool será utilizado para fornecer endereços IP aos clientes PPPoE.

---

# 👤 Perfis PPP

## Local A

```routeros
/ppp profile
add name=localA \
    local-address=1.1.1.1 \
    remote-address=pool1 \
    dns-server=1.1.1.1,1.0.0.1 \
    use-mpls=yes
```

## Local B

```routeros
/ppp profile
add name=localB \
    local-address=2.2.2.2 \
    remote-address=pool1 \
    dns-server=1.1.1.1,1.0.0.1 \
    use-mpls=yes
```

### `local-address`

É o endereço utilizado pelo lado local da sessão PPP.

### `remote-address`

Define de onde será obtido o endereço IP do cliente.

Neste caso:

```text
remote-address=pool1
```

---

# 🔐 Usuários PPP

```routeros
/ppp secret
add name=PC1 disabled=no password="<senha-do-lab>"

add name=PC2 disabled=no password="<senha-do-lab>"
```

Os usuários serão utilizados para autenticação das sessões PPPoE.

> 🔒 As credenciais reais do laboratório não precisam ficar expostas no README/documentação.

---

# 📡 Servidor PPPoE — Local A

```routeros
/interface pppoe-server server
add disabled=no \
    service-name=localA \
    interface=PPPoE-LocalA \
    default-profile=localA \
    authentication=chap,mschap1,mschap2 \
    keepalive-timeout=7000 \
    max-mru=1500 \
    max-mtu=1500 \
    one-session-per-host=yes
```

O servidor PPPoE é associado à interface VPLS:

```text
PPPoE-LocalA
```

Portanto:

```text
Cliente
   │
 PPPoE
   │
   ▼
PPPoE-LocalA
   │
   ▼
VPLS
   │
   ▼
R3
```

---

# 📡 Servidor PPPoE — Local B

```routeros
/interface pppoe-server server
add disabled=no \
    service-name=localB \
    interface=PPPoE-LocalB \
    default-profile=localB \
    authentication=chap,mschap1,mschap2 \
    keepalive-timeout=7000 \
    max-mru=1500 \
    max-mtu=1500 \
    one-session-per-host=yes
```

Agora:

```text
Cliente
   │
 PPPoE
   │
   ▼
PPPoE-LocalB
   │
   ▼
VPLS
   │
   ▼
R4
```

---

# 3. R3

## Loopback e enlace

```routeros
/interface bridge add name=lo0

/ip address
add address=172.0.0.2/32 interface=lo0
add address=192.168.1.2/30 interface=ether1
```

A rede entre R2 e R3:

```text
192.168.1.0/30

R2 → 192.168.1.1
R3 → 192.168.1.2
```

---

# 🛰️ OSPF

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=172.0.0.2 \
    routing-table=main \
    version=2 \
    vrf=main

/routing ospf area
add name=backbone \
    area-id=0.0.0.0 \
    instance=instance0 \
    disabled=no \
    type=default

/routing ospf interface-template
add disabled=no \
    area=backbone \
    instance-id=0 \
    type=broadcast
```

---

# 🏷️ MPLS/LDP

```routeros
/mpls interface
add disabled=no interface=all mpls-mtu=1512
```

```routeros
/mpls ldp
add disabled=no \
    lsr-id=172.0.0.2 \
    transport-addresses=172.0.0.2
```

Interfaces LDP:

```routeros
/mpls ldp interface
add disabled=no interface=ether1
add disabled=no interface=ether2
```

---

# 🌐 VPLS no R3

```routeros
/interface vpls
add name=PPPoE \
    disabled=no \
    peer=172.0.0.1 \
    vpls-id=1:1
```

O VPLS conecta:

```text
R3
 │
 │ VPLS 1:1
 │
R2
```

---

# 🌉 Bridge do serviço

```routeros
/interface bridge
add name=PPPoE-VPLS

/interface bridge port
add bridge=PPPoE-VPLS interface=ether2
add bridge=PPPoE-VPLS interface=PPPoE
```

A ideia é colocar:

```text
ether2
   │
   ├──── Bridge PPPoE-VPLS
   │
PPPoE
```

Assim, o tráfego Ethernet que chega pelo lado físico pode alcançar o pseudowire VPLS.

---

# 4. R4

## Loopback e enlace

```routeros
/interface bridge add name=lo0

/ip address
add address=172.0.0.3/32 interface=lo0
add address=192.168.2.2/30 interface=ether1
```

Rede R2 ↔ R4:

```text
192.168.2.0/30

R2 → 192.168.2.1
R4 → 192.168.2.2
```

---

# 🛰️ OSPF

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=172.0.0.3 \
    routing-table=main \
    version=2 \
    vrf=main

/routing ospf area
add name=backbone \
    area-id=0.0.0.0 \
    instance=instance0 \
    disabled=no \
    type=default

/routing ospf interface-template
add disabled=no \
    area=backbone \
    instance-id=0 \
    type=broadcast
```

---

# 🏷️ MPLS/LDP

```routeros
/mpls interface
add disabled=no interface=all mpls-mtu=1512
```

```routeros
/mpls ldp
add disabled=no \
    lsr-id=172.0.0.3 \
    transport-addresses=172.0.0.3
```

Interfaces:

```routeros
/mpls ldp interface
add disabled=no interface=ether1
add disabled=no interface=ether2
```

---

# 🌐 VPLS no R4

```routeros
/interface vpls
add name=PPPoE \
    disabled=no \
    peer=172.0.0.1 \
    vpls-id=1:2
```

Aqui temos:

```text
R4
 │
 │ VPLS 1:2
 │
R2
```

---

# 🌉 Bridge do serviço

```routeros
/interface bridge
add name=PPPoE-VPLS

/interface bridge port
add bridge=PPPoE-VPLS interface=ether2
add bridge=PPPoE-VPLS interface=PPPoE
```

---

# 🔄 Fluxo completo

## Local A

```text
              R2
               │
        PPPoE-LocalA
               │
             VPLS
               │
             MPLS
               │
              R3
               │
             Cliente
```

VPLS:

```text
1:1
```

---

## Local B

```text
              R2
               │
        PPPoE-LocalB
               │
             VPLS
               │
             MPLS
               │
              R4
               │
             Cliente
```

VPLS:

```text
1:2
```

---

# 🧩 Como as tecnologias trabalham juntas

```text
                    BGP
             ┌──────────────┐
             │              │
            R1 ◄──────────► R2
                            │
                           OSPF
                            │
                       MPLS / LDP
                       ┌────┴────┐
                       │         │
                      VPLS      VPLS
                       │         │
                      R3        R4
                       │         │
                     PPPoE     PPPoE
                       │         │
                    Cliente   Cliente
```

Cada camada possui uma responsabilidade:

```text
BGP
 ↓
Roteamento entre AS

OSPF
 ↓
Conectividade do core

LDP
 ↓
Distribuição das labels

MPLS
 ↓
Transporte baseado em labels

VPLS
 ↓
Transporte Ethernet virtual

PPPoE
 ↓
Sessão/autenticação do cliente
```

---

# 🔍 Verificação

## BGP

```routeros
/routing bgp connection print
```

---

## OSPF

```routeros
/routing ospf neighbor print
```

---

## LDP

```routeros
/mpls ldp neighbor print
```

---

## VPLS

```routeros
/interface vpls print
```

---

## PPPoE

```routeros
/ppp active print
```

Também:

```routeros
/interface pppoe-server server print
```

---

# 🧠 Para memorizar

O conceito principal desta etapa é:

```text
PPPoE
  ↓
VPLS
  ↓
MPLS
  ↓
LDP
  ↓
OSPF
  ↓
Core do ISP
```

Ou seja:

> **O PPPoE fornece o serviço ao cliente, o VPLS transporta Ethernet, o MPLS fornece o transporte por labels, o LDP distribui essas labels e o OSPF fornece a conectividade do core.**

### ⚠️ Observação

Este cenário é um laboratório de **MPLS/VPLS com PPPoE**. Ele não deve ser confundido com uma **MPLS L3VPN tradicional**, que normalmente envolve **VRFs e MP-BGP VPNv4/VPNv6** além do transporte MPLS.
