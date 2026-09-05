# 🌐 Trabalhando com Bridge VLAN Filtering

O **Bridge VLAN Filtering** permite transformar uma bridge do MikroTik em uma bridge **VLAN-aware**, controlando quais VLANs podem passar por cada porta e se os quadros entram ou saem **tagged** ou **untagged**.

Neste laboratório:

```text
                         R1
                          │
                    ether2/ether1
                          │
                       TRUNK
                    VLAN 10-13
                          │
                    ┌─────┴─────┐
                    │    R2     │
                    │ bridge100 │
                    └─────┬─────┘
                          │
             ┌────────────┼────────────┐
             │            │            │
          ether3       ether4       ether5
             │            │            │
          ACCESS        ACCESS        ACCESS
          VLAN 11       VLAN 12       VLAN 13
             │            │            │
             R3           R4           PC
```

---

# 🖥️ R1 — Criando as VLANs

No R1 são criadas quatro interfaces VLAN sobre a `ether2`:

```bash
/interface vlan
add name=vlan10 vlan-id=10 interface=ether2
add name=vlan11 vlan-id=11 interface=ether2
add name=vlan12 vlan-id=12 interface=ether2
add name=vlan13 vlan-id=13 interface=ether2
```

A `ether2` transportará as VLANs:

```text
VLAN 10
VLAN 11
VLAN 12
VLAN 13
```

---

# 🌐 Endereçamento das VLANs

```bash
/ip address
add address=10.10.10.1/24 interface=vlan10
add address=11.11.11.1/24 interface=vlan11
add address=12.12.12.1/24 interface=vlan12
add address=13.13.13.1/24 interface=vlan13
```

Cada VLAN possui sua própria rede IP:

| VLAN | Rede            | Gateway      |
| ---: | --------------- | ------------ |
|   10 | `10.10.10.0/24` | `10.10.10.1` |
|   11 | `11.11.11.0/24` | `11.11.11.1` |
|   12 | `12.12.12.0/24` | `12.12.12.1` |
|   13 | `13.13.13.0/24` | `13.13.13.1` |

---

# 📦 DHCP no R1

O DHCP será utilizado nas VLANs 11, 12 e 13:

```bash
/ip dhcp-server setup
```

Selecionando:

```text
interface = vlan11
```

Depois:

```bash
/ip dhcp-server setup
```

Selecionando:

```text
interface = vlan12
```

E:

```bash
/ip dhcp-server setup
```

Selecionando:

```text
interface = vlan13
```

Assim:

```text
VLAN 11 → DHCP → R3
VLAN 12 → DHCP → R4
VLAN 13 → DHCP → PC
```

A VLAN 10, neste exemplo, possui apenas o endereço IP configurado e não possui DHCP.

---

# 🔀 R2 — Bridge VLAN-aware

Primeiro identificamos as conexões:

```bash
/interface
set ether1 comment="R2->R1"
set ether3 comment="R2->R3"
set ether4 comment="R2->R4"
set ether5 comment="R2->PC"
```

A topologia será:

```text
ether1 → R1
ether3 → R3
ether4 → R4
ether5 → PC
```

---

# 🌉 Criando a bridge

```bash
/interface bridge
add name=bridge100 admin-mac=02:84:1B:0E:62:70
```

A bridge será o elemento central responsável pelo encaminhamento das VLANs.

Depois adicionamos as portas:

```bash
/interface bridge port
add interface=ether1 bridge=bridge100
add interface=ether2 bridge=bridge100
add interface=ether3 bridge=bridge100
add interface=ether4 bridge=bridge100
add interface=ether5 bridge=bridge100
```

> ⚠️ Aqui existe uma inconsistência no material original: a configuração coloca **`ether1` e `ether2`** na bridge, mas os comentários indicam que `ether1` é R2→R1. Se `ether2` não estiver sendo usado para outra conexão, ele não precisa estar na bridge.

O ponto principal é identificar corretamente qual porta conecta ao R1.

---

# 🏷️ Interface VLAN 10 na Bridge

No R2:

```bash
/interface vlan
add name=vlan10 vlan-id=10 interface=bridge100
```

Isso permite que o próprio R2 participe da VLAN 10 através da bridge.

Depois:

```bash
/ip address
add address=10.10.10.1/24 interface=vlan10
```

⚠️ **Outro ponto importante:** o R1 também está usando:

```text
10.10.10.1/24
```

na VLAN 10.

Portanto, temos:

```text
R1 → 10.10.10.1/24
R2 → 10.10.10.1/24
```

Isso é um **conflito de endereço IP**.

Se R2 também precisar ter um IP na VLAN 10, utilize outro endereço, por exemplo:

```bash
/ip address
add address=10.10.10.2/24 interface=vlan10
```

ficando:

```text
R1 = 10.10.10.1/24
R2 = 10.10.10.2/24
```

---

# 🔗 Configurando as VLANs na Bridge

Agora definimos quais portas transportam cada VLAN.

## VLAN 10 — Tagged

```bash
/interface bridge vlan
add bridge=bridge100 \
    vlan-ids=10 \
    tagged=ether1,ether2,bridge100
```

A VLAN 10 será transportada com tag nas interfaces especificadas.

Conceitualmente:

```text
R1
 │
 │ VLAN 10 tagged
 ▼
ether1
 │
 ▼
bridge100
```

> ⚠️ `bridge100` em `tagged=` é importante porque a própria CPU do MikroTik precisa participar da VLAN quando existe uma interface VLAN criada sobre a bridge.

---

# VLAN 11

```bash
/interface bridge vlan
add bridge=bridge100 \
    vlan-ids=11 \
    tagged=ether1 \
    untagged=ether3
```

Temos:

```text
R1
 │
 │ VLAN 11 tagged
 ▼
ether1
 │
 ▼
bridge100
 │
 │ VLAN 11 untagged
 ▼
ether3
 │
 ▼
R3
```

R3 recebe quadros **sem tag** na `ether1`.

---

# VLAN 12

```bash
/interface bridge vlan
add bridge=bridge100 \
    vlan-ids=12 \
    tagged=ether1 \
    untagged=ether4
```

Fluxo:

```text
R1
 │
 │ VLAN 12 tagged
 ▼
bridge100
 │
 │ VLAN 12 untagged
 ▼
ether4
 │
 ▼
R4
```

---

# VLAN 13

```bash
/interface bridge vlan
add bridge=bridge100 \
    vlan-ids=13 \
    tagged=ether1 \
    untagged=ether5
```

Fluxo:

```text
R1
 │
 │ VLAN 13 tagged
 ▼
bridge100
 │
 │ VLAN 13 untagged
 ▼
ether5
 │
 ▼
PC
```

---

# 🔢 PVID

Agora configuramos o **PVID** das portas de acesso:

```bash
/interface bridge port
set 2 pvid=11
set 3 pvid=12
set 4 pvid=13
```

O PVID define qual VLAN será atribuída aos quadros **untagged que entram** naquela porta.

Por exemplo:

```text
ether3
  │
  │ quadro untagged
  ▼
PVID 11
  │
  ▼
VLAN 11
```

Portanto:

| Porta    | PVID | VLAN de acesso |
| -------- | ---: | -------------: |
| `ether3` |   11 |        VLAN 11 |
| `ether4` |   12 |        VLAN 12 |
| `ether5` |   13 |        VLAN 13 |

> ⚠️ Os números usados em `set 2`, `set 3` e `set 4` são **índices das portas na configuração**, não necessariamente `ether2`, `ether3` e `ether4`. É mais seguro verificar com `/interface bridge port print` antes de utilizar esses índices.

Uma forma mais clara seria utilizar o `find`:

```bash
/interface bridge port
set [find interface=ether3] pvid=11
set [find interface=ether4] pvid=12
set [find interface=ether5] pvid=13
```

---

# 🔒 Ativando o VLAN Filtering

Por último:

```bash
/interface bridge
set bridge100 vlan-filtering=yes
```

Agora a bridge passa a aplicar efetivamente a tabela:

```text
/interface bridge vlan
```

Antes do `vlan-filtering=yes`, as regras de VLAN não são aplicadas da mesma maneira no encaminhamento.

---

# 💻 R3 — Cliente da VLAN 11

No R3:

```bash
/interface vlan
add name=vlan11 vlan-id=11 interface=ether1
```

Porém, aqui existe uma diferença importante.

No R2, `ether3` foi configurada como:

```text
untagged VLAN 11
```

Portanto, se o R3 estiver diretamente conectado à `ether3`, ele receberá **tráfego sem tag**.

Nesse caso, criar:

```bash
/interface vlan
add name=vlan11 vlan-id=11 interface=ether1
```

no R3 **não é compatível com essa porta de acesso**, porque uma interface VLAN espera receber quadros com a tag correspondente.

### Existem duas possibilidades.

### Opção 1 — R3 como access

Se R3 deve ser apenas um cliente da VLAN 11:

```text
R2 ether3
     │
     │ untagged
     ▼
R3 ether1
     │
     └── IP/DHCP diretamente na ether1
```

Então seria:

```bash
/ip dhcp-client
add interface=ether1
```

### Opção 2 — R3 como trunk

Se você realmente quer:

```text
R2 ether3
     │
     │ VLAN 11 tagged
     ▼
R3 ether1
     │
   vlan11
```

então a `ether3` do R2 deve ser configurada como **tagged**, e aí o R3 pode utilizar:

```bash
/interface vlan
add name=vlan11 vlan-id=11 interface=ether1

/ip dhcp-client
add interface=vlan11
```

Para o laboratório original, como `ether3` está configurada como `untagged`, a **Opção 1 é a coerente**.

---

# 💻 R4 — Cliente da VLAN 12

O mesmo princípio vale para R4.

No R2:

```text
ether4
PVID 12
untagged VLAN 12
```

Portanto, se R4 estiver conectado diretamente nessa porta como cliente:

```bash
/ip dhcp-client
add interface=ether1
```

Se quiser que R4 receba VLAN 12 **tagged**, então a porta do R2 precisa ser configurada como trunk/tagged.

---

# 🧩 Tagged × Untagged

Essa é a parte mais importante do laboratório.

### Tagged

O quadro possui uma tag 802.1Q:

```text
┌───────────────┬─────────┐
│ Ethernet      │ VLAN 11 │
└───────────────┴─────────┘
```

Normalmente usado em:

```text
TRUNK
```

### Untagged

O quadro não possui a tag quando sai da porta:

```text
┌───────────────┐
│ Ethernet      │
└───────────────┘
```

Normalmente usado em:

```text
ACCESS
```

---

# 🔄 PVID

O PVID trabalha principalmente com o tráfego **que entra** na porta.

Exemplo:

```text
PC
 │
 │ quadro untagged
 ▼
ether5
 │
 │ PVID 13
 ▼
VLAN 13
```

Na saída:

```text
VLAN 13
   │
   ▼
ether5
   │
   ▼
quadro untagged
   │
   ▼
PC
```

---

# 🧠 Fluxo completo do laboratório

```text
                           R1
                            │
                            │
                     TRUNK VLAN 10-13
                            │
                         ether1
                            │
                    ┌───────┴───────┐
                    │   bridge100   │
                    │ VLAN Filtering│
                    └───────┬───────┘
                            │
           ┌────────────────┼────────────────┐
           │                │                │
        ether3           ether4           ether5
        PVID 11          PVID 12          PVID 13
        access           access           access
           │                │                │
           ▼                ▼                ▼
          R3               R4               PC
        VLAN 11          VLAN 12          VLAN 13
```

---

# 📋 Tabela da Bridge

| VLAN | Trunk    | Access   | PVID |
| ---: | -------- | -------- | ---: |
|   10 | `ether1` | —        |    — |
|   11 | `ether1` | `ether3` |   11 |
|   12 | `ether1` | `ether4` |   12 |
|   13 | `ether1` | `ether5` |   13 |

E a CPU participa da VLAN 10:

```text
VLAN 10
  │
  ├── ether1
  ├── ether2* 
  └── bridge100
```

`ether2` só deve aparecer se realmente fizer parte do trunk no seu cenário.

---

# 🔍 Comandos para verificar

Ver as portas da bridge:

```bash
/interface bridge port print
```

Ver a tabela VLAN:

```bash
/interface bridge vlan print
```

Ver as bridges:

```bash
/interface bridge print
```

Ver as interfaces VLAN:

```bash
/interface vlan print
```

Ver os endereços:

```bash
/ip address print
```

Ver os leases DHCP:

```bash
/ip dhcp-server lease print
```

---

# 🧠 Para memorizar

```text
BRIDGE
   │
   ├── PORTA TRUNK
   │      └── VLANs TAGGED
   │
   └── PORTA ACCESS
          └── VLAN UNTAGGED
```

```text
PVID
 ↓
VLAN atribuída ao quadro UNTAGGED que entra
```

```text
TAGGED
 ↓
quadro sai com VLAN ID
```

```text
UNTAGGED
 ↓
quadro sai sem VLAN tag
```

```text
VLAN FILTERING
 ↓
Bridge passa a controlar
quais VLANs cada porta pode transportar
```

### ⚠️ Três correções importantes no exemplo original

1. **R1 e R2 não podem usar simultaneamente `10.10.10.1/24` na VLAN 10.** O R2 deveria usar outro endereço, como `10.10.10.2/24`, se precisar de IP nessa VLAN.
2. **R3/R4 estão configurados como interfaces VLAN, mas as portas correspondentes no R2 foram definidas como `untagged`.** Se forem portas de acesso, o DHCP deve ser recebido diretamente pela interface física; se quiser interfaces VLAN nos clientes, as portas precisam transportar a VLAN como `tagged`.
3. **`set 2`, `set 3`, `set 4` depende dos índices atuais das portas.** Para evitar erro, prefira `set [find interface=...]`.

> **Observação:** `use-service-tag=yes` não é necessário para uma VLAN 802.1Q comum. Ele está relacionado ao uso de **service tags/802.1ad (Q-in-Q)**. Para este laboratório de VLAN filtering tradicional, normalmente não seria utilizado.
