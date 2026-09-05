# Trabalhando com OSPF Avançado

O **OSPF (Open Shortest Path First)** permite dividir uma rede em diferentes **áreas**, reduzindo o tamanho da LSDB e limitando a propagação de informações de roteamento.

Neste cenário será utilizado **OSPFv2** com:

```text
Area 0.0.0.0 → Backbone
Area 0.0.0.1 → Área 1
Area 0.0.0.2 → Área 2
```

---

# Topologia

```text
                         INTERNET
                            │
                         [ WEB ]
                            │
                       50.50.50.0/30
                            │
                       50.50.50.1
                           [R2]
                    1.0.0.1/32
                     /          \
                    /            \
             AREA 0               AREA 1
          172.30.0.0/30       172.30.1.0/30
                │                   │
             [R3]                [R4]
          1.0.0.2/32          1.0.1.1/32
                │
          172.30.2.0/30
                │
             [R5]
          1.0.2.1/32
                │
         192.168.20.0/25
```

Uma organização válida para as áreas é:

```text
R2 ↔ R3 → Area 0
R2 ↔ R4 → Area 1
R3 ↔ R5 → Area 2
```

Assim:

```text
                 AREA 0
              ┌──────────┐
              │          │
             R2          R3
              │          │
          AREA 1       AREA 2
              │          │
             R4          R5
```

R2 e R3 são **ABRs (Area Border Routers)** porque possuem interfaces em mais de uma área.

---

# Conceitos importantes

## Router ID

Cada roteador possui um identificador único dentro do domínio OSPF:

```text
R2 → 1.0.0.1
R3 → 1.0.0.2
R4 → 1.0.1.1
R5 → 1.0.2.1
```

Esses valores são utilizados como **Router ID**, não precisam necessariamente ser endereços roteáveis.

Uma prática comum é utilizar um endereço de loopback `/32` como Router ID.

---

# R2

## Interfaces

```bash id="m2w6jy"
# Loopback
/interface bridge
add name=lo0

/ip address
add address=1.0.0.1/32 interface=lo0

# Link com Web
/ip address
add address=50.50.50.2/30 interface=ether1

# Link com R3
/ip address
add address=172.30.0.1/30 interface=ether2

# Link com R4
/ip address
add address=172.30.1.1/30 interface=ether3
```

> O loopback é usado como Router ID. Se também quiser anunciá-lo pelo OSPF, ele precisa ser incluído em uma `interface-template` ou anunciado por outro mecanismo apropriado.

---

## Rota para a Internet

```bash id="6v4e4z"
/ip route
add dst-address=0.0.0.0/0 gateway=50.50.50.1
```

Essa rota permite que R2 encaminhe tráfego desconhecido para o Web/ISP.

---

## Router ID

```bash id="tq4h9w"
/routing id
add disabled=no name=1.0.0.1 id=1.0.0.1 select-dynamic-id=any
```

---

## OSPF

### Instância

```bash id="9r9vqb"
/routing ospf instance
add name=instance-0 router-id=1.0.0.1 version=2
```

### Áreas

```bash id="n2eh8w"
/routing ospf area
add area-id=0.0.0.0 instance=instance-0 name=backbone

/routing ospf area
add area-id=0.0.0.1 instance=instance-0 name=local-1
```

### Interfaces OSPF

Link R2 ↔ R3:

```bash id="2bq3ad"
/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=172.30.0.0/30
```

Link R2 ↔ R4:

```bash id="3n3d7w"
/routing ospf interface-template
add area=local-1 \
    instance-id=instance-0 \
    networks=172.30.1.0/30
```

Portanto:

```text
R2
├── 172.30.0.0/30 → Area 0
└── 172.30.1.0/30 → Area 1
```

R2 é um:

> **ABR — Area Border Router**

---

# R3

## Interfaces

```bash id="j3g5q4"
/interface bridge
add name=lo0

/ip address
add address=1.0.0.2/32 interface=lo0

/ip address
add address=172.30.0.2/30 interface=ether1

/ip address
add address=172.30.2.1/30 interface=ether2
```

---

## Router ID

```bash id="k7q1p2"
/routing id
add disabled=no name=1.0.0.2 id=1.0.0.2 select-dynamic-id=any
```

---

## OSPF

```bash id="v1f0p6"
/routing ospf instance
add name=instance-0 router-id=1.0.0.2 version=2
```

Áreas:

```bash id="g3w8x4"
/routing ospf area
add area-id=0.0.0.0 instance=instance-0 name=backbone

/routing ospf area
add area-id=0.0.0.2 instance=instance-0 name=local-2
```

Interfaces:

### R3 ↔ R2

```bash id="j8s4q1"
/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=172.30.0.0/30
```

### R3 ↔ R5

```bash id="x5d8m2"
/routing ospf interface-template
add area=local-2 \
    instance-id=instance-0 \
    networks=172.30.2.0/30
```

R3 também é um:

> **ABR — Area Border Router**

Porque conecta:

```text
Area 0
  │
 R3
  │
Area 2
```

---

# R4

R4 pertence à **Area 1**.

## Interfaces

```bash id="b6f3p8"
/interface bridge
add name=lo0

/ip address
add address=1.0.1.1/32 interface=lo0

/ip address
add address=172.30.1.2/30 interface=ether1

/ip address
add address=192.168.10.1/25 interface=ether2

/ip address
add address=192.168.10.129/25 interface=ether3
```

Redes locais:

```text
192.168.10.0/25
192.168.10.128/25
```

---

## Router ID

```bash id="k8r2n5"
/routing id
add disabled=no name=1.0.1.1 id=1.0.1.1 select-dynamic-id=any
```

---

## OSPF

```bash id="m7c1q9"
/routing ospf instance
add name=instance-0 router-id=1.0.1.1 version=2
```

Área:

```bash id="p4w6z3"
/routing ospf area
add area-id=0.0.0.1 instance=instance-0 name=local-1
```

Interfaces:

```bash id="h9s2v7"
/routing ospf interface-template
add area=local-1 \
    instance-id=instance-0 \
    networks=172.30.1.0/30,192.168.10.0/25,192.168.10.128/25
```

Assim:

```text
R4
│
├── 172.30.1.0/30
├── 192.168.10.0/25
└── 192.168.10.128/25

          ↓

       AREA 1
```

---

# R5

R5 pertence à **Area 2**.

## Interfaces

```bash id="w4p8n2"
/interface bridge
add name=lo0

/ip address
add address=1.0.2.1/32 interface=lo0

/ip address
add address=172.30.2.2/30 interface=ether1

/ip address
add address=192.168.20.1/25 interface=ether2
```

---

## Router ID

```bash id="q2v7m4"
/routing id
add disabled=no name=1.0.2.1 id=1.0.2.1 select-dynamic-id=any
```

---

## OSPF

```bash id="c8n1r6"
/routing ospf instance
add name=instance-0 router-id=1.0.2.1 version=2
```

Área:

```bash id="z5k3p9"
/routing ospf area
add area-id=0.0.0.2 instance=instance-0 name=local-2
```

Interfaces:

```bash id="r6y2w8"
/routing ospf interface-template
add area=local-2 \
    instance-id=instance-0 \
    networks=172.30.2.0/30,192.168.20.0/25
```

---

# ⚠️ Correção importante da configuração original

Na configuração enviada havia, por exemplo, em R3:

```bash
/routing ospf area
add area-id=0.0.0.1 ...
```

mas depois:

```bash
/routing ospf interface-template
add area=backbone ...
```

Isso é inconsistente porque `backbone` precisa representar a **Area 0**, enquanto a única área criada era `0.0.0.1`.

O mesmo problema aparecia em R4 e R5.

A regra é:

```text
area=backbone
       ↓
area-id=0.0.0.0
```

e:

```text
area=local-1
       ↓
area-id=0.0.0.1
```

```text
area=local-2
       ↓
area-id=0.0.0.2
```

---

# Por que a Area 0 é importante?

Em um OSPF multiárea tradicional, as áreas não devem ficar simplesmente isoladas umas das outras.

A **Area 0 (Backbone)** funciona como núcleo de interconexão.

Neste exemplo:

```text
             AREA 0
          ┌──────────┐
          │          │
         R2          R3
        /              \
       /                \
  AREA 1              AREA 2
     │                    │
    R4                   R5
```

Assim:

```text
R4
 ↓
Area 1
 ↓
R2
 ↓
Area 0
 ↓
R3
 ↓
Area 2
 ↓
R5
```

R2 e R3 funcionam como **ABRs**.

---

# Tipos de roteador OSPF

| Roteador | Função          |
| -------- | --------------- |
| R2       | ABR             |
| R3       | ABR             |
| R4       | Internal Router |
| R5       | Internal Router |

### R2

```text
Area 0 + Area 1
      ↓
     ABR
```

### R3

```text
Area 0 + Area 2
      ↓
     ABR
```

### R4

```text
Somente Area 1
      ↓
Internal Router
```

### R5

```text
Somente Area 2
      ↓
Internal Router
```

---

# Loopback e Router ID

Os endereços:

```text
R2 → 1.0.0.1/32
R3 → 1.0.0.2/32
R4 → 1.0.1.1/32
R5 → 1.0.2.1/32
```

podem ser utilizados como Router ID.

Entretanto, configurar o Router ID **não significa automaticamente que a rede `/32` será anunciada pelo OSPF**.

Se quiser anunciar os loopbacks, inclua-os em uma `interface-template`, por exemplo:

```bash
/routing ospf interface-template
add area=local-1 \
    instance-id=instance-0 \
    networks=1.0.1.1/32
```

Isso é diferente de simplesmente utilizar `1.0.1.1` como Router ID.

---

# Verificação

Depois da configuração, alguns comandos úteis são:

```bash
/routing ospf neighbor print
```

Ver vizinhos OSPF.

```bash
/routing ospf interface print
```

Ver interfaces OSPF.

```bash
/routing ospf route print
```

Ver rotas aprendidas pelo OSPF.

```bash
/ip route print
```

Verificar as rotas instaladas na tabela de roteamento.

---

# Fluxo do OSPF

```text
Interface
    │
    ↓
OSPF Interface Template
    │
    ↓
Area
    │
    ↓
OSPF Instance
    │
    ↓
Router ID
    │
    ↓
Formação de vizinhança
    │
    ↓
Troca de LSAs
    │
    ↓
LSDB
    │
    ↓
SPF
    │
    ↓
Rotas OSPF
```

---

# 🧠 Para memorizar

```text
Router ID
    ↓
identifica o roteador

Area 0
    ↓
Backbone

ABR
    ↓
conecta áreas diferentes

LSA
    ↓
informação de estado do link

LSDB
    ↓
banco de dados da topologia

SPF
    ↓
calcula o melhor caminho
```

### Estrutura deste laboratório

```text
                  AREA 0
              ┌────────────┐
              │            │
             R2            R3
            /                \
           /                  \
       AREA 1               AREA 2
          │                     │
         R4                    R5
```

```text
R2 = ABR → Area 0 + Area 1
R3 = ABR → Area 0 + Area 2
R4 = Internal Router → Area 1
R5 = Internal Router → Area 2
```

> **Regra de ouro:** em OSPF multiárea, pense na **Area 0 como o backbone** e nos **ABRs como os roteadores que fazem a ligação entre o backbone e as demais áreas**.
