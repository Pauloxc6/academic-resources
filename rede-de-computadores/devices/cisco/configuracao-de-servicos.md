# ⚙️ Configuração de Serviços Cisco

---

# 🔐 SSH

O **SSH (Secure Shell)** permite acesso remoto seguro ao equipamento, utilizando criptografia.

### Configuração

```bash
R1# configure terminal
R1(config)# hostname R1
R1(config)# username cisco secret cisco123
R1(config)# ip domain-name cisco.local
R1(config)# crypto key generate rsa
R1(config)# ip ssh version 2

R1(config)# line vty 0 7
R1(config-line)# transport input ssh
R1(config-line)# login local

R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip address 10.10.20.1 255.255.255.0
R1(config-if)# no shutdown
```

### Explicação

| Comando                          | Descrição                                            |
| -------------------------------- | ---------------------------------------------------- |
| `username cisco secret cisco123` | Cria usuário local                                   |
| `line vty 0 7`                   | Seleciona as linhas VTY 0–7                          |
| `transport input ssh`            | Permite somente SSH                                  |
| `login local`                    | Utiliza a base de usuários locais                    |
| `ip domain-name`                 | Define o domínio necessário para gerar as chaves RSA |
| `crypto key generate rsa`        | Gera as chaves RSA                                   |
| `ip ssh version 2`               | Define SSH versão 2                                  |

> 💡 Em configurações reais, prefira `secret` em vez de `password` para credenciais locais.

---

# ⚠️ TELNET

O **Telnet** permite acesso remoto ao dispositivo, porém transmite a sessão sem a proteção criptográfica fornecida pelo SSH.

### Configuração

```bash
R1# configure terminal
R1(config)# username cisco secret cisco123

R1(config)# line vty 0 7
R1(config-line)# transport input telnet
R1(config-line)# login local

R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip address 10.10.20.1 255.255.255.0
R1(config-if)# no shutdown
```

### SSH x Telnet

| Característica          | SSH    | Telnet |
| ----------------------- | ------ | ------ |
| Criptografia            | ✅      | ❌      |
| Proteção de credenciais | ✅      | ❌      |
| Porta padrão            | TCP 22 | TCP 23 |
| Uso recomendado         | ✅      | ❌      |

> **Para administração remota, prefira SSH.**

---

# 📡 SNMP

O **SNMP (Simple Network Management Protocol)** é utilizado para monitoramento e gerenciamento de dispositivos de rede.

```text
       ┌──────────────┐
       │ SNMP Manager │
       └──────┬───────┘
              │
          UDP 161
              │
       ┌──────▼───────┐
       │ SNMP Agent   │
       │   Router     │
       └──────────────┘
```

### Configuração

```bash
S1(config)# access-list 100 permit 10.10.20.0 0.0.0.255

S1(config)# snmp-server community cisco RO 100
S1(config)# snmp-server community xyz123 RW 100

S1(config)# snmp-server enable traps
```

| Comando                               | Descrição                  |
| ------------------------------------- | -------------------------- |
| `snmp-server community cisco RO 100`  | Comunidade somente leitura |
| `snmp-server community xyz123 RW 100` | Comunidade leitura/escrita |
| `snmp-server enable traps`            | Habilita o envio de traps  |

> ⚠️ `RW` permite operações de escrita e deve ser utilizado com muito cuidado.

> 💡 Em ambientes modernos, **SNMPv3** é preferível porque oferece mecanismos de autenticação e, conforme a configuração, privacidade/criptografia.

---

# 🌐 NAT

**NAT (Network Address Translation)** traduz endereços IP entre diferentes domínios de endereçamento.

## Topologia

```text
LAN
192.168.0.0/24
     │
     ▼
┌──────────┐
│ Switch   │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Router   │
│   NAT    │
└────┬─────┘
     │
     │ Internet
     ▼
   WAN
```

### NAT estático

Exemplo:

```bash
R1(config)# ip nat inside source static 192.168.0.10 209.100.50.2
```

> ⚠️ É importante não utilizar o mesmo endereço em ambos os lados da topologia. O endereço interno e o endereço público representam interfaces/hosts diferentes no cenário.

### Interface interna

```bash
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip address 192.168.0.1 255.255.255.0
R1(config-if)# ip nat inside
R1(config-if)# no shutdown
```

### Interface externa

```bash
R1(config)# interface Serial0/0/0
R1(config-if)# ip address 209.100.50.2 255.255.255.224
R1(config-if)# ip nat outside
R1(config-if)# no shutdown
```

### Conceito

```text
Inside Local
192.168.0.10
      │
      │ NAT
      ▼
Inside Global
209.100.50.2
```

---

# 🆕 IPv6

Para permitir que o roteador encaminhe pacotes IPv6:

```bash
R1(config)# ipv6 unicast-routing
```

Configuração de endereço:

```bash
R1(config)# interface FastEthernet0/0
R1(config-if)# ipv6 address 2001:db8:1::1/64
R1(config-if)# ipv6 address fe80::1 link-local
R1(config-if)# no shutdown
```

### Endereço Link-Local

O endereço:

```text
fe80::/10
```

é utilizado para comunicação local do IPv6.

Exemplo:

```bash
ipv6 address fe80::1 link-local
```

---

# 🔢 EUI-64

O EUI-64 permite que parte do endereço IPv6 seja formada automaticamente a partir do endereço MAC da interface.

```bash
R1(config-if)# ipv6 address 2001:db8:1::/64 eui-64
```

Exemplo conceitual:

```text
Prefixo IPv6
2001:db8:1::/64
       +
Identificador baseado no MAC
       ↓
Endereço IPv6 completo
```

---

# 🏷️ VLAN

As VLANs permitem dividir logicamente uma rede Layer 2.

### Criando VLANs

```bash
Switch(config)# vlan 10
Switch(config-vlan)# name Engineering

Switch(config)# vlan 20
Switch(config-vlan)# name Sales

Switch(config)# vlan 30
Switch(config-vlan)# name Marketing
```

---

## Atribuindo portas

### VLAN 10

```bash
Switch(config)# interface range FastEthernet0/1-8
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
```

### VLAN 20

```bash
Switch(config)# interface range FastEthernet0/9
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
```

### VLAN 30

```bash
Switch(config)# interface range FastEthernet0/10-12
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 30
```

### Visualização

```text
VLAN 10 → Engineering
VLAN 20 → Sales
VLAN 30 → Marketing
```

---

# 🛣️ OSPF

O **OSPF (Open Shortest Path First)** é um protocolo de roteamento dinâmico do tipo **Link-State**.

## Virtual Link

Um **OSPF Virtual Link** pode ser utilizado para estabelecer conectividade lógica com a **Area 0** quando uma área não está fisicamente conectada ao backbone.

Exemplo conceitual:

```text
Area 0
  │
  │
Area 1
  │
  │
Area 2
```

O virtual link pode criar uma conexão lógica entre roteadores OSPF para que a Area 1 tenha acesso lógico ao backbone.

### Router A

```bash
RouterA(config)# router ospf 1000
RouterA(config-router)# network 172.16.0.0 0.0.255.255 area 1
RouterA(config-router)# network 10.0.0.0 0.255.255.255 area 0
RouterA(config-router)# area 1 virtual-link 10.2.2.2
```

### Router B

```bash
RouterB(config)# router ospf 1000
RouterB(config-router)# network 172.16.0.0 0.0.255.255 area 1
RouterB(config-router)# network 10.0.0.0 0.255.255.255 area 0
RouterB(config-router)# area 1 virtual-link 10.1.1.1
```

> ⚠️ Os endereços utilizados no `virtual-link` devem ser os **Router IDs dos roteadores envolvidos**, e os dois roteadores precisam possuir conectividade através de uma área de trânsito.

---

# 📜 Syslog

O **Syslog** permite enviar mensagens de eventos e registros dos dispositivos para um servidor centralizado.

## Topologia

```text
                    ┌──────────────┐
                    │ Syslog Server│
                    │  20.0.0.1/24 │
                    └──────┬───────┘
                           │
                       20.0.0.0/24
                           │
                    ┌──────▼───────┐
                    │    Router    │
                    │  20.0.0.2    │
                    └──────┬───────┘
                           │
                        Switch
                       /      \
                     PC1      PC2
```

### Configuração

```bash
Router# configure terminal
Router(config)# logging host 20.0.0.1
Router(config)# logging trap 7
Router(config)# logging history 7
Router(config)# service sequence-numbers
Router(config)# service timestamps log datetime
```

### Syslog Severity

Os níveis vão de `0` a `7`:

| Nível | Nome          |
| ----: | ------------- |
|     0 | Emergencies   |
|     1 | Alerts        |
|     2 | Critical      |
|     3 | Errors        |
|     4 | Warnings      |
|     5 | Notifications |
|     6 | Informational |
|     7 | Debugging     |

Quanto **menor o número**, maior a severidade.

```text
0 → mais grave
│
├── 1
├── 2
├── 3
├── 4
├── 5
├── 6
└── 7 → Debug
```

> `logging trap 7` permite o envio de mensagens de todos os níveis de severidade, de 0 a 7.

---

# 🔄 EIGRP

O **EIGRP (Enhanced Interior Gateway Routing Protocol)** é um protocolo de roteamento do tipo **Advanced Distance Vector**.

### Configuração

```bash
R1(config)# router eigrp 100
R1(config-router)# network 192.168.1.0 0.0.0.255
R1(config-router)# network 10.0.0.0 0.0.0.255
R1(config-router)# no auto-summary
```

### Elementos

```text
EIGRP
 │
 ├── DUAL
 ├── Successor
 ├── Feasible Successor
 ├── Métrica
 └── Neighbor Table
```

---

# 🌍 Default Route + OSPF

Uma rota padrão pode ser utilizada para enviar tráfego desconhecido para o ISP.

## Topologia

```text
LAN
10.0.0.0/24
    │
    ▼
[ENGINE]
    │
11.0.0.0/24
    │
    ▼
[ENTRANCE]
    │
    │ Default Route
    ▼
   ISP
```

### Rota padrão

```bash
Entrance(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0
```

### OSPF

```bash
Entrance(config)# router ospf 1
Entrance(config-router)# network 10.0.0.0 0.0.0.255 area 0
Entrance(config-router)# network 11.0.0.0 0.0.0.255 area 0
Entrance(config-router)# default-information originate
```

O comando:

```bash
default-information originate
```

permite que o roteador anuncie a rota padrão através do OSPF.

> 💡 Normalmente o roteador precisa possuir uma rota padrão na tabela para anunciá-la. Para anunciar mesmo sem uma rota padrão instalada, existe a opção `always`.

---

# 📡 DHCP Server

O Cisco IOS pode funcionar como servidor DHCP.

### Configuração

```bash
Router(config)# ip dhcp excluded-address 192.168.1.1

Router(config)# ip dhcp pool MYLAN
Router(dhcp-config)# network 192.168.1.0 255.255.255.0
Router(dhcp-config)# default-router 192.168.1.1
Router(dhcp-config)# dns-server 10.10.10.10
```

### Funcionamento

```text
DHCP Server
192.168.1.1
     │
     │ DHCP
     ▼
┌──────────┐
│ Cliente  │
└──────────┘
```

O servidor fornece automaticamente informações como:

* endereço IP;
* máscara;
* gateway padrão;
* servidor DNS.

---

# 🔑 PPPoE

**PPPoE (Point-to-Point Protocol over Ethernet)** permite transportar sessões PPP através de Ethernet.

Uma configuração de servidor PPPoE pode utilizar uma **Virtual-Template**.

### Interface

```bash
R1(config)# interface FastEthernet0/0
R1(config-if)# description WAN-PPPoE
R1(config-if)# no shutdown
R1(config-if)# pppoe enable
```

### Virtual Template

```bash
R1(config)# interface Virtual-Template 1
R1(config-if)# ip unnumbered FastEthernet0/0
R1(config-if)# peer default ip address pool PPPoE-POOL
R1(config-if)# ppp authentication chap
```

### VPDN

Em plataformas IOS que utilizam essa configuração:

```bash
R1(config)# vpdn enable
R1(config)# vpdn-group PPPoE-Server
R1(config-vpdn)# accept-dialin
R1(config-vpdn-acc-in)# protocol pppoe
R1(config-vpdn-acc-in)# virtual-template 1
```

### Pool

```bash
R1(config)# ip local pool PPPoE-POOL 192.168.0.10 192.168.0.20
```

### Usuário

```bash
R1(config)# username cisco-pppoe password cisco
```

> ⚠️ A configuração de PPPoE varia bastante conforme a versão do IOS e se o equipamento está atuando como **PPPoE client ou PPPoE server**. O exemplo acima representa o cenário de servidor PPPoE.

---

# 🏷️ MPLS

**MPLS (Multiprotocol Label Switching)** utiliza labels para encaminhar tráfego através da rede do provedor.

## Topologia

```text
      MPLS Core

R1 ─────── R2 ─────── R3
PE          P           PE
```

* **PE** → Provider Edge
* **P** → Provider Router

---

# 🔖 MPLS Básico

Em plataformas IOS compatíveis:

### R1

```bash
R1(config)# ip cef
R1(config)# mpls label protocol ldp

R1(config)# interface FastEthernet0/0
R1(config-if)# mpls ip
```

### R2

```bash
R2(config)# ip cef
R2(config)# mpls label protocol ldp

R2(config)# interface FastEthernet0/0
R2(config-if)# mpls ip

R2(config)# interface FastEthernet0/1
R2(config-if)# mpls ip
```

### R3

```bash
R3(config)# ip cef
R3(config)# mpls label protocol ldp

R3(config)# interface FastEthernet0/0
R3(config-if)# mpls ip
```

> ⚠️ Em versões diferentes do IOS, a configuração de MPLS pode exigir comandos adicionais ou utilizar sintaxe diferente.

---

# 🛣️ MPLS + OSPF

O OSPF pode fornecer a conectividade IP necessária para o LDP estabelecer os LSPs.

## Endereçamento

| Link    | Rede             |
| ------- | ---------------- |
| R1 ↔ R2 | `192.168.1.0/30` |
| R2 ↔ R3 | `192.168.2.0/30` |

---

## R1

```bash
R1(config)# router ospf 100
R1(config-router)# network 192.168.1.0 0.0.0.3 area 0
R1(config-router)# mpls ldp autoconfig
```

## R2

```bash
R2(config)# router ospf 100
R2(config-router)# network 192.168.1.0 0.0.0.3 area 0
R2(config-router)# network 192.168.2.0 0.0.0.3 area 0
R2(config-router)# mpls ldp autoconfig
```

## R3

```bash
R3(config)# router ospf 100
R3(config-router)# network 192.168.2.0 0.0.0.3 area 0
R3(config-router)# mpls ldp autoconfig
```

### LDP Sync

Em plataformas IOS que suportam o recurso:

```bash
R1(config-router)# mpls ldp sync
```

O objetivo é evitar que o OSPF utilize uma rota enquanto o LDP ainda não está sincronizado para aquele enlace.

---

# 🔎 Comandos de Verificação

| Comando                      | Descrição                            |
| ---------------------------- | ------------------------------------ |
| `show ip interface brief`    | Mostra interfaces, IPs e status      |
| `show running-config`        | Mostra configuração atual            |
| `show startup-config`        | Mostra configuração salva            |
| `show ip route`              | Mostra tabela de roteamento          |
| `show vlan brief`            | Mostra VLANs e portas                |
| `show ip ospf neighbor`      | Mostra vizinhos OSPF                 |
| `show ip eigrp neighbors`    | Mostra vizinhos EIGRP                |
| `show ip nat translations`   | Mostra traduções NAT                 |
| `show ip nat statistics`     | Mostra estatísticas do NAT           |
| `show logging`               | Mostra logs locais                   |
| `show snmp`                  | Mostra informações/configuração SNMP |
| `show mpls forwarding-table` | Mostra tabela de encaminhamento MPLS |
| `show mpls ldp neighbor`     | Mostra vizinhos LDP                  |
| `show mpls interfaces`       | Mostra interfaces MPLS               |

---

# 🧠 Resumo

```text
SERVIÇOS CISCO
│
├── 🔐 SSH
│   └── Acesso remoto seguro
│
├── ⚠️ TELNET
│   └── Acesso remoto sem criptografia
│
├── 📡 SNMP
│   └── Gerenciamento e monitoramento
│
├── 🌐 NAT
│   └── Tradução de endereços
│
├── 🆕 IPv6
│   └── Endereçamento IPv6
│
├── 🏷️ VLAN
│   └── Segmentação Layer 2
│
├── 🛣️ OSPF
│   └── Roteamento dinâmico
│
├── 📜 Syslog
│   └── Registro de eventos
│
├── 🔄 EIGRP
│   └── Roteamento dinâmico
│
├── 🌍 DHCP
│   └── Distribuição automática de IP
│
├── 🔑 PPPoE
│   └── PPP sobre Ethernet
│
└── 🏷️ MPLS
    └── Encaminhamento baseado em labels
```

### Para memorizar

```text
SSH       → acesso remoto seguro
Telnet    → acesso remoto legado
SNMP      → gerenciamento
NAT       → tradução de IP
IPv6      → endereçamento
VLAN      → segmentação
OSPF      → roteamento
Syslog    → logs
EIGRP     → roteamento
DHCP      → configuração automática
PPPoE     → PPP sobre Ethernet
MPLS      → labels
```
