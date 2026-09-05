# Link Failover via Netwatch

O **Netwatch** pode ser utilizado para implementar failover monitorando um endereço IP externo.

Neste exemplo:

* **LINK 1** → principal;
* **LINK 2** → backup;
* `1.1.1.1` → endereço utilizado para monitoramento;
* quando o LINK 1 falha, sua rota é desabilitada;
* quando o LINK 1 volta, sua rota é habilitada novamente.

---

## Rotas

### LINK 1 — Principal

```bash
/ip route add \
    comment="LINK 1" \
    disabled=yes \
    distance=1 \
    dst-address=0.0.0.0/0 \
    gateway=192.168.100.1 \
    pref-src="" \
    routing-table=main \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

### LINK 2 — Backup

```bash
/ip route add \
    comment="LINK 2" \
    disabled=no \
    distance=2 \
    dst-address=0.0.0.0/0 \
    gateway=172.16.0.1 \
    pref-src="" \
    routing-table=main \
    scope=30 \
    suppress-hw-offload=no \
    target-scope=10
```

Inicialmente:

```text
LINK 1 → disabled=yes  → INATIVO
LINK 2 → disabled=no   → ATIVO
```

> Se a intenção for iniciar com o LINK 1 como principal, normalmente ele deveria começar com `disabled=no` e o LINK 2 com `disabled=no`/`distance=2` como backup.

---

# Netwatch

```bash
/tool netwatch add \
    disabled=no \
    down-script="/ip route disable [find comment=\"LINK 1\"]" \
    host=1.1.1.1 \
    http-codes="" \
    interval=10s \
    test-script="" \
    timeout=50ms \
    type=simple \
    up-script="/ip route enable [find comment=\"LINK 1\"]"
```

O Netwatch verifica:

```text
1.1.1.1
```

a cada:

```text
10 segundos
```

com timeout de:

```text
50 ms
```

---

# Funcionamento

## LINK 1 funcionando

O Netwatch consegue alcançar:

```text
1.1.1.1
```

Então executa:

```bash
/ip route enable [find comment="LINK 1"]
```

A rota fica:

```text
LINK 1 → distance 1 → ATIVA
LINK 2 → distance 2 → BACKUP
```

Como a rota do LINK 1 possui menor `distance`, ela é preferida.

---

## LINK 1 falhou

O Netwatch detecta que:

```text
1.1.1.1 → DOWN
```

Então executa:

```bash
/ip route disable [find comment="LINK 1"]
```

A rota do LINK 1 é removida da seleção ativa:

```text
LINK 1 → disabled=yes
LINK 2 → distance 2 → ATIVA
```

O tráfego passa a utilizar o LINK 2.

---

## LINK 1 retorna

Quando o Netwatch detectar novamente:

```text
1.1.1.1 → UP
```

executa:

```bash
/ip route enable [find comment="LINK 1"]
```

Voltamos para:

```text
LINK 1 → distance 1 → ATIVA
LINK 2 → distance 2 → BACKUP
```

---

# Fluxo

```text
                  Netwatch
                     │
                     ↓
                  1.1.1.1
                     │
              ┌──────┴──────┐
              │             │
             UP            DOWN
              │             │
              ↓             ↓
        enable LINK 1   disable LINK 1
              │             │
              ↓             ↓
       LINK 1 principal   LINK 2 assume
```

---

# Diferença para o failover por `distance`

No failover tradicional:

```text
LINK 1 → distance 1
LINK 2 → distance 2
```

A rota de backup já está presente, mas possui menor preferência.

No exemplo com Netwatch:

```text
LINK 1 → habilita/desabilita
LINK 2 → permanece disponível
```

O Netwatch controla diretamente a disponibilidade da rota do LINK 1.

---

# ⚠️ Atenção ao estado inicial

No seu exemplo:

```bash
disabled=yes
```

na rota do LINK 1 significa que **ela começa desabilitada**.

Portanto, se você deseja iniciar usando o LINK 1 como principal, utilize:

```bash
disabled=no
```

ficando:

```text
LINK 1 → disabled=no  distance=1 → PRINCIPAL
LINK 2 → disabled=no  distance=2 → BACKUP
```

---

# ⚠️ Outro ponto importante: o caminho até 1.1.1.1

O Netwatch monitora `1.1.1.1`, mas é importante garantir que esse destino seja alcançado pelo **LINK 1 que você deseja testar**.

Caso contrário, pode acontecer:

```text
LINK 1 caiu
    ↓
Netwatch tenta 1.1.1.1
    ↓
roteamento utiliza LINK 2
    ↓
1.1.1.1 continua acessível
    ↓
Netwatch entende que está UP
```

Por isso, em configurações de failover mais robustas, é comum criar uma rota específica para o IP de monitoramento através do LINK 1.

Exemplo:

```bash
/ip route add \
    dst-address=1.1.1.1/32 \
    gateway=192.168.100.1 \
    comment="MONITOR-LINK1"
```

Assim, o monitoramento pode ser associado explicitamente ao caminho do LINK 1.

---

# 🧠 Para memorizar

```text
Netwatch
   │
   ├── UP
   │    ↓
   │  enable LINK 1
   │
   └── DOWN
        ↓
      disable LINK 1
```

E as prioridades:

```text
LINK 1 → distance 1 → PRINCIPAL
LINK 2 → distance 2 → BACKUP
```

### Ideia principal

> **Netwatch detecta a conectividade e controla o estado da rota.**

```text
Monitoramento
      ↓
Netwatch
      ↓
UP/DOWN
      ↓
enable/disable
      ↓
Failover
```
