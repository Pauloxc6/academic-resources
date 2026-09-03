# 🖥️ SNMP — Simple Network Management Protocol

O **SNMP (Simple Network Management Protocol)** é um protocolo da **camada de aplicação** utilizado para **monitorar e gerenciar dispositivos de rede e sistemas**.

Pode ser utilizado para obter informações de:

* Roteadores;
* Switches;
* Servidores;
* Impressoras;
* Firewalls;
* Access Points;
* Interfaces de rede;
* Sistemas operacionais;
* Outros dispositivos compatíveis com SNMP.

O SNMP utiliza normalmente **UDP**, sendo tradicionalmente associado às portas:

```text
UDP/161 → consultas e operações SNMP
UDP/162 → traps e notificações
```

---

# 🏗️ Arquitetura do SNMP

O funcionamento do SNMP envolve principalmente dois componentes:

```text
┌─────────────────────┐
│   SNMP Manager      │
│     (Gerente)       │
└──────────┬──────────┘
           │
           │ SNMP
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
┌─────────┐  ┌─────────┐
│ Agent   │  │ Agent   │
│ Switch  │  │ Router  │
└─────────┘  └─────────┘
```

### SNMP Manager

É o sistema responsável por **consultar e gerenciar** os dispositivos.

Exemplos:

* Sistema de monitoramento;
* NMS (Network Management System);
* Servidor de gerenciamento.

### SNMP Agent

É o software executado no dispositivo monitorado.

Ele coleta informações do equipamento e responde às solicitações do gerente.

---

# 📚 MIB — Management Information Base

A **MIB (Management Information Base)** é uma estrutura hierárquica que define os **objetos gerenciáveis** disponíveis através do SNMP.

Cada informação é identificada por um **OID (Object Identifier)**.

Exemplo:

```text
MIB
 │
 └── system
      ├── sysDescr
      ├── sysObjectID
      ├── sysUpTime
      ├── sysContact
      ├── sysName
      └── sysLocation
```

Os OIDs são representados hierarquicamente.

Exemplo:

```text
1.3.6.1.2.1.1.5
```

Esse OID corresponde ao objeto `sysName`, utilizado para identificar o nome do dispositivo.

> **MIB ≠ banco de dados tradicional.**
> A MIB funciona como uma definição/estrutura dos objetos que podem ser consultados ou modificados pelo SNMP. Os valores desses objetos ficam mantidos pelo agente/dispositivo.

---

# 🔄 Funcionamento

Um exemplo de consulta:

```text
┌──────────────┐
│ SNMP Manager │
└──────┬───────┘
       │
       │ GET → OID
       ▼
┌──────────────┐
│ SNMP Agent   │
│   Router     │
└──────┬───────┘
       │
       │ valor do OID
       ▼
┌──────────────┐
│ SNMP Manager │
└──────────────┘
```

Por exemplo:

```text
Manager → GET sysName
Agent   → "router01"
```

---

# 📦 SNMP PDUs

A comunicação SNMP utiliza **PDU (Protocol Data Unit)** para transportar operações e informações.

## GetRequest

Solicita o valor de um ou mais objetos da MIB.

```text
Manager → GET → Agent
Agent   → Response
```

Exemplo:

```text
GET sysName
```

---

## GetNextRequest

Solicita o próximo objeto disponível na árvore da MIB.

É muito utilizado para **percorrer a estrutura da MIB**.

```text
GETNEXT
   ↓
OID 1
   ↓
OID 2
   ↓
OID 3
   ↓
OID 4
```

---

## GetBulk

Disponível a partir do **SNMPv2**, permite solicitar vários objetos de uma vez.

É muito útil para percorrer grandes partes da MIB de maneira mais eficiente.

---

## SetRequest

Permite alterar o valor de um objeto da MIB, desde que o agente permita escrita.

```text
Manager
   │
   │ SET
   ▼
Agent
   │
   ▼
Configuração alterada
```

Por isso, uma comunidade com permissão de escrita pode representar um risco significativo.

---

## Response

É a resposta enviada pelo agente ao gerente após uma solicitação.

```text
Manager → GET
Agent   → RESPONSE
```

---

## Trap

Um **Trap** é uma notificação enviada pelo agente **sem que o gerente tenha solicitado diretamente aquela informação**.

Exemplo:

```text
Switch
  │
  │ Interface caiu
  ▼
SNMP Trap
  │
  ▼
SNMP Manager
```

Pode ser utilizado para informar eventos como:

* Interface indisponível;
* Falha de hardware;
* Alteração de estado;
* Problemas de serviço.

---

## Inform

O **InformRequest**, introduzido no SNMPv2, é semelhante ao Trap, mas possui confirmação pelo destinatário.

```text
Agent → INFORM → Manager
Agent ← RESPONSE ← Manager
```

---

# 🔐 Versões do SNMP

Existem três versões principais:

```text
SNMPv1
   ↓
SNMPv2
   ↓
SNMPv3
```

---

# 🔴 SNMPv1

É a versão mais antiga e possui mecanismos de segurança bastante limitados.

Utiliza **community strings** para controlar o acesso.

Exemplos tradicionais:

```text
public
private
```

A comunicação não possui criptografia.

Portanto, uma community string utilizada no SNMPv1 pode ser capturada durante a comunicação.

---

# 🟠 SNMPv2c

É importante diferenciar:

```text
SNMPv2
SNMPv2c
```

O **SNMPv2c** é a variante baseada em **community strings** que se tornou amplamente utilizada.

Ela trouxe melhorias principalmente em:

* desempenho;
* operações em massa;
* tratamento de erros;
* `GetBulk`.

Porém, **SNMPv2c continua sem criptografia e sem autenticação forte**.

---

# 🟢 SNMPv3

O **SNMPv3** introduziu mecanismos de segurança muito mais robustos.

Dependendo da configuração, pode fornecer:

* autenticação;
* integridade;
* criptografia;
* controle de acesso.

Os níveis de segurança mais conhecidos são:

| Nível          | Autenticação | Criptografia |
| -------------- | ------------ | ------------ |
| `noAuthNoPriv` | ❌            | ❌            |
| `authNoPriv`   | ✅            | ❌            |
| `authPriv`     | ✅            | ✅            |

O modo mais seguro normalmente é:

```text
authPriv
```

---

# 🔑 Community String

Nas versões **SNMPv1 e SNMPv2c**, a community string é utilizada para controlar o acesso.

Exemplos:

```text
public
private
```

Tradicionalmente:

```text
public  → leitura (RO)
private → escrita (RW)
```

⚠️ Isso é apenas uma **configuração tradicional**, não uma regra obrigatória.

Uma community string não deve ser tratada exatamente como uma senha moderna, pois nas versões v1/v2c ela não fornece autenticação criptograficamente forte.

---

# 🔎 SNMP em Pentest

O SNMP pode ser muito interessante durante um **pentest autorizado**, principalmente quando o serviço está exposto com configurações inseguras.

O primeiro passo é verificar as portas:

```bash
nmap -sU -p161,162 <IP>
```

Também podemos tentar identificar informações do serviço:

```bash
nmap -sU -p161 --script snmp-info <IP>
```

---

# 🕵️ Enumeração com snmp-check

Uma ferramenta bastante conhecida é:

```bash
snmp-check
```

Ajuda a consultar diversas informações disponíveis através do SNMP.

Exemplo:

```bash
snmp-check <IP>
```

Também é possível especificar uma community string:

```bash
snmp-check -c public <IP>
```

> O resultado depende das permissões e da configuração do agente SNMP.

---

# 🔍 snmpwalk

Outra ferramenta extremamente útil é o:

```bash
snmpwalk
```

Exemplo:

```bash
snmpwalk -v2c -c public <IP>
```

Podemos consultar um OID específico:

```bash
snmpwalk -v2c -c public <IP> 1.3.6.1.2.1.1
```

Isso pode permitir enumerar objetos relacionados ao sistema.

---

# 🎯 Informações que podem ser expostas

Quando o SNMP está configurado de maneira inadequada, podem aparecer informações como:

### 🖥️ Sistema

* hostname;
* descrição do sistema;
* versão;
* uptime;
* localização;
* contato administrativo.

### 🌐 Rede

* interfaces;
* endereços IP;
* endereços MAC;
* estado das interfaces;
* tráfego;
* informações de roteamento.

### 💻 Processos e software

Dependendo das MIBs disponíveis:

* processos;
* software instalado;
* serviços;
* informações do sistema.

### 👤 Usuários

Dependendo da implementação e das MIBs expostas, informações relacionadas a contas e usuários podem aparecer.

> A quantidade de informações disponíveis varia bastante entre sistemas, agentes e MIBs instaladas.

---

# 🚨 SNMP com permissão de escrita

Uma configuração especialmente perigosa é permitir **SNMP SET** para usuários não autorizados.

Exemplo conceitual:

```text
Atacante
   │
   │ SET
   ▼
SNMP Agent
   │
   ▼
Alteração de configuração
```

Uma community string com acesso **RW (Read/Write)** pode permitir alterações em objetos que aceitam escrita.

Por isso:

```text
RO → Read Only
RW → Read/Write
```

O acesso de escrita deve ser restrito e utilizado somente quando realmente necessário.

---

# 🛡️ Principais riscos

Uma configuração insegura de SNMP pode resultar em:

* enumeração de dispositivos;
* exposição de informações do sistema;
* exposição de informações de rede;
* descoberta de interfaces;
* descoberta de software;
* descoberta de processos;
* enumeração de usuários, dependendo das MIBs;
* captura de community strings em v1/v2c;
* alteração de configurações quando existe acesso de escrita.

---

# 🔐 Boas práticas

### 1. Preferir SNMPv3

```text
SNMPv3
   ↓
authPriv
   ↓
Autenticação + Criptografia
```

### 2. Restringir origem

Permitir SNMP somente de servidores de monitoramento autorizados.

```text
          ┌───────────────┐
          │ SNMP Manager  │
          └───────┬───────┘
                  │
             permitido
                  │
                  ▼
             ┌─────────┐
             │ Router  │
             │  SNMP   │
             └─────────┘

Outros hosts ──X──► SNMP
```

### 3. Evitar community strings padrão

Evitar valores previsíveis como:

```text
public
private
```

### 4. Evitar acesso de escrita desnecessário

Sempre que possível:

```text
RO > RW
```

### 5. Não expor SNMP desnecessariamente na Internet

O serviço deve ser limitado à rede de gerenciamento.

---

# 🧠 Fluxo de enumeração

```text
UDP/161
   ↓
Identificar SNMP
   ↓
Descobrir versão
   ↓
Testar community string
   ↓
Enumerar MIB/OIDs
   ↓
Identificar informações
   ↓
Verificar permissões
   ↓
Avaliar impacto
```

---

# 🧠 Para memorizar

```text
SNMP
│
├── Manager
│      └── Gerencia/consulta
│
├── Agent
│      └── Dispositivo monitorado
│
├── MIB
│      └── Estrutura dos objetos
│
├── OID
│      └── Identificador do objeto
│
└── PDU
       ├── GET
       ├── GETNEXT
       ├── GETBULK
       ├── SET
       ├── RESPONSE
       ├── TRAP
       └── INFORM
```

### Portas

```text
UDP/161 → consultas SNMP
UDP/162 → traps/notificações
```

### Versões

```text
SNMPv1  → antigo + community string
SNMPv2c → community string + GetBulk
SNMPv3  → autenticação + integridade + criptografia
```

### Pentest

```text
snmp-check → enumeração simplificada
snmpwalk   → percorrer MIB/OIDs
nmap       → descoberta/enumeração
```

> **SNMP = gerenciamento e monitoramento.**
> **MIB = estrutura dos objetos.**
> **OID = identificador do objeto.**
> **161 = consultas.**
> **162 = traps.**
> **v1/v2c = community string.**
> **v3 = segurança.**
