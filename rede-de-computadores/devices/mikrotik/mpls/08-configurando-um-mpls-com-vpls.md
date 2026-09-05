# 08 — Configurando um MPLS com VPLS

Nesta etapa vamos configurar uma rede **MPLS com VPLS (Virtual Private LAN Service)**.

O objetivo é criar uma conexão Ethernet virtual entre **PE1 e PE2**, utilizando o roteador **P** como transporte MPLS.

---

# 🗺️ Topologia

```text
                   MPLS CORE

              192.168.10.0/30
        ┌────────────────────────┐
        │                        │
       P                        PE1
   1.1.1.1                    2.2.2.2
        │                        │
        │                        │
        │                        │
        │                    INEC-VPLS
        │                        │
        │                      ether2
        │
        │
        │
        └────────────────────────┐
                                 │
                         192.168.20.0/30
                                 │
                                PE2
                              3.3.3.3
                                 │
                              ether2
                                 │
                            INEC-VPLS
```

De forma simplificada:

```text
PE1 ───── P ───── PE2
 │                 │
 └────── VPLS ─────┘
```

O VPLS cria uma espécie de **bridge Ethernet virtual** entre PE1 e PE2.

---

# 🧠 Conceitos utilizados

Nesta configuração temos várias tecnologias trabalhando juntas:

```text
OSPF
  ↓
Conectividade IP do core

LDP
  ↓
Distribuição das labels

MPLS
  ↓
Transporte no core

VPLS
  ↓
Serviço Ethernet Layer 2
```

O fluxo pode ser representado assim:

```text
Ethernet
   │
   ▼
VPLS
   │
   ▼
MPLS
   │
   ▼
LDP
   │
   ▼
OSPF
```

---

# 1. Router P

O roteador `P` funciona como **Provider/Core Router**.

Ele não participa diretamente do serviço Ethernet dos clientes. Sua função principal é transportar os pacotes MPLS entre os dois PE.

---

## Loopback

```routeros
/interface bridge
add name=lo0

/ip address
add address=1.1.1.1/32 interface=lo0
```

A loopback será utilizada como:

```text
Router ID OSPF
LSR ID MPLS
Endereço de transporte LDP
```

---

## Interfaces

```routeros
/ip address
add address=192.168.10.1/30 interface=ether1
add address=192.168.20.1/30 interface=ether2
```

Temos:

```text
P ↔ PE1

192.168.10.0/30
P   = 192.168.10.1
PE1 = 192.168.10.2
```

E:

```text
P ↔ PE2

192.168.20.0/30
P   = 192.168.20.1
PE2 = 192.168.20.2
```

---

# 🛰️ OSPF no Router P

## Instância

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=1.1.1.1 \
    routing-table=main \
    vrf=main \
    version=2
```

## Área

```routeros
/routing ospf area
add disabled=no \
    name=backbone \
    area-id=0.0.0.0 \
    type=default \
    instance=instance0
```

## Interface-template

```routeros
/routing ospf interface-template
add disabled=no \
    instance-id=0 \
    area=backbone \
    type=broadcast
```

O OSPF permite que P, PE1 e PE2 conheçam as loopbacks uns dos outros.

Isso é importante porque o LDP/VPLS utiliza essas loopbacks para estabelecer o transporte.

---

# 🏷️ MPLS

```routeros
/mpls interface
add disabled=no \
    interface=all \
    mpls-mtu=1508
```

O MPLS é habilitado nas interfaces do roteador.

> 💡 Em um ambiente real, normalmente seria melhor habilitar MPLS apenas nas interfaces que pertencem ao core.

---

# 📦 LDP

```routeros
/mpls ldp
add disabled=no \
    lsr-id=1.1.1.1 \
    transport-addresses=1.1.1.1 \
    afi=ip \
    vrf=main
```

O P possui:

```text
LSR ID = 1.1.1.1
Transport Address = 1.1.1.1
```

---

## Interfaces LDP

```routeros
/mpls ldp interface
add disabled=no afi=ip interface=ether1

add disabled=no afi=ip interface=ether2
```

Portanto:

```text
ether1 → P ↔ PE1
ether2 → P ↔ PE2
```

---

# 🤝 Vizinhos LDP

```routeros
/mpls ldp neighbor
add transport=2.2.2.2

add transport=3.3.3.3
```

O P conhece os dois PE como possíveis vizinhos LDP:

```text
             P
          1.1.1.1
          /      \
         /        \
      PE1          PE2
    2.2.2.2      3.3.3.3
```

---

# 2. PE1

O PE1 funciona como **Provider Edge**.

É nele que o serviço VPLS é iniciado para o PE2.

---

## Loopback

```routeros
/interface bridge
add name=lo0

/ip address
add address=2.2.2.2/32 interface=lo0
```

---

## Conexão com P

```routeros
/ip address
add address=192.168.10.2/30 interface=ether1
```

Assim:

```text
P   = 192.168.10.1
PE1 = 192.168.10.2
```

---

# 🛰️ OSPF

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=2.2.2.2 \
    routing-table=main \
    vrf=main \
    version=2
```

Área:

```routeros
/routing ospf area
add disabled=no \
    name=backbone \
    area-id=0.0.0.0 \
    type=default \
    instance=instance0
```

Interface:

```routeros
/routing ospf interface-template
add disabled=no \
    instance-id=0 \
    area=backbone \
    type=broadcast
```

---

# 🏷️ MPLS/LDP no PE1

```routeros
/mpls interface
add disabled=no \
    interface=all \
    mpls-mtu=1508
```

```routeros
/mpls ldp
add disabled=no \
    lsr-id=2.2.2.2 \
    transport-addresses=2.2.2.2 \
    afi=ip \
    vrf=main
```

Interface LDP:

```routeros
/mpls ldp interface
add disabled=no \
    afi=ip \
    interface=ether1
```

Vizinho:

```routeros
/mpls ldp neighbor
add transport=1.1.1.1
```

O PE1 estabelece LDP com o P.

---

# 🌐 Criando o VPLS no PE1

```routeros
/interface vpls
add comment="INEC-PHC" \
    disabled=no \
    pw-l2mtu=1500 \
    name=INEC-PHC \
    peer=3.3.3.3 \
    vpls-id=10:0
```

Essa é uma das partes mais importantes da configuração.

O PE1 cria um pseudowire VPLS com:

```text
peer=3.3.3.3
```

ou seja:

```text
PE1 ───────── PE2
      VPLS
```

O tráfego entre os dois endpoints será transportado através do core MPLS.

---

# 🆔 VPLS ID

```text
vpls-id=10:0
```

O `VPLS ID` identifica o serviço VPLS.

O mesmo ID precisa ser utilizado nos dois endpoints:

```text
PE1 → 10:0
PE2 → 10:0
```

Assim ambos pertencem ao mesmo serviço VPLS.

---

# 🌉 Bridge do serviço

Criamos uma bridge:

```routeros
/interface bridge
add name=INEC-VPLS
```

Depois adicionamos:

```routeros
/interface bridge port
add interface=ether2 bridge=INEC-VPLS

add interface=INEC-PHC bridge=INEC-VPLS
```

A estrutura fica:

```text
                    PE1

                 INEC-VPLS
                /          \
           ether2          VPLS
             │               │
          Cliente          MPLS
```

Isso conecta o segmento Ethernet local ao pseudowire VPLS.

---

# 3. PE2

O PE2 funciona como o segundo **Provider Edge** do serviço.

---

## Loopback

```routeros
/interface bridge
add name=lo0

/ip address
add address=3.3.3.3/32 interface=lo0
```

---

## Interface para P

```routeros
/ip address
add address=192.168.20.2/30 interface=ether1
```

Temos:

```text
P   = 192.168.20.1
PE2 = 192.168.20.2
```

---

# 🛰️ OSPF

```routeros
/routing ospf instance
add name=instance0 \
    disabled=no \
    router-id=3.3.3.3 \
    routing-table=main \
    vrf=main \
    version=2
```

Área:

```routeros
/routing ospf area
add disabled=no \
    name=backbone \
    area-id=0.0.0.0 \
    type=default \
    instance=instance0
```

Interface:

```routeros
/routing ospf interface-template
add disabled=no \
    instance-id=0 \
    area=backbone \
    type=broadcast
```

---

# 🏷️ MPLS/LDP

```routeros
/mpls interface
add disabled=no \
    interface=all \
    mpls-mtu=1508
```

```routeros
/mpls ldp
add disabled=no \
    lsr-id=3.3.3.3 \
    transport-addresses=3.3.3.3 \
    afi=ip \
    vrf=main
```

Interface:

```routeros
/mpls ldp interface
add disabled=no \
    afi=ip \
    interface=ether1
```

Vizinho:

```routeros
/mpls ldp neighbor
add transport=1.1.1.1
```

---

# 🌐 Criando o VPLS no PE2

```routeros
/interface vpls
add comment="INEC-PHC" \
    disabled=no \
    pw-l2mtu=1500 \
    name=INEC-PHC \
    peer=2.2.2.2 \
    vpls-id=10:0
```

Observe que o VPLS é espelhado:

```text
PE1:
peer=3.3.3.3
vpls-id=10:0

PE2:
peer=2.2.2.2
vpls-id=10:0
```

O `vpls-id` é o mesmo nos dois lados.

---

# 🌉 Bridge no PE2

```routeros
/interface bridge
add name=INEC-VPLS
```

```routeros
/interface bridge port
add interface=ether2 bridge=INEC-VPLS

add interface=INEC-PHC bridge=INEC-VPLS
```

Agora temos:

```text
                   PE2

                INEC-VPLS
                /        \
           ether2        VPLS
             │             │
          Cliente         MPLS
```

---

# 🔄 Funcionamento completo

O resultado final é:

```text
                MPLS CORE

       PE1                     PE2
    2.2.2.2                 3.3.3.3
       │                       │
       │                       │
       │       VPLS            │
       └────────────┬──────────┘
                    │
                    │
              ┌─────┴─────┐
              │     P     │
              │  1.1.1.1 │
              └───────────┘
```

Mais precisamente:

```text
Cliente A
    │
  ether2
    │
    ▼
INEC-VPLS
    │
    ▼
VPLS
    │
    ▼
MPLS
    │
    ▼
P
    │
    ▼
MPLS
    │
    ▼
VPLS
    │
    ▼
INEC-VPLS
    │
  ether2
    │
    ▼
Cliente B
```

---

# 🧱 O que o VPLS está fazendo?

Sem VPLS:

```text
PE1 ─── P ─── PE2
```

O core trabalha principalmente com IP/MPLS.

Com VPLS:

```text
Ethernet
   │
   ▼
VPLS
   │
   ▼
MPLS Core
   │
   ▼
VPLS
   │
   ▼
Ethernet
```

Assim, o serviço Ethernet pode atravessar uma infraestrutura MPLS.

Para os dispositivos nas pontas, a comunicação pode parecer estar acontecendo dentro de um mesmo domínio Layer 2, apesar de existir uma rede MPLS entre eles.

---

# 🔍 Verificação

## OSPF

```routeros
/routing ospf neighbor print
```

Deve existir adjacência entre:

```text
P ↔ PE1
P ↔ PE2
```

---

## LDP

```routeros
/mpls ldp neighbor print
```

Esperamos:

```text
P ↔ PE1
P ↔ PE2
```

---

## Interfaces MPLS

```routeros
/mpls interface print
```

---

## VPLS

```routeros
/interface vpls print
```

---

## Bridge

```routeros
/interface bridge port print
```

---

# 🧠 Ordem de funcionamento

Uma maneira fácil de memorizar:

```text
1. OSPF
   ↓
   Descobre a topologia IP

2. LDP
   ↓
   Distribui labels

3. MPLS
   ↓
   Cria o transporte baseado em labels

4. VPLS
   ↓
   Cria o serviço Ethernet virtual

5. Bridge
   ↓
   Conecta o VPLS ao segmento local
```

---

# 📌 Resumo dos equipamentos

| Equipamento | Função                              |
| ----------- | ----------------------------------- |
| `P`         | Core/Provider Router                |
| `PE1`       | Provider Edge                       |
| `PE2`       | Provider Edge                       |
| OSPF        | IGP                                 |
| LDP         | Distribuição de labels              |
| MPLS        | Transporte                          |
| VPLS        | Serviço Layer 2                     |
| Bridge      | Conecta o VPLS ao segmento Ethernet |

---

# 🧠 Para memorizar

> **OSPF fornece a conectividade, LDP distribui as labels, MPLS transporta os dados e VPLS entrega um serviço Ethernet Layer 2 entre os PE.**

O ponto mais importante deste laboratório é:

```text
             PE1
              │
           VPLS
              │
             MPLS
              │
              P
              │
             MPLS
              │
           VPLS
              │
             PE2
```

O **P não precisa conhecer o serviço Ethernet do cliente**. Ele atua principalmente como parte do **core MPLS**, enquanto os **PEs são responsáveis pelos endpoints do serviço VPLS**.
