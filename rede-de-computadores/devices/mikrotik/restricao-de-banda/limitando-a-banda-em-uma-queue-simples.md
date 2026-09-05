# 🚦 Limitando a Banda com Simple Queue

As **Simple Queues** do MikroTik permitem controlar a quantidade máxima de banda utilizada por determinados dispositivos, redes ou destinos.

A sintaxe básica é:

```routeros
/queue simple add name=NOME target=ALVO max-limit=DOWNLOAD/UPLOAD
```

> ⚠️ No `max-limit`, o primeiro valor representa o **upload** e o segundo o **download** em relação ao alvo da queue.

---

## 📌 Limitando uma interface

```routeros
/queue simple add name=LAN_LIMIT_5MB target=ether4 max-limit=5M/5M
```

Essa regra cria uma Simple Queue chamada `LAN_LIMIT_5MB` para o tráfego associado à interface `ether4`.

### Parâmetros

| Parâmetro            | Função                               |
| -------------------- | ------------------------------------ |
| `name=LAN_LIMIT_5MB` | Nome da queue                        |
| `target=ether4`      | Interface/target que será controlado |
| `max-limit=5M/5M`    | Limite máximo de banda               |

Nesse exemplo, a banda fica limitada a aproximadamente **5 Mbps em cada direção**.

---

## 🎯 Limitando o acesso a um destino específico

Também é possível utilizar o parâmetro `dst` para limitar o tráfego destinado a um determinado endereço IP:

```routeros
/queue simple add name=REDE_LAN target=ether4 dst=172.217.162.206 max-limit=10M/10M
```

Nesse caso:

```text
LAN
 │
 │ ether4
 ▼
┌───────────────────┐
│     MikroTik      │
│                   │
│ Simple Queue      │
│ REDE_LAN          │
│                   │
│ Destino:          │
│ 172.217.162.206   │
│ Limite: 10 Mbps   │
└─────────┬─────────┘
          │
          ▼
   172.217.162.206
```

A queue utiliza:

```text
target = ether4
dst    = 172.217.162.206
```

Portanto, o objetivo é aplicar a limitação ao tráfego que corresponda ao **target** e ao **destino especificado**.

---

## 🔎 Verificando as Simple Queues

Para visualizar as queues configuradas:

```routeros
/queue simple print
```

Para acompanhar o tráfego em tempo real:

```routeros
/queue simple print stats
```

---

## 🧠 Resumo

```text
target → QUEM/ONDE será controlado
dst    → PARA QUAL DESTINO
max-limit → QUANTO de banda poderá utilizar
```

Exemplo:

```routeros
/queue simple add \
    name=LAN_LIMIT_5MB \
    target=ether4 \
    max-limit=5M/5M
```

→ Limita o target `ether4`.

```routeros
/queue simple add \
    name=REDE_LAN \
    target=ether4 \
    dst=172.217.162.206 \
    max-limit=10M/10M
```

→ Aplica uma regra mais específica envolvendo o target e o destino `172.217.162.206`.
