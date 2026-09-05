# Fazendo as Configurações NBMA

Depois de configurar o endereçamento da topologia, o próximo passo é preparar o **OSPFv2** em cada roteador.

Nesta etapa são configurados:

1. **Router ID**
2. **Instância OSPF**
3. **OSPF versão 2**
4. Ativação da instância

A configuração ainda **não define a interface como NBMA nem os vizinhos OSPF**. Essas etapas serão feitas posteriormente.

---

# R1

## Router ID

```bash
/routing id
add name=192.168.1.251 \
    id=192.168.1.251 \
    select-dynamic-id=any
```

## Instância OSPF

```bash
/routing ospf instance
add router-id=192.168.1.251 \
    version=2 \
    disabled=no
```

O R1 utilizará:

```text
Router ID → 192.168.1.251
OSPF     → versão 2
Status   → habilitado
```

---

# R2

## Router ID

```bash
/routing id
add name=192.168.2.252 \
    id=192.168.2.252 \
    select-dynamic-id=any
```

## Instância OSPF

```bash
/routing ospf instance
add router-id=192.168.2.252 \
    version=2 \
    disabled=no
```

Configuração:

```text
Router ID → 192.168.2.252
OSPF     → versão 2
Status   → habilitado
```

---

# R3

## Router ID

```bash
/routing id
add name=192.168.3.253 \
    id=192.168.3.253 \
    select-dynamic-id=any
```

## Instância OSPF

```bash
/routing ospf instance
add router-id=192.168.3.253 \
    version=2 \
    disabled=no
```

Configuração:

```text
Router ID → 192.168.3.253
OSPF     → versão 2
Status   → habilitado
```

---

# R4

## Router ID

```bash
/routing id
add name=192.168.4.254 \
    id=192.168.4.254 \
    select-dynamic-id=any
```

## Instância OSPF

```bash
/routing ospf instance
add router-id=192.168.4.254 \
    version=2 \
    disabled=no
```

Configuração:

```text
Router ID → 192.168.4.254
OSPF     → versão 2
Status   → habilitado
```

---

# Tabela de Router IDs

| Roteador | Router ID       |
| -------- | --------------- |
| R1       | `192.168.1.251` |
| R2       | `192.168.2.252` |
| R3       | `192.168.3.253` |
| R4       | `192.168.4.254` |

Cada roteador possui um **Router ID único**, o que é fundamental para o funcionamento do OSPF.

---

# O que é o Router ID?

O **Router ID** é um identificador de 32 bits utilizado pelo OSPF para identificar unicamente cada roteador dentro do domínio OSPF.

Apesar de possuir o mesmo formato de um endereço IPv4:

```text
192.168.1.251
```

ele **não precisa necessariamente ser um endereço IP utilizado para comunicação**.

Neste laboratório, estamos utilizando os endereços das loopbacks:

```text
R1 → 192.168.1.251/32
R2 → 192.168.2.252/32
R3 → 192.168.3.253/32
R4 → 192.168.4.254/32
```

Isso é uma prática comum porque a loopback tende a permanecer ativa mesmo quando uma interface física específica apresenta problema.

---

# OSPFv2

O parâmetro:

```bash
version=2
```

define que a instância utilizará **OSPFv2**, utilizado para IPv4.

```text
OSPFv2 → IPv4
OSPFv3 → IPv6
```

---

# `disabled=no`

O parâmetro:

```bash
disabled=no
```

mantém a instância OSPF habilitada.

Conceitualmente:

```text
disabled=yes
    ↓
OSPF desabilitado

disabled=no
    ↓
OSPF habilitado
```

---

# Fluxo da configuração

Até aqui temos:

```text
                  R1
          Router ID: .251
                 │
                 │
                 │
        ┌────────┴────────┐
        │                 │
       R2                R3
    Router ID: .252   Router ID: .253
        │                 │
        └────────┬────────┘
                 │
                 R4
          Router ID: .254
```

Porém, **os roteadores ainda não formarão vizinhança OSPF apenas com essa configuração**.

Ainda precisamos configurar:

```text
Router ID
    ↓
Instância OSPF
    ↓
Área
    ↓
Interface-template
    ↓
Tipo de rede NBMA
    ↓
Vizinhos OSPF
    ↓
Adjacências
```

---

# 🧠 Para memorizar

```text
Router ID
   ↓
"Quem sou eu no OSPF?"

Instance
   ↓
"Qual processo OSPF estou utilizando?"

Version
   ↓
"IPv4 ou IPv6?"
```

Neste laboratório:

```text
R1 → 192.168.1.251 → OSPFv2
R2 → 192.168.2.252 → OSPFv2
R3 → 192.168.3.253 → OSPFv2
R4 → 192.168.4.254 → OSPFv2
```

> **Resumo:** nesta etapa cada roteador recebe um Router ID único e uma instância OSPFv2 habilitada. A configuração de NBMA propriamente dita ocorrerá quando definirmos o tipo de rede OSPF e os vizinhos.
