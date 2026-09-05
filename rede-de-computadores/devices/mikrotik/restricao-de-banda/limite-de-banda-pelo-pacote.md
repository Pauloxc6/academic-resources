# 📦 Limite de Banda pelo Pacote

O **Mangle** do MikroTik pode ser utilizado para identificar determinados tipos de tráfego e criar **marcas de conexão** e **marcas de pacote**.

Essas marcas podem posteriormente ser utilizadas por recursos como **Queues, QoS e Policy Routing**.

---

## 🔄 Fluxo

```text
                 Tráfego entrando
                       │
                       ▼
                ┌─────────────┐
                │   Mangle    │
                └──────┬──────┘
                       │
                       ▼
              Porta TCP 25?
                 │       │
                NÃO     SIM
                 │       │
                 │       ▼
                 │  Marca conexão
                 │  smtp-mark
                 │       │
                 │       ▼
                 │  Marca pacote
                 │  smtp-packet
                 │       │
                 │       ▼
                 │   QoS / Queue
                 │
                 ▼
              Continua
```

---

# 1. Marcando a conexão

```routeros
/ip firewall mangle add \
    chain=prerouting \
    protocol=tcp \
    dst-port=25 \
    action=mark-connection \
    new-connection-mark=smtp-mark \
    passthrough=yes
```

Essa regra identifica conexões **TCP destinadas à porta 25** e atribui a elas a marca:

```text
smtp-mark
```

### Parâmetros

| Parâmetro                       | Função                                           |
| ------------------------------- | ------------------------------------------------ |
| `chain=prerouting`              | Processa o pacote antes da decisão de roteamento |
| `protocol=tcp`                  | Procura somente tráfego TCP                      |
| `dst-port=25`                   | Procura tráfego destinado à porta 25             |
| `action=mark-connection`        | Marca a conexão                                  |
| `new-connection-mark=smtp-mark` | Nome da marca criada                             |
| `passthrough=yes`               | Permite continuar para outras regras do Mangle   |

### Fluxo

```text
TCP
 │
 └── destino: porta 25
          │
          ▼
    smtp-mark
```

A porta **25/TCP** é tradicionalmente utilizada para **SMTP entre servidores**.

---

# 2. Marcando os pacotes

Depois de marcar a conexão, podemos marcar os pacotes pertencentes a essa conexão:

```routeros
/ip firewall mangle add \
    chain=prerouting \
    connection-mark=smtp-mark \
    action=mark-packet \
    new-packet-mark=smtp-packet \
    passthrough=no
```

Agora o MikroTik procura pacotes pertencentes a conexões que possuem:

```text
connection-mark=smtp-mark
```

e atribui:

```text
packet-mark=smtp-packet
```

### Parâmetros

| Parâmetro                     | Função                                            |
| ----------------------------- | ------------------------------------------------- |
| `chain=prerouting`            | Processa o pacote antes do roteamento             |
| `connection-mark=smtp-mark`   | Procura conexões já marcadas                      |
| `action=mark-packet`          | Marca os pacotes                                  |
| `new-packet-mark=smtp-packet` | Nome da marca dos pacotes                         |
| `passthrough=no`              | Para o processamento do Mangle para aquele pacote |

---

# 🔗 Conexão × Pacote

É importante diferenciar os dois tipos de marca:

```text
CONNECTION MARK
      │
      │ smtp-mark
      ▼
 identifica a conexão
      │
      ▼
PACKET MARK
      │
      │ smtp-packet
      ▼
 identifica os pacotes
```

Uma **conexão** pode possuir vários pacotes.

Por isso, é comum primeiro marcar a conexão e depois utilizar essa marca para marcar os pacotes pertencentes a ela.

---

# 🚦 Utilizando a marca para QoS

Depois que os pacotes possuem:

```text
smtp-packet
```

podemos utilizar essa marca em uma Queue.

Por exemplo:

```routeros
/queue tree add \
    name="SMTP-LIMIT" \
    parent=global \
    packet-mark=smtp-packet \
    max-limit=1M
```

Nesse exemplo, o tráfego identificado como `smtp-packet` recebe um limite de **1 Mbps**.

```text
              SMTP TCP/25
                   │
                   ▼
             mark-connection
                   │
              smtp-mark
                   │
                   ▼
               mark-packet
                   │
              smtp-packet
                   │
                   ▼
              Queue Tree
                   │
                1 Mbps
```

> ⚠️ A Queue Tree precisa estar associada ao `packet-mark` correto e ao `parent` adequado ao sentido do tráfego. Em um cenário real, normalmente é necessário separar cuidadosamente **upload e download**.

---

# 🧠 Para memorizar

```text
MANGLE
  │
  ├── mark-connection
  │       ↓
  │   smtp-mark
  │
  └── mark-packet
          ↓
      smtp-packet
          │
          ▼
      Queue / QoS
```

### Regra mental

```text
Conexão → identifica o fluxo
Pacote   → identifica os pacotes desse fluxo
Queue    → aplica o tratamento
```

---

## ⚠️ Observação importante

Essa configuração **não limita a banda sozinha**.

O Mangle apenas **classifica e marca o tráfego**:

```text
Mangle
  ↓
marca
  ↓
Queue/QoS
  ↓
limita/prioriza
```

Portanto, `mark-packet` é o mecanismo de **classificação**; quem efetivamente aplica o limite de banda é o mecanismo de **fila/QoS**.
