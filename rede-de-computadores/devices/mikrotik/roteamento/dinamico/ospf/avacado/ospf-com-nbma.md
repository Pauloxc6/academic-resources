# OSPF com NBMA

**NBMA (Non-Broadcast Multi-Access)** é um tipo de rede que permite que vários roteadores compartilhem uma mesma rede IP, porém **não possui broadcast/multicast nativo**.

Em OSPF, isso é importante porque o protocolo normalmente utiliza multicast para descoberta e comunicação entre vizinhos:

```text
224.0.0.5 → AllSPFRouters
224.0.0.6 → AllDRouters
```

Em uma rede NBMA, os vizinhos podem precisar ser **configurados manualmente**, dependendo do modo de operação utilizado.

---

# Topologia

Os quatro roteadores estão conectados à mesma rede:

```text
                  NBMA
             192.168.0.0/29
                    │
       ┌────────────┼────────────┐
       │            │            │
      R1           R2           R3
       │            │            │
       └────────────┼────────────┘
                    │
                   R4
```

Endereçamento:

```text
R1 → 192.168.0.1/29
R2 → 192.168.0.2/29
R3 → 192.168.0.3/29
R4 → 192.168.0.4/29
```

A rede:

```text
192.168.0.0/29
```

possui:

```text
Rede:       192.168.0.0
Hosts:      192.168.0.1 - 192.168.0.6
Broadcast:  192.168.0.7
```

Portanto, os quatro roteadores estão na mesma sub-rede.

---

# R1

## Loopback

```bash
/interface bridge
add name=lo0

/ip address
add address=192.168.1.251/32 interface=lo0
```

## Interface NBMA

```bash
/ip address
add address=192.168.0.1/29 interface=ether1
```

## Rede adicional

```bash
/ip address
add address=192.168.1.1/29 interface=ether2
```

---

# R2

```bash
/interface bridge
add name=lo0

/ip address
add address=192.168.2.252/32 interface=lo0
add address=192.168.0.2/29 interface=ether1
add address=192.168.2.1/29 interface=ether2
```

---

# R3

```bash
/interface bridge
add name=lo0

/ip address
add address=192.168.3.253/32 interface=lo0
add address=192.168.0.3/29 interface=ether1
add address=192.168.3.1/29 interface=ether2
```

---

# R4

```bash
/interface bridge
add name=lo0

/ip address
add address=192.168.4.254/32 interface=lo0
add address=192.168.0.4/29 interface=ether1
add address=192.168.4.1/29 interface=ether2
```

---

# O que é uma rede NBMA?

**NBMA (Non-Broadcast Multi-Access)** é uma rede:

* **Multi-Access:** vários dispositivos podem compartilhar o mesmo segmento lógico;
* **Non-Broadcast:** não existe broadcast/multicast nativo ou ele não é utilizado da mesma forma que em uma rede Ethernet broadcast.

Exemplos clássicos incluem tecnologias como:

* Frame Relay;
* ATM.

Em laboratórios modernos, o conceito também pode ser simulado em determinados ambientes para estudar o comportamento do OSPF.

---

# NBMA × Broadcast

Em uma Ethernet tradicional:

```text
             Ethernet
                │
       ┌────────┼────────┐
       │        │        │
      R1       R2       R3
       │        │        │
       └────────┼────────┘
              Broadcast
```

Os roteadores podem utilizar multicast para descobrir os vizinhos OSPF.

Em NBMA:

```text
                NBMA
                 │
       ┌─────────┼─────────┐
       │         │         │
      R1        R2        R3
       │         │         │
       └───── comunicação ──┘

     descoberta pode precisar
        de configuração
           explícita
```

---

# OSPF e NBMA

O OSPF possui diferentes tipos de rede, entre eles:

```text
Broadcast
NBMA
Point-to-Point
Point-to-Multipoint
```

O tipo de rede influencia diretamente o comportamento da formação de vizinhança.

Em **NBMA**, o OSPF tradicionalmente não pode simplesmente depender do broadcast/multicast para descobrir todos os vizinhos.

Por isso, pode ser necessário informar explicitamente os vizinhos.

---

# DR e BDR

Uma característica importante do OSPF em redes multi-access é a eleição de:

```text
DR  → Designated Router
BDR → Backup Designated Router
```

Em uma rede NBMA tradicional, essa eleição possui algumas particularidades.

Exemplo:

```text
             NBMA
               │
        ┌──────┼──────┐
        │      │      │
       R1     R2     R3
        │
       DR
```

O DR ajuda a reduzir a quantidade de adjacências necessárias em uma rede multi-access.

Sem DR/BDR, todos os roteadores poderiam precisar formar adjacência entre si.

Com quatro roteadores:

```text
R1
├── R2
├── R3
└── R4
```

o modelo com DR/BDR evita uma malha completa de adjacências em determinadas operações de OSPF.

---

# Por que utilizar Loopback?

Cada roteador possui uma interface lógica:

```text
R1 → 192.168.1.251/32
R2 → 192.168.2.252/32
R3 → 192.168.3.253/32
R4 → 192.168.4.254/32
```

Essas interfaces podem ser utilizadas como **Router ID**.

Por exemplo:

```text
R1 → 192.168.1.251
R2 → 192.168.2.252
R3 → 192.168.3.253
R4 → 192.168.4.254
```

Isso fornece um identificador estável para cada roteador.

> A existência da loopback não faz com que ela seja automaticamente anunciada pelo OSPF. Para anunciá-la, ela precisa estar incluída no processo OSPF conforme a configuração utilizada.

---

# Fluxo do OSPF no NBMA

```text
           Interface NBMA
                  │
                  ↓
          Tipo de rede OSPF
                  │
                  ↓
        Descoberta de vizinhos
                  │
                  ↓
       Formação de adjacência
                  │
                  ↓
             DR / BDR
                  │
                  ↓
              LSDB
                  │
                  ↓
                SPF
                  │
                  ↓
          Tabela de roteamento
```

---

# Ponto importante no MikroTik

A configuração dos **endereços IP** acima apenas prepara a topologia.

Ela ainda não configura o OSPF.

Será necessário configurar:

```text
1. Router ID
2. Instância OSPF
3. Área
4. Interface-template
5. Tipo de rede
6. Vizinhos, quando necessário
```

A parte especialmente importante neste laboratório será definir o comportamento da interface como **NBMA** e configurar os vizinhos de acordo com a implementação do RouterOS utilizada.

---

# Verificação inicial

Antes de configurar o OSPF, confira os endereços:

```bash
/ip/address/print
```

Teste a conectividade entre os roteadores:

```bash
/ping 192.168.0.2
/ping 192.168.0.3
/ping 192.168.0.4
```

Por exemplo, no R1:

```text
R1
 │
 ├── ping 192.168.0.2 → R2
 ├── ping 192.168.0.3 → R3
 └── ping 192.168.0.4 → R4
```

Antes de investigar OSPF, todos os vizinhos diretamente conectados à rede NBMA devem possuir conectividade IP.

---

# 🧠 Para memorizar

```text
NBMA
 │
 ├── Non-Broadcast
 └── Multi-Access
```

**Multi-Access:**

```text
vários roteadores
       │
       ↓
mesmo segmento lógico
```

**Non-Broadcast:**

```text
não depende de broadcast
para descobrir os vizinhos
```

### Comparação

| Característica             | Broadcast       | NBMA                            |
| -------------------------- | --------------- | ------------------------------- |
| Multi-access               | Sim             | Sim                             |
| Broadcast                  | Sim             | Não                             |
| Descoberta automática OSPF | Normalmente sim | Pode exigir configuração        |
| DR/BDR                     | Sim             | Sim, no modelo NBMA tradicional |
| Exemplo clássico           | Ethernet        | Frame Relay / ATM               |

---

## Resumo

Neste laboratório:

```text
R1 → 192.168.0.1/29
R2 → 192.168.0.2/29
R3 → 192.168.0.3/29
R4 → 192.168.0.4/29
```

Todos compartilham:

```text
192.168.0.0/29
```

Essa rede será utilizada para estudar o comportamento do **OSPF em uma topologia NBMA**, especialmente:

* descoberta de vizinhos;
* adjacências;
* DR/BDR;
* configuração explícita de vizinhos;
* tipo de rede OSPF;
* propagação de LSAs.
