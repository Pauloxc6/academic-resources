# Balanceamento PCC com links de velocidades iguais

O **PCC (Per Connection Classifier)** pode ser utilizado para distribuir conexões entre dois ou mais links de Internet.

Quando os links possuem a mesma velocidade, podemos dividir as conexões igualmente.

### Exemplo

```text
WAN 1 → 100 Mbps
WAN 2 → 100 Mbps
```

Como os links possuem a mesma capacidade:

```text
WAN 1 → 50% das conexões
WAN 2 → 50% das conexões
```

Com dois links, utilizamos:

```text
both-addresses:2
```

O `2` representa a quantidade de grupos.

```text
both-addresses:2/0 → Grupo 0 → WAN 1
both-addresses:2/1 → Grupo 1 → WAN 2
```

---

# 1. Evitando loops na rede

Antes das regras PCC, devemos impedir que tráfego destinado às redes locais ou às redes dos próprios links seja balanceado.

```bash
/ip firewall mangle
add action=accept \
    chain=prerouting \
    src-address=10.1.1.0/24 \
    dst-address=10.1.1.0/24 \
    comment="Evita loop na rede local"

add action=accept \
    chain=prerouting \
    src-address=10.1.1.0/24 \
    dst-address=192.168.100.0/24 \
    comment="Evita loop na rede WAN 1"

add action=accept \
    chain=prerouting \
    src-address=10.1.1.0/24 \
    dst-address=172.16.0.0/24 \
    comment="Evita loop na rede WAN 2"
```

Essas regras precisam ficar **antes das regras PCC**.

---

# 2. Marcação das conexões que chegam pelas WANs

Quando uma conexão chega pela Internet, precisamos identificar por qual WAN ela entrou.

```bash
/ip firewall mangle
add action=mark-connection \
    chain=prerouting \
    connection-mark=no-mark \
    in-interface=ether1 \
    new-connection-mark=WAN1-con \
    passthrough=yes

add action=mark-connection \
    chain=prerouting \
    connection-mark=no-mark \
    in-interface=ether2 \
    new-connection-mark=WAN2-con \
    passthrough=yes
```

Considerando:

```text
ether1 → WAN 1
ether2 → WAN 2
```

Assim:

```text
Internet
   │
   ├── WAN 1 → WAN1-con
   │
   └── WAN 2 → WAN2-con
```

> É importante utilizar **marcas diferentes** para as duas WANs. Se ambas receberem `WAN-con`, não será possível distinguir corretamente por qual link a conexão entrou.

---

# 3. PCC — Distribuição das conexões

Agora classificamos as conexões originadas pela LAN.

Considerando:

```text
ether4 → LAN
```

### Grupo 0 → WAN 1

```bash
/ip firewall mangle
add action=mark-connection \
    chain=prerouting \
    connection-mark=no-mark \
    in-interface=ether4 \
    dst-address-type=!local \
    per-connection-classifier=both-addresses:2/0 \
    new-connection-mark=WAN1-con \
    passthrough=yes
```

### Grupo 1 → WAN 2

```bash
/ip firewall mangle
add action=mark-connection \
    chain=prerouting \
    connection-mark=no-mark \
    in-interface=ether4 \
    dst-address-type=!local \
    per-connection-classifier=both-addresses:2/1 \
    new-connection-mark=WAN2-con \
    passthrough=yes
```

### Resultado

```text
                 PCC
                  │
          both-addresses:2
                  │
          ┌───────┴───────┐
          │               │
       Grupo 0          Grupo 1
          │               │
          ↓               ↓
        WAN 1           WAN 2
         50%             50%
```

---

# 4. Mark Routing

Depois de marcar as conexões, marcamos o roteamento.

```bash
/ip firewall mangle
add action=mark-routing \
    chain=prerouting \
    connection-mark=WAN1-con \
    in-interface=ether4 \
    new-routing-mark=rota-wan1 \
    passthrough=no

add action=mark-routing \
    chain=prerouting \
    connection-mark=WAN2-con \
    in-interface=ether4 \
    new-routing-mark=rota-wan2 \
    passthrough=no
```

Para conexões originadas pelo próprio MikroTik:

```bash
/ip firewall mangle
add action=mark-routing \
    chain=output \
    connection-mark=WAN1-con \
    new-routing-mark=rota-wan1 \
    passthrough=no

add action=mark-routing \
    chain=output \
    connection-mark=WAN2-con \
    new-routing-mark=rota-wan2 \
    passthrough=no
```

---

# 5. Routing Tables

No RouterOS 7, é necessário criar as tabelas de roteamento utilizadas pelas marcas.

```bash
/routing/table
add fib name=rota-wan1

add fib name=rota-wan2
```

---

# 6. Rotas principais

As rotas padrão da tabela `main` podem funcionar como:

```text
WAN 1 → distância 1
WAN 2 → distância 2
```

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=GW-WAN1 distance=1
add dst-address=0.0.0.0/0 gateway=GW-WAN2 distance=2
```

Isso cria uma rota principal pela WAN 1 e uma rota de backup pela WAN 2.

---

# 7. Rotas das tabelas PCC

Para a tabela da WAN 1:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=GW-WAN1 \
    routing-table=rota-wan1
```

Para a tabela da WAN 2:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=GW-WAN2 \
    routing-table=rota-wan2
```

---

# Fluxo completo

```text
                       INTERNET
                    ┌──────┴──────┐
                    │             │
                 WAN 1          WAN 2
                    │             │
                    └──────┬──────┘
                           │
                     ┌─────▼─────┐
                     │  MikroTik │
                     │    PCC    │
                     └─────┬─────┘
                           │
                          LAN
                       ether4
                           │
                    10.1.1.0/24
```

O tráfego da LAN:

```text
Cliente
   │
   ↓
PCC
   │
   ├── 50% → WAN1-con → rota-wan1 → WAN 1
   │
   └── 50% → WAN2-con → rota-wan2 → WAN 2
```

---

# `both-addresses`

No exemplo foi utilizado:

```text
both-addresses
```

O PCC utiliza os endereços de origem e destino para determinar em qual grupo uma conexão será colocada.

Com:

```text
both-addresses:2/0
both-addresses:2/1
```

temos dois grupos.

### Divisão

```text
Total = 2 grupos

Grupo 0 → 50%
Grupo 1 → 50%
```

---

# ⚠️ Correções importantes no exemplo original

### 1. `dst-address-type=local`

Você tinha:

```text
dst-address-type=local
```

na regra PCC.

Para balanceamento de Internet, normalmente queremos o contrário:

```text
dst-address-type=!local
```

Porque queremos classificar destinos que **não são endereços locais do roteador**.

---

### 2. Marcas diferentes

Você tinha:

```text
WAN-con
```

para as duas WANs.

O ideal é:

```text
WAN1-con
WAN2-con
```

Assim conseguimos associar:

```text
WAN1-con → rota-wan1
WAN2-con → rota-wan2
```

---

### 3. Tabelas diferentes

Você tinha:

```text
new-routing-mark=rota-wan
```

para ambas.

Isso faria as duas marcas utilizarem a mesma tabela.

Para separar os links:

```text
WAN1-con → rota-wan1
WAN2-con → rota-wan2
```

---

### 4. Gateway

Evite assumir:

```text
gateway=ether1
gateway=ether2
```

Quando a WAN utiliza Ethernet com um roteador/gateway do provedor, normalmente a rota deve apontar para o **gateway IP**:

```text
gateway=192.168.100.1
```

ou:

```text
gateway=172.16.0.1
```

dependendo da rede.

---

# 🧠 Para memorizar

```text
2 links iguais
      ↓
2 grupos PCC
      ↓
50% / 50%
```

```text
WAN 1
  ↓
WAN1-con
  ↓
rota-wan1
  ↓
Gateway WAN1
```

```text
WAN 2
  ↓
WAN2-con
  ↓
rota-wan2
  ↓
Gateway WAN2
```

### Regra fundamental

```text
PCC → marca a conexão
      ↓
Mangle → marca o roteamento
      ↓
Routing Table → escolhe a WAN
```

> **PCC distribui conexões, não pacotes.** Portanto, uma única conexão não é necessariamente dividida entre os dois links. O benefício aparece principalmente quando existem várias conexões simultâneas.
