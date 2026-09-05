# Trabalhando OSPF com Filtros

Os **filtros de roteamento** do MikroTik podem ser utilizados junto ao OSPF para controlar quais rotas serão:

* anunciadas;
* aceitas;
* redistribuídas;
* modificadas antes de entrarem na tabela de roteamento.

Neste laboratório temos quatro roteadores utilizando **OSPFv2** em uma única área:

```text
Area 0.0.0.0 → Backbone
```

---

# Topologia

Com base nos endereços configurados:

```text
                     R1
              192.168.100.251/32
                 /           \
                /             \
               /               \
             R2                 R3
              \                 /
               \               /
                \             /
                     R4
```

Os enlaces são:

```text
R1 ↔ R2
192.168.100.0/30

R1 ↔ R3
192.168.100.0/30

R2 ↔ R3
192.168.100.16/30

R2 ↔ R4
192.168.100.12/30

R3 ↔ R4
192.168.100.8/30
```

> **Atenção:** alguns desses enlaces estão dentro do mesmo bloco `192.168.100.0/24`, mas cada `/30` representa uma sub-rede diferente.

---

# Endereçamento

| Roteador | Loopback             | Interface           | Rede                |
| -------- | -------------------- | ------------------- | ------------------- |
| R1       | `192.168.100.251/32` | `192.168.100.1/30`  | `192.168.100.0/30`  |
| R1       | —                    | `192.168.100.5/30`  | `192.168.100.4/30`  |
| R2       | `192.168.100.252/32` | `192.168.100.6/30`  | `192.168.100.4/30`  |
| R2       | —                    | `192.168.100.13/30` | `192.168.100.12/30` |
| R2       | —                    | `192.168.100.17/30` | `192.168.100.16/30` |
| R3       | `192.168.100.253/32` | `192.168.100.3/30`  | `192.168.100.0/30`  |
| R3       | —                    | `192.168.100.9/30`  | `192.168.100.8/30`  |
| R3       | —                    | `192.168.100.18/30` | `192.168.100.16/30` |
| R4       | `192.168.100.254/32` | `192.168.100.10/30` | `192.168.100.8/30`  |
| R4       | —                    | `192.168.100.14/30` | `192.168.100.12/30` |

---

# R1

## Loopback e interfaces

```bash id="1q6x8p"
/interface bridge
add name=lo0

/ip address
add address=192.168.100.251/32 interface=lo0
add address=192.168.100.1/30 interface=ether1
add address=192.168.100.5/30 interface=ether2
```

## Router ID

```bash id="5n2w7c"
/routing id
add disabled=no \
    name=192.168.100.251 \
    id=192.168.100.251 \
    select-dynamic-id=any
```

## OSPF

```bash id="7v4m1z"
/routing ospf instance
add name=instance-0 \
    router-id=192.168.100.251 \
    version=2
```

Área:

```bash id="9s6k2p"
/routing ospf area
add area-id=0.0.0.0 \
    instance=instance-0 \
    name=backbone
```

Template:

```bash id="2d8x5r"
/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=192.168.0.0/16
```

---

# R2

```bash id="3m7q9a"
/interface bridge
add name=lo0

/ip address
add address=192.168.100.252/32 interface=lo0
add address=192.168.100.6/30 interface=ether1
add address=192.168.100.13/30 interface=ether2
add address=192.168.100.17/30 interface=ether3
```

Router ID:

```bash id="6p2z4k"
/routing id
add disabled=no \
    name=192.168.100.252 \
    id=192.168.100.252 \
    select-dynamic-id=any
```

OSPF:

```bash id="8c5n1w"
/routing ospf instance
add name=instance-0 \
    router-id=192.168.100.252 \
    version=2

/routing ospf area
add area-id=0.0.0.0 \
    instance=instance-0 \
    name=backbone

/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=192.168.0.0/16
```

---

# R3

```bash id="4r8v2m"
/interface bridge
add name=lo0

/ip address
add address=192.168.100.253/32 interface=lo0
add address=192.168.100.3/30 interface=ether1
add address=192.168.100.9/30 interface=ether2
add address=192.168.100.18/30 interface=ether3
```

Router ID:

```bash id="7k3p9d"
/routing id
add disabled=no \
    name=192.168.100.253 \
    id=192.168.100.253 \
    select-dynamic-id=any
```

OSPF:

```bash id="5x1n8q"
/routing ospf instance
add name=instance-0 \
    router-id=192.168.100.253 \
    version=2

/routing ospf area
add area-id=0.0.0.0 \
    instance=instance-0 \
    name=backbone

/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=192.168.0.0/16
```

---

# R4

```bash id="2m6v9x"
/interface bridge
add name=lo0

/ip address
add address=192.168.100.254/32 interface=lo0
add address=192.168.100.10/30 interface=ether1
add address=192.168.100.14/30 interface=ether2
```

Router ID:

```bash id="9q4k7b"
/routing id
add disabled=no \
    name=192.168.100.254 \
    id=192.168.100.254 \
    select-dynamic-id=any
```

OSPF:

```bash id="6w2c8m"
/routing ospf instance
add name=instance-0 \
    router-id=192.168.100.254 \
    version=2

/routing ospf area
add area-id=0.0.0.0 \
    instance=instance-0 \
    name=backbone

/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=192.168.0.0/16
```

---

# OSPF Interface Template

O comando:

```bash id="1v8n3p"
/routing ospf interface-template
add area=backbone \
    instance-id=instance-0 \
    networks=192.168.0.0/16
```

faz o template corresponder às interfaces/endereço dentro desse prefixo.

Por isso, o OSPF poderá utilizar as interfaces que possuem endereços como:

```text
192.168.100.1/30
192.168.100.3/30
192.168.100.5/30
192.168.100.6/30
...
```

Uma abordagem mais específica também é possível, utilizando os prefixos exatos de cada enlace.

---

# Onde entram os filtros?

Depois que a vizinhança OSPF estiver estabelecida, podemos utilizar filtros para controlar as rotas.

Conceitualmente:

```text
              OSPF
                │
                ↓
        ┌───────────────┐
        │ Routing Filter│
        └───────┬───────┘
                │
       ┌────────┴────────┐
       ↓                 ↓
     ACCEPT             REJECT
       │                 │
       ↓                 ↓
   Instala/          Descarta/
   anuncia rota      não anuncia
```

Os filtros podem ser usados em diferentes pontos do processo de roteamento.

---

# Exemplo conceitual

Suponha que R1 possua:

```text
192.168.50.0/24
192.168.60.0/24
192.168.70.0/24
```

e queremos permitir somente:

```text
192.168.50.0/24
```

Um filtro pode utilizar a rede como critério:

```text
192.168.50.0/24 → ACCEPT
192.168.60.0/24 → REJECT
192.168.70.0/24 → REJECT
```

Fluxo:

```text
                    R1
                     │
                  Rotas
                     │
                     ↓
                OSPF Filter
                     │
          ┌──────────┼──────────┐
          ↓          ↓          ↓
       50/24       60/24      70/24
          │          │          │
       ACCEPT      REJECT     REJECT
          │
          ↓
       OSPF
```

---

# Filtros × OSPF

É importante diferenciar:

### Filtro de entrada

Controla rotas recebidas pelo roteador.

```text
Vizinho OSPF
     ↓
   Rotas
     ↓
  IN-FILTER
     ↓
Tabela de roteamento
```

### Filtro de saída

Controla rotas que serão anunciadas.

```text
Tabela de roteamento
       ↓
   OUT-FILTER
       ↓
    OSPF
       ↓
 Vizinho
```

---

# 🧠 Para memorizar

```text
IN
 ↓
"Posso aceitar essa rota?"

OUT
 ↓
"Posso anunciar essa rota?"
```

Ou:

```text
             ROTEADOR
                 │
       ┌─────────┴─────────┐
       ↓                   ↓
     INPUT                OUTPUT
       │                   │
       ↓                   ↓
  rotas recebidas     rotas anunciadas
```

### Estrutura do laboratório

```text
R1 ───── R2
│      ╱ │
│    ╱   │
R3 ───── R4

Todos:
    ↓
OSPFv2
    ↓
Area 0
    ↓
Backbone
```

> **Ideia principal:** o OSPF determina as rotas com base no estado da topologia; os **routing filters** permitem aplicar políticas sobre quais rotas podem ser aceitas, anunciadas ou modificadas.
