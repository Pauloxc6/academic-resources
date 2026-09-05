# 📶 Criando uma rede para convidados com VLAN Wi-Fi

A ideia é criar uma rede Wi-Fi exclusiva para convidados:

```text
                 Internet
                    │
                 Router
                    │
              ┌─────┴─────┐
              │           │
           Rede LAN    VLAN 10
                          │
                    Wi-Fi Convidados
                          │
                    10.1.1.0/24
```

A rede de convidados será separada da rede principal através da **VLAN 10** e de regras de firewall.

---

# 📡 Criando a interface Wi-Fi virtual

```bash
/interface virtual
add name=WIFI-Convidados \
    mode=ap-bridge \
    ssid=Convidados \
    master-interface=wlan1 \
    wps=disabled \
    vlan-id=10 \
    security=profile-100
```

Essa interface cria uma **interface virtual (VAP)** sobre a interface física `wlan1`.

```text
wlan1
  │
  ├── Wi-Fi principal
  │
  └── WIFI-Convidados
          │
          └── VLAN 10
```

### Parâmetros importantes

| Parâmetro                | Função                               |
| ------------------------ | ------------------------------------ |
| `name`                   | Nome da interface virtual            |
| `mode=ap-bridge`         | Opera como ponto de acesso           |
| `ssid=Convidados`        | Nome da rede Wi-Fi                   |
| `master-interface=wlan1` | Interface Wi-Fi principal            |
| `wps=disabled`           | Desativa WPS                         |
| `vlan-id=10`             | Associa a interface à VLAN 10        |
| `security=profile-100`   | Utiliza o perfil de segurança criado |

> ⚠️ A sintaxe de interfaces Wi-Fi varia entre versões e entre os pacotes `wireless` e `wifi` do RouterOS. Em versões modernas, confirme os parâmetros disponíveis com `?`.

---

# 🔐 Criando o perfil de segurança

```bash
/interface wifi security
add authentication-types=wpa2-psk,wpa3-psk \
    disabled=no \
    group-encryption=ccmp \
    group-key-update=10m \
    name=profile-100 \
    wps=disable
```

O perfil permite autenticação utilizando:

```text
WPA2-PSK
WPA3-PSK
```

e utiliza:

```text
CCMP
```

para criptografia do tráfego de grupo.

O parâmetro:

```text
group-key-update=10m
```

define o intervalo de atualização da chave de grupo.

---

# 🏷️ Criando a interface VLAN

```bash
/interface vlan
add name=vlan10 \
    vlan-id=10 \
    interface=WIFI-Convidados
```

Criamos uma interface lógica para a VLAN 10:

```text
WIFI-Convidados
       │
       │ VLAN 10
       ▼
    vlan10
```

---

# 🌉 Criando a bridge dos convidados

```bash
/interface bridge
add name=bridge10
```

Agora adicionamos as interfaces:

```bash
/interface bridge port
add interface=vlan10 bridge=bridge10

/interface bridge port
add interface=WIFI-Convidados bridge=bridge10
```

Porém, **aqui existe um ponto importante na configuração original**.

Você está colocando na mesma bridge:

```text
WIFI-Convidados
       │
       ▼
     vlan10
       │
       ▼
   bridge10
```

Como `vlan10` foi criada sobre `WIFI-Convidados`, isso pode criar uma topologia inadequada ou até um caminho redundante/loop.

Para uma configuração de **Wi-Fi com VLAN**, é necessário definir claramente onde a VLAN será aplicada:

```text
Wi-Fi
  │
  ▼
VLAN 10
  │
  ▼
Bridge
  │
  ▼
Rede 10.1.1.0/24
```

A configuração exata depende de onde você quer fazer a **tag/untag da VLAN**.

---

# 🌐 Endereço IP da rede de convidados

```bash
/ip address
add address=10.1.1.1/24 \
    interface=bridge10 \
    comment=Convidados
```

A rede será:

```text
Rede:       10.1.1.0/24
Gateway:    10.1.1.1
Broadcast:  10.1.1.255
```

Os clientes receberão endereços dentro dessa rede.

Exemplo:

```text
10.1.1.10
10.1.1.11
10.1.1.12
...
```

---

# 📦 DHCP

Podemos criar o servidor DHCP utilizando:

```bash
/ip dhcp-server setup
```

E selecionar:

```text
interface = bridge10
```

O DHCP fornecerá automaticamente aos clientes:

```text
IP
Máscara
Gateway
DNS
```

Por exemplo:

```text
Cliente
   │
   ├── IP:      10.1.1.10
   ├── Mask:    255.255.255.0
   ├── Gateway: 10.1.1.1
   └── DNS:     configurado pelo DHCP
```

---

# 🔥 Isolando a rede de convidados

As primeiras regras impedem comunicação entre a interface `ether4` e a rede de convidados.

### LAN → Convidados

```bash
/ip firewall filter
add chain=forward \
    action=drop \
    disabled=no \
    in-interface=ether4 \
    out-interface=bridge10
```

Fluxo bloqueado:

```text
ether4 ─────X─────► bridge10
```

### Convidados → LAN

```bash
/ip firewall filter
add chain=forward \
    action=drop \
    disabled=no \
    in-interface=bridge10 \
    out-interface=ether4
```

Fluxo bloqueado:

```text
bridge10 ─────X─────► ether4
```

Assim, o tráfego entre as duas redes é bloqueado nos dois sentidos.

---

# 🚫 Impedindo acesso dos convidados ao próprio roteador

```bash
/ip firewall filter
add chain=input \
    action=drop \
    disabled=no \
    in-interface=bridge10 \
    comment="Drop tudo da rede convidado"
```

A diferença entre `input` e `forward` é muito importante:

```text
                 Router
                /      \
           INPUT        FORWARD
             │             │
             ▼             ▼
        próprio       outra rede/
        roteador      outro destino
```

### `chain=input`

Controla tráfego destinado **ao próprio MikroTik**.

Exemplo:

```text
Cliente convidado
       │
       ▼
10.1.1.1 (MikroTik)
       X
```

### `chain=forward`

Controla tráfego que **passa pelo MikroTik** em direção a outro destino.

Exemplo:

```text
Convidado
   │
   ▼
MikroTik
   │
   X
   ▼
LAN
```

---

# ⚠️ Cuidado com "Drop tudo"

A regra:

```bash
chain=input
in-interface=bridge10
action=drop
```

bloqueia **todo tráfego destinado ao roteador** vindo dessa interface.

Isso inclui, dependendo das demais regras e da ordem do firewall:

* DNS;
* DHCP já possui tratamento especial no RouterOS;
* ping para o gateway;
* acesso administrativo;
* outros serviços do próprio roteador.

Portanto, se os convidados precisarem utilizar o MikroTik como **DNS**, por exemplo, será necessário permitir DNS antes do `drop`.

A ordem das regras importa:

```text
1. ACCEPT necessário
2. ACCEPT necessário
3. DROP convidados
```

---

# 🌎 Internet para os convidados

Bloquear a comunicação com a LAN não significa bloquear a Internet.

O fluxo desejado normalmente é:

```text
                    Internet
                       ▲
                       │
                    NAT/WAN
                       │
                    MikroTik
                       │
             ┌─────────┴─────────┐
             │                   │
            LAN            Rede Convidados
                                  │
                              VLAN 10
                                  │
                              Wi-Fi
```

Ou seja:

```text
Convidado ──► Internet     ✅
Convidado ──X──► LAN       ❌
Convidado ──X──► Router    ❌
```

Para isso, além das regras de firewall, é necessário que exista **rota e NAT adequados** para a rede `10.1.1.0/24`.

Exemplo conceitual:

```bash
/ip firewall nat
add chain=srcnat \
    src-address=10.1.1.0/24 \
    out-interface=WAN \
    action=masquerade
```

Substitua `WAN` pela interface WAN real do seu cenário.

---

# 🧠 Fluxo completo

```text
                   INTERNET
                       ▲
                       │
                     NAT
                       │
                  ┌────┴────┐
                  │ MikroTik│
                  └────┬────┘
                       │
                  VLAN 10
                       │
                WIFI-Convidados
                       │
                 SSID: Convidados
                       │
                  10.1.1.0/24
                       │
                    Clientes
```

Firewall:

```text
                 CONVIDADOS
                     │
          ┌──────────┼──────────┐
          │          │          │
          ▼          ▼          ▼
       Internet     LAN       Router
          │          X           X
          ▼
        ALLOW
```

---

# 🧠 Para memorizar

```text
SSID
 ↓
WIFI-Convidados
 ↓
VLAN 10
 ↓
bridge10
 ↓
10.1.1.0/24
 ↓
DHCP
 ↓
Firewall
 ↓
Internet
```

### `input`

```text
Cliente → MikroTik
```

### `forward`

```text
Cliente → MikroTik → outro destino
```

### Objetivo da rede de convidados

```text
┌──────────────────────────────┐
│       REDE CONVIDADOS        │
│                              │
│ VLAN 10                      │
│ 10.1.1.0/24                  │
│                              │
│ Internet       ✅             │
│ LAN            ❌             │
│ Router         ❌*            │
└──────────────────────────────┘

* conforme as regras de firewall
```
