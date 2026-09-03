# 📡 Guia do `nmcli` — NetworkManager no Linux

> [!info] Sobre  
> O `nmcli` (NetworkManager CLI) é a ferramenta de linha de comando para gerenciar conexões de rede através do **NetworkManager**.
> 
> Útil para configurar **Ethernet, Wi-Fi, IP estático, DHCP, DNS, rotas, VLANs, bridges, VPNs** e muito mais.

---

## 📚 Índice

- [[#1. Conceitos básicos]]
    
- [[#2. Verificar o estado da rede]]
    
- [[#3. Interfaces de rede]]
    
- [[#4. Conexões]]
    
- [[#5. Wi-Fi]]
    
- [[#6. DHCP]]
    
- [[#7. IP estático]]
    
- [[#8. DNS]]
    
- [[#9. Gateway e rotas]]
    
- [[#10. Ativar e desativar interfaces]]
    
- [[#11. Criar conexões]]
    
- [[#12. Modificar conexões]]
    
- [[#13. Remover conexões]]
    
- [[#14. VLAN]]
    
- [[#15. Bridge]]
    
- [[#16. Comandos úteis]]
    
- [[#17. Troubleshooting]]
    
- [[#18. Exemplos práticos]]
    
- [[#19. Cheat Sheet]]
    

---

# 1. Conceitos básicos

O `nmcli` trabalha principalmente com:

```text
nmcli
 ├── general
 ├── networking
 ├── radio
 ├── device
 ├── connection
 └── agent
```

Os dois conceitos mais importantes são:

### Device

É a **interface física ou virtual**.

Exemplos:

```text
eth0
enp3s0
wlan0
wlp2s0
```

### Connection

É o **perfil de configuração** utilizado pelo NetworkManager.

Exemplo:

```text
Wired connection 1
Minha-WiFi
Servidor
VLAN-10
```

Uma interface pode ter vários perfis de conexão.

---

# 2. Verificar o estado da rede

## Estado geral

```bash
nmcli general status
```

Exemplo:

```text
STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN
connected  full          enabled  enabled  enabled  enabled
```

---

## Estado do NetworkManager

```bash
systemctl status NetworkManager
```

Iniciar:

```bash
sudo systemctl start NetworkManager
```

Habilitar no boot:

```bash
sudo systemctl enable NetworkManager
```

---

## Ver informações gerais

```bash
nmcli general
```

---

# 3. Interfaces de rede

## Listar interfaces

```bash
nmcli device
```

ou:

```bash
nmcli device status
```

Exemplo:

```text
DEVICE   TYPE      STATE      CONNECTION
eth0     ethernet  connected  Wired connection 1
wlan0    wifi      connected  MinhaWiFi
lo       loopback  unmanaged  --
```

---

## Mostrar informações detalhadas

```bash
nmcli device show
```

Para uma interface específica:

```bash
nmcli device show eth0
```

Wi-Fi:

```bash
nmcli device show wlan0
```

---

## Mostrar apenas interfaces conectadas

```bash
nmcli device status
```

---

## Listar dispositivos por tipo

Ethernet:

```bash
nmcli device status | grep ethernet
```

Wi-Fi:

```bash
nmcli device status | grep wifi
```

---

# 4. Conexões

## Listar conexões

```bash
nmcli connection show
```

Atalhos:

```bash
nmcli con show
```

Exemplo:

```text
NAME              UUID                                  TYPE      DEVICE
MinhaWiFi         12345678-aaaa-bbbb-cccc-123456789abc  wifi      wlan0
Wired connection 1 87654321-aaaa-bbbb-cccc-987654321abc ethernet  eth0
```

---

## Mostrar uma conexão específica

```bash
nmcli connection show "MinhaWiFi"
```

---

## Ver somente conexões ativas

```bash
nmcli connection show --active
```

---

# 5. Wi-Fi

## Ativar Wi-Fi

```bash
nmcli radio wifi on
```

Desativar:

```bash
nmcli radio wifi off
```

Ver estado:

```bash
nmcli radio wifi
```

---

## Procurar redes Wi-Fi

```bash
nmcli device wifi list
```

ou:

```bash
nmcli dev wifi
```

---

## Atualizar a lista de redes

```bash
nmcli device wifi rescan
```

Depois:

```bash
nmcli device wifi list
```

---

## Conectar a uma rede Wi-Fi

```bash
nmcli device wifi connect "NOME_DA_REDE" password "SENHA"
```

Exemplo:

```bash
nmcli device wifi connect "MinhaWiFi" password "minhasenha"
```

---

## Conectar usando uma interface específica

```bash
nmcli device wifi connect "MinhaWiFi" password "minhasenha" ifname wlan0
```

---

## Desconectar Wi-Fi

```bash
nmcli device disconnect wlan0
```

---

## Reconectar

```bash
nmcli device connect wlan0
```

---

# 6. DHCP

Para utilizar DHCP:

```bash
nmcli connection modify "MinhaConexao" ipv4.method auto
```

Depois:

```bash
nmcli connection down "MinhaConexao"
nmcli connection up "MinhaConexao"
```

Verificar:

```bash
nmcli device show eth0
```

Procure por:

```text
IP4.ADDRESS
IP4.GATEWAY
IP4.DNS
```

---

# 7. IP estático

## Configurar IP

Exemplo:

```text
IP:      192.168.4.100
Prefixo: 24
Gateway: 192.168.4.1
```

Comando:

```bash
sudo nmcli connection modify "Wired connection 1" \
ipv4.addresses 192.168.4.100/24 \
ipv4.gateway 192.168.4.1 \
ipv4.method manual
```

---

## Configurar DNS

```bash
sudo nmcli connection modify "Wired connection 1" \
ipv4.dns "1.1.1.1 8.8.8.8"
```

---

## Aplicar configuração

```bash
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"
```

---

## Verificar

```bash
ip addr
```

```bash
ip route
```

```bash
resolvectl status
```

ou:

```bash
nmcli device show
```

---

# 8. DNS

## Definir DNS

```bash
nmcli connection modify "MinhaConexao" ipv4.dns "1.1.1.1 8.8.8.8"
```

---

## DNS automático

```bash
nmcli connection modify "MinhaConexao" ipv4.ignore-auto-dns no
```

---

## Ignorar DNS recebido pelo DHCP

```bash
nmcli connection modify "MinhaConexao" ipv4.ignore-auto-dns yes
```

---

## Consultar DNS configurado

```bash
nmcli device show | grep DNS
```

---

# 9. Gateway e rotas

## Ver tabela de rotas

```bash
ip route
```

Também:

```bash
nmcli device show
```

---

## Configurar gateway

```bash
nmcli connection modify "MinhaConexao" ipv4.gateway 192.168.4.1
```

---

## Adicionar rota estática

Exemplo:

```text
Rede:    10.10.0.0/24
Gateway: 192.168.4.1
```

```bash
nmcli connection modify "MinhaConexao" \
+ipv4.routes "10.10.0.0/24 192.168.4.1"
```

Aplicar:

```bash
nmcli connection down "MinhaConexao"
nmcli connection up "MinhaConexao"
```

Verificar:

```bash
ip route
```

---

## Remover rota

```bash
nmcli connection modify "MinhaConexao" \
-ipv4.routes "10.10.0.0/24 192.168.4.1"
```

---

# 10. Ativar e desativar interfaces

## Desconectar interface

```bash
nmcli device disconnect eth0
```

## Conectar interface

```bash
nmcli device connect eth0
```

---

## Desativar rede inteira

```bash
nmcli networking off
```

Ativar:

```bash
nmcli networking on
```

Verificar:

```bash
nmcli networking
```

---

# 11. Criar conexões

## Criar conexão Ethernet

```bash
sudo nmcli connection add \
type ethernet \
ifname eth0 \
con-name "Servidor"
```

---

## Criar conexão Ethernet com IP estático

```bash
sudo nmcli connection add \
type ethernet \
ifname eth0 \
con-name "Servidor" \
ipv4.addresses 192.168.4.100/24 \
ipv4.gateway 192.168.4.1 \
ipv4.dns "1.1.1.1 8.8.8.8" \
ipv4.method manual
```

Ativar:

```bash
nmcli connection up "Servidor"
```

---

# 12. Modificar conexões

Sintaxe geral:

```bash
nmcli connection modify "CONEXAO" PARAMETRO VALOR
```

Exemplo:

```bash
nmcli connection modify "Servidor" ipv4.addresses 192.168.4.150/24
```

Alterar gateway:

```bash
nmcli connection modify "Servidor" ipv4.gateway 192.168.4.1
```

Alterar método IPv4:

```bash
nmcli connection modify "Servidor" ipv4.method manual
```

Voltar para DHCP:

```bash
nmcli connection modify "Servidor" ipv4.method auto
```

---

## Alterar nome da conexão

```bash
nmcli connection modify "Servidor" connection.id "Servidor-LAN"
```

---

# 13. Remover conexões

Listar:

```bash
nmcli connection show
```

Remover:

```bash
sudo nmcli connection delete "MinhaConexao"
```

Também pode usar UUID:

```bash
sudo nmcli connection delete uuid UUID
```

---

# 14. VLAN

O `nmcli` permite criar interfaces VLAN.

Exemplo:

```text
Interface física: eth0
VLAN ID: 10
Nome: VLAN10
```

Criar:

```bash
sudo nmcli connection add \
type vlan \
ifname vlan10 \
dev eth0 \
id 10 \
con-name VLAN10
```

---

## Configurar IP na VLAN

```bash
sudo nmcli connection modify VLAN10 \
ipv4.addresses 192.168.10.2/24 \
ipv4.method manual
```

Ativar:

```bash
sudo nmcli connection up VLAN10
```

Verificar:

```bash
ip addr show vlan10
```

---

# 15. Bridge

Criar uma bridge:

```bash
sudo nmcli connection add \
type bridge \
ifname br0 \
con-name br0
```

Adicionar uma interface à bridge:

```bash
sudo nmcli connection add \
type ethernet \
ifname eth0 \
master br0 \
con-name br0-eth0
```

Ativar:

```bash
sudo nmcli connection up br0
```

Verificar:

```bash
nmcli device
```

---

# 16. Comandos úteis

## Resumo rápido

```bash
nmcli
```

---

## Interfaces

```bash
nmcli device
```

```bash
nmcli device status
```

```bash
nmcli device show
```

---

## Conexões

```bash
nmcli connection show
```

```bash
nmcli connection show --active
```

---

## Wi-Fi

```bash
nmcli radio wifi
```

```bash
nmcli device wifi list
```

```bash
nmcli device wifi rescan
```

---

## Rede

```bash
nmcli networking
```

```bash
nmcli networking on
```

```bash
nmcli networking off
```

---

## Interface específica

```bash
nmcli device show eth0
```

---

# 17. Troubleshooting

## Ver se o NetworkManager está rodando

```bash
systemctl status NetworkManager
```

---

## Ver dispositivos

```bash
nmcli device status
```

---

## Ver conexões ativas

```bash
nmcli connection show --active
```

---

## Ver IP

```bash
ip addr
```

ou:

```bash
nmcli device show
```

---

## Ver gateway

```bash
ip route
```

---

## Testar conectividade

```bash
ping 192.168.4.1
```

Internet:

```bash
ping 1.1.1.1
```

DNS:

```bash
ping google.com
```

---

## Problema de DNS

Testar diretamente um IP:

```bash
ping 1.1.1.1
```

Depois testar domínio:

```bash
ping google.com
```

Se o IP funciona mas o domínio não, provavelmente existe um problema de **DNS**.

Ver DNS:

```bash
nmcli device show | grep DNS
```

---

## Logs do NetworkManager

```bash
journalctl -u NetworkManager
```

Últimas mensagens:

```bash
journalctl -u NetworkManager -n 50
```

Acompanhar em tempo real:

```bash
journalctl -u NetworkManager -f
```

---

# 18. Exemplos práticos

## 🖥️ Exemplo 1 — Configurar servidor com IP fixo

Configuração:

```text
Interface: eth0
IP:        192.168.4.100/24
Gateway:   192.168.4.1
DNS:       1.1.1.1
```

Criar:

```bash
sudo nmcli connection add \
type ethernet \
ifname eth0 \
con-name "Servidor"
```

Configurar:

```bash
sudo nmcli connection modify "Servidor" \
ipv4.addresses 192.168.4.100/24 \
ipv4.gateway 192.168.4.1 \
ipv4.dns 1.1.1.1 \
ipv4.method manual
```

Ativar:

```bash
sudo nmcli connection up "Servidor"
```

Verificar:

```bash
ip addr show eth0
```

```bash
ip route
```

---

## 📶 Exemplo 2 — Conectar ao Wi-Fi

```bash
nmcli device wifi list
```

Depois:

```bash
nmcli device wifi connect "MinhaWiFi" password "SENHA"
```

Verificar:

```bash
nmcli connection show --active
```

---

## 🔄 Exemplo 3 — Voltar para DHCP

```bash
nmcli connection modify "Servidor" ipv4.method auto
```

Limpar IP manual:

```bash
nmcli connection modify "Servidor" ipv4.addresses ""
```

Reativar:

```bash
nmcli connection down "Servidor"
nmcli connection up "Servidor"
```

---

## 🌐 Exemplo 4 — Configurar DNS personalizado

```bash
nmcli connection modify "Servidor" \
ipv4.ignore-auto-dns yes \
ipv4.dns "1.1.1.1 8.8.8.8"
```

Aplicar:

```bash
nmcli connection up "Servidor"
```

---

## 🛣️ Exemplo 5 — Criar rota estática

Enviar a rede `10.10.10.0/24` pelo gateway `192.168.4.254`:

```bash
nmcli connection modify "Servidor" \
+ipv4.routes "10.10.10.0/24 192.168.4.254"
```

Aplicar:

```bash
nmcli connection up "Servidor"
```

Verificar:

```bash
ip route
```

---

# 19. Cheat Sheet

|Objetivo|Comando|
|---|---|
|Ver estado|`nmcli general status`|
|Listar interfaces|`nmcli device`|
|Detalhes da interface|`nmcli device show eth0`|
|Listar conexões|`nmcli connection show`|
|Conexões ativas|`nmcli con show --active`|
|Listar Wi-Fi|`nmcli device wifi list`|
|Rescan Wi-Fi|`nmcli device wifi rescan`|
|Conectar Wi-Fi|`nmcli dev wifi connect "SSID" password "SENHA"`|
|Desconectar interface|`nmcli dev disconnect eth0`|
|Conectar interface|`nmcli dev connect eth0`|
|Ativar Wi-Fi|`nmcli radio wifi on`|
|Desativar Wi-Fi|`nmcli radio wifi off`|
|Ativar rede|`nmcli networking on`|
|Desativar rede|`nmcli networking off`|
|Criar conexão|`nmcli con add ...`|
|Alterar conexão|`nmcli con modify ...`|
|Ativar conexão|`nmcli con up "NOME"`|
|Desativar conexão|`nmcli con down "NOME"`|
|Remover conexão|`nmcli con delete "NOME"`|
|Ver rotas|`ip route`|
|Ver IP|`ip addr`|
|Ver logs|`journalctl -u NetworkManager`|

---

# 🧠 Modelo mental

```text
                 NetworkManager
                       │
                       ▼
                     nmcli
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
       DEVICE                    CONNECTION
          │                         │
       eth0                       Servidor
       wlan0                      MinhaWiFi
       vlan10                     VLAN10
       br0                        br0-eth0
          │                         │
          └──────────┬──────────────┘
                     ▼
              Configuração de rede
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
       IP          Gateway        DNS
```

> [!tip] Regra importante  
> **`device` = interface de rede.**
> 
> **`connection` = perfil/configuração usado pelo NetworkManager.**
> 
> Na prática, você normalmente trabalha com `nmcli device` para descobrir o hardware/interfaces e com `nmcli connection` para configurar como essas interfaces devem funcionar.

> [!warning] Cuidado  
> Alterações feitas com `nmcli connection modify` podem substituir a configuração atual da conexão. Em servidores remotos via SSH, tenha cuidado ao alterar **IP, gateway ou interface**, pois você pode perder a conexão.

> [!tip] Para estudar  
> Os comandos que mais vale decorar primeiro são:
> 
> ```bash
> nmcli device
> nmcli device show
> nmcli connection show
> nmcli connection show --active
> nmcli device wifi list
> nmcli connection modify
> nmcli connection up
> nmcli connection down
> ```