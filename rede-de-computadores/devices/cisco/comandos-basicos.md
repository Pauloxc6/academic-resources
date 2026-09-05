# 🌐 Comandos de Gerenciamento de Redes (CLI)

## 🧭 Modos do Cisco IOS

O Cisco IOS utiliza diferentes modos de operação. O prompt indica em qual modo o dispositivo está.

| Prompt                   | Modo                    | Descrição                                 |
| ------------------------ | ----------------------- | ----------------------------------------- |
| `Router>`                | User EXEC               | Comandos básicos de consulta              |
| `Router#`                | Privileged EXEC         | Comandos administrativos e de verificação |
| `Router(config)#`        | Global Configuration    | Configuração global do dispositivo        |
| `Router(config-if)#`     | Interface Configuration | Configuração de uma interface             |
| `Router(config-line)#`   | Line Configuration      | Configuração de linhas VTY/console        |
| `Router(config-router)#` | Router Configuration    | Configuração de protocolos de roteamento  |
| `Router(config-vlan)#`   | VLAN Configuration      | Configuração de uma VLAN                  |

### Navegação entre modos

```text
Router>
   │
   │ enable
   ▼
Router#
   │
   │ configure terminal
   ▼
Router(config)#
   │
   ├── interface ...
   │       ↓
   │   Router(config-if)#
   │
   ├── line vty ...
   │       ↓
   │   Router(config-line)#
   │
   └── router ospf ...
           ↓
       Router(config-router)#
```

---

# ⚙️ Comandos Básicos

| Comando               | Descrição                                           |
| --------------------- | --------------------------------------------------- |
| `?`                   | Exibe comandos/opções disponíveis no contexto atual |
| `enable`              | Entra no modo EXEC privilegiado                     |
| `configure terminal`  | Entra no modo de configuração global                |
| `exit`                | Volta um nível de configuração                      |
| `end`                 | Retorna diretamente ao modo privilegiado            |
| `hostname R1`         | Define o hostname                                   |
| `show running-config` | Mostra a configuração atualmente em execução        |
| `show startup-config` | Mostra a configuração salva na NVRAM                |
| `show history`        | Mostra o histórico de comandos                      |
| `show version`        | Mostra informações do IOS, hardware e versão        |
| `show interfaces`     | Mostra informações detalhadas das interfaces        |

> ⚠️ `name RH` não é um comando genérico para "dar nome a uma rede". Em Cisco IOS, o comando depende do contexto. Para identificar o dispositivo, utilize `hostname`.

---

# 💾 Configuração e Salvamento

A configuração atual fica na **running-config**.

Para salvar essa configuração na **startup-config**:

```bash
copy running-config startup-config
```

ou, em IOS compatível:

```bash
write memory
```

Fluxo:

```text
running-config
      │
      │ copy running-config startup-config
      ▼
startup-config
```

### Diferença

| Configuração     | Local | Função                                      |
| ---------------- | ----- | ------------------------------------------- |
| `running-config` | RAM   | Configuração atualmente em uso              |
| `startup-config` | NVRAM | Configuração utilizada após reinicialização |

---

# 🔌 Configuração de Interfaces

## FastEthernet / GigabitEthernet

```bash
interface FastEthernet0/0
ip address 192.168.0.1 255.255.255.0
description LAN Network
no shutdown
```

| Comando                                | Descrição                      |
| -------------------------------------- | ------------------------------ |
| `interface FastEthernet0/0`            | Seleciona a interface          |
| `ip address 192.168.0.1 255.255.255.0` | Define endereço IPv4 e máscara |
| `description LAN Network`              | Adiciona descrição             |
| `no shutdown`                          | Habilita a interface           |
| `shutdown`                             | Desabilita a interface         |

> Em equipamentos mais novos, é comum encontrar `GigabitEthernet` ou `TenGigabitEthernet` em vez de `FastEthernet`.

---

# 🧷 Endereço MAC

Em plataformas Cisco que permitem alteração manual do MAC:

```bash
mac-address 0000.0011.1111
```

O formato utilizado pelo IOS normalmente é:

```text
XXXX.XXXX.XXXX
```

e não necessariamente o formato:

```text
00:00:00:11:11:11
```

---

# 🌐 Gateway Padrão

Em um **switch Layer 2**, pode ser configurado:

```bash
ip default-gateway 192.168.1.1
```

Isso permite que o próprio switch alcance redes externas para funções de gerenciamento.

> ⚠️ Em um roteador, o encaminhamento de pacotes não é configurado normalmente com `ip default-gateway`. Para o roteador, utiliza-se uma **rota padrão**:

```bash
ip route 0.0.0.0 0.0.0.0 192.168.1.1
```

---

# 🔗 Interface Serial

Exemplo:

```bash
interface Serial0/0/0
ip address 192.168.0.1 255.255.255.252
no shutdown
```

Em enlaces seriais legados, o lado **DCE** pode precisar fornecer clock:

```bash
clock rate 64000
```

Verifique o lado DCE com:

```bash
show controllers serial 0/0/0
```

> `clock rate` é relevante quando a interface possui o papel DCE. Em muitos equipamentos modernos e ambientes de laboratório, interfaces seriais podem nem estar disponíveis.

---

# 🛣️ Rotas Estáticas

## Via próximo salto

```bash
ip route 192.168.10.0 255.255.255.0 10.10.10.1
```

Estrutura:

```text
ip route REDE_DESTINO MÁSCARA PRÓXIMO_SALTO
```

### Com distância administrativa

```bash
ip route 192.168.10.0 255.255.255.0 10.10.10.1 150
```

* Destino: `192.168.10.0/24`
* Próximo salto: `10.10.10.1`
* Distância administrativa: `150`

---

## Via interface de saída

```bash
ip route 192.168.10.0 255.255.255.0 Serial0/0/0
```

Indica diretamente a interface pela qual o tráfego deve sair.

---

# 🌍 Rota Padrão

A rota padrão é utilizada quando não existe uma rota mais específica para o destino.

## Via próximo salto

```bash
ip route 0.0.0.0 0.0.0.0 10.10.10.2
```

```text
Destino:       0.0.0.0/0
Próximo salto: 10.10.10.2
```

## Via interface

```bash
ip route 0.0.0.0 0.0.0.0 Serial0/0/0
```

> A rota padrão pode ser entendida como o **"caminho para destinos desconhecidos"**.

---

# 🔄 Protocolos de Roteamento

## RIP

```bash
router rip
network 192.168.1.0
```

Para RIPv2:

```bash
router rip
version 2
network 192.168.1.0
no auto-summary
```

---

## OSPF

```bash
router ospf 1
network 192.168.1.0 0.0.0.255 area 0
```

Estrutura:

```text
network REDE WILDCARD area ÁREA
```

Exemplo:

```bash
network 200.100.100.64 0.0.0.63 area 0
```

---

## EIGRP

Em IOS clássico:

```bash
router eigrp 100
network 192.168.1.0 0.0.0.255
```

> O número `100` é o **número do sistema autônomo (AS) do EIGRP**, não uma versão do protocolo.

---

## BGP

O BGP exige um número de AS:

```bash
router bgp 65001
```

Exemplo:

```bash
router bgp 65001
neighbor 10.10.10.2 remote-as 65002
```

---

# 🛡️ ACL — Access Control List

ACLs permitem controlar o tráfego com base em critérios como:

* endereço IP de origem;
* endereço IP de destino;
* protocolo;
* porta.

Exemplo:

```bash
access-list 111 deny tcp 192.168.100.16 0.0.0.31 200.100.100.64 0.0.0.63 eq 23
```

Nesse exemplo, a ACL bloqueia tráfego **TCP destinado à porta 23 (Telnet)** entre as redes especificadas.

Para aplicar a ACL à interface:

```bash
interface GigabitEthernet0/0
ip access-group 111 in
```

* `in` → tráfego entrando na interface;
* `out` → tráfego saindo da interface.

> ⚠️ ACLs possuem uma regra implícita de **deny** no final. Portanto, a ordem das entradas é importante.

---

# 🔐 Senhas e Acesso

## Enable Password

```bash
enable password 1234
```

Define uma senha para o modo privilegiado.

Porém, é considerada uma opção **legada e menos segura**.

---

## Enable Secret

```bash
enable secret test1
```

Define a senha protegida utilizada para acesso ao modo privilegiado.

Quando configurados juntos, o `enable secret` tem prioridade sobre o `enable password`.

---

# 🖥️ Linhas VTY

As linhas VTY são utilizadas para acesso remoto ao equipamento.

```bash
line vty 0 4
```

Em plataformas que possuem as linhas `0` a `4`, isso representa **5 linhas VTY**.

Configuração básica:

```bash
line vty 0 4
password 1234
login
```

---

# 👤 Usuário Local

```bash
username admin privilege 15 secret SenhaForte
```

Cria um usuário local.

É preferível utilizar `secret` em vez de `password` para credenciais locais.

---

# 🔑 SSH

Exemplo de configuração básica:

```bash
hostname R1
ip domain-name exemplo.local

username admin privilege 15 secret SenhaForte

crypto key generate rsa

line vty 0 4
login local
transport input ssh
```

O comando:

```bash
transport input ssh
```

permite somente conexões SSH nas linhas VTY.

---

# ⚠️ Telnet

```bash
transport input telnet
```

Permite Telnet.

Também é possível permitir ambos:

```bash
transport input ssh telnet
```

Porém:

> ⚠️ **Telnet não deve ser utilizado quando SSH estiver disponível**, pois não oferece proteção adequada para as credenciais e a sessão.

---

# 📢 Banner

```bash
banner login #Acesso somente autorizado#
```

Exibe uma mensagem antes do login.

Exemplo:

```text
************************************************
*     ACESSO SOMENTE PARA USUARIOS AUTORIZADOS *
************************************************
```

---

# 🔀 Configuração Básica de Switch

## Criar VLAN

```bash
vlan 10
name RH
```

Aqui, diferentemente do comando `name RH` citado anteriormente, `name RH` está sendo utilizado dentro do contexto da VLAN para atribuir o nome **RH** à VLAN 10.

---

# 🔌 Porta Access

```bash
interface FastEthernet0/1
switchport mode access
switchport access vlan 10
```

A porta passa a operar como **access** e é associada à VLAN 10.

```text
┌──────────┐
│  PC      │
└────┬─────┘
     │
     │ Access VLAN 10
     ▼
┌──────────────┐
│    Switch    │
│    VLAN 10   │
└──────────────┘
```

---

# 🔗 Porta Trunk

Para transportar múltiplas VLANs entre dispositivos:

```bash
interface GigabitEthernet0/1
switchport mode trunk
```

Exemplo:

```text
             TRUNK
       VLAN 10,20,30
             │
┌────────────▼────────────┐
│         Switch          │
└──────┬────────┬─────────┘
       │        │
     VLAN 10  VLAN 20
```

---

# 🧑‍💻 IP de Gerenciamento do Switch

Em um switch Layer 2, o endereço IP normalmente é configurado em uma **SVI (Switch Virtual Interface)**:

```bash
interface vlan 10
ip address 192.168.10.2 255.255.255.0
no shutdown
```

Gateway:

```bash
ip default-gateway 192.168.10.1
```

---

# 🔎 Comandos de Verificação

| Comando                   | Descrição                                         |
| ------------------------- | ------------------------------------------------- |
| `show ip route`           | Mostra a tabela de roteamento                     |
| `show ip route rip`       | Mostra rotas aprendidas via RIP                   |
| `show ip interface brief` | Resumo das interfaces e endereços IP              |
| `show interfaces`         | Informações detalhadas das interfaces             |
| `show interfaces status`  | Status resumido das portas de switch              |
| `show vlan brief`         | Lista VLANs e portas associadas                   |
| `show running-config`     | Mostra configuração em execução                   |
| `show startup-config`     | Mostra configuração salva                         |
| `show arp`                | Mostra a tabela ARP                               |
| `show mac address-table`  | Mostra a tabela MAC do switch                     |
| `show version`            | Mostra versão do IOS e informações do dispositivo |
| `show ip protocols`       | Mostra informações dos protocolos de roteamento   |
| `show access-lists`       | Mostra ACLs configuradas                          |

---

# 🧰 Comandos de Rede no Cisco IOS

Alguns comandos possuem nomes diferentes daqueles encontrados em Linux ou Windows.

| Comando                   | Função                                |
| ------------------------- | ------------------------------------- |
| `ping`                    | Testa conectividade                   |
| `traceroute`              | Rastreia o caminho até um destino     |
| `telnet`                  | Cliente Telnet                        |
| `ssh`                     | Cliente SSH                           |
| `show arp`                | Consulta tabela ARP                   |
| `show hosts`              | Mostra entradas de resolução de nomes |
| `show ip interface brief` | Mostra resumo das interfaces          |

> ⚠️ Comandos como `ipconfig`, `netstat`, `nslookup` e `tracert` são principalmente associados a Windows/Linux e **não devem ser tratados como comandos padrão do Cisco IOS**.

---

# 🧪 SNMP

Ferramentas como:

```bash
snmpget
snmpgetbulk
snmpset
```

são normalmente utilizadas em **hosts de gerenciamento**, e não como comandos nativos gerais do Cisco IOS.

No próprio Cisco IOS, é possível configurar o agente SNMP, por exemplo:

```bash
snmp-server community public ro
```

> ⚠️ `public` é apenas um exemplo clássico. Em ambientes reais, evite comunidades padrão e prefira **SNMPv3** quando suportado.

---

# 📁 Gerenciamento de Arquivos

Alguns comandos de gerenciamento de arquivos no IOS:

```bash
dir
```

Lista arquivos disponíveis.

```bash
delete <arquivo>
```

Remove um arquivo.

Exemplo:

```bash
delete flash:arquivo.txt
```

---

# 🧠 Fluxo básico de configuração

```text
Router>
   │
   │ enable
   ▼
Router#
   │
   │ configure terminal
   ▼
Router(config)#
   │
   ├── hostname R1
   │
   ├── interface GigabitEthernet0/0
   │      │
   │      ├── ip address ...
   │      └── no shutdown
   │
   ├── ip route ...
   │
   └── router ospf 1
          │
          └── network ... area 0
```

Depois:

```bash
end
copy running-config startup-config
```

---

# 🧠 Para memorizar

### Modos

```text
>       → Usuário
#       → Privilegiado
(config)#    → Configuração global
(config-if)# → Interface
(config-line)# → Linha
(config-router)# → Roteamento
```

### Interfaces

```text
interface
   ↓
ip address
   ↓
description
   ↓
no shutdown
```

### Roteamento

```text
Rota estática
      ↓
ip route

RIP
      ↓
router rip

OSPF
      ↓
router ospf

EIGRP
      ↓
router eigrp

BGP
      ↓
router bgp
```

### Acesso remoto

```text
VTY
 │
 ├── SSH   ✅ recomendado
 │
 └── Telnet ⚠️ legado/inseguro
```

### Salvamento

```text
running-config
      │
      │ copy running-config startup-config
      ▼
startup-config
```

> **Cisco IOS = navegar pelos modos → configurar → verificar → salvar.**
