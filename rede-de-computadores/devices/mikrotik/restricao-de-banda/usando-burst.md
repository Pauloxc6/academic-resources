# 🚀 Usando Burst em Simple Queue

O **Burst** permite que uma Simple Queue ultrapasse temporariamente o `max-limit`, fornecendo um **pico de velocidade** quando o tráfego médio está abaixo de determinado limite.

Isso é útil, por exemplo, para permitir que uma máquina tenha um pico de velocidade ao iniciar um download, abrir uma página ou carregar um arquivo, sem liberar essa velocidade continuamente.

---

## 📌 Principais parâmetros

```routeros
burst-limit
burst-threshold
burst-time
```

| Parâmetro         | Função                                                       |
| ----------------- | ------------------------------------------------------------ |
| `max-limit`       | Limite normal da queue                                       |
| `burst-limit`     | Velocidade máxima permitida durante o burst                  |
| `burst-threshold` | Média de tráfego que determina se o burst pode ser utilizado |
| `burst-time`      | Período utilizado para calcular a média de tráfego           |

### Relação

```text
                ┌──────────────────┐
                │   Tráfego baixo  │
                └────────┬─────────┘
                         │
                         ▼
                  Burst disponível
                         │
                         ▼
              ┌─────────────────────┐
              │   burst-limit       │
              │      10 Mbps        │
              └─────────────────────┘
                         │
                         │ média aumenta
                         ▼
              ┌─────────────────────┐
              │ burst-threshold     │
              │       3 Mbps        │
              └──────────┬──────────┘
                         │
                         ▼
                  Burst encerrado
                         │
                         ▼
              ┌─────────────────────┐
              │    max-limit        │
              │       5 Mbps        │
              └─────────────────────┘
```

---

## ⚙️ Exemplo

```routeros
/queue simple add name="LAN_LIMIT" target=ether4 \
    max-limit=5M/5M \
    burst-time=16/16 \
    burst-threshold=3M/3M \
    burst-limit=10M/10M
```

### `max-limit=5M/5M`

É o limite normal da queue:

```text
Download: 5 Mbps
Upload:   5 Mbps
```

Quando o burst não está sendo utilizado, a queue fica limitada a esse valor.

---

### `burst-limit=10M/10M`

Define o limite máximo durante o burst:

```text
Download: 10 Mbps
Upload:   10 Mbps
```

Ou seja, temporariamente a queue pode atingir até **10 Mbps**, em vez dos 5 Mbps normais.

---

### `burst-threshold=3M/3M`

Define o **limiar de tráfego médio** usado para determinar se o burst pode continuar sendo utilizado.

```text
Média < 3 Mbps
       ↓
   Burst pode ocorrer

Média ≥ 3 Mbps
       ↓
   Burst deixa de ser aplicado
       ↓
   max-limit = 5 Mbps
```

⚠️ Portanto, o `burst-threshold` **não é simplesmente "a velocidade de saída anterior"**. Ele é comparado com a **taxa média de tráfego calculada durante o período definido pelo `burst-time`**.

---

### `burst-time=16/16`

Define a janela de tempo usada no cálculo da média.

```text
Download → 16 segundos
Upload   → 16 segundos
```

O MikroTik utiliza essa janela para avaliar o consumo médio e decidir se o burst pode continuar.

---

# 🧮 Entendendo a ideia da conta

Uma forma simplificada de visualizar o conceito é:

```text
burst-threshold
───────────────
 burst-limit
```

No exemplo:

```text
3M
─── = 0,3
10M
```

Ou seja:

```text
3 / 10 = 0,3
```

E:

```text
1 / 0,3 ≈ 3,33
```

Isso **não significa diretamente "16 segundos = 16/0,3"**.

O comportamento real do burst depende da média calculada pelo RouterOS durante o `burst-time`. A relação entre `burst-limit`, `burst-threshold` e `burst-time` serve para determinar por quanto tempo e em quais condições o pico pode ser utilizado.

---

# 📊 Exemplo prático

Suponha:

```text
max-limit        = 5 Mbps
burst-limit      = 10 Mbps
burst-threshold  = 3 Mbps
burst-time       = 16 segundos
```

Um cliente começa a baixar um arquivo:

```text
Velocidade
   │
10M│       ┌──────── Burst ────────┐
   │      /                         \
 5M│─────/───────────────────────────\──── max-limit
   │
 3M│ - - - - - threshold - - - - - - - -
   │
   └──────────────────────────────────────► tempo
```

Enquanto a média de consumo estiver abaixo do `burst-threshold`, o MikroTik pode permitir o uso do `burst-limit`.

Conforme o consumo médio aumenta e ultrapassa o threshold, o burst deixa de ser aplicado e a queue retorna ao `max-limit`.

---

# 🧠 Para memorizar

```text
max-limit
   ↓
Velocidade normal

burst-limit
   ↓
Velocidade máxima durante o pico

burst-threshold
   ↓
Limiar de média para controlar o burst

burst-time
   ↓
Janela usada para calcular essa média
```

### Exemplo completo

```routeros
/queue simple add name="LAN_LIMIT" \
    target=ether4 \
    max-limit=5M/5M \
    burst-time=16/16 \
    burst-threshold=3M/3M \
    burst-limit=10M/10M
```

**Resultado conceitual:**

```text
Normal:     5 Mbps
Burst:     10 Mbps
Threshold:  3 Mbps
Janela:    16 segundos
```

O objetivo é permitir **picos temporários de velocidade**, mas impedir que o cliente mantenha o `burst-limit` continuamente.
