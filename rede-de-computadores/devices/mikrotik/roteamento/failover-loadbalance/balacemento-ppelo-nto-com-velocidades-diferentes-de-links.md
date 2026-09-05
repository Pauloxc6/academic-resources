# Balanceamento PCC com links de velocidades diferentes

O **PCC (Per Connection Classifier)** pode ser utilizado no MikroTik para distribuir conexões entre múltiplos links de Internet.

Quando os links possuem **velocidades diferentes**, podemos distribuir as conexões proporcionalmente à capacidade de cada link.

---

# Exemplo

Suponha dois links:

```text
WAN 1 → 10 Mbps
WAN 2 → 20 Mbps
```

Velocidade total:

```text
10 + 20 = 30 Mbps
```

Para distribuir proporcionalmente:

```text
30 / 10 = 3
```

Isso significa que podemos trabalhar com **3 grupos de conexões**.

Como temos 30 Mbps no total:

```text
30 / 3 = 10 Mbps
```

Distribuição:

```text
┌──────────────────────────────┐
│       3 grupos PCC           │
├──────────────────────────────┤
│ Grupo 1 → WAN 1 → 10 Mbps    │
│ Grupo 2 → WAN 1 → 10 Mbps    │
│ Grupo 3 → WAN 2 → 10 Mbps    │
└──────────────────────────────┘
```

Portanto:

```text
WAN 1 → 2 grupos
WAN 2 → 1 grupo
```

Proporção:

```text
WAN 1 = 2/3
WAN 2 = 1/3
```

> **Importante:** PCC distribui **conexões**, não soma fisicamente os links em uma única conexão. Uma conexão individual normalmente continuará passando por apenas um dos links.

---

# 1. Evitando loops / tráfego que não deve passar pelo PCC

Antes de aplicar o PCC, devemos impedir que tráfego destinado às redes locais ou às próprias redes dos links seja classificado como tráfego de Internet.

```bash
/ip firewall mangle
add chain=prerouting action=accept \
    src-address=10.1.1.0/24 \
    dst-address=10.1.1.0/24 \
    comment="Evita loop na rede local"

add chain=prerouting action=accept \
    src-address=10.1.1.0/24 \
    dst-address=192.168.100.0/24 \
    comment="Evita loop na rede WAN 1"

add chain=prerouting action=accept \
    src-address=10.1.1.0/24 \
    dst-address=172.16.0.0/24 \
    comment="Evita loop na rede WAN 2"
```

A ideia é:

```text
LAN
10.1.1.0/24
      │
      ├──→ Rede local
      ├──→ WAN 1
      └──→ WAN 2
```

Esse tráfego deve ser aceito **antes das regras PCC**, evitando que seja marcado para uma WAN incorreta.

> Em uma configuração real, também é comum excluir outras redes internas, redes de gerenciamento, VPNs e destinos que não devem passar pelo balanceamento.

---

# 2. Marcação das conexões recebidas pelas WANs

As conexões que chegam pela Internet também precisam manter a mesma WAN durante o retorno.

```bash
/ip firewall mangle
add chain=prerouting \
    in-interface=ether1 \
    connection-mark=no-mark \
    action=mark-connection \
    new-connection-mark=Con-WAN1

add chain=prerouting \
    in-interface=ether2 \
    connection-mark=no-mark \
    action=mark-connection \
    new-connection-mark=Con-WAN2
```

Nesse exemplo:

```text
ether1 → WAN 1
ether2 → WAN 2
```

Quando uma conexão entra pela WAN 1:

```text
WAN 1
  │
  ↓
Con-WAN1
```

Quando entra pela WAN 2:

```text
WAN 2
  │
  ↓
Con-WAN2
```

Isso ajuda a garantir **simetria de roteamento**.

---

# 3. PCC — Distribuição das conexões

A interface `ether4` representa a LAN.

```bash
/ip firewall mangle
add chain=prerouting \
    dst-address-type=!local \
    in-interface=ether4 \
    connection-mark=no-mark \
    per-connection-classifier=both-addresses:3/0 \
    action=mark-connection \
    new-connection-mark=Con-WAN1

add chain=prerouting \
    dst-address-type=!local \
    in-interface=ether4 \
    connection-mark=no-mark \
    per-connection-classifier=both-addresses:3/1 \
    action=mark-connection \
    new-connection-mark=Con-WAN1

add chain=prerouting \
    dst-address-type=!local \
    in-interface=ether4 \
    connection-mark=no-mark \
    per-connection-classifier=both-addresses:3/2 \
    action=mark-connection \
    new-connection-mark=Con-WAN2
```

### Distribuição

```text
PCC: both-addresses:3

         ┌──────────────┐
         │ 3 grupos     │
         └──────┬───────┘
                │
       ┌────────┼────────┐
       ↓        ↓        ↓
     grupo 0  grupo 1  grupo 2
       │        │        │
       ↓        ↓        ↓
     WAN 1    WAN 1    WAN 2
```

Resultado:

```text
WAN 1 → 2/3 das conexões
WAN 2 → 1/3 das conexões
```

---

# 4. Mark Routing

Depois de marcar as conexões, criamos uma marca de roteamento.

```bash
/ip firewall mangle
add chain=prerouting \
    in-interface=ether4 \
    connection-mark=Con-WAN1 \
    action=mark-routing \
    new-routing-mark=Rota-WAN1

add chain=prerouting \
    in-interface=ether4 \
    connection-mark=Con-WAN2 \
    action=mark-routing \
    new-routing-mark=Rota-WAN2
```

Para tráfego originado pelo próprio MikroTik:

```bash
/ip firewall mangle
add chain=output \
    connection-mark=Con-WAN1 \
    action=mark-routing \
    new-routing-mark=Rota-WAN1

add chain=output \
    connection-mark=Con-WAN2 \
    action=mark-routing \
    new-routing-mark=Rota-WAN2
```

O fluxo fica:

```text
Cliente
   │
   ↓
PCC
   │
   ├──→ Con-WAN1 ──→ Rota-WAN1
   │
   └──→ Con-WAN2 ──→ Rota-WAN2
```

---

# 5. Rotas

### Rotas principais

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=GW-WAN1 distance=1
add dst-address=0.0.0.0/0 gateway=GW-WAN2 distance=2
```

Atenção:

```text
0.0.0.0/0
```

é a **rota padrão**.

Não:

```text
0.0.0.0/24
```

---

# 6. Rotas para cada tabela de roteamento

Para a tabela da WAN 1:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=GW-WAN1 \
    routing-mark=Rota-WAN1
```

Para a WAN 2:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=GW-WAN2 \
    routing-mark=Rota-WAN2
```

> Em versões recentes do RouterOS, o modelo recomendado utiliza **routing tables** em vez da antiga abordagem baseada somente em `routing-mark`. A sintaxe também varia entre RouterOS 6 e RouterOS 7.

---

# Fluxo completo

```text
                         INTERNET
                    ┌────────┴────────┐
                    │                 │
                 WAN 1             WAN 2
                 10 Mbps           20 Mbps
                    │                 │
                    └────────┬────────┘
                             │
                       ┌─────▼─────┐
                       │ MikroTik  │
                       │   PCC     │
                       └─────┬─────┘
                             │
                           LAN
                       10.1.1.0/24
                             │
                    ┌────────┴────────┐
                    │                 │
                 Cliente           Cliente
```

Distribuição:

```text
             3 grupos
                │
       ┌────────┼────────┐
       ↓        ↓        ↓
     WAN 1    WAN 1    WAN 2
     10 Mbps  10 Mbps  10 Mbps
       │        │        │
       └────────┴────────┘
                │
          30 Mbps total*
```

* A capacidade agregada pode chegar aproximadamente à soma dos links **quando há múltiplas conexões**, mas isso não significa que uma única conexão TCP passe simultaneamente pelos dois links.

---

# 🧠 Para memorizar

```text
PCC
 │
 ├── connection-mark
 │       │
 │       ├── Con-WAN1
 │       └── Con-WAN2
 │
 └── routing-mark / routing-table
         │
         ├── Rota-WAN1
         └── Rota-WAN2
```

### Links diferentes

```text
10 Mbps + 20 Mbps
       ↓
     30 Mbps
       ↓
     3 grupos
       ↓
  2 grupos → WAN 1
  1 grupo  → WAN 2
```

### Regra principal

```text
PCC = distribuição de conexões
```

e não:

```text
PCC ≠ soma física dos links em uma única conexão
```
