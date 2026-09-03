# 🌐 TCP e UDP

Os protocolos **TCP (Transmission Control Protocol)** e **UDP (User Datagram Protocol)** pertencem à **camada de transporte** do modelo TCP/IP.

A camada de transporte é responsável, entre outras coisas, pela comunicação **processo a processo**, utilizando **portas** para identificar os serviços de origem e destino.

De forma simplificada:

```text
Aplicação
   │
   ▼
TCP / UDP
   │
   ▼
IP
   │
   ▼
Rede
```

Na Internet, muitas aplicações funcionam através de um modelo de **requisição e resposta**.

Por exemplo, ao acessar um site:

```text
Cliente                         Servidor
   │                               │
   │────── Requisição HTTP ──────►│
   │                               │
   │◄────── Resposta HTTP ─────────│
   │                               │
```

O HTTP, entretanto, não é responsável sozinho pelo transporte dos dados. Ele pode utilizar **TCP** ou, no caso do **HTTP/3**, **QUIC sobre UDP**.

---

# 📦 UDP — User Datagram Protocol

O **UDP** é um protocolo de transporte **orientado a datagramas e não orientado à conexão**.

Sua principal característica é a **simplicidade e baixa sobrecarga**.

O UDP não estabelece uma conexão antes de enviar os dados e não fornece mecanismos próprios de:

* confirmação de recebimento;
* retransmissão;
* ordenação dos dados;
* controle de fluxo;
* controle de congestionamento como o TCP.

Portanto, se um datagrama for perdido, duplicado ou chegar fora de ordem, o próprio UDP **não corrige o problema**.

```text
Cliente                         Servidor
   │                               │
   │──── Datagram 1 ─────────────►│
   │──── Datagram 2 ──────────X   │  ← perdido
   │──── Datagram 3 ─────────────►│
   │                               │

UDP não retransmite o Datagram 2
```

---

# ⚡ Características do UDP

* Não orientado à conexão;
* Não possui handshake;
* Não garante entrega;
* Não garante ordenação;
* Não realiza retransmissão;
* Possui baixo overhead;
* Utiliza portas;
* Trabalha com datagramas.

O UDP pode enviar dados para diferentes destinos sem precisar estabelecer uma conexão TCP individual para cada comunicação.

> Isso não significa que UDP seja “melhor” ou “pior” que TCP. Ele é adequado para aplicações que priorizam **baixa latência e simplicidade**, ou que implementam seus próprios mecanismos de confiabilidade.

---

# 📡 Exemplos de utilização do UDP

Alguns protocolos e aplicações utilizam UDP:

| Protocolo/Aplicação | Uso                                     |
| ------------------- | --------------------------------------- |
| **DNS**             | Resolução de nomes                      |
| **DHCP**            | Configuração automática de rede         |
| **SNMP**            | Gerenciamento de dispositivos           |
| **NTP**             | Sincronização de horário                |
| **RTP**             | Transporte de áudio/vídeo em tempo real |
| **QUIC**            | Transporte utilizado pelo HTTP/3        |

Exemplo:

```text
Cliente
   │
   │ UDP
   ▼
Servidor DNS
```

---

# 🔵 TCP — Transmission Control Protocol

O **TCP** é um protocolo de transporte **orientado à conexão e confiável**.

Antes de transmitir dados normalmente, os dois hosts estabelecem uma conexão através do **Three-Way Handshake**.

```text
Cliente                         Servidor
   │                               │
   │──────── SYN ─────────────────►│
   │                               │
   │◄────── SYN + ACK ─────────────│
   │                               │
   │──────── ACK ─────────────────►│
   │                               │
   │       Conexão estabelecida    │
```

---

# 🤝 Three-Way Handshake

### 1. SYN

O cliente envia um segmento com a flag:

```text
SYN
```

Isso inicia o processo de estabelecimento da conexão.

```text
Cliente ───── SYN ─────► Servidor
```

---

### 2. SYN + ACK

O servidor responde:

```text
SYN + ACK
```

Indicando que recebeu o SYN e também deseja estabelecer a conexão.

```text
Cliente ◄── SYN + ACK ── Servidor
```

---

### 3. ACK

O cliente envia:

```text
ACK
```

A conexão está estabelecida.

```text
Cliente ───── ACK ─────► Servidor
```

---

# 🛡️ Confiabilidade do TCP

O TCP fornece mecanismos para garantir uma transmissão confiável.

Entre eles:

* **Sequence Number**;
* **Acknowledgment Number**;
* retransmissão;
* detecção de segmentos perdidos;
* controle de fluxo;
* controle de congestionamento;
* ordenação dos dados.

Exemplo:

```text
Segmentos enviados:

1 ───────────────►
2 ───────────────►
3 ───────X          ← perdido
4 ───────────────►
```

O TCP consegue detectar a perda e realizar a retransmissão necessária.

```text
3 ───────────────►
```

Assim, a aplicação recebe os dados na ordem correta.

---

# 🔢 Sequence Number

Cada byte transmitido pelo TCP é associado a números de sequência.

Isso permite ao TCP saber:

```text
Qual dado foi enviado?
Qual dado foi recebido?
Qual dado está faltando?
Em qual ordem os dados devem ser entregues?
```

Exemplo simplificado:

```text
1000 → dados
1100 → dados
1200 → dados
```

Se um segmento correspondente à sequência `1100` for perdido, o TCP consegue identificar a lacuna.

---

# ✅ ACK — Acknowledgment

O **ACK** é utilizado para confirmar o recebimento dos dados.

```text
Cliente ───── Dados ─────► Servidor
Cliente ◄──── ACK ──────── Servidor
```

Isso permite ao TCP acompanhar quais dados foram recebidos.

---

# 🌊 Controle de fluxo

O TCP também possui **controle de fluxo**, evitando que um transmissor envie dados mais rapidamente do que o receptor consegue processar.

Um dos mecanismos utilizados é a **janela de recepção (receive window)**.

```text
Transmissor
     │
     │ Dados
     ▼
┌─────────────┐
│   Receptor  │
│   Buffer    │
└─────────────┘
```

---

# 🚦 Controle de congestionamento

O TCP também possui mecanismos para controlar a quantidade de dados enviados de acordo com as condições da rede.

O objetivo é evitar que o transmissor sobrecarregue a rede.

Isso é diferente de **controle de fluxo**:

```text
Controle de fluxo
→ capacidade do receptor

Controle de congestionamento
→ capacidade/condições da rede
```

---

# 🔚 Encerramento da conexão

O encerramento normal de uma conexão TCP geralmente utiliza `FIN` e `ACK`.

Uma representação simplificada:

```text
Cliente                         Servidor
   │                               │
   │──────── FIN ────────────────►│
   │◄─────── ACK ─────────────────│
   │                               │
   │◄─────── FIN ─────────────────│
   │──────── ACK ────────────────►│
   │                               │
   │       Conexão encerrada       │
```

Já o **RST (Reset)** pode ser utilizado para encerrar ou rejeitar uma conexão de maneira abrupta.

---

# 📦 TCP vs UDP

| Característica               | TCP                 | UDP                     |
| ---------------------------- | ------------------- | ----------------------- |
| Conexão                      | Orientado à conexão | Não orientado à conexão |
| Handshake                    | ✅                   | ❌                       |
| Confiabilidade               | ✅                   | ❌                       |
| Ordenação                    | ✅                   | ❌                       |
| Retransmissão                | ✅                   | ❌                       |
| Controle de fluxo            | ✅                   | ❌                       |
| Controle de congestionamento | ✅                   | ❌                       |
| Unidade de dados             | Segmento            | Datagrama               |
| Overhead                     | Maior               | Menor                   |
| Latência                     | Geralmente maior    | Geralmente menor        |
| Portas                       | ✅                   | ✅                       |

---

# 🔌 Portas

Tanto TCP quanto UDP utilizam **portas** para identificar processos/serviços.

Exemplo:

```text
192.168.1.10:443
```

Onde:

```text
192.168.1.10 → endereço IP
443           → porta
```

Uma mesma numeração de porta pode existir simultaneamente em TCP e UDP, pois são espaços de portas separados.

Por exemplo:

```text
TCP/53
UDP/53
```

são endpoints diferentes.

---

# 🌐 Exemplos práticos

### HTTP/1.1 e HTTP/2

Tradicionalmente utilizam:

```text
HTTP
 ↓
TCP
 ↓
IP
```

### HTTP/3

Utiliza:

```text
HTTP/3
 ↓
QUIC
 ↓
UDP
 ↓
IP
```

Isso mostra que **UDP não significa necessariamente comunicação sem confiabilidade em toda a aplicação**.

O QUIC, por exemplo, implementa mecanismos próprios de confiabilidade, ordenação e controle de congestionamento sobre UDP.

---

# 🧠 Analogia

Imagine o envio de uma encomenda.

### TCP

```text
"Enviei a encomenda 1.
Você recebeu?"

"Sim."

"Agora envio a 2."

"Recebi."
```

Existe confirmação, controle e organização.

### UDP

```text
"Vou enviar várias encomendas."
      ↓
Envia
Envia
Envia
```

Não existe uma confirmação fornecida pelo próprio UDP para cada datagrama.

---

# 🧠 Para memorizar

```text
TCP
│
├── Conexão
├── Handshake
├── ACK
├── Sequence Number
├── Retransmissão
├── Ordenação
├── Controle de fluxo
└── Controle de congestionamento
```

```text
UDP
│
├── Datagramas
├── Sem conexão
├── Sem handshake
├── Sem ACK próprio
├── Sem retransmissão própria
└── Baixo overhead
```

### Regra rápida

> **TCP = confiabilidade e controle.**
> **UDP = simplicidade e baixa sobrecarga.**

E lembre-se:

> **TCP e UDP não são protocolos de aplicação. São protocolos da camada de transporte.**
