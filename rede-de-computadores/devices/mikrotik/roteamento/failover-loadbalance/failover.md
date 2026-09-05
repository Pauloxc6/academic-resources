# Failover

O **failover** permite utilizar um link principal e deixar outro como backup. No MikroTik, uma forma simples de fazer isso é criar duas rotas padrão (`0.0.0.0/0`) com diferentes valores de `distance`.

A rota com **menor distance** é preferida.

---

## Configuração

### LINK 1 — Principal

```bash
/ip route
add disabled=no \
    distance=1 \
    dst-address=0.0.0.0/0 \
    gateway=ether1-WAN \
    routing-table=main \
    pref-src="" \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

### LINK 2 — Backup

```bash
/ip route
add disabled=no \
    distance=2 \
    dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    routing-table=main \
    pref-src="" \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

---

## Como funciona

```text
                    INTERNET
                   /        \
                  /          \
           ether1-WAN      ether4-WAN2
                │               │
                │               │
             distance 1      distance 2
                │               │
                └─────┬─────────┘
                      │
                   MikroTik
```

Enquanto o primeiro link estiver disponível:

```text
LINK 1 → distance 1 → ATIVO
LINK 2 → distance 2 → BACKUP
```

O RouterOS prefere a rota com menor `distance`.

Se a rota do LINK 1 deixar de estar ativa:

```text
LINK 1 → distance 1 → INDISPONÍVEL
LINK 2 → distance 2 → ATIVO
```

O tráfego passa a utilizar o segundo link.

---

# Parâmetros importantes

| Parâmetro                | Função                                            |
| ------------------------ | ------------------------------------------------- |
| `dst-address=0.0.0.0/0`  | Rota padrão para qualquer destino                 |
| `gateway=ether1-WAN`     | Gateway/caminho utilizado pela rota               |
| `distance=1`             | Prioridade da rota                                |
| `distance=2`             | Menor preferência que a rota de distance 1        |
| `routing-table=main`     | Utiliza a tabela principal de roteamento          |
| `scope=30`               | Define o escopo da rota                           |
| `target-scope=10`        | Define o escopo utilizado na resolução do gateway |
| `disabled=no`            | Rota habilitada                                   |
| `pref-src=""`            | Não força um endereço IP de origem                |
| `suppress-hw-offload=no` | Permite hardware offload quando aplicável         |

---

# ⚠️ Atenção

Ter duas rotas com `distance=1` faria com que elas pudessem participar de **ECMP**, dependendo da configuração.

```text
distance=1
distance=1
    ↓
ECMP
```

Já:

```text
distance=1
distance=2
    ↓
Failover
```

Portanto:

> **Menor `distance` = maior preferência.**

---

# Failover simples × Failover monitorado

A configuração acima depende do estado das rotas/gateways. Para detectar uma falha de conectividade além do gateway, pode-se utilizar mecanismos como **Netwatch** ou monitoramento de gateway.

### Failover por prioridade

```text
LINK 1
distance=1
    │
    ├── OK → utiliza LINK 1
    │
    └── rota fica indisponível
              ↓
         LINK 2
       distance=2
```

### Failover com Netwatch

```text
Netwatch
    │
    ↓
Monitora IP externo
    │
    ├── UP ──→ LINK 1
    │
    └── DOWN → altera rota
                   ↓
                LINK 2
```

O segundo modelo é mais útil quando você quer verificar **conectividade real**, e não apenas se a interface/gateway está disponível.

---

# 🧠 Para memorizar

```text
dst-address → PARA ONDE?
gateway     → POR ONDE?
distance    → QUAL TEM PRIORIDADE?
routing-table → EM QUAL TABELA?
```

No failover:

```text
distance 1 → principal
distance 2 → backup
```
