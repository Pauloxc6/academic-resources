# 05 — SNAT, Masquerade e Forward

Neste exemplo vamos combinar os conceitos de **NAT** e **Firewall Filter**, observando principalmente o funcionamento da chain `forward`.

> ⚠️ Os comandos apresentados nesta etapa não são regras de SNAT/Masquerade. Eles pertencem ao **Firewall Filter** e controlam tráfego ICMP que atravessa o roteador.

---

# 🔀 Forward

A chain:

```routeros
/ip/firewall/filter
```

com:

```routeros
chain=forward
```

é utilizada para analisar pacotes que **passam pelo roteador**, indo de uma rede/interface para outra.

Exemplo:

```text id="7a1b4c"
LAN
   │
   │ ICMP
   ▼
┌──────────┐
│ MikroTik │
└────┬─────┘
     │
     ▼
 INTERNET
```

Nesse caso, o pacote não é destinado ao próprio MikroTik. Ele está sendo **encaminhado**.

Por isso:

```text id="8c2d5e"
forward → tráfego atravessando o roteador
```

---

# 📡 Permitindo Ping — Regra 1

A primeira regra:

```routeros id="91d4f7"
/ip/firewall/filter
add chain=forward \
    action=accept \
    protocol=icmp \
    icmp-options=8:0 \
    src-address-list=list-permitidos-1
```

permite determinadas requisições ICMP provenientes dos endereços presentes em:

```text id="3e6a91"
list-permitidos-1
```

---

## `protocol=icmp`

Define que a regra será aplicada somente ao protocolo:

```text id="0f52bc"
ICMP
```

O ICMP é utilizado por ferramentas e mecanismos como:

* `ping`;
* mensagens de erro;
* diagnóstico de conectividade;
* controle de determinadas condições de rede.

---

## `icmp-options=8:0`

Esse parâmetro identifica:

```text id="a91e73"
Type = 8
Code = 0
```

No IPv4:

```text id="6bc2f4"
ICMP Type 8 / Code 0
        │
        └── Echo Request
```

Ou seja, corresponde à **requisição de Echo**, normalmente enviada pelo `ping`.

O fluxo é:

```text id="c52a18"
Cliente
   │
   │ ICMP Echo Request
   ▼
MikroTik
   │
   ▼
Destino
```

---

# 📋 `src-address-list`

Na primeira regra temos:

```routeros id="f8b3c2"
src-address-list=list-permitidos-1
```

Isso significa:

> A **origem** do pacote precisa pertencer à `list-permitidos-1`.

Por exemplo:

```routeros id="e7a241"
/ip/firewall/address-list
add list=list-permitidos-1 address=192.168.4.0/24
```

Nesse caso, a rede:

```text
192.168.4.0/24
```

será considerada pela regra.

---

# 📡 Permitindo Ping — Regra 2

A segunda regra é:

```routeros id="b53f18"
/ip/firewall/filter
add chain=forward \
    action=accept \
    protocol=icmp \
    icmp-options=8:0 \
    dst-address-list=list-permitidos-1
```

Aqui temos uma diferença importante:

```text id="9d8a41"
src-address-list
        ↓
      ORIGEM

dst-address-list
        ↓
      DESTINO
```

Portanto, essa regra permite Echo Request cujo **destino** esteja na `list-permitidos-1`.

---

# 🔄 Diferença entre as duas regras

### Regra 1

```routeros id="8f5e10"
src-address-list=list-permitidos-1
```

Representação:

```text id="c9b1d3"
LISTA
  │
  │ origem
  ▼
[ CLIENTE ] ─────► [ DESTINO ]
```

A origem precisa estar na lista.

---

### Regra 2

```routeros id="0b7a42"
dst-address-list=list-permitidos-1
```

Representação:

```text id="2f6c81"
[ ORIGEM ] ─────► [ DESTINO ]
                       │
                       │ destino
                       ▼
                     LISTA
```

O destino precisa estar na lista.

---

# 🧠 Por que usar as duas?

Suponha que:

```text id="a4f921"
list-permitidos-1
        │
        ├── 192.168.4.0/24
        └── 10.10.10.0/24
```

A primeira regra permite:

```text id="e21b64"
192.168.4.0/24
       │
       │ ICMP Echo Request
       ▼
   qualquer destino
```

desde que o restante das regras permita esse tráfego.

A segunda permite:

```text id="9c41e7"
qualquer origem
       │
       │ ICMP Echo Request
       ▼
192.168.4.0/24
```

Assim, a `address-list` pode ser utilizada tanto para identificar **origens permitidas** quanto **destinos permitidos**.

---

# ⚠️ E o Echo Reply?

Aqui existe um detalhe importante.

O:

```text id="e6d832"
ICMP Type 8
```

é:

```text
Echo Request
```

A resposta do `ping` é:

```text id="0f7a65"
ICMP Type 0
```

ou:

```text
Echo Reply
```

Em um firewall stateful, normalmente podemos permitir o retorno utilizando `connection-state=established,related`, dependendo da configuração geral do firewall.

Exemplo comum:

```routeros id="a92c51"
/ip/firewall/filter
add chain=forward \
    connection-state=established,related \
    action=accept \
    comment="Permite conexões estabelecidas e relacionadas"
```

Assim:

```text id="4c82e1"
Echo Request
     │
     ▼
  [Firewall]
     │
     ▼
Destino
     │
     │ Echo Reply
     ▼
  [Firewall]
     │
     ▼
Origem
```

---

# 🔥 Onde entra o SNAT/Masquerade?

O **SNAT/Masquerade** e o **Forward** são mecanismos diferentes.

### Filter

```text id="0f4e72"
/ip/firewall/filter
```

Decide:

```text
ACCEPT
DROP
REJECT
```

### NAT

```text id="3b8a91"
/ip/firewall/nat
```

Realiza traduções como:

```text
MASQUERADE
SRC-NAT
DST-NAT
```

Podemos ter os dois trabalhando juntos:

```text id="71d9c4"
LAN
192.168.4.10
     │
     │
     ▼
┌─────────────┐
│   FILTER    │
│  FORWARD    │
└──────┬──────┘
       │ ACCEPT
       ▼
┌─────────────┐
│    SNAT     │
│ MASQUERADE  │
└──────┬──────┘
       │
       ▼
   INTERNET
```

O Filter controla **se pode passar**.

O NAT modifica **como o endereço aparece na comunicação**.

---

# 📊 Comparação

| Mecanismo  | Menu                  | Função                        |
| ---------- | --------------------- | ----------------------------- |
| Filter     | `/ip/firewall/filter` | Controlar tráfego             |
| SNAT       | `/ip/firewall/nat`    | Traduzir origem               |
| Masquerade | `/ip/firewall/nat`    | SNAT usando o IP da interface |
| DNAT       | `/ip/firewall/nat`    | Traduzir destino              |

---

# 🔍 Verificando as regras

Para visualizar as regras de Filter:

```routeros id="b7e2d9"
/ip/firewall/filter/print
```

Com estatísticas:

```routeros id="c4a81f"
/ip/firewall/filter/print stats
```

Para verificar NAT:

```routeros id="d92e47"
/ip/firewall/nat/print
```

E as address-lists:

```routeros id="e51b73"
/ip/firewall/address-list/print
```

---

# 🧠 Resumo

As regras desta etapa:

```routeros id="f1c3b8"
/ip/firewall/filter
add chain=forward action=accept protocol=icmp icmp-options=8:0 src-address-list=list-permitidos-1

/ip/firewall/filter
add chain=forward action=accept protocol=icmp icmp-options=8:0 dst-address-list=list-permitidos-1
```

fazem **Filter**, não SNAT.

### Primeira:

```text
src-address-list
        ↓
ORIGEM pertence à lista
```

### Segunda:

```text
dst-address-list
        ↓
DESTINO pertence à lista
```

E:

```text
ICMP Type 8 / Code 0
        ↓
Echo Request (ping)
```

---

## 🧩 Para memorizar

```text
FORWARD
   ↓
O pacote está atravessando o roteador?

src-address
   ↓
Quem enviou?

dst-address
   ↓
Para quem está indo?

src-address-list
   ↓
A origem pertence à lista?

dst-address-list
   ↓
O destino pertence à lista?

SNAT/MASQUERADE
   ↓
Modificar a origem

DNAT
   ↓
Modificar o destino
```
