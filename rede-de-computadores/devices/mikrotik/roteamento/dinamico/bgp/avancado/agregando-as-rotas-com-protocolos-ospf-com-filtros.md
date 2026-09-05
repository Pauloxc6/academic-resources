# 🧩 Agregando rotas com OSPF e filtros

Nesta etapa vamos combinar dois recursos:

* **agregação de rotas no OSPF**;
* **filtros de entrada no BGP**.

O objetivo é reduzir a quantidade de prefixos anunciados pelo OSPF e controlar quais rotas BGP serão aceitas.

---

# 📚 Agregação de rotas no OSPF

O OSPF permite utilizar **áreas de sumarização** para representar vários prefixos através de um prefixo maior.

Neste exemplo:

```text id="r8v3m1"
100.100.0.0/24
100.100.1.0/24
       │
       ▼
100.100.0.0/23
```

A rede:

```text
100.100.0.0/23
```

abrange:

```text
100.100.0.0/24
100.100.1.0/24
```

---

# 🖥️ R1

Configuramos a sumarização na área `backbone`:

```bash id="6z1v4n"
/routing ospf area range add \
    area=backbone \
    advertise=yes \
    disabled=no \
    prefix=100.100.0.0/23
```

### Parâmetros

| Parâmetro               | Função                                |
| ----------------------- | ------------------------------------- |
| `area=backbone`         | Área OSPF onde o range será utilizado |
| `advertise=yes`         | Permite anunciar o prefixo sumarizado |
| `disabled=no`           | Mantém a configuração ativa           |
| `prefix=100.100.0.0/23` | Prefixo agregado                      |

A ideia é representar:

```text
100.100.0.0/24
100.100.1.0/24
```

através de:

```text
100.100.0.0/23
```

---

# 🔐 Filtro BGP no R1

Criamos uma cadeia de filtro:

```bash id="b9w0sk"
/routing filter rule add \
    chain=bgp1-201-in \
    disabled=no \
    rule=accept
```

Depois associamos essa cadeia à entrada da conexão BGP:

```bash id="f7k2qa"
/routing bgp connection set 0 \
    input.filter=bgp1-201-in
```

O fluxo fica:

```text
                 R2
                  │
                  │ BGP
                  ▼
             ┌──────────┐
             │  Input   │
             │  Filter  │
             └────┬─────┘
                  │
             accept
                  │
                  ▼
                 R1
```

Nesse exemplo, a regra:

```text
rule=accept
```

aceita as rotas que chegam nessa cadeia.

> ⚠️ Como o filtro contém somente `accept`, ele não está restringindo prefixos específicos. Ele funciona como uma política de aceitação geral. Para realmente filtrar prefixos, seriam necessárias condições, como `if (dst in ...)`.

---

# 🖥️ R2

No R2 fazemos a mesma sumarização:

```bash id="c5r9xe"
/routing ospf area range add \
    area=backbone \
    advertise=yes \
    disabled=no \
    prefix=100.100.0.0/23
```

Assim, o R2 também utiliza:

```text
100.100.0.0/23
```

como prefixo sumarizado.

---

# 🔐 Filtro BGP no R2

Criamos o filtro de entrada:

```bash id="p4x7nm"
/routing filter rule add \
    chain=bgp1-200-in \
    disabled=no \
    rule=accept
```

E associamos à conexão BGP:

```bash id="j2v8qa"
/routing bgp connection set 0 \
    input.filter=bgp1-200-in
```

O nome:

```text
bgp1-200-in
```

indica que o filtro está relacionado à entrada da sessão com o **AS 200**.

No R1:

```text
bgp1-201-in
```

indica a entrada da sessão com o **AS 201**.

---

# 🔄 Visão geral

Podemos representar o laboratório assim:

```text
                 OSPF
        ┌──────────────────┐
        │                  │
        ▼                  ▼
   ┌─────────┐        ┌─────────┐
   │   R1    │        │   R2    │
   │ AS 200  │        │ AS 201  │
   └────┬────┘        └────┬────┘
        │                  │
        └─────── BGP ──────┘
```

No OSPF, temos a sumarização:

```text
100.100.0.0/24
100.100.1.0/24
        │
        ▼
100.100.0.0/23
```

No BGP, temos filtros de entrada:

```text
R2 ──► bgp1-201-in ──► R1

R1 ──► bgp1-200-in ──► R2
```

---

# 🧠 OSPF Area Range

O comando:

```bash
/routing ospf area range add ...
```

é utilizado para configurar um **range de endereços para sumarização dentro de uma área OSPF**.

A ideia geral é:

```text
Vários prefixos
      │
      ▼
 sumarização
      │
      ▼
Um prefixo maior
```

Isso pode reduzir a quantidade de informações de roteamento propagadas entre áreas.

---

# 🔐 Filtros de entrada BGP

O parâmetro:

```text
input.filter=bgp1-201-in
```

define a política utilizada para processar as **rotas recebidas** daquela conexão BGP.

Enquanto:

```text
output.filter-chain=bgp1-out
```

está relacionado às **rotas enviadas**.

Portanto:

```text
INPUT
  ↓
Rotas recebidas
  ↓
Filtro de entrada
  ↓
Tabela BGP


OUTPUT
  ↓
Rotas a anunciar
  ↓
Filtro de saída
  ↓
Vizinho BGP
```

---

# ⚠️ `accept` não significa "filtrar"

É importante entender esta diferença.

Uma cadeia:

```bash
rule=accept
```

basicamente diz:

```text
Recebeu uma rota?
       │
       ▼
    ACCEPT
```

Portanto, sozinha, ela não restringe os anúncios.

Um filtro realmente seletivo poderia, por exemplo, permitir somente:

```text
100.100.0.0/23
```

e rejeitar outros prefixos.

Conceitualmente:

```text
Prefixo recebido
      │
      ▼
É 100.100.0.0/23?
   │          │
  SIM        NÃO
   │          │
   ▼          ▼
ACCEPT       REJECT
```

---

# 🧩 Agregação + BGP

Os dois recursos possuem objetivos diferentes.

### OSPF

```text
Agregação
    ↓
Reduz quantidade de prefixos
    ↓
100.100.0.0/24
100.100.1.0/24
       ↓
100.100.0.0/23
```

### BGP

```text
Filtro
   ↓
Controla rotas recebidas/anunciadas
   ↓
ACCEPT / REJECT
```

Juntos:

```text
                 OSPF
                  │
          Sumarização
                  │
                  ▼
          Prefixo agregado
                  │
                  ▼
                 BGP
                  │
           Filtro de entrada
                  │
                  ▼
             Rota aceita
```

---

# 📋 Configuração completa

## R1

```bash
/routing ospf area range add \
    area=backbone \
    advertise=yes \
    disabled=no \
    prefix=100.100.0.0/23

/routing filter rule add \
    chain=bgp1-201-in \
    disabled=no \
    rule=accept

/routing bgp connection set 0 \
    input.filter=bgp1-201-in
```

## R2

```bash
/routing ospf area range add \
    area=backbone \
    advertise=yes \
    disabled=no \
    prefix=100.100.0.0/23

/routing filter rule add \
    chain=bgp1-200-in \
    disabled=no \
    rule=accept

/routing bgp connection set 0 \
    input.filter=bgp1-200-in
```

---

# 🧠 Para memorizar

```text
OSPF Area Range
        ↓
SUMARIZAÇÃO
        ↓
Vários prefixos → um prefixo maior
```

```text
BGP input.filter
        ↓
FILTRO DE ENTRADA
        ↓
Controla rotas recebidas
```

```text
advertise=yes
        ↓
Permite anunciar o prefixo sumarizado
```

```text
rule=accept
        ↓
Aceita a rota que chegar àquela regra
```

### Resumo final

```text
       OSPF
         │
         │ sumarização
         ▼
   100.100.0.0/23
         │
         │ BGP
         ▼
    Input Filter
         │
    ┌────┴────┐
    │         │
 ACCEPT     REJECT
```
