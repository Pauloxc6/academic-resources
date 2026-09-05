# ⭐ Privilégios de Conexões nas Queues

O **Mangle** pode ser utilizado para identificar determinado tráfego e atribuir uma prioridade a ele através de **marcas de conexão** e **marcas de pacote**.

Neste exemplo, o tráfego relacionado ao endereço `192.168.100.1` é identificado como **VoIP** e posteriormente recebe prioridade máxima em uma **Simple Queue**.

---

## 🔄 Fluxo

```text
              Tráfego
                 │
                 ▼
             PREROUTING
                 │
        ┌────────┴────────┐
        │                 │
 src = 192.168.100.1   dst = 192.168.100.1
        │                 │
        └────────┬────────┘
                 ▼
          Con-VoIP
       (connection-mark)
                 │
                 ▼
          VoIP
       (packet-mark)
                 │
                 ▼
          Simple Queue
                 │
           priority=1
                 │
                 ▼
          Tráfego priorizado
```

---

# 1. Marcando conexões de origem

```routeros
/ip firewall mangle add \
    chain=prerouting \
    src-address=192.168.100.1 \
    action=mark-connection \
    new-connection-mark=Con-VoIP \
    passthrough=yes
```

Essa regra identifica conexões cujo **endereço de origem** é `192.168.100.1`.

A conexão recebe a marca:

```text
Con-VoIP
```

---

# 2. Marcando conexões de destino

```routeros
/ip firewall mangle add \
    chain=prerouting \
    dst-address=192.168.100.1 \
    action=mark-connection \
    new-connection-mark=Con-VoIP \
    passthrough=yes
```

Essa regra faz o mesmo para o tráfego cujo **destino** é `192.168.100.1`.

Assim, o tráfego é identificado nos dois sentidos:

```text
192.168.100.1 → destino
       ↓
    Con-VoIP

origem → 192.168.100.1
       ↓
    Con-VoIP
```

Isso é importante para que tanto o tráfego **indo para** o equipamento VoIP quanto o tráfego **retornando dele** possa receber a classificação.

---

# 3. Marcando os pacotes

Depois que a conexão recebeu `Con-VoIP`, os pacotes pertencentes a ela podem ser marcados:

```routeros
/ip firewall mangle add \
    chain=prerouting \
    connection-mark=Con-VoIP \
    action=mark-packet \
    new-packet-mark=VoIP \
    passthrough=no
```

Agora temos:

```text
Connection Mark
      │
      ▼
  Con-VoIP
      │
      ▼
 Packet Mark
      │
      ▼
    VoIP
```

A marca `VoIP` poderá ser utilizada posteriormente pela Queue.

---

# 4. Criando a Simple Queue

```routeros
/queue simple add \
    name="VoIP" \
    target=ether1,ether4 \
    packet-marks=VoIP \
    priority=1/1 \
    max-limit=50M/50M
```

Essa queue procura pacotes que possuem:

```text
packet-mark=VoIP
```

e aplica:

```text
priority=1/1
```

---

## ⭐ Priority

No RouterOS, a prioridade das queues vai de:

```text
1 → maior prioridade
8 → menor prioridade
```

Portanto:

```text
priority=1/1
```

atribui a maior prioridade possível em cada direção da Simple Queue.

### Exemplo

```text
Prioridade

1  ███████████████  ← maior
2  ██████████████
3  █████████████
4  ████████████
5  ███████████
6  ██████████
7  █████████
8  ████████          ← menor
```

> A prioridade **não significa que a queue sempre terá 100% da banda antes das outras**. Ela influencia a distribuição de banda quando existe competição entre queues sob o mesmo parent/limite relevante.

---

# 🚦 `max-limit=50M/50M`

Define o limite máximo da queue:

```text
Upload:   50 Mbps
Download: 50 Mbps
```

Portanto, prioridade e limite são coisas diferentes:

```text
priority=1
     ↓
"Atenda esta queue antes das de menor prioridade"

max-limit=50M
     ↓
"Não ultrapasse 50 Mbps"
```

---

# 🧠 Funcionamento completo

```text
┌───────────────────────────────┐
│       Equipamento VoIP        │
│       192.168.100.1           │
└───────────────┬───────────────┘
                │
                ▼
         Firewall Mangle
                │
                ▼
       connection-mark
          Con-VoIP
                │
                ▼
          packet-mark
             VoIP
                │
                ▼
       ┌─────────────────┐
       │  Simple Queue   │
       │                 │
       │ Priority: 1     │
       │ Limit: 50 Mbps  │
       └─────────────────┘
                │
                ▼
          Tráfego VoIP
```

---

# 📌 Resumo

| Configuração                | Função                                    |
| --------------------------- | ----------------------------------------- |
| `src-address=192.168.100.1` | Identifica tráfego originado pelo VoIP    |
| `dst-address=192.168.100.1` | Identifica tráfego destinado ao VoIP      |
| `mark-connection`           | Marca a conexão                           |
| `Con-VoIP`                  | Marca da conexão                          |
| `mark-packet`               | Marca os pacotes                          |
| `VoIP`                      | Marca dos pacotes                         |
| `packet-marks=VoIP`         | Faz a queue trabalhar sobre esses pacotes |
| `priority=1/1`              | Maior prioridade                          |
| `max-limit=50M/50M`         | Limite máximo de 50 Mbps                  |

### Para memorizar

```text
Mangle
  │
  ├── Identifica conexão
  │       ↓
  │   Con-VoIP
  │
  ├── Identifica pacotes
  │       ↓
  │      VoIP
  │
  └── Queue
          ↓
    priority=1
          ↓
    maior prioridade
```

> ⚠️ **Observação:** se `192.168.100.1` for apenas um dispositivo VoIP, essa classificação é específica para ele. Se você quiser classificar **todo o tráfego VoIP independentemente do IP do telefone/PBX**, pode ser mais adequado identificar o tráfego por portas/protocolos, DSCP ou outros critérios.
