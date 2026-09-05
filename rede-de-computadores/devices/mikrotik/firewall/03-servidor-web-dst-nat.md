# 03 — Servidor Web com DST-NAT

O **DST-NAT (Destination NAT)** é utilizado para alterar o **endereço IP e/ou porta de destino** de uma conexão.

Um dos usos mais comuns é o **port forwarding**, permitindo que um serviço localizado na rede interna seja acessado através do endereço da interface WAN do MikroTik.

---

# 🌐 Cenário

Considere:

```text
                 INTERNET
                     │
                     │ TCP/80
                     ▼
              ┌──────────────┐
              │   MikroTik   │
              │              │
              │ ether1-WAN   │
              └───────┬──────┘
                      │
                  LAN │
                      ▼
              192.168.4.1
              Servidor Web
                  TCP/80
```

O cliente externo acessa:

```text
http://IP-PUBLICO/
```

O MikroTik recebe a conexão na porta `80` e redireciona para:

```text
192.168.4.1:80
```

---

# 🔀 Regra DST-NAT

A regra utilizada é:

```routeros
/ip firewall nat
add chain=dstnat \
    action=dst-nat \
    to-addresses=192.168.4.1 \
    to-ports=80 \
    protocol=tcp \
    in-interface=ether1-WAN \
    dst-port=80 \
    log=no \
    log-prefix=""
```

---

# 🧩 Entendendo a regra

### `chain=dstnat`

Indica que a regra pertence à cadeia de **Destination NAT**.

Ela será utilizada para modificar o destino da conexão.

---

### `action=dst-nat`

Define a ação como **Destination NAT**.

Neste caso, o endereço de destino original será substituído pelo endereço especificado em:

```routeros
to-addresses=192.168.4.1
```

---

### `to-addresses=192.168.4.1`

Define o **IP de destino após a tradução**.

Ou seja:

```text
IP público do MikroTik
        │
        │ DST-NAT
        ▼
192.168.4.1
```

---

### `to-ports=80`

Define a porta de destino utilizada pelo servidor interno.

Nesse caso:

```text
TCP/80 → TCP/80
```

Não é obrigatório que as portas sejam iguais.

Por exemplo:

```routeros
to-addresses=192.168.4.1
to-ports=8080
```

poderia encaminhar:

```text
IP-PUBLICO:80
       ↓
192.168.4.1:8080
```

---

### `protocol=tcp`

A regra será aplicada somente a tráfego **TCP**.

Isso faz sentido para um servidor HTTP tradicional utilizando TCP/80.

---

### `in-interface=ether1-WAN`

Determina que o pacote precisa **entrar pela interface WAN**:

```text
Internet
   │
   ▼
ether1-WAN
   │
   ▼
MikroTik
```

Isso evita que a regra seja aplicada indiscriminadamente a tráfego recebido por outras interfaces.

---

### `dst-port=80`

A regra procura conexões destinadas à porta:

```text
TCP/80
```

Portanto, uma conexão para:

```text
IP-PUBLICO:80
```

corresponderá à regra.

---

# 🔄 Fluxo da conexão

Antes do NAT:

```text
CLIENTE EXTERNO
      │
      │
      │ SRC = 200.10.10.20
      │ DST = IP-PUBLICO:80
      ▼
   MIKROTIK
```

Depois do DST-NAT:

```text
   MIKROTIK
      │
      │ SRC = 200.10.10.20
      │ DST = 192.168.4.1:80
      ▼
SERVIDOR WEB
192.168.4.1:80
```

O MikroTik mantém o estado da tradução para que as respostas retornem corretamente ao cliente.

---

# 🛡️ DST-NAT não substitui o Firewall Filter

Um ponto **muito importante**:

Criar o DST-NAT não significa automaticamente que o firewall permitirá o tráfego.

O pacote ainda precisa ser aceito pelo **Filter** na chain `forward`.

Por exemplo:

```routeros
/ip firewall filter
add chain=forward \
    in-interface=ether1-WAN \
    dst-address=192.168.4.1 \
    protocol=tcp \
    dst-port=80 \
    action=accept \
    comment="Permite acesso ao servidor Web"
```

A regra de NAT faz:

```text
IP-PUBLICO:80
      ↓
192.168.4.1:80
```

Enquanto o Filter decide:

```text
"Esse tráfego pode passar?"
```

---

# 🔁 Retorno da conexão

O NAT funciona nos dois sentidos da conexão.

Fluxo inicial:

```text
Internet
   │
   ▼
IP-PUBLICO:80
   │
   ▼
DST-NAT
   │
   ▼
192.168.4.1:80
```

Resposta:

```text
192.168.4.1:80
   │
   ▼
MikroTik
   │
   ▼
IP-PUBLICO:80
   │
   ▼
Internet
```

O **connection tracking** mantém as informações necessárias para realizar a tradução reversa.

---

# 🌍 Port Forwarding

Esse mecanismo também é conhecido como:

* **Port Forwarding**
* **Port Mapping**
* **Destination NAT**
* **DNAT**

Exemplo:

```text
WAN
203.0.113.10:80
       │
       │ Port Forward
       ▼
192.168.4.1:80
```

Outro exemplo:

```text
WAN
203.0.113.10:443
       │
       ▼
192.168.4.1:443
```

Para HTTPS:

```routeros
/ip firewall nat
add chain=dstnat \
    action=dst-nat \
    to-addresses=192.168.4.1 \
    to-ports=443 \
    protocol=tcp \
    in-interface=ether1-WAN \
    dst-port=443
```

---

# 📋 Verificando as regras

Visualizar as regras:

```routeros
/ip firewall nat print
```

Visualizar estatísticas:

```routeros
/ip firewall nat print stats
```

Os contadores de **packets** e **bytes** ajudam a verificar se as conexões estão realmente correspondendo à regra.

Também podemos verificar as conexões:

```routeros
/ip firewall connection print
```

---

# ⚠️ Cuidados de segurança

Publicar um serviço na Internet aumenta a superfície de ataque.

Antes de fazer isso em produção, considere:

* manter o servidor atualizado;
* utilizar HTTPS;
* restringir portas desnecessárias;
* utilizar regras de firewall específicas;
* monitorar logs;
* utilizar autenticação adequada;
* evitar expor serviços administrativos diretamente na Internet;
* manter o servidor em uma **DMZ** quando apropriado.

Por exemplo:

```text
                 INTERNET
                     │
                     ▼
               ┌──────────┐
               │ MikroTik │
               └────┬─────┘
                    DMZ
                     │
                     ▼
              ┌─────────────┐
              │ Web Server  │
              │ 192.168.4.1 │
              └─────────────┘
```

Assim, o servidor publicado fica separado da rede interna principal.

---

# 🧠 Resumo

### `srcnat`

Modifica principalmente a **origem**:

```text
192.168.4.10
     ↓
IP público
```

### `dstnat`

Modifica principalmente o **destino**:

```text
IP público:80
     ↓
192.168.4.1:80
```

### Regra do exemplo

```routeros
/ip firewall nat
add chain=dstnat \
    action=dst-nat \
    to-addresses=192.168.4.1 \
    to-ports=80 \
    protocol=tcp \
    in-interface=ether1-WAN \
    dst-port=80
```

Pode ser lida como:

> **“Tudo que chegar pela WAN usando TCP na porta 80 deve ter seu destino traduzido para `192.168.4.1:80`.”**

---

## 🧩 Para memorizar

```text
srcnat → QUEM está enviando?
dstnat → PARA QUEM está indo?

MASQUERADE → Internet saindo da LAN
DST-NAT     → Internet entrando em um servidor interno
```

```text
              INTERNET
                 │
                 │ :80
                 ▼
              [WAN]
             MikroTik
                 │
              DST-NAT
                 │
                 ▼
          192.168.4.1:80
           Web Server
```
