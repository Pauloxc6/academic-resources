# 06 — QoS com DSCP, Mangle e Queue Tree

Nesta etapa vamos utilizar recursos de **QoS (Quality of Service)** no PE1 para classificar e controlar o tráfego.

O fluxo utilizado será:

```text
Tráfego
   │
   ▼
DSCP
   │
   ▼
Mangle
   │
   ├── Packet Mark
   │
   └── Priority
   │
   ▼
Queue Tree
   │
   ▼
PCQ / PFIFO
   │
   ▼
Tráfego controlado
```

A ideia é utilizar o campo **DSCP** para identificar determinado tráfego e posteriormente aplicar tratamento diferenciado através de filas.

---

# 🧠 DSCP

**DSCP (Differentiated Services Code Point)** é um campo utilizado para classificar pacotes IP de acordo com o tratamento que devem receber.

Neste laboratório utilizamos:

```text
DSCP = 46
```

O valor decimal `46` corresponde ao **EF (Expedited Forwarding)**, tradicionalmente associado a tráfego que necessita de baixa latência, como VoIP.

Neste laboratório, entretanto, ele está sendo utilizado simplesmente como uma **classe de teste/QoS**.

---

# 1. Marcando o tráfego com DSCP

```routeros
/ip firewall mangle
add chain=prerouting \
    dst-address=172.0.0.2 \
    action=change-dscp \
    new-dscp=46 \
    passthrough=yes \
    comment="INPUT"
```

Essa regra procura pacotes destinados a:

```text
172.0.0.2
```

e altera o DSCP para:

```text
46
```

### Fluxo

```text
Pacote
  │
  ├── destino = 172.0.0.2
  │
  ▼
DSCP = 46
```

### Parâmetros

| Parâmetro               | Função                                           |
| ----------------------- | ------------------------------------------------ |
| `chain=prerouting`      | Processa o pacote antes da decisão de roteamento |
| `dst-address=172.0.0.2` | Seleciona o destino                              |
| `action=change-dscp`    | Altera o campo DSCP                              |
| `new-dscp=46`           | Novo valor do DSCP                               |
| `passthrough=yes`       | Permite continuar o processamento no Mangle      |

---

# 2. Criando uma marca de pacote

Depois de definir o DSCP, podemos procurar os pacotes que possuem:

```text
DSCP = 46
```

```routeros
add chain=prerouting \
    dscp=46 \
    action=mark-packet \
    new-packet-mark=Teste \
    passthrough=yes
```

Agora os pacotes são identificados com:

```text
packet-mark=Teste
```

O fluxo fica:

```text
Destino 172.0.0.2
       │
       ▼
   DSCP = 46
       │
       ▼
packet-mark = Teste
```

---

# 3. Convertendo DSCP em prioridade

```routeros
add chain=prerouting \
    packet-mark=Teste \
    action=set-priority \
    new-priority=from-dscp-high-3-bits \
    passthrough=yes \
    comment="OUTPUT"
```

Essa regra utiliza os **3 bits mais significativos do DSCP** para determinar a prioridade interna do pacote.

```text
DSCP
┌──────────────┐
│ 6 bits       │
└──────────────┘
       │
       ▼
3 bits superiores
       │
       ▼
Priority
```

Isso permite transformar a classificação DSCP em uma prioridade utilizada pelo processamento/filas do RouterOS.

> ⚠️ `new-priority` não é a mesma coisa que `priority=1` de uma Queue Tree. São mecanismos diferentes. A prioridade da fila define a preferência entre filas concorrentes, enquanto `set-priority` altera a prioridade interna associada ao pacote.

---

# 4. Classificando os pacotes externos

```routeros
add chain=prerouting \
    priority=5 \
    action=mark-packet \
    new-packet-mark=Pacote-EXT \
    passthrough=yes
```

Pacotes que possuem:

```text
priority=5
```

recebem:

```text
packet-mark=Pacote-EXT
```

Assim:

```text
DSCP
 │
 ▼
Packet Mark
 │
 ▼
Priority
 │
 ▼
Pacote-EXT
```

> ⚠️ Essa regra depende da prioridade que estiver sendo atribuída anteriormente. Como o laboratório usa `set-priority`, é importante verificar os valores efetivamente produzidos para não classificar tráfego inesperado.

---

# 📦 Resultado do Mangle

Podemos visualizar a lógica como:

```text
              Destino 172.0.0.2
                       │
                       ▼
                  DSCP = 46
                       │
                       ▼
                Mark = Teste
                       │
                       ▼
              Set Priority
                       │
                       ▼
                 Priority = 5
                       │
                       ▼
             Mark = Pacote-EXT
```

---

# 5. Queue Type — PCQ

Agora criamos um tipo de fila baseado em **PCQ**.

```routeros
/queue type
add name=Teste \
    kind=pcq \
    pcq-classifier=dst-address \
    pcq-dst-address6-mask=64 \
    pcq-rate=200k \
    pcq-src-address6-mask=64
```

## PCQ

**PCQ (Per Connection Queue)** é um mecanismo que pode criar subfilas dinamicamente de acordo com um classificador.

Neste caso:

```text
pcq-classifier=dst-address
```

significa que a separação é feita com base no **endereço IP de destino**.

---

## `pcq-rate`

```text
pcq-rate=200k
```

Define a taxa associada a cada subfila PCQ.

Neste laboratório:

```text
200 kbit/s
```

é o limite utilizado para cada classe/subfila criada pelo PCQ, conforme a classificação.

---

## Máscaras IPv6

```text
pcq-dst-address6-mask=64
pcq-src-address6-mask=64
```

Esses parâmetros definem como endereços IPv6 serão agrupados pelo PCQ.

Como o classificador utilizado é:

```text
dst-address
```

a parte mais relevante neste exemplo é:

```text
pcq-dst-address6-mask=64
```

Para IPv4, a classificação utiliza o endereço IPv4 normalmente.

---

# 6. Queue Type — PFIFO

Também criamos uma fila PFIFO:

```routeros
add name=PFIFO \
    kind=pfifo \
    pfifo-limit=10
```

**PFIFO (Packet First In, First Out)** trabalha de forma simples:

```text
Primeiro pacote que entra
          ↓
Primeiro pacote que sai
```

O:

```text
pfifo-limit=10
```

define o limite da fila em quantidade de pacotes.

---

# 7. Queue Tree — INPUT

Criamos uma árvore para o tráfego de entrada:

```routeros
/queue tree
add name=INPUT \
    parent=ether1 \
    limit-at=500k \
    max-limit=500k \
    queue=default
```

Aqui:

```text
ether1
  │
  ▼
INPUT
  │
  ├── CE1
  └── INPUT-default
```

A fila possui:

```text
limit-at=500k
max-limit=500k
```

Ou seja, o limite garantido e o limite máximo configurados para essa fila são ambos de:

```text
500 kbit/s
```

---

# 8. Fila específica para CE1

```routeros
add name=CE1 \
    parent=INPUT \
    packet-mark=Pacote-EXT \
    priority=1 \
    queue=Teste \
    limit-at=200k \
    max-limit=200k
```

Essa fila recebe somente pacotes marcados como:

```text
Pacote-EXT
```

e utiliza o tipo:

```text
Teste
```

que foi configurado como PCQ.

### Parâmetros importantes

```text
packet-mark=Pacote-EXT
```

Seleciona os pacotes classificados pelo Mangle.

```text
priority=1
```

Define prioridade alta para essa fila.

No Queue Tree, normalmente:

```text
1 = maior prioridade
8 = menor prioridade
```

```text
limit-at=200k
```

Define a taxa garantida, considerando as regras e a concorrência entre filas.

```text
max-limit=200k
```

Define o limite máximo da fila.

---

# 9. Tráfego restante do INPUT

```routeros
add name=INPUT-default \
    parent=INPUT \
    max-limit=500k \
    queue=PFIFO
```

Essa fila recebe o tráfego que não foi direcionado para uma fila específica.

Utiliza:

```text
queue=PFIFO
```

---

# 10. Queue Tree — OUTPUT

Agora fazemos estrutura semelhante para o tráfego de saída:

```routeros
add name=OUTPUT \
    parent=ether3 \
    limit-at=500k \
    max-limit=500k \
    queue=default
```

Estrutura:

```text
ether3
  │
  ▼
OUTPUT
  │
  ├── CE2
  └── OUTPUT-DEFAULT
```

---

# 11. Fila específica para CE2

```routeros
add name=CE2 \
    parent=OUTPUT \
    packet-mark=Pacote-EXT \
    priority=1 \
    queue=Teste \
    limit-at=200k \
    max-limit=200k
```

Novamente, somente os pacotes com:

```text
packet-mark=Pacote-EXT
```

serão classificados nessa fila.

A fila utiliza PCQ:

```text
queue=Teste
```

com:

```text
pcq-rate=200k
```

---

# 12. Tráfego restante do OUTPUT

```routeros
add name=OUTPUT-DEFAULT \
    parent=OUTPUT \
    queue=PFIFO \
    max-limit=500k
```

O restante do tráfego utiliza:

```text
PFIFO
```

---

# 🗺️ Estrutura final

```text
                         PE1
                          │
             ┌────────────┴────────────┐
             │                         │
          ether1                    ether3
             │                         │
             ▼                         ▼
           INPUT                    OUTPUT
             │                         │
       ┌─────┴─────┐             ┌─────┴─────┐
       │           │             │           │
      CE1       DEFAULT          CE2       DEFAULT
       │           │             │           │
     PCQ          PFIFO          PCQ        PFIFO
       │                         │
    200k                       200k
```

---

# 🔄 Fluxo completo

```text
                    MANGLE
                       │
                       ▼
              ┌────────────────┐
              │ Identifica      │
              │ destino         │
              └───────┬────────┘
                      │
                      ▼
                 DSCP = 46
                      │
                      ▼
              packet-mark=Teste
                      │
                      ▼
                 set-priority
                      │
                      ▼
             priority = 5
                      │
                      ▼
           packet-mark=Pacote-EXT
                      │
                      ▼
                  QUEUE TREE
                      │
             ┌────────┴────────┐
             ▼                 ▼
           INPUT             OUTPUT
             │                 │
             ▼                 ▼
            CE1               CE2
             │                 │
             ▼                 ▼
            PCQ               PCQ
```

---

# ⚠️ Observações importantes

## `packet-mark` não limita velocidade sozinho

O Mangle apenas classifica:

```text
Mangle
  ↓
packet-mark
```

Quem efetivamente aplica o controle de tráfego é a fila:

```text
Queue Tree
  ↓
limitação/priorização
```

---

## `priority=1` não significa 200 kbit/s

São conceitos diferentes:

```text
priority=1
     ↓
Preferência da fila

max-limit=200k
     ↓
Limite máximo da fila
```

---

## PCQ também não significa simplesmente "limitar a 200k"

Com:

```text
pcq-rate=200k
```

o PCQ pode criar subfilas e aplicar essa taxa conforme o classificador.

Neste caso:

```text
pcq-classifier=dst-address
```

faz a separação por endereço de destino.

---

# 🧠 Para memorizar

```text
DSCP
 ↓
Classificação QoS

Mangle
 ↓
Marca o pacote

Packet Mark
 ↓
Identifica o tráfego

Queue Tree
 ↓
Organiza o tráfego

PCQ
 ↓
Divide em subfilas

PFIFO
 ↓
Fila simples FIFO
```

A lógica principal desta etapa é:

> **Classificar o tráfego com DSCP/Mangle e depois utilizar Queue Tree para aplicar prioridade e controle de banda.**
