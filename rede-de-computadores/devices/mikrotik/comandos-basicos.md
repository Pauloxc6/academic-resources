# Comandos de gerenciamento de redes (CLI)

CLI do MikroTik RouterOS:

```text
[user@Mikrotik] >
```

> **Dica:** no RouterOS, os comandos são organizados em *menus*.
> Você pode usar caminhos completos, como `/ip/address/print`, ou entrar no menu correspondente.

---

## Configuração básica do roteador

| Comando                            | Descrição                                              |
| ---------------------------------- | ------------------------------------------------------ |
| `/ping 1.1.1.1`                    | Testa conectividade com um endereço IP                 |
| `/ping google.com`                 | Testa conectividade e resolução DNS                    |
| `/undo`                            | Desfaz a última alteração                              |
| `/redo`                            | Refaz uma alteração desfeita                           |
| `/export`                          | Exporta a configuração em formato de comandos          |
| `/export file=config`              | Exporta a configuração para um arquivo                 |
| `/system/identity/set name="RB-1"` | Altera o nome do roteador                              |
| `/system/identity/print`           | Mostra o nome atual                                    |
| `/system/resource/print`           | Mostra informações de CPU, RAM, armazenamento e versão |
| `/system/routerboard/print`        | Mostra informações do hardware RouterBOARD             |
| `/system/package/print`            | Mostra os pacotes instalados                           |
| `/system/clock/print`              | Mostra data, hora e fuso horário                       |

---

# Navegação pela CLI

| Comando                | Descrição                           |
| ---------------------- | ----------------------------------- |
| `/`                    | Volta para a raiz da CLI            |
| `..`                   | Volta um nível                      |
| `print`                | Mostra os itens do menu atual       |
| `print detail`         | Mostra mais detalhes                |
| `print terse`          | Mostra uma saída mais compacta      |
| `print without-paging` | Exibe tudo sem paginação            |
| `?`                    | Mostra ajuda/comandos disponíveis   |
| `Tab`                  | Completa comandos                   |
| `Ctrl + C`             | Interrompe uma operação em execução |

Exemplo:

```text
/ip/address/print
```

ou:

```text
/ip/address
print
```

---

# Interfaces

**Path:**

```text
/interface
```

| Comando               | Descrição                            |
| --------------------- | ------------------------------------ |
| `print`               | Lista as interfaces                  |
| `print detail`        | Mostra detalhes das interfaces       |
| `monitor ether1`      | Monitora uma interface em tempo real |
| `disable ether1`      | Desabilita a interface               |
| `enable ether1`       | Habilita a interface                 |
| `set ether1 name=WAN` | Renomeia a interface                 |
| `set ether2 name=LAN` | Renomeia a interface                 |

Exemplo:

```text
/interface/print
```

---

# IP Address

**Path:**

```text
/ip/address
```

| Comando                                    | Descrição              |
| ------------------------------------------ | ---------------------- |
| `print`                                    | Mostra os endereços IP |
| `add address=10.1.1.1/24 interface=ether2` | Adiciona um IP         |
| `remove 1`                                 | Remove a entrada 1     |
| `remove 1,2,3`                             | Remove várias entradas |
| `disable 2,3`                              | Desabilita entradas    |
| `enable 2,3`                               | Habilita entradas      |
| `comment 2 comment="TESTE"`                | Adiciona um comentário |
| `comment 2 comment=""`                     | Remove o comentário    |
| `set 3 interface=ether4`                   | Altera a interface     |
| `set 2 address=10.40.40.1/24`              | Altera o endereço IP   |

Também é possível usar `find`:

```text
/ip/address/print where interface=ether2
```

---

# DHCP Client

**Path:**

```text
/ip/dhcp-client
```

| Comando                | Descrição                  |
| ---------------------- | -------------------------- |
| `add interface=ether1` | Cria um cliente DHCP       |
| `print`                | Lista clientes DHCP        |
| `release 0`            | Libera o endereço DHCP     |
| `renew 0`              | Solicita renovação do DHCP |
| `disable 0`            | Desabilita o cliente       |
| `enable 0`             | Habilita o cliente         |

Exemplo:

```text
/ip/dhcp-client/add interface=ether1
```

---

# DHCP Server

**Path:**

```text
/ip/dhcp-server
```

| Comando        | Descrição                              |
| -------------- | -------------------------------------- |
| `setup`        | Assistente para configurar DHCP Server |
| `print`        | Mostra os servidores DHCP              |
| `print detail` | Mostra detalhes                        |

### DHCP Leases

**Path:**

```text
/ip/dhcp-server/lease
```

| Comando         | Descrição                           |
| --------------- | ----------------------------------- |
| `print`         | Lista os leases                     |
| `print detail`  | Mostra detalhes                     |
| `make-static 0` | Torna um lease dinâmico em estático |
| `remove 0`      | Remove um lease                     |

Exemplo:

```text
/ip/dhcp-server/lease/print
```

---

# Pool de endereços

**Path:**

```text
/ip/pool
```

| Comando                                             | Descrição      |
| --------------------------------------------------- | -------------- |
| `print`                                             | Lista os pools |
| `add name=LAN ranges=192.168.10.100-192.168.10.200` | Cria um pool   |
| `set 0 ranges=192.168.10.50-192.168.10.150`         | Altera o range |

---

# Rotas

**Path:**

```text
/ip/route
```

| Comando                                          | Descrição                |
| ------------------------------------------------ | ------------------------ |
| `print`                                          | Mostra a tabela de rotas |
| `print detail`                                   | Mostra detalhes          |
| `add dst-address=0.0.0.0/0 gateway=10.0.0.1`     | Adiciona rota padrão     |
| `add dst-address=10.10.10.0/24 gateway=10.0.0.2` | Adiciona rota estática   |
| `remove 0`                                       | Remove uma rota          |
| `disable 0`                                      | Desabilita uma rota      |
| `enable 0`                                       | Habilita uma rota        |

### Rota padrão

```text
/ip/route/add dst-address=0.0.0.0/0 gateway=192.168.1.1
```

---

# DNS

**Path:**

```text
/ip/dns
```

| Comando                         | Descrição                         |
| ------------------------------- | --------------------------------- |
| `print`                         | Mostra a configuração DNS         |
| `set servers=1.1.1.1,8.8.8.8`   | Configura servidores DNS          |
| `set allow-remote-requests=yes` | Permite consultas DNS ao roteador |
| `cache/print`                   | Mostra o cache DNS                |

Exemplo:

```text
/ip/dns/set servers=1.1.1.1,8.8.8.8
```

---

# ARP

**Path:**

```text
/ip/arp
```

| Comando                                                                   | Descrição                 |
| ------------------------------------------------------------------------- | ------------------------- |
| `print`                                                                   | Lista entradas ARP        |
| `print where interface=ether2`                                            | Filtra por interface      |
| `remove 0`                                                                | Remove uma entrada        |
| `add address=192.168.1.10 mac-address=AA:BB:CC:DD:EE:FF interface=ether2` | Cria entrada ARP estática |

---

# Firewall Filter

**Path:**

```text
/ip/firewall/filter
```

### Listar regras

```text
print
```

### Adicionar regra

```text
add chain=input protocol=tcp dst-port=22 action=accept
```

### Bloquear ICMP

```text
add chain=input protocol=icmp action=drop
```

### Permitir uma rede

```text
add chain=input src-address=192.168.10.0/24 action=accept
```

### Bloquear uma rede

```text
add chain=forward src-address=10.10.10.0/24 action=drop
```

### Desabilitar regra

```text
disable 0
```

### Habilitar regra

```text
enable 0
```

### Remover regra

```text
remove 0
```

> **Importante:** a ordem das regras do firewall é significativa. As regras são avaliadas de cima para baixo.

---

# NAT

**Path:**

```text
/ip/firewall/nat
```

### Listar regras

```text
print
```

### Masquerade

```text
add chain=srcnat out-interface=ether1 action=masquerade
```

### Source NAT

```text
add chain=srcnat src-address=192.168.10.0/24 action=masquerade
```

### Port Forward / DNAT

Exemplo: encaminhar porta TCP 80 para um servidor interno:

```text
add chain=dstnat in-interface=ether1 protocol=tcp dst-port=80 \
    action=dst-nat to-addresses=192.168.10.10 to-ports=80
```

---

# Alterando várias regras

Uma das partes mais úteis da CLI do RouterOS é o uso de `find`.

**Path:**

```text
/ip/firewall/nat
```

### Alterar todas as regras `dstnat`

```text
set [find chain=dstnat] in-interface=ether1
```

### Alterar regras que não possuem `in-interface`

```text
set [find chain=dstnat !in-interface] in-interface=ether1
```

### Adicionar comentário

```text
set [find chain=dstnat] comment="Regra de teste"
```

### Limpar comentário

```text
set [find chain=dstnat] comment=""
```

### Procurar determinada porta

```text
set [find dst-port~"55"] in-interface=ether1
```

### Procurar portas que começam com determinado padrão

```text
set [find dst-port~"55.."] in-interface=ether1
```

### Procurar por comentário

```text
set [find comment~"Teste"] src-address=1.1.1.1
```

> `~` é usado para comparação por padrão/expressão regular.

---

# Connection Tracking

**Path:**

```text
/ip/firewall/connection
```

| Comando                    | Descrição                      |
| -------------------------- | ------------------------------ |
| `print`                    | Mostra conexões rastreadas     |
| `print where protocol=tcp` | Mostra conexões TCP            |
| `print where dst-port=80`  | Filtra por porta               |
| `remove [find]`            | Remove as conexões encontradas |

Exemplo:

```text
/ip/firewall/connection/print
```

---

# VLAN

**Path:**

```text
/interface/vlan
```

### Criar VLAN

```text
add name=vlan10 vlan-id=10 interface=ether2
```

### Listar VLANs

```text
print
```

### Remover VLAN

```text
remove 0
```

Exemplo:

```text
/interface/vlan/add \
    name=VLAN10 \
    vlan-id=10 \
    interface=ether2
```

---

# Bridge

**Path:**

```text
/interface/bridge
```

### Criar bridge

```text
add name=bridge-LAN
```

### Listar bridges

```text
print
```

### Adicionar porta ao bridge

**Path:**

```text
/interface/bridge/port
```

```text
add bridge=bridge-LAN interface=ether2
```

```text
add bridge=bridge-LAN interface=ether3
```

### Listar portas

```text
print
```

---

# Interface Bridge VLAN

**Path:**

```text
/interface/bridge/vlan
```

Exemplo:

```text
add bridge=bridge-LAN vlan-ids=10 tagged=bridge-LAN,ether2 untagged=ether3
```

* `tagged` → porta recebe quadros com tag VLAN.
* `untagged` → porta recebe quadros sem tag.
* `vlan-ids` → VLAN configurada.

---

# Ferramentas de diagnóstico

## Ping

```text
/ping 8.8.8.8
```

Definindo interface:

```text
/ping 8.8.8.8 interface=ether1
```

---

## Traceroute

```text
/tool/traceroute 8.8.8.8
```

---

## Torch

O `torch` permite visualizar o tráfego passando por uma interface.

```text
/tool/torch ether1
```

Exemplo com protocolo:

```text
/tool/torch ether1 protocol=tcp
```

---

## Profile

Mostra utilização de CPU e processos:

```text
/tool/profile
```

---

## Netwatch

Permite monitorar a disponibilidade de hosts.

**Path:**

```text
/tool/netwatch
```

Exemplo:

```text
add host=8.8.8.8 interval=30s
```

---

# Interface Monitor

```text
/interface/monitor ether1
```

Mostra informações como:

* link;
* velocidade;
* duplex;
* tráfego;
* estado da interface.

Para monitoramento contínuo:

```text
/interface/monitor ether1 once=no
```

---

# MAC Address

**Path:**

```text
/interface/bridge/host
```

```text
print
```

Mostra os dispositivos MAC aprendidos pelo bridge.

---

# Neighbor Discovery

```text
/ip/neighbor/print
```

Mostra dispositivos MikroTik descobertos na rede.

---

# Serviços

**Path:**

```text
/ip/service
```

```text
print
```

Exemplo:

```text
/ip/service/set telnet disabled=yes
```

Desabilita o Telnet.

Exemplo:

```text
/ip/service/set ssh port=2222
```

Altera a porta do SSH.

> Evite deixar serviços administrativos desnecessários expostos na WAN.

---

# Usuários

**Path:**

```text
/user
```

### Listar usuários

```text
print
```

### Criar usuário

```text
add name=admin2 group=full
```

### Remover usuário

```text
remove 1
```

### Alterar senha

```text
set 0 password="NovaSenha"
```

---

# Backup

## Backup binário

```text
/system/backup/save name=backup-router
```

Para listar:

```text
/file/print
```

---

## Export

Para gerar uma configuração em comandos:

```text
/export file=router-config
```

### Diferença importante

**Backup:**

* formato binário;
* usado para restauração do equipamento;
* mais ligado ao estado/configuração do dispositivo.

**Export:**

* formato textual;
* gera comandos do RouterOS;
* muito útil para documentação e migração.

---

# Logs

**Path:**

```text
/log
```

### Mostrar logs

```text
print
```

### Filtrar

```text
print where topics~"firewall"
```

---

# NTP / Hora

**Path:**

```text
/system/ntp/client
```

Exemplo:

```text
set enabled=yes
```

Em versões/configurações que usam servidores:

```text
servers=pool.ntp.org
```

Verificar:

```text
print
```

---

# Informações do sistema

```text
/system/resource/print
```

Mostra informações como:

* CPU;
* memória;
* armazenamento;
* uptime;
* versão do RouterOS.

### Identidade

```text
/system/identity/print
```

### Clock

```text
/system/clock/print
```

### Versão

```text
/system/package/print
```

---

# Comandos úteis com `find`

O `find` é extremamente importante para automatizar alterações.

### Procurar por interface

```text
/ip/address/print where interface=ether2
```

### Procurar por endereço

```text
/ip/address/print where address~"192.168"
```

### Procurar regra do firewall

```text
/ip/firewall/filter/print where chain=input
```

### Procurar NAT

```text
/ip/firewall/nat/print where chain=dstnat
```

### Alterar resultado encontrado

```text
/ip/address/set [find address~"10.10.10"] comment="LAN"
```

---

# Operadores úteis

| Operador | Função                           |   |           |
| -------- | -------------------------------- | - | --------- |
| `=`      | Igual                            |   |           |
| `!=`     | Diferente                        |   |           |
| `~`      | Correspondência por padrão/regex |   |           |
| `!`      | Negação                          |   |           |
| `&&`     | AND lógico                       |   |           |
| `        |                                  | ` | OR lógico |

Exemplo:

```text
/ip/firewall/filter/print where chain=input && protocol=tcp
```

---

# Fluxo básico de configuração

Um fluxo comum para configurar um MikroTik:

```text
1. Configurar identidade
        ↓
2. Configurar interfaces
        ↓
3. Configurar endereços IP
        ↓
4. Configurar rotas
        ↓
5. Configurar DNS
        ↓
6. Configurar DHCP
        ↓
7. Configurar NAT
        ↓
8. Configurar Firewall
        ↓
9. Configurar serviços de gerenciamento
        ↓
10. Testar conectividade
        ↓
11. Fazer backup/export
```

---

# Comandos para memorizar

```text
/ip/address/print
/ip/route/print
/ip/dhcp-client/print
/ip/dhcp-server/print
/ip/firewall/filter/print
/ip/firewall/nat/print
/ip/arp/print
/ip/dns/print
/interface/print
/interface/monitor ether1
/ping 8.8.8.8
/tool/traceroute 8.8.8.8
/tool/torch ether1
/log/print
/system/resource/print
/export
```

## 🧠 Para memorizar

```text
/ip/address       → IPs
/ip/route         → Rotas
/ip/dhcp-client   → DHCP cliente
/ip/dhcp-server   → DHCP servidor
/ip/dns           → DNS
/ip/arp           → ARP
/ip/firewall      → Firewall/NAT
/interface        → Interfaces
/interface/bridge → Bridge
/tool             → Ferramentas de diagnóstico
/system           → Sistema
/user             → Usuários
/log              → Logs
```
