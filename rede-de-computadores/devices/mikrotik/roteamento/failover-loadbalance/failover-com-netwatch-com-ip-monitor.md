# Failover com Netwatch e IP de monitoramento

O **Netwatch** pode ser utilizado para monitorar um endereço IP e executar scripts quando o destino fica:

* **UP** → acessível;
* **DOWN** → inacessível.

Isso permite implementar um mecanismo simples de **failover** entre links de Internet.

---

# Topologia

Exemplo com dois links:

```text
                  INTERNET
                 /        \
                /          \
           LINK 1          LINK 2
        192.168.100.1    172.16.0.1
              \              /
               \            /
                └── MikroTik
```

A ideia:

```text
LINK 1 → principal
LINK 2 → backup
```

---

# 1. Criando rota de monitoramento

Primeiro criamos uma rota específica para o endereço que será monitorado.

```bash
/ip route add \
    dst-address=8.8.8.8/32 \
    gateway=192.168.100.1 \
    comment="monitor"
```

Nesse exemplo:

```text
8.8.8.8
   ↓
192.168.100.1
   ↓
LINK 1
```

Assim, o tráfego destinado a `8.8.8.8` será encaminhado pelo LINK 1.

> É importante que o IP utilizado para monitoramento seja alcançável exclusivamente pelo caminho que você deseja testar.

---

# 2. Criando a rota principal

A rota que será alterada pelo failover deve possuir um comentário que permita encontrá-la.

```bash
/ip route add \
    dst-address=0.0.0.0/0 \
    gateway=192.168.100.1 \
    distance=1 \
    comment="LINK-1"
```

Rota de backup:

```bash
/ip route add \
    dst-address=0.0.0.0/0 \
    gateway=172.16.0.1 \
    distance=2 \
    comment="LINK-2"
```

Inicialmente:

```text
LINK-1 → distance 1 → ATIVO
LINK-2 → distance 2 → BACKUP
```

---

# 3. Script de LINK DOWN

Quando o Netwatch detectar que `8.8.8.8` ficou inacessível, o script altera a distância da rota `LINK-1`.

```bash
/system script add \
    name=linkdown \
    source="/ip route set [/ip route find where comment=\"LINK-1\"] distance=3" \
    dont-require-permissions=yes
```

Resultado:

```text
Antes:

LINK-1 → distance 1
LINK-2 → distance 2

        ↓ LINK-1 DOWN

Depois:

LINK-1 → distance 3
LINK-2 → distance 2
```

Agora o LINK-2 passa a ser preferido.

---

# 4. Script de LINK UP

Quando o Netwatch detectar novamente o IP:

```text
8.8.8.8 → UP
```

o script restaura a preferência do LINK-1.

```bash
/system script add \
    name=linkup \
    source="/ip route set [/ip route find where comment=\"LINK-1\"] distance=1" \
    dont-require-permissions=yes
```

Resultado:

```text
LINK-1 → distance 1
LINK-2 → distance 2
```

O LINK-1 volta a ser o principal.

---

# 5. Configurando o Netwatch

Agora criamos o monitoramento:

```bash
/tool netwatch add \
    host=8.8.8.8 \
    interval=5s \
    down-script=linkdown \
    up-script=linkup
```

Fluxo:

```text
                    Netwatch
                       │
                       ↓
                    8.8.8.8
                       │
             ┌─────────┴─────────┐
             │                   │
            UP                  DOWN
             │                   │
             ↓                   ↓
         linkup              linkdown
             │                   │
             ↓                   ↓
       LINK-1 dist=1        LINK-1 dist=3
```

---

# Funcionamento completo

### LINK 1 funcionando

```text
8.8.8.8
   │
   ↓
LINK-1
   │
   ↓
distance=1
   │
   ↓
Internet
```

O LINK-2 permanece como backup:

```text
LINK-2 → distance=2
```

---

### LINK 1 cai

O Netwatch não consegue alcançar:

```text
8.8.8.8
```

Então executa:

```text
linkdown
```

que altera:

```text
LINK-1 → distance=3
```

Agora:

```text
LINK-2 → distance=2
```

é preferido.

```text
Internet
   │
   ↓
LINK-2
   │
   ↓
MikroTik
```

---

### LINK 1 retorna

O Netwatch detecta:

```text
8.8.8.8 → UP
```

Executa:

```text
linkup
```

e restaura:

```text
LINK-1 → distance=1
```

Voltando para:

```text
LINK-1 → principal
LINK-2 → backup
```

---

# Comandos completos

```bash
# Rota de monitoramento
/ip route add \
    dst-address=8.8.8.8/32 \
    gateway=192.168.100.1 \
    comment="monitor"

# LINK 1
/ip route add \
    dst-address=0.0.0.0/0 \
    gateway=192.168.100.1 \
    distance=1 \
    comment="LINK-1"

# LINK 2
/ip route add \
    dst-address=0.0.0.0/0 \
    gateway=172.16.0.1 \
    distance=2 \
    comment="LINK-2"

# Script de queda
/system script add \
    name=linkdown \
    source="/ip route set [/ip route find where comment=\"LINK-1\"] distance=3" \
    dont-require-permissions=yes

# Script de retorno
/system script add \
    name=linkup \
    source="/ip route set [/ip route find where comment=\"LINK-1\"] distance=1" \
    dont-require-permissions=yes

# Netwatch
/tool netwatch add \
    host=8.8.8.8 \
    interval=5s \
    down-script=linkdown \
    up-script=linkup
```

---

# Verificação

### Ver rotas

```bash
/ip route print
```

### Ver scripts

```bash
/system script print
```

### Ver Netwatch

```bash
/tool netwatch print
```

---

# ⚠️ Atenção ao IP monitorado

Monitorar somente:

```text
8.8.8.8
```

não garante que o problema seja exclusivamente o LINK-1.

Por exemplo:

```text
MikroTik → LINK-1 → ISP → Internet → 8.8.8.8
```

Se houver um problema no caminho entre o ISP e `8.8.8.8`, o Netwatch também poderá considerar o LINK-1 como DOWN.

Por isso, em ambientes mais robustos, pode-se utilizar:

* mais de um IP de monitoramento;
* um destino sob controle do próprio provedor;
* ferramentas de monitoramento mais avançadas;
* mecanismos de detecção de gateway/rota.

---

# 🧠 Para memorizar

```text
Netwatch
   │
   ↓
Monitora IP
   │
   ├── UP
   │    ↓
   │  linkup
   │    ↓
   │  distance=1
   │
   └── DOWN
        ↓
      linkdown
        ↓
      distance=3
```

### Failover

```text
LINK-1 → distance 1 → PRINCIPAL
LINK-2 → distance 2 → BACKUP

LINK-1 DOWN
      ↓
LINK-1 → distance 3
      ↓
LINK-2 → PRINCIPAL
```

**Ideia principal:**

```text
Netwatch detecta
       ↓
Script altera a rota
       ↓
Distance muda
       ↓
Outra rota assume
```
