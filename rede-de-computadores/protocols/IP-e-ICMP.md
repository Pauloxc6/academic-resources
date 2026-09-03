# 🌐 IP e ICMP

---

# 📡 Protocolo IP

**IP (Internet Protocol)** é um protocolo de comunicação responsável pelo **endereçamento e encaminhamento de pacotes** entre dispositivos e redes.

O IP permite que um pacote saia de uma rede de origem e seja encaminhado até uma rede de destino, podendo passar por diversos **roteadores** durante o caminho.

O IP pertence à **camada de rede** no modelo OSI e à **camada de Internet** no modelo TCP/IP.

---

## 🏗️ Modelo TCP/IP

| Camada | Nome          | Exemplos              | Função                                             |
| -----: | ------------- | --------------------- | -------------------------------------------------- |
|    `4` | Aplicação     | HTTP, HTTPS, FTP, DNS | Fornece serviços de rede diretamente às aplicações |
|    `3` | Transporte    | TCP, UDP              | Comunicação fim a fim entre processos/hosts        |
|    `2` | Internet      | IP, ICMP, IGMP        | Endereçamento e roteamento entre redes             |
|    `1` | Acesso à Rede | Ethernet, Wi-Fi, ARP  | Comunicação através do meio físico e enlace        |

### 🔎 Exemplos

```text
Aplicação
    │
    ├── HTTP
    ├── HTTPS
    ├── DNS
    └── FTP
         │
         ▼
Transporte
    │
    ├── TCP
    └── UDP
         │
         ▼
Internet
    │
    ├── IPv4
    ├── IPv6
    ├── ICMP
    └── IGMP
         │
         ▼
Acesso à Rede
    │
    ├── Ethernet
    ├── Wi-Fi
    └── ARP
```

> **Observação:** no modelo TCP/IP de 4 camadas, a camada de Internet corresponde aproximadamente à **camada de Rede (camada 3) do modelo OSI**.

---

# 📦 Funcionamento do IP

O IP é responsável principalmente por:

* **Endereçamento** dos dispositivos;
* **Encaminhamento (routing)** dos pacotes;
* Identificação da origem e do destino;
* Transporte de **datagramas IP** entre redes.

Exemplo:

```text
PC A
192.168.1.10
   │
   ▼
Roteador
   │
   ▼
Internet
   │
   ▼
Roteador
   │
   ▼
Servidor
203.0.113.10
```

O protocolo IP permite que os roteadores determinem **para onde o pacote deve ser encaminhado**.

---

# 🔢 IPv4

Um endereço IPv4 possui **32 bits**, normalmente representados em quatro octetos.

Exemplo:

```text
192.168.1.10
```

Representação binária:

```text
11000000.10101000.00000001.00001010
```

---

# 🌎 IPv6

O IPv6 utiliza endereços de **128 bits**.

Exemplo:

```text
2001:db8::10
```

O IPv6 foi desenvolvido, entre outros motivos, para solucionar a limitação de endereços existente no IPv4.

---

# ⚠️ IP é um protocolo não orientado à conexão

O IP não estabelece uma conexão antes de enviar os pacotes.

Ele trabalha com **datagramas**, e não garante por si só:

* entrega;
* ordem dos pacotes;
* retransmissão;
* ausência de duplicação;
* controle de congestionamento.

Essas funções podem ser fornecidas por protocolos de camadas superiores, como o **TCP**.

```text
IP
 │
 ├── Não garante entrega
 ├── Não garante ordem
 └── Não realiza retransmissão
```

---

# 📡 ICMP

**ICMP (Internet Control Message Protocol)** é um protocolo utilizado para **mensagens de controle, diagnóstico e comunicação de erros relacionados ao IP**.

Ele está associado à **camada de Internet** do modelo TCP/IP.

O ICMP é definido, para o ICMPv4 clássico, pela **RFC 792**.

---

## 🎯 Para que serve o ICMP?

O ICMP pode ser utilizado para:

* informar erros de entrega;
* indicar que um destino está inacessível;
* informar problemas de roteamento;
* realizar diagnósticos;
* verificar conectividade;
* auxiliar na descoberta do caminho até um destino.

---

# 🏓 ICMP e o Ping

Um dos usos mais conhecidos do ICMP é o comando:

```bash
ping 192.168.1.1
```

O `ping` utiliza principalmente:

```text
ICMP Echo Request
        ↓
     Servidor
        ↓
ICMP Echo Reply
```

Exemplo:

```text
Cliente                         Servidor
   │                               │
   │──── Echo Request ───────────►│
   │                               │
   │◄──── Echo Reply ─────────────│
   │                               │
```

Se o servidor responder, temos uma indicação de que existe **conectividade IP** entre os dois pontos.

> ⚠️ Um host não responder ao `ping` **não significa necessariamente que está offline**. Um firewall pode bloquear mensagens ICMP enquanto os serviços TCP/UDP continuam funcionando.

---

# 🚨 Principais mensagens ICMP

| Mensagem                    | Função                                             |
| --------------------------- | -------------------------------------------------- |
| **Echo Request**            | Solicita uma resposta para verificar conectividade |
| **Echo Reply**              | Responde a um Echo Request                         |
| **Destination Unreachable** | Indica que o destino não pôde ser alcançado        |
| **Time Exceeded**           | Indica que o TTL expirou                           |
| **Redirect**                | Informa uma possível rota melhor para um destino   |

---

# ⏱️ TTL e ICMP

O campo **TTL (Time To Live)** existe no cabeçalho IPv4.

A cada roteador atravessado, o TTL normalmente é decrementado:

```text
TTL = 64
   │
   ▼
Roteador
TTL = 63
   │
   ▼
Roteador
TTL = 62
   │
   ▼
Roteador
...
```

Quando o TTL chega a zero, o roteador descarta o pacote e normalmente envia uma mensagem ICMP:

```text
ICMP Time Exceeded
```

Esse mecanismo é utilizado pelo **traceroute/tracert** para descobrir os roteadores existentes no caminho.

---

# 🔍 IP x ICMP

| Característica                 | IP                                             | ICMP                             |
| ------------------------------ | ---------------------------------------------- | -------------------------------- |
| Função principal               | Endereçamento e encaminhamento                 | Controle, diagnóstico e erros    |
| Camada TCP/IP                  | Internet                                       | Internet                         |
| Possui endereços?              | Sim                                            | Utiliza IP para transporte       |
| Transporta dados de aplicação? | Transporta datagramas de protocolos superiores | Transporta mensagens de controle |
| Exemplo                        | IPv4 / IPv6                                    | Echo Request / Echo Reply        |
| Uso comum                      | Roteamento                                     | `ping` / `traceroute`            |

---

# 🧠 Relação entre IP e ICMP

Uma forma simples de entender:

```text
             CAMADA DE INTERNET
                     │
          ┌──────────┴──────────┐
          │                     │
         IP                    ICMP
          │                     │
   Endereçamento           Diagnóstico
   Roteamento              Mensagens de erro
   Datagramas              Controle
```

O **IP** é responsável pelo encaminhamento dos datagramas, enquanto o **ICMP** fornece mensagens relacionadas ao funcionamento e diagnóstico da comunicação IP.

---

# 🔥 Em Pentest e Redes

O ICMP pode ser utilizado durante reconhecimento para verificar se um host responde:

```bash
ping 192.168.1.10
```

Também pode ser observado com:

```bash
tcpdump -i eth0 icmp
```

ou:

```bash
wireshark
```

Em uma análise de rede, algumas mensagens ICMP podem fornecer informações importantes sobre:

* conectividade;
* filtragem por firewall;
* roteamento;
* existência de hosts;
* problemas de comunicação;
* caminho percorrido pelos pacotes.

---

# 📌 Resumo

```text
IP
│
├── Endereçamento
├── Roteamento
├── IPv4
└── IPv6

ICMP
│
├── Mensagens de controle
├── Mensagens de erro
├── Diagnóstico
├── Ping
└── Traceroute
```

### 🔑 Para memorizar

> **IP = leva o pacote até o destino.**

> **ICMP = informa o que está acontecendo com a comunicação IP.**
