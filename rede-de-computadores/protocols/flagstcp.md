# 🚦 Flags TCP

As **flags TCP** são bits presentes no cabeçalho TCP utilizados para controlar e indicar o estado de uma conexão.

Elas permitem, por exemplo, **iniciar uma conexão, confirmar o recebimento de dados, encerrá-la ou resetá-la**.

---

## 📋 Principais Flags

| Flag  | Nome                      | Função                                                          |
| ----- | ------------------------- | --------------------------------------------------------------- |
| `SYN` | Synchronize               | Inicia uma conexão TCP e sincroniza os números de sequência     |
| `ACK` | Acknowledgment            | Confirma o recebimento de dados/segmentos                       |
| `FIN` | Finish                    | Indica que o remetente deseja encerrar a conexão                |
| `RST` | Reset                     | Interrompe/reseta uma conexão imediatamente                     |
| `PSH` | Push                      | Solicita que os dados sejam entregues à aplicação imediatamente |
| `URG` | Urgent                    | Indica que existem dados urgentes                               |
| `ECE` | ECN Echo                  | Relacionada ao mecanismo de congestionamento ECN                |
| `CWR` | Congestion Window Reduced | Indica redução da janela de congestionamento                    |

---

# 🔄 Combinações de Flags

As flags podem aparecer combinadas no mesmo segmento TCP.

### `SYN-ACK` → `SA`

Combinação:

```text
SYN + ACK
```

É utilizada principalmente como **resposta ao primeiro `SYN` durante o estabelecimento de uma conexão TCP**.

Exemplo:

```text
Cliente                 Servidor
   │                       │
   │────── SYN ──────────►│
   │                       │
   │◄──── SYN + ACK ──────│
   │                       │
   │────── ACK ──────────►│
```

### ⚠️ Em varreduras TCP

Em um **TCP SYN Scan**, uma resposta `SYN-ACK` normalmente indica que a porta está **aberta**.

```text
SYN
 │
 ▼
Porta aberta
 │
 ▼
SYN-ACK
```

Porém, isso é uma interpretação específica do **SYN scan**, não uma regra geral de que todo `SYN-ACK` significa simplesmente "porta aberta".

---

## `RST-ACK` → `RA`

Combinação:

```text
RST + ACK
```

O `RST` indica que a conexão/segmento está sendo **resetado**.

Em um **TCP SYN Scan**, uma resposta `RST` ou `RST-ACK` normalmente indica que a porta está **fechada**.

```text
SYN
 │
 ▼
Porta fechada
 │
 ▼
RST / RST-ACK
```

> Portanto, no contexto de **Nmap/SYN scan**, `RA` pode ser interpretado como indicação de **porta fechada**. Fora desse contexto, `RST-ACK` não significa simplesmente "rejeita um pacote"; o significado depende do estado da conexão.

---

# 🤝 Estabelecimento da conexão TCP

O estabelecimento de uma conexão TCP utiliza o chamado **Three-Way Handshake**.

```text
Cliente                         Servidor
   │                               │
   │────────── SYN ──────────────►│
   │                               │
   │◄──────── SYN + ACK ──────────│
   │                               │
   │────────── ACK ──────────────►│
   │                               │
   │       CONEXÃO ESTABELECIDA    │
```

### 1. `SYN`

O cliente solicita o estabelecimento de uma conexão.

```text
Cliente → Servidor
SYN
```

### 2. `SYN-ACK`

O servidor aceita a solicitação e responde.

```text
Servidor → Cliente
SYN + ACK
```

### 3. `ACK`

O cliente confirma o recebimento da resposta.

```text
Cliente → Servidor
ACK
```

Após isso, a conexão TCP está estabelecida.

---

# 🔴 Encerramento da conexão

O encerramento normal de uma conexão TCP geralmente utiliza `FIN` e `ACK`.

Um exemplo típico:

```text
Cliente                         Servidor
   │                               │
   │────────── FIN ──────────────►│
   │                               │
   │◄────────── ACK ──────────────│
   │                               │
   │◄────────── FIN ──────────────│
   │                               │
   │────────── ACK ──────────────►│
   │                               │
   │       CONEXÃO ENCERRADA       │
```

Isso é frequentemente chamado de **Four-Way Handshake**, porque o fechamento envolve normalmente quatro segmentos.

---

# ⚡ RST — Reset

Diferentemente do `FIN`, o `RST` é utilizado para **encerrar/resetar uma conexão de forma abrupta**.

Exemplo:

```text
Cliente                         Servidor
   │                               │
   │────────── RST ──────────────►│
   │                               │
   │       CONEXÃO RESETADA        │
```

Pode ocorrer, por exemplo, quando um segmento chega a uma porta que não está aceitando conexões.

---

# 🔎 TCP em ferramentas de análise

Ao utilizar ferramentas como `tcpdump`, `Wireshark` ou `nmap`, é comum encontrar representações abreviadas:

| Representação | Flags     |
| ------------- | --------- |
| `S`           | SYN       |
| `A`           | ACK       |
| `F`           | FIN       |
| `R`           | RST       |
| `P`           | PSH       |
| `U`           | URG       |
| `SA`          | SYN + ACK |
| `FA`          | FIN + ACK |
| `RA`          | RST + ACK |

---

# 🧠 Resumo

### Estabelecimento

```text
SYN → SYN-ACK → ACK
```

### Comunicação

```text
Dados ↔ Dados ↔ Dados
```

### Encerramento normal

```text
FIN → ACK → FIN → ACK
```

### Reset

```text
RST
```

---

# 🎯 Para Pentest / Nmap

Em um **TCP SYN Scan**:

```text
        SYN
Cliente ───────────► Servidor

        SYN-ACK
Cliente ◄─────────── Servidor
   ↓
PORTA ABERTA
```

ou:

```text
        SYN
Cliente ───────────► Servidor

        RST / RST-ACK
Cliente ◄─────────── Servidor
   ↓
PORTA FECHADA
```

Uma ausência de resposta ou uma resposta `ICMP` específica pode indicar que a porta está **filtrada**, dependendo do comportamento do firewall.
