# Roteamento estático

O **roteamento estático** consiste em configurar manualmente uma rota para informar ao roteador **por onde determinado destino deve ser alcançado**.

No MikroTik:

```text
/ip/route/add
```

---

## Rota padrão

A rota padrão é utilizada quando não existe uma rota mais específica para o destino.

```text
Destino: 0.0.0.0/0
Gateway: 192.168.0.1
```

No CLI:

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.0.1
```

### Estrutura

```text
0.0.0.0/0
   ↓
qualquer destino
   ↓
gateway 192.168.0.1
```

> `0.0.0.0/0` significa **qualquer rede IPv4**.

---

# Rota para um host específico

É possível criar uma rota destinada a um único endereço IP.

Exemplo:

```bash
/ip route add \
    dst-address=8.8.8.8/32 \
    gateway=192.168.122.1 \
    comment="Destino 8.8.8.8"
```

O `/32` significa que a rota corresponde a **apenas um endereço IP**:

```text
8.8.8.8/32
```

---

# Rota para uma rede

Para encaminhar todo o tráfego destinado a uma rede:

```bash
/ip route add \
    dst-address=10.10.10.0/24 \
    gateway=192.168.122.1 \
    comment="Rota para rede 10.10.10.0/24"
```

Nesse caso:

```text
10.10.10.0/24
       ↓
Gateway 192.168.122.1
```

---

# Visualização das rotas

```bash
/ip route print
```

Para obter mais detalhes:

```bash
/ip route print detail
```

---

# Exemplos

### Rota padrão

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.0.1
```

### Rota para uma rede

```bash
/ip route add dst-address=192.168.50.0/24 gateway=192.168.0.2
```

### Rota para um host

```bash
/ip route add dst-address=8.8.8.8/32 gateway=192.168.122.1
```

### Rota com comentário

```bash
/ip route add \
    dst-address=10.20.30.0/24 \
    gateway=192.168.0.2 \
    comment="Rede filial"
```

---

# Distance

A propriedade `distance` determina a preferência administrativa da rota.

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.0.1 distance=1
```

Uma rota com menor `distance` normalmente é preferida:

```text
WAN 1 → distance=1 → principal
WAN 2 → distance=2 → backup
```

Exemplo:

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.0.1 distance=1
add dst-address=0.0.0.0/0 gateway=192.168.1.1 distance=2
```

---

# Rota estática x rota padrão

```text
Rota específica
    ↓
10.10.10.0/24
    ↓
Gateway específico
```

Enquanto:

```text
Rota padrão
    ↓
0.0.0.0/0
    ↓
Qualquer destino que não tenha uma rota mais específica
```

---

# ⚠️ Correção do exemplo original

Você tinha:

```text
dst.address: 0.0.0.0/0
netmask: 192.168.0.1
```

O correto conceitualmente é:

```text
dst-address → 0.0.0.0/0
gateway     → 192.168.0.1
```

Ou:

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.0.1
```

E no seu segundo exemplo, é melhor especificar `/32`:

```bash
/ip route add \
    dst-address=8.8.8.8/32 \
    gateway=192.168.122.1 \
    comment="Destino 8.8.8.8"
```

---

# 🧠 Para memorizar

```text
dst-address → PARA ONDE?
gateway     → POR ONDE?
distance    → QUAL É A PREFERÊNCIA?
comment     → O QUE ESSA ROTA FAZ?
```

Exemplo:

```text
dst-address=10.10.10.0/24
        ↓
gateway=192.168.0.2
```

Significa:

> "Para chegar à rede `10.10.10.0/24`, encaminhe o tráfego para `192.168.0.2`."

### Prefixos importantes

```text
0.0.0.0/0       → qualquer destino
10.10.10.0/24   → uma rede
8.8.8.8/32      → um único host
```
