# ⚖️ Restrição de Banda com PCQ

O **PCQ (Per Connection Queue)** é um tipo de fila utilizado no MikroTik para distribuir uma determinada quantidade de banda entre múltiplos usuários ou conexões.

Ele é muito utilizado para criar uma política como:

```text
Rede LAN
   │
   ├── Cliente 1 → 1 Mbps
   ├── Cliente 2 → 1 Mbps
   ├── Cliente 3 → 1 Mbps
   └── Cliente 4 → 1 Mbps
```

O PCQ pode criar subfilas dinamicamente para distribuir a banda entre os diferentes classificadores.

---

# 1. Marcando as conexões da rede

```routeros
/ip firewall mangle add \
    chain=prerouting \
    action=mark-connection \
    new-connection-mark=Con-Rede \
    passthrough=yes \
    src-address=192.168.100.0/24
```

Essa regra identifica conexões originadas pela rede:

```text
192.168.100.0/24
```

e atribui a elas a marca:

```text
Con-Rede
```

### Fluxo

```text
192.168.100.0/24
        │
        ▼
    PREROUTING
        │
        ▼
 connection-mark
     Con-Rede
```

---

# 2. Marcando os pacotes

Depois, os pacotes pertencentes às conexões marcadas são classificados:

```routeros
/ip firewall mangle add \
    chain=prerouting \
    action=mark-packet \
    new-packet-mark=Pac-Rede \
    passthrough=no \
    connection-mark=Con-Rede
```

Agora temos:

```text
Connection Mark
      │
      ▼
  Con-Rede
      │
      ▼
 Packet Mark
      │
      ▼
  Pac-Rede
```

A marca `Pac-Rede` será utilizada posteriormente pela **Queue Tree**.

---

# 3. Criando o tipo de fila PCQ

```routeros
/queue type add \
    name="queue-pcq" \
    kind=pcq \
    pcq-rate=1M
```

Aqui criamos um tipo de fila chamado:

```text
queue-pcq
```

com:

```text
kind=pcq
```

e:

```text
pcq-rate=1M
```

O `pcq-rate` define a taxa máxima para **cada subfila PCQ**, quando diferente de zero.

Assim, conceitualmente:

```text
PCQ
 │
 ├── Subfila 1 → 1 Mbps
 ├── Subfila 2 → 1 Mbps
 ├── Subfila 3 → 1 Mbps
 └── Subfila 4 → 1 Mbps
```

⚠️ **Mas há um detalhe importante:** para o PCQ separar os usuários/conexões, é necessário definir um `pcq-classifier`.

---

# 4. Classificador do PCQ

Por exemplo, para separar os clientes pelo endereço de origem:

```routeros
/queue type set [find name="queue-pcq"] \
    pcq-classifier=src-address
```

Agora o PCQ cria as subfilas de acordo com o endereço IP de origem.

Por exemplo:

```text
192.168.100.10 ──┐
192.168.100.11 ──┼── PCQ
192.168.100.12 ──┤
192.168.100.13 ──┘
```

Resultado conceitual:

```text
              PCQ
               │
       ┌───────┼────────┐
       │       │        │
       ▼       ▼        ▼
    .10      .11      .12
    1 Mbps   1 Mbps   1 Mbps
```

---

# 5. Criando a Queue Tree

```routeros
/queue tree add \
    name="limitando-rede-LAN" \
    parent=global \
    packet-mark=Pac-Rede \
    queue=queue-pcq \
    max-limit=5M
```

Essa Queue Tree associa:

```text
packet-mark=Pac-Rede
```

ao tipo:

```text
queue=queue-pcq
```

e estabelece:

```text
max-limit=5M
```

como limite máximo da árvore.

---

# 🧮 `pcq-rate` × `max-limit`

Essa é uma das partes mais importantes.

Temos:

```text
pcq-rate = 1 Mbps
max-limit = 5 Mbps
```

Eles possuem funções diferentes.

### `pcq-rate`

Define a taxa máxima de cada subfila:

```text
Cliente 1 → até 1 Mbps
Cliente 2 → até 1 Mbps
Cliente 3 → até 1 Mbps
...
```

### `max-limit`

Limita a banda total disponibilizada pela Queue Tree:

```text
Rede inteira → máximo de 5 Mbps
```

Portanto, se houver cinco clientes ativos:

```text
         TOTAL = 5 Mbps
              │
      ┌───────┼───────┐
      ▼       ▼       ▼
     1M      1M      1M
      │       │       │
   Cliente Cliente Cliente
      1       2       3
```

Os clientes adicionais também ficam sujeitos ao limite global de 5 Mbps.

---

# ⚠️ O `pcq-classifier` é fundamental

Na sua configuração original:

```routeros
/queue type add name="queue-pcq" kind=pcq pcq-rate=1M
```

não foi definido um:

```text
pcq-classifier
```

Sem um classificador adequado, o PCQ **não está necessariamente separando os usuários da forma que você provavelmente pretende**.

Para uma rede LAN, um exemplo comum seria:

```routeros
/queue type add \
    name="queue-pcq" \
    kind=pcq \
    pcq-rate=1M \
    pcq-classifier=src-address
```

Para tráfego no sentido contrário, pode ser necessário considerar `dst-address`, dependendo de como a fila está sendo aplicada.

---

# 🔄 Funcionamento completo

```text
                 REDE LAN
             192.168.100.0/24
                     │
                     ▼
                MANGLE
                     │
                     ▼
              Con-Rede
           Connection Mark
                     │
                     ▼
               Pac-Rede
             Packet Mark
                     │
                     ▼
                QUEUE TREE
                     │
                max-limit
                   5 Mbps
                     │
                     ▼
                    PCQ
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
     Cliente 1    Cliente 2    Cliente 3
       ≤1M          ≤1M          ≤1M
```

---

# 📊 Resumo dos parâmetros

| Parâmetro                      | Função                              |
| ------------------------------ | ----------------------------------- |
| `src-address=192.168.100.0/24` | Identifica a rede LAN               |
| `Con-Rede`                     | Marca das conexões                  |
| `Pac-Rede`                     | Marca dos pacotes                   |
| `kind=pcq`                     | Define o algoritmo PCQ              |
| `pcq-rate=1M`                  | Limite por subfila PCQ              |
| `pcq-classifier=src-address`   | Separa as subfilas por IP de origem |
| `max-limit=5M`                 | Limite total da Queue Tree          |
| `packet-mark=Pac-Rede`         | Seleciona o tráfego classificado    |
| `parent=global`                | Define a fila pai                   |

---

# 🧠 Para memorizar

```text
MANGLE
  ↓
Classifica o tráfego
  ↓
Packet Mark
  ↓
Queue Tree
  ↓
PCQ
  ↓
Divide em subfilas
  ↓
pcq-rate
  ↓
Limite por subfila
```

### Diferença principal

```text
Simple Queue
    ↓
Pode limitar diretamente um alvo

PCQ
    ↓
Cria subfilas dinamicamente
    ↓
Pode distribuir a banda entre clientes
```

No seu exemplo:

```text
max-limit = 5M
pcq-rate  = 1M
```

significa, conceitualmente:

> **A fila inteira pode utilizar até 5 Mbps, enquanto cada subfila PCQ pode utilizar até 1 Mbps.**

Isso é diferente de simplesmente colocar `max-limit=5M` em uma Simple Queue para toda a rede.
