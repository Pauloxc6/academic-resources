# 07 — Trabalhando com estado de conexão

O MikroTik possui um mecanismo chamado **Connection Tracking**, que permite acompanhar o estado das conexões que passam pelo roteador.

Isso possibilita criar regras de firewall baseadas no estado da conexão, em vez de analisar cada pacote isoladamente.

As regras são normalmente utilizadas com:

```routeros id="j3f8qa"
/ip/firewall/filter
```

e com o parâmetro:

```routeros id="4h6k2p"
connection-state=
```

---

# 🔄 Estados de conexão

Os principais estados utilizados nas regras de firewall são:

| Estado        | Significado                                   |
| ------------- | --------------------------------------------- |
| `new`         | Nova conexão                                  |
| `established` | Conexão já estabelecida                       |
| `related`     | Conexão relacionada a outra existente         |
| `invalid`     | Pacote que não corresponde a um estado válido |

---

# 🟢 Established

A regra:

```routeros id="8x2k4m"
/ip/firewall/filter
add chain=forward \
    action=accept \
    connection-state=established \
    dst-address-list=list-permitidos-1 \
    comment="Permite conexões estabelecidas"
```

permite pacotes pertencentes a uma conexão que já foi estabelecida.

Por exemplo:

```text id="c9f7a1"
PC ───────► Internet
     NEW
      │
      ▼
  Conexão estabelecida
      │
      ▼
ESTABLISHED
```

Depois que uma conexão é estabelecida, os pacotes seguintes podem ser identificados pelo Connection Tracking como `established`.

---

# 🔵 Related

A segunda regra:

```routeros id="7p4m2s"
/ip/firewall/filter
add chain=forward \
    action=accept \
    connection-state=related \
    dst-address-list=list-permitidos-1 \
    comment="Permite conexões relacionadas"
```

permite conexões que possuem uma relação conhecida com outra conexão existente.

Um exemplo clássico envolve protocolos que utilizam conexões auxiliares.

```text id="a1c8e3"
Conexão principal
       │
       ▼
ESTABLISHED
       │
       └──────► conexão auxiliar
                    │
                    ▼
                 RELATED
```

`related` não significa simplesmente "outra conexão qualquer". O Connection Tracking precisa conseguir identificar a relação entre as conexões.

---

# 🆕 New

A terceira regra do exemplo é:

```routeros id="v2c6m8"
/ip/firewall/filter
add chain=forward \
    action=accept \
    connection-state=new \
    dst-address=192.168.122.0/24 \
    comment="Permite novas conexões para a rede"
```

Ela permite novas conexões destinadas à rede:

```text id="d7k2p9"
192.168.122.0/24
```

### ⚠️ Correção importante

O exemplo original utiliza:

```routeros id="9m3x7q"
dst-address-list=192.168.122.0/24
```

Isso mistura dois conceitos.

`dst-address-list` espera o **nome de uma Address List**, por exemplo:

```routeros id="b5k8n1"
dst-address-list=list-permitidos-1
```

Já para informar diretamente uma rede IP, utilize:

```routeros id="q4w6e2"
dst-address=192.168.122.0/24
```

Portanto, para o endereço apresentado, a forma correta é:

```routeros id="z8r1v5"
dst-address=192.168.122.0/24
```

---

# 🧠 Como funciona na prática

Imagine um computador:

```text id="p5s7d3"
192.168.122.10
```

tentando acessar um servidor:

```text id="u4x9c1"
192.168.122.20
```

O primeiro pacote de uma conexão pode ser identificado como:

```text id="h2m6k8"
connection-state=new
```

Se a conexão for aceita e estabelecida, os próximos pacotes podem ser classificados como:

```text id="w7q3n9"
connection-state=established
```

Se surgir uma conexão auxiliar relacionada à principal:

```text id="k1d5r8"
connection-state=related
```

---

# 🔥 Estrutura comum de um firewall Stateful

Uma configuração bastante comum começa com:

```routeros id="f3m8q2"
/ip/firewall/filter
add chain=forward connection-state=established,related action=accept \
    comment="Permite conexões estabelecidas e relacionadas"
```

Depois podemos bloquear conexões inválidas:

```routeros id="n6v2s4"
/ip/firewall/filter
add chain=forward connection-state=invalid action=drop \
    comment="Descarta conexões inválidas"
```

E então criar regras específicas para novas conexões.

Por exemplo:

```routeros id="c8j1x5"
/ip/firewall/filter
add chain=forward \
    connection-state=new \
    protocol=tcp \
    dst-port=80,443 \
    action=accept \
    comment="Permite novas conexões HTTP/HTTPS"
```

A lógica fica:

```text id="r5t9b2"
                 PACOTE
                    │
                    ▼
            Connection Tracking
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
       NEW     ESTABLISHED    RELATED
        │           │           │
        ▼           └─────┬─────┘
      regras              │
     específicas          ▼
                       ACCEPT
```

---

# 🚫 Estado `invalid`

O estado `invalid` representa um pacote que não consegue ser associado corretamente a um estado válido de conexão.

Uma regra comum é:

```routeros id="s3h7k1"
/ip/firewall/filter
add chain=forward \
    connection-state=invalid \
    action=drop \
    comment="Descarta conexões inválidas"
```

Isso ajuda a eliminar tráfego que não possui um estado válido para o Connection Tracking.

---

# 📋 Por que usar estados?

Sem Connection Tracking, poderíamos precisar criar muitas regras para lidar separadamente com diferentes tipos de pacotes.

Com estados:

```text id="e4m9c7"
NEW
 │
 ├──► regra específica
 │
 ▼
ESTABLISHED
 │
 └──► regra geral de ACCEPT
```

Isso simplifica bastante o firewall.

Por exemplo:

```routeros id="j6p2w8"
/ip/firewall/filter
add chain=forward connection-state=established,related action=accept
```

Uma única regra pode permitir o retorno de várias conexões já estabelecidas.

---

# 🔁 Exemplo de acesso à Internet

Imagine:

```text id="v8k3n2"
PC
192.168.10.10
      │
      │ NEW
      ▼
  MikroTik
      │
      ▼
  Internet
```

Depois da conexão ser estabelecida:

```text id="a5q7d1"
PC
      │
      │ ESTABLISHED
      ▼
 MikroTik
      │
      ▼
Internet
```

A resposta da Internet também pertence à conexão rastreada:

```text id="m2x9c4"
Internet
    │
    │ ESTABLISHED
    ▼
MikroTik
    │
    ▼
192.168.10.10
```

Isso é especialmente importante em firewalls stateful.

---

# ⚠️ Ordem das regras

Como as regras são processadas em ordem, uma configuração típica pode começar assim:

```text id="q7r3m5"
1. DROP invalid
2. ACCEPT established,related
3. ACCEPT novas conexões necessárias
4. DROP restante
```

Por exemplo:

```routeros id="u1x6k9"
/ip/firewall/filter
add chain=forward connection-state=invalid action=drop \
    comment="DROP invalid"

add chain=forward connection-state=established,related action=accept \
    comment="ACCEPT established/related"

add chain=forward connection-state=new protocol=tcp dst-port=80,443 \
    action=accept \
    comment="ACCEPT HTTP/HTTPS"

add chain=forward action=drop \
    comment="DROP restante"
```

> ⚠️ A ordem exata depende da política do firewall e das demais regras. Um `drop` final pode bloquear tráfego legítimo se as exceções necessárias não tiverem sido criadas antes.

---

# 🔍 Verificando o Connection Tracking

As conexões rastreadas podem ser visualizadas com:

```routeros id="p4n8s2"
/ip/firewall/connection/print
```

Também podemos verificar informações relacionadas ao firewall:

```routeros id="c6w1z9"
/ip/firewall/filter/print stats
```

Os contadores ajudam a descobrir quais regras estão recebendo tráfego.

---

# 🧩 `address` x `address-list`

É importante não confundir:

### Endereço ou rede diretamente

```routeros id="a9k4v2"
dst-address=192.168.122.0/24
```

### Nome de uma Address List

```routeros id="n7c3x5"
dst-address-list=list-permitidos-1
```

A Address List pode ser criada assim:

```routeros id="r2m8d6"
/ip/firewall/address-list
add list=list-permitidos-1 address=192.168.122.0/24
```

E então utilizada:

```routeros id="w5q1h8"
/ip/firewall/filter
add chain=forward \
    dst-address-list=list-permitidos-1 \
    action=accept
```

---

# 📊 Resumo dos estados

| Estado        | O que representa                            |
| ------------- | ------------------------------------------- |
| `new`         | Primeiros pacotes de uma nova conexão       |
| `established` | Pacotes de uma conexão já estabelecida      |
| `related`     | Conexão relacionada a uma conexão existente |
| `invalid`     | Pacote sem estado válido/reconhecível       |

---

# 🧠 Para memorizar

```text id="k8p4z1"
NEW
 ↓
"É uma nova conexão?"

ESTABLISHED
 ↓
"Essa conexão já existe?"

RELATED
 ↓
"Essa conexão está relacionada a outra existente?"

INVALID
 ↓
"Não consigo associar corretamente esse pacote a uma conexão válida."
```

A regra mais comum para permitir o retorno de conexões é:

```routeros id="m3x7q9"
/ip/firewall/filter
add chain=forward \
    connection-state=established,related \
    action=accept
```

E uma política comum é descartar estados inválidos:

```routeros id="v6n2c8"
/ip/firewall/filter
add chain=forward \
    connection-state=invalid \
    action=drop
```

> **Connection Tracking + Firewall Filter = firewall stateful**

O roteador deixa de analisar cada pacote completamente de forma isolada e passa a considerar **o contexto da conexão**.
