# 04 — Criando várias regras de DNAT para um serviço igual

É possível criar várias regras de **DST-NAT (DNAT)** para publicar serviços semelhantes de diferentes servidores internos.

Isso é especialmente útil quando temos, por exemplo, **vários servidores SSH**, mas apenas um endereço IP público.

---

# 🌐 Cenário

Imagine que temos dois servidores dentro da LAN:

```text
Servidor 1
192.168.4.106
SSH → TCP/22

Servidor 2
192.168.4.104
SSH → TCP/8022
```

E apenas um IP público na interface:

```text
MikroTik
    │
    └── ether1-WAN
          │
          ▼
       INTERNET
```

Como não podemos utilizar a mesma combinação de:

```text
IP público + porta
```

para dois destinos diferentes simultaneamente, podemos utilizar **portas externas diferentes**.

---

# 🔀 Regra 1 — Porta 22

```routeros
/ip firewall nat
add chain=dstnat \
    action=dst-nat \
    to-addresses=192.168.4.106 \
    to-ports=22 \
    protocol=tcp \
    in-interface=ether1-WAN \
    dst-port=22 \
    comment="Redireciona TCP/22 para servidor SSH 192.168.4.106"
```

Essa regra recebe:

```text
IP-PUBLICO:22
```

e encaminha para:

```text
192.168.4.106:22
```

Fluxo:

```text
INTERNET
    │
    │ TCP/22
    ▼
MikroTik
    │
    │ DNAT
    ▼
192.168.4.106:22
```

---

# 🔀 Regra 2 — Porta externa 20

A segunda regra utiliza outra porta externa:

```routeros
/ip firewall nat
add chain=dstnat \
    action=dst-nat \
    to-addresses=192.168.4.104 \
    to-ports=8022 \
    protocol=tcp \
    in-interface=ether1-WAN \
    dst-port=20 \
    comment="Redireciona TCP/20 para servidor 192.168.4.104:8022"
```

Nesse caso:

```text
IP-PUBLICO:20
```

é traduzido para:

```text
192.168.4.104:8022
```

Fluxo:

```text
INTERNET
    │
    │ TCP/20
    ▼
MikroTik
    │
    │ DNAT
    ▼
192.168.4.104:8022
```

---

# 🧩 Porta externa ≠ porta interna

Essa é uma das partes mais importantes desse exemplo.

Na regra:

```routeros
dst-port=20
to-ports=8022
```

temos:

```text
dst-port
    ↓
Porta utilizada pelo cliente externo

to-ports
    ↓
Porta utilizada pelo servidor interno
```

Portanto:

```text
EXTERNO                  INTERNO

IP-PUBLICO:20  ──────►  192.168.4.104:8022
```

Não é necessário que sejam iguais.

---

# 🔐 Vários servidores SSH

Podemos ter:

```text
                    INTERNET
                       │
                       │
                 IP-PÚBLICO
                       │
                  ┌────┴────┐
                  │ MikroTik│
                  └────┬────┘
                       │
          ┌────────────┴────────────┐
          │                         │
      TCP/22                     TCP/20
          │                         │
          ▼                         ▼
  192.168.4.106:22         192.168.4.104:8022
       SSH #1                    SSH #2
```

Assim, um administrador poderia acessar:

```bash
ssh usuario@IP-PUBLICO -p 22
```

para o primeiro servidor.

E:

```bash
ssh usuario@IP-PUBLICO -p 20
```

para o segundo.

> ⚠️ Usar a porta `20` para SSH funciona tecnicamente como porta de entrada escolhida pelo administrador, mas é uma escolha pouco convencional. A porta TCP/20 é tradicionalmente associada ao FTP ativo. Para um ambiente real, é preferível escolher uma porta não conflitante e documentá-la.

---

# 🔄 DNAT com mudança de porta

Podemos representar a tradução assim:

### Servidor 1

```text
IP-PÚBLICO:22
      │
      │ DNAT
      ▼
192.168.4.106:22
```

### Servidor 2

```text
IP-PÚBLICO:20
      │
      │ DNAT
      ▼
192.168.4.104:8022
```

Perceba que o MikroTik pode alterar:

* endereço IP de destino;
* porta de destino;
* ou ambos.

---

# 🛡️ Firewall Filter

Assim como no exemplo anterior, **criar o DNAT não significa que devemos deixar o tráfego passar sem controle**.

Podemos criar regras específicas no `forward`.

Exemplo:

```routeros
/ip firewall filter
add chain=forward \
    in-interface=ether1-WAN \
    protocol=tcp \
    dst-address=192.168.4.106 \
    dst-port=22 \
    action=accept \
    comment="Permite SSH para servidor 106"
```

E:

```routeros
/ip firewall filter
add chain=forward \
    in-interface=ether1-WAN \
    protocol=tcp \
    dst-address=192.168.4.104 \
    dst-port=8022 \
    action=accept \
    comment="Permite SSH para servidor 104"
```

O firewall pode controlar exatamente quais servidores publicados podem receber conexões externas.

---

# 📊 Resumo das regras

| Porta externa | Servidor interno | Porta interna | Serviço |
| ------------: | ---------------- | ------------: | ------- |
|          `22` | `192.168.4.106`  |          `22` | SSH     |
|          `20` | `192.168.4.104`  |        `8022` | SSH     |

Representação:

```text
WAN:22 ──► 192.168.4.106:22
WAN:20 ──► 192.168.4.104:8022
```

---

# 🔍 Verificando o DNAT

Visualizar as regras:

```routeros
/ip firewall nat print
```

Ver estatísticas:

```routeros
/ip firewall nat print stats
```

Também podemos acompanhar as conexões:

```routeros
/ip firewall connection print
```

Os contadores de pacotes e bytes ajudam a confirmar se as regras estão sendo utilizadas.

---

# 🧠 Conceito principal

O objetivo dessa configuração é permitir que **um único IP público publique vários serviços/servidores**, utilizando portas externas diferentes.

```text
               IP PÚBLICO
                   │
          ┌────────┼────────┐
          │        │        │
        :22      :20      :443
          │        │        │
          ▼        ▼        ▼
       Server1  Server2   Server3
```

Cada porta externa pode possuir uma regra de DNAT diferente.

---

## 🧩 Para memorizar

```text
dst-port  → porta recebida na WAN

to-addresses → IP do servidor interno

to-ports → porta do serviço interno
```

Exemplo:

```routeros
dst-port=20
to-addresses=192.168.4.104
to-ports=8022
```

Leia como:

> **“Quando chegar TCP/20 pela WAN, encaminhe para `192.168.4.104:8022`.”**

### Regra mental

```text
PORTA EXTERNA
      ↓
    DNAT
      ↓
IP:PORTA INTERNA
```
