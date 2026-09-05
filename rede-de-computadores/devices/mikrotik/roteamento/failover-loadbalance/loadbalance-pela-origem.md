# Load Balance pela Origem

O **load balance pela origem** distribui o tráfego de diferentes redes, hosts ou origens entre múltiplos links.

No MikroTik, isso pode ser feito utilizando **Policy Routing**, associando diferentes origens a diferentes tabelas de roteamento.

> ⚠️ Apenas criar duas rotas com `distance=1` e `distance=2` **não realiza load balance**. Essa configuração representa **rota principal + rota de backup (failover)**.

---

# Rotas

## LINK 1

```bash
/ip route
add disabled=no \
    distance=1 \
    dst-address=0.0.0.0/0 \
    gateway=ether1-WAN \
    pref-src="" \
    routing-table=main \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

## LINK 2

```bash
/ip route
add disabled=no \
    distance=2 \
    dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    pref-src="" \
    routing-table=main \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

Essa configuração resulta em:

```text
LINK 1 → distance 1 → PRINCIPAL
LINK 2 → distance 2 → BACKUP
```

Portanto, **não existe distribuição de carga entre os dois links**.

---

# Load Balance por origem

Um exemplo simples seria dividir os clientes pela rede de origem:

```text
LAN
│
├── 192.168.10.0/24 → LINK 1
│
└── 192.168.20.0/24 → LINK 2
```

A lógica seria:

```text
Origem 192.168.10.0/24
        ↓
    Routing Table
        ↓
      LINK 1


Origem 192.168.20.0/24
        ↓
    Routing Table
        ↓
      LINK 2
```

---

# Exemplo com Policy Routing

Primeiro criamos as tabelas:

```bash
/routing table
add fib name=to-WAN1

/routing table
add fib name=to-WAN2
```

Depois criamos as rotas em cada tabela.

### Tabela WAN1

```bash
/ip route
add \
    dst-address=0.0.0.0/0 \
    gateway=ether1-WAN \
    routing-table=to-WAN1
```

### Tabela WAN2

```bash
/ip route
add \
    dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    routing-table=to-WAN2
```

---

# Regras por origem

Agora podemos direcionar cada rede para uma tabela específica:

```bash
/routing rule
add src-address=192.168.10.0/24 action=lookup-only-in-table table=to-WAN1

/routing rule
add src-address=192.168.20.0/24 action=lookup-only-in-table table=to-WAN2
```

Resultado:

```text
192.168.10.0/24
       │
       ↓
   to-WAN1
       │
       ↓
   ether1-WAN


192.168.20.0/24
       │
       ↓
   to-WAN2
       │
       ↓
   ether4-WAN2
```

---

# Diferença entre Load Balance e Failover

### Failover

```text
LINK 1 → distance 1 → ATIVO
LINK 2 → distance 2 → BACKUP
```

O segundo link só é utilizado quando o primeiro deixa de ser utilizável.

### Load Balance pela origem

```text
Origem A → LINK 1
Origem B → LINK 2
```

Os dois links podem ser utilizados **simultaneamente**, mas cada origem é direcionada para um caminho específico.

---

# 🧠 Para memorizar

```text
distance
   ↓
preferência de rota
   ↓
FAILOVER
```

```text
src-address
     ↓
routing-table
     ↓
gateway
     ↓
LOAD BALANCE POR ORIGEM
```

### Regra mental

> **Failover decide qual link usar quando existe uma rota preferencial.**

> **Load balance pela origem decide qual link usar com base na origem do tráfego.**
