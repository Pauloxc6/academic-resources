# 🔌 PPPoE

**PPPoE (Point-to-Point Protocol over Ethernet)** é um protocolo que permite transportar **sessões PPP através de uma rede Ethernet**.

É muito utilizado por **provedores de Internet (ISPs)** para estabelecer uma sessão individual com cada assinante, permitindo recursos como:

* autenticação do usuário;
* controle de acesso;
* gerenciamento de banda;
* contabilização do uso;
* identificação da sessão do assinante;
* atribuição de endereço IP.

---

# 🔗 PPP — Point-to-Point Protocol

O **PPP (Point-to-Point Protocol)** é um protocolo utilizado para transportar datagramas através de um **link ponto a ponto**.

```text
Nó A ───────────────── Nó B
       Link ponto a ponto
```

### 📌 Nó

Um **nó (node)** é qualquer dispositivo que participa de uma rede e pode enviar, receber ou encaminhar dados.

Exemplos:

* computador;
* roteador;
* switch;
* servidor;
* modem/ONT.

O PPP fornece mecanismos para:

* estabelecer uma conexão;
* autenticar os participantes;
* configurar parâmetros da conexão;
* transportar dados de protocolos de rede.

---

# 🌐 PPP sobre Ethernet

O PPP foi originalmente muito utilizado em conexões **discadas** e links ponto a ponto.

O PPPoE combina:

```text
PPP + Ethernet
```

permitindo utilizar os mecanismos do PPP em uma infraestrutura Ethernet.

```text
┌───────────────┐
│      PPP      │
├───────────────┤
│   Ethernet    │
└───────────────┘
```

Dessa forma, é possível criar uma **sessão PPP individual** sobre uma rede Ethernet.

---

# 🔐 PPPoE em provedores

Um dos principais motivos para o uso do PPPoE por provedores é permitir que cada cliente tenha uma **sessão autenticada individualmente**.

Exemplo:

```text
                 PROVEDOR
                    │
             ┌──────┴──────┐
             │ PPPoE Server│
             └──────┬──────┘
                    │
             Rede de acesso
                    │
          ┌─────────┼─────────┐
          │         │         │
         ONU       ONU       ONU
          │         │         │
       Cliente   Cliente   Cliente
```

Cada cliente pode estabelecer sua própria sessão:

```text
Cliente A → PPPoE Session A
Cliente B → PPPoE Session B
Cliente C → PPPoE Session C
```

---

# 🔑 Autenticação

O PPPoE pode utilizar mecanismos de autenticação do PPP, como:

* **PAP (Password Authentication Protocol)**
* **CHAP (Challenge Handshake Authentication Protocol)**

Exemplo:

```text
Cliente
   │
   │ Usuário + Senha
   ▼
Servidor PPPoE
   │
   ├── Autentica
   │
   └── Estabelece sessão
```

Após a autenticação, o provedor pode associar a sessão a informações do assinante e aplicar políticas de acesso.

---

# 🔄 Funcionamento do PPPoE

O estabelecimento de uma sessão PPPoE ocorre em duas fases principais.

## 1. Descoberta

Primeiro, o cliente precisa encontrar o servidor PPPoE e estabelecer uma sessão.

A descoberta utiliza mensagens específicas:

```text
PADI
 ↓
PADO
 ↓
PADR
 ↓
PADS
```

### PADI — PPPoE Active Discovery Initiation

O cliente procura por um servidor PPPoE.

```text
Cliente ───── PADI ─────►
```

---

### PADO — PPPoE Active Discovery Offer

O servidor PPPoE responde oferecendo o serviço.

```text
Cliente ◄──── PADO ───── Servidor
```

---

### PADR — PPPoE Active Discovery Request

O cliente solicita a criação de uma sessão.

```text
Cliente ───── PADR ─────► Servidor
```

---

### PADS — PPPoE Active Discovery Session-confirmation

O servidor confirma a criação da sessão e fornece um **Session ID**.

```text
Cliente ◄──── PADS ───── Servidor
```

A partir desse momento, a sessão PPPoE pode ser utilizada.

---

# 🔐 2. Sessão PPP

Depois da fase de descoberta, ocorre a negociação da sessão PPP.

De forma simplificada:

```text
PPPoE Discovery
      │
      ▼
Sessão PPP
      │
      ├── Autenticação
      │
      ├── Configuração
      │
      └── Transporte de dados
```

Os protocolos PPP envolvidos podem incluir:

```text
LCP
 │
 ├── Estabelecimento
 ├── Configuração
 └── Manutenção do link

Authentication
 │
 ├── PAP
 └── CHAP

NCP
 │
 └── Configuração dos protocolos de rede
```

---

# 📦 Encapsulamento

Uma forma simplificada de visualizar o encapsulamento:

```text
┌──────────────────────────┐
│ Ethernet Header          │
├──────────────────────────┤
│ PPPoE Header             │
├──────────────────────────┤
│ PPP Protocol             │
├──────────────────────────┤
│ Dados                    │
└──────────────────────────┘
```

O cabeçalho PPPoE possui **6 bytes**.

Além dele, existe o campo de protocolo PPP e os dados encapsulados.

---

# ⚠️ MTU

Uma consequência importante do PPPoE é o aumento do overhead em relação a uma conexão Ethernet tradicional.

A Ethernet normalmente utiliza:

```text
MTU = 1500 bytes
```

O PPPoE adiciona **8 bytes** de overhead, resultando normalmente em:

```text
MTU PPPoE = 1492 bytes
```

```text
1500 - 8 = 1492
```

Isso é importante em configurações de rede e pode causar problemas de comunicação quando determinados equipamentos ou aplicações não lidam corretamente com a redução da MTU.

---

# 🔴 Encerramento da sessão

Uma sessão PPPoE pode ser encerrada através de mensagens de término da descoberta.

### PADT — PPPoE Active Discovery Terminate

Indica que uma sessão PPPoE está sendo encerrada.

```text
Cliente ───── PADT ─────► Servidor
```

---

# 🏠 PPPoE em uma residência

Um cenário comum é:

```text
                 INTERNET
                    │
                    │
                Provedor
                    │
                   OLT
                    │
                Fibra óptica
                    │
                  ONT/ONU
                    │
                    ▼
                Roteador
                    │
              PPPoE Client
                    │
          Usuário + Senha
                    │
                    ▼
                Internet
```

O roteador pode atuar como **cliente PPPoE**, realizando a autenticação junto ao provedor.

---

# 🖥️ PPPoE no computador

Dependendo da arquitetura da rede, o próprio computador também pode estabelecer a sessão PPPoE.

```text
Computador
    │
    │ PPPoE
    ▼
Ethernet
    │
    ▼
Provedor
```

Entretanto, em redes residenciais é comum que o **roteador** seja responsável pela sessão PPPoE.

---

# 🔄 PPPoE x PPPoA

Outro protocolo relacionado é o **PPPoA (PPP over ATM)**.

A diferença principal está na tecnologia utilizada como transporte.

| Característica | PPPoE              | PPPoA                     |
| -------------- | ------------------ | ------------------------- |
| Nome           | PPP over Ethernet  | PPP over ATM              |
| Transporte     | Ethernet           | ATM                       |
| Uso histórico  | Redes Ethernet/DSL | Redes DSL baseadas em ATM |
| PPP            | Sim                | Sim                       |

```text
PPPoE
PPP
 ↓
Ethernet
```

```text
PPPoA
PPP
 ↓
ATM
```

> **PPPoA é associado às antigas infraestruturas DSL baseadas em ATM, enquanto PPPoE transporta PPP sobre Ethernet.**

---

# 🧠 Resumo do funcionamento

```text
             PPPoE
               │
       ┌───────┴────────┐
       │                │
   Discovery          Sessão
       │                │
       ▼                ▼
 PADI/PADO/       Autenticação
 PADR/PADS             │
                       ▼
                  Transporte
                    de dados
```

### 🔑 Fase de descoberta

```text
PADI → PADO → PADR → PADS
```

### 🔑 Fase de sessão

```text
LCP
 ↓
Autenticação
 ↓
NCP
 ↓
Transporte de dados
```

### 🔑 Encerramento

```text
PADT
```

---

# 🎯 Para memorizar

> **PPP** → protocolo para comunicação ponto a ponto.

> **PPPoE** → PPP transportado sobre Ethernet.

> **PPPoA** → PPP transportado sobre ATM.

> **PADI/PADO/PADR/PADS** → descoberta e estabelecimento da sessão PPPoE.

> **PADT** → encerramento da sessão.

> **PPPoE normalmente reduz a MTU de 1500 para 1492 bytes devido ao overhead de 8 bytes.**

> **Em provedores, PPPoE é muito utilizado para autenticar e gerenciar sessões individuais de assinantes.**
