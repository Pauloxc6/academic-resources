# ☎️ VoIP — Voice over IP

**VoIP (Voice over Internet Protocol)**, ou **Voz sobre IP**, é uma tecnologia que permite transmitir **voz e outros tipos de mídia em tempo real através de redes IP**.

Em vez de utilizar exclusivamente uma rede telefônica tradicional, a comunicação é transformada em **dados digitais**, encapsulada em pacotes e transportada por uma rede IP.

```text
Voz
 ↓
Digitalização
 ↓
Codificação
 ↓
Pacotes IP
 ↓
Rede
 ↓
Pacotes recebidos
 ↓
Decodificação
 ↓
Voz
```

O VoIP pode funcionar através da Internet ou de uma **rede IP privada**, como uma rede corporativa.

---

# 🌐 Funcionamento básico

Durante uma chamada VoIP, existem diferentes etapas.

```text
┌─────────────┐
│ Telefone IP │
└──────┬──────┘
       │
       │ Sinalização
       ▼
┌─────────────┐
│ Servidor/PBX│
└──────┬──────┘
       │
       │ Estabelecimento da chamada
       ▼
┌─────────────┐
│ Outro       │
│ telefone    │
└─────────────┘

        ↓

     Durante a chamada

Voz → Codec → RTP → UDP/IP → Rede → RTP → Codec → Voz
```

É importante separar duas funções:

```text
Sinalização → controla a chamada
Mídia        → transporta áudio/vídeo
```

---

# 📡 Protocolos utilizados

O VoIP não é um único protocolo. É um conjunto de tecnologias e protocolos que trabalham juntos.

## 📞 Sinalização

A sinalização é responsável por controlar a chamada.

Entre os protocolos utilizados estão:

```text
SIP
H.323
MGCP
H.248 / MEGACO
Jingle
IAX2
```

---

# 📞 SIP — Session Initiation Protocol

O **SIP** é um dos protocolos de sinalização mais utilizados em sistemas VoIP.

Ele pode ser utilizado para:

* iniciar chamadas;
* localizar usuários;
* negociar parâmetros da sessão;
* modificar uma chamada;
* encerrar chamadas;
* registrar dispositivos.

Exemplo simplificado:

```text
Telefone A                 Servidor/Telefone B
    │                              │
    │──────── INVITE ─────────────►│
    │◄──────── 180 Ringing ────────│
    │◄──────── 200 OK ─────────────│
    │──────── ACK ────────────────►│
    │                              │
    │══════ ÁUDIO / RTP ══════════│
    │                              │
    │──────── BYE ────────────────►│
    │◄──────── 200 OK ─────────────│
```

> **SIP não é responsável por transportar diretamente o áudio da chamada.** Ele é principalmente um protocolo de **sinalização**.

---

# 🎙️ Transporte de mídia

Depois que a chamada é estabelecida, o áudio precisa ser transportado.

Um dos principais protocolos utilizados é:

```text
RTP
```

### RTP — Real-time Transport Protocol

O **RTP** transporta dados de mídia em tempo real, como:

* áudio;
* vídeo;
* outros fluxos multimídia.

Normalmente, o RTP utiliza **UDP** como protocolo de transporte.

```text
Voz
 ↓
Codec
 ↓
RTP
 ↓
UDP
 ↓
IP
```

---

# 📊 RTCP

O **RTCP (RTP Control Protocol)** trabalha junto com o RTP para fornecer informações de controle e monitoramento da sessão de mídia.

Pode fornecer informações relacionadas a:

* qualidade da transmissão;
* perda de pacotes;
* jitter;
* sincronização;
* identificação dos participantes.

Simplificando:

```text
RTP
 ↓
Transporta a mídia

RTCP
 ↓
Monitora/controla a sessão
```

---

# 🚀 Por que UDP é utilizado?

Chamadas de voz são aplicações **sensíveis à latência**.

Imagine uma chamada em que um pacote de áudio é perdido:

```text
Pacote 1 → recebido
Pacote 2 → perdido
Pacote 3 → recebido
Pacote 4 → recebido
```

Se o sistema esperasse uma retransmissão do pacote 2 antes de continuar:

```text
Pacote 1
   ↓
Pacote 2 → retransmissão
   ↓
Pacote 3
```

isso poderia introduzir atraso perceptível.

Por isso, o RTP normalmente utiliza UDP, permitindo que a aplicação priorize a **continuidade e baixa latência**.

> UDP não garante a entrega. Em aplicações VoIP, é preferível muitas vezes perder um pequeno trecho de áudio a introduzir uma grande espera para retransmiti-lo.

---

# 🎚️ Codecs

Antes de ser transportada, a voz precisa ser **digitalizada e codificada**.

Para isso são utilizados **codecs**.

Exemplos:

```text
G.711
G.729
Opus
G.722
AMR
```

O codec influencia:

* qualidade;
* consumo de banda;
* latência;
* compressão;
* quantidade de dados transmitidos.

Exemplo:

```text
Voz
 ↓
Codec
 ↓
Dados digitais
 ↓
RTP
 ↓
UDP
 ↓
IP
```

---

# 🏢 PBX / IP-PBX

Em uma rede corporativa, é comum existir uma **IP-PBX**, responsável por gerenciar as chamadas.

Exemplo:

```text
             ┌──────────────┐
             │   IP-PBX     │
             └──────┬───────┘
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
    ┌──────────┐        ┌──────────┐
    │Telefone A│        │Telefone B│
    └──────────┘        └──────────┘
```

A IP-PBX pode realizar funções como:

* ramais;
* encaminhamento;
* filas;
* correio de voz;
* conferências;
* autenticação;
* roteamento de chamadas.

---

# 🔐 VoIP pode ser atacado?

Sim.

Assim como qualquer infraestrutura conectada à rede, sistemas VoIP podem apresentar vulnerabilidades.

Possíveis problemas incluem:

* enumeração de ramais;
* credenciais fracas;
* captura de sinalização;
* interceptação de mídia;
* spoofing;
* sequestro de sessão;
* fraude telefônica;
* chamadas não autorizadas;
* ataques de negação de serviço;
* configuração inadequada de SIP;
* exposição de servidores VoIP à Internet.

---

# 🕵️ SIP e segurança

O SIP merece atenção durante um pentest autorizado porque informações de sinalização podem revelar detalhes da infraestrutura.

Dependendo da configuração, pode ser possível descobrir:

```text
Servidor SIP
     ↓
 ┌─────────────┐
 │ Ramais      │
 │ Domínios    │
 │ Métodos     │
 │ Extensões   │
 │ Dispositivos│
 └─────────────┘
```

Um problema comum é a **enumeração de ramais**.

Por exemplo:

```text
1001 → existe
1002 → existe
1003 → não existe
1004 → existe
```

Isso pode fornecer informações úteis para um atacante.

---

# 🎭 SIP Spoofing

Em determinadas configurações inseguras, um atacante pode tentar manipular mensagens SIP para se passar por outro participante.

Conceitualmente:

```text
Cliente A
   │
   │ SIP
   ▼
Atacante
   │
   │ SIP manipulado
   ▼
Cliente B
```

Porém, **não significa que todo ambiente SIP seja automaticamente vulnerável a MITM ou spoofing**.

A possibilidade depende de fatores como:

* autenticação;
* criptografia;
* arquitetura da rede;
* configuração do servidor;
* proteção do tráfego;
* controle de acesso.

---

# 🔒 Proteção do VoIP

Algumas tecnologias podem ser utilizadas para proteger a comunicação.

### SIP sobre TLS

Protege a **sinalização SIP**:

```text
SIP
 ↓
TLS
 ↓
TCP/IP
```

### SRTP

O **SRTP (Secure Real-time Transport Protocol)** protege a mídia transportada pelo RTP.

```text
Áudio
 ↓
SRTP
 ↓
UDP/IP
```

Assim:

```text
SIP + TLS → protege sinalização
SRTP      → protege mídia
```

São problemas diferentes e precisam de proteções diferentes.

---

# 🔎 Enumeração em pentest

Durante um pentest autorizado, podemos primeiro verificar portas relacionadas ao serviço.

Por exemplo:

```bash
nmap -sU -p5060,5061 <IP>
```

Portas comuns:

```text
5060 → SIP
5061 → SIP sobre TLS
```

Também é possível utilizar ferramentas específicas para analisar SIP, dependendo do cenário e da autorização.

Uma ferramenta bastante conhecida em ambientes de laboratório é o **SIPVicious**, que possui ferramentas para descoberta e enumeração de dispositivos/serviços SIP.

---

# 🧪 Metasploit

O Metasploit possui módulos relacionados a VoIP/SIP.

Por exemplo, módulos de teste podem ser utilizados em **ambientes autorizados** para estudar problemas de sinalização.

A ideia geral de um ataque de spoofing é:

```text
Atacante
   │
   │ Mensagem SIP manipulada
   ▼
Servidor/Telefone
   │
   ▼
Comportamento inesperado
```

> Ferramentas de spoofing devem ser utilizadas somente em laboratórios ou redes para as quais você possui autorização.

---

# 🧩 Arquitetura completa

Uma chamada VoIP pode ser entendida assim:

```text
                 SINALIZAÇÃO
            ┌──────────────────┐
            │       SIP        │
            └────────┬─────────┘
                     │
                     ▼
             Estabelece chamada
                     │
                     ▼
Voz → Codec → RTP → UDP → IP → Rede
                     │
                     ▼
                  RTCP
             monitora a mídia
```

Ou, de forma resumida:

```text
┌────────────────────────────────────┐
│             APLICAÇÃO              │
│                                    │
│     SIP       RTP       RTCP       │
└────────────────┬───────────────────┘
                 │
                 ▼
             UDP / TCP
                 │
                 ▼
                IP
                 │
                 ▼
               Rede
```

---

# 🧠 SIP × RTP × RTCP

| Protocolo | Função                                    |
| --------- | ----------------------------------------- |
| **SIP**   | Sinalização e controle da chamada         |
| **RTP**   | Transporte da mídia                       |
| **RTCP**  | Controle/monitoramento do RTP             |
| **UDP**   | Transporte normalmente utilizado pelo RTP |

---

# 🧠 Para memorizar

```text
VoIP
│
├── 📞 Sinalização
│      ├── SIP
│      ├── H.323
│      ├── MGCP
│      └── H.248/MEGACO
│
├── 🎙️ Mídia
│      └── RTP
│
├── 📊 Controle
│      └── RTCP
│
└── 🚀 Transporte
       └── UDP
```

### Fluxo principal

```text
SIP
 ↓
Estabelece a chamada
 ↓
Codec
 ↓
RTP
 ↓
UDP
 ↓
IP
```

### Segurança

```text
SIP + TLS → sinalização protegida
SRTP      → áudio/vídeo protegido
```

> **VoIP = voz/multimídia sobre redes IP.**
> **SIP = sinalização.**
> **RTP = mídia.**
> **RTCP = controle/monitoramento da mídia.**
> **UDP = transporte comum para RTP.**
