# OSPF com Stub Area

Uma **Stub Area** é uma área OSPF que reduz a quantidade de informações de roteamento externas que precisam ser propagadas para seus roteadores.

Em vez de receber diversas rotas externas individualmente, os roteadores da área podem utilizar uma **rota default** para alcançar destinos externos.

---

# Topologia

Considerando a topologia anterior:

```text
                         INTERNET
                            │
                           WEB
                            │
                           R2
                         /    \
                        /      \
                   AREA 0      AREA 1
                      │           │
                     R3          R4
                      │
                   AREA 2
                      │
                     R5
```

Uma configuração coerente seria:

```text
AREA 0 → Backbone → não stub
AREA 1 → Stub
AREA 2 → Stub
```

Portanto:

```text
             AREA 0
          ┌──────────┐
          │          │
         R2          R3
          │           │
       AREA 1       AREA 2
          │           │
         R4          R5
         STUB        STUB
```

---

# O que é uma Stub Area?

Uma Stub Area evita que determinados tipos de LSAs externos sejam propagados para dentro da área.

Em vez de conhecer individualmente todas as redes externas:

```text
Internet
   │
   ├── Rede A
   ├── Rede B
   ├── Rede C
   ├── Rede D
   └── Rede E
```

o roteador pode utilizar:

```text
0.0.0.0/0
```

para alcançar destinos externos.

```text
Rede interna
     │
     ↓
  Stub Area
     │
     ↓
  0.0.0.0/0
     │
     ↓
   ABR
     │
     ↓
  Internet
```

---

# R2

R2 é o **ABR** entre:

```text
Area 0
Area 1
```

A Area 1 pode ser configurada como Stub.

```bash
/routing ospf area
set [find area-id=0.0.0.1] type=stub
```

A rota default para a Internet continua em R2:

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=50.50.50.1
```

Assim:

```text
R4
 │
 ↓
Area 1
 │
 ↓
R2
 │
 ↓
0.0.0.0/0
 │
 ↓
50.50.50.1
 │
 ↓
Internet
```

> A rota default configurada em R2 é uma rota IP normal. Para que ela seja utilizada pelos roteadores da Stub Area, o OSPF precisa fornecer uma rota default apropriada para a área.

---

# R3

R3 é o ABR entre:

```text
Area 0
Area 2
```

A Area 2 pode ser configurada como Stub:

```bash
/routing ospf area
set [find area-id=0.0.0.2] type=stub
```

A Area 0 permanece como Backbone.

```text
AREA 0
   │
   ↓
  R3
   │
   ↓
AREA 2 — STUB
   │
   ↓
  R5
```

---

# R4

R4 pertence à Area 1.

Não é necessário configurar a Area 0 ou Area 2 nele.

```bash
/routing ospf area
set [find area-id=0.0.0.1] type=stub
```

R4 passa a pertencer a uma área Stub:

```text
R4
 │
 ↓
AREA 1
 │
 ↓
Stub
```

---

# R5

R5 pertence à Area 2.

```bash
/routing ospf area
set [find area-id=0.0.0.2] type=stub
```

Assim:

```text
R5
 │
 ↓
AREA 2
 │
 ↓
Stub
```

---

# ⚠️ Não transforme a Area 0 em Stub

Na configuração original havia:

```bash
routing ospf area set 0 type=stub
```

Isso não é adequado para este cenário.

A Area 0 é o **Backbone Area**:

```text
Area 0.0.0.0
```

Ela é responsável pela interconexão das demais áreas.

O correto é manter:

```text
Area 0 → Backbone
Area 1 → Stub
Area 2 → Stub
```

---

# ⚠️ Todos os roteadores da área devem concordar

Se a Area 1 for Stub:

```text
R2 → Area 1 → Stub
R4 → Area 1 → Stub
```

Os roteadores da mesma área precisam utilizar o mesmo tipo de área.

Da mesma forma para a Area 2:

```text
R3 → Area 2 → Stub
R5 → Area 2 → Stub
```

Não seria coerente ter:

```text
R3 → Area 2 → normal
R5 → Area 2 → stub
```

pois isso pode impedir a formação correta da vizinhança OSPF.

---

# Stub Area e rota default

A principal vantagem da Stub Area é reduzir informações externas.

Imagine que o domínio OSPF tenha:

```text
100.0.0.0/24
100.1.0.0/24
100.2.0.0/24
100.3.0.0/24
...
```

Em uma área normal, várias informações externas podem ser propagadas.

Na Stub Area, o conceito é:

```text
"Se o destino não for conhecido
 dentro da minha área, use o ABR."
```

Representado por:

```text
0.0.0.0/0
```

---

# Stub × Normal

| Característica  | Área Normal  | Stub Area                    |
| --------------- | ------------ | ---------------------------- |
| Backbone        | Pode ser     | Não deve ser                 |
| Rotas internas  | Sim          | Sim                          |
| Rotas interárea | Sim          | Sim                          |
| Rotas externas  | Pode receber | Restritas                    |
| Rota default    | Opcional     | Usada para destinos externos |
| Complexidade    | Maior        | Menor                        |
| LSDB            | Maior        | Pode ser reduzida            |

---

# Tipos relacionados

Além de `stub`, existem outros tipos de áreas especiais:

```text
Normal
  │
  ├── Stub
  │
  ├── Totally Stubby
  │
  ├── NSSA
  │
  └── Totally NSSA
```

### Stub

Bloqueia determinados LSAs externos e utiliza uma rota default.

### Totally Stubby

É ainda mais restritiva, reduzindo também informações interárea, dependendo da implementação.

### NSSA

Permite que uma área tenha características de stub, mas ainda permita a entrada de informações externas originadas dentro da própria área.

---

# 🧠 Para memorizar

```text
AREA 0
   ↓
BACKBONE
   ↓
não transformar em Stub
```

```text
AREA 1
   ↓
STUB
   ↓
R4
```

```text
AREA 2
   ↓
STUB
   ↓
R5
```

### Ideia principal

```text
                 INTERNET
                    │
                    ↓
                   R2
                    │
                 AREA 0
                    │
              ┌─────┴─────┐
              ↓           ↓
          AREA 1       AREA 2
            STUB          STUB
              │           │
              ↓           ↓
             R4           R5
```

A ideia da **Stub Area** é:

> **Reduzir informações externas dentro da área e utilizar uma rota default para alcançar destinos externos.**

```text
Destino externo
      ↓
0.0.0.0/0
      ↓
ABR
      ↓
Área 0
      ↓
Internet
```
