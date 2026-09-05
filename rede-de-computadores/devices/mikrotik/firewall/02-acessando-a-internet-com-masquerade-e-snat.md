# 02 — Acessando a Internet com Masquerade e SNAT

O **NAT (Network Address Translation)** permite alterar endereços IP e/ou portas dos pacotes durante o encaminhamento.

No MikroTik, as regras de NAT ficam em:

```routeros
/ip/firewall/nat
```

Uma das utilizações mais comuns é permitir que máquinas de uma rede privada acessem a Internet utilizando o endereço IP público da interface WAN.

---

# 🌐 Cenário

Considere a seguinte topologia:

```text
LAN
192.168.10.0/24
      │
      │
      ▼
┌─────────────┐
│   MikroTik  │
│             │
│ LAN         │ WAN
│ 192.168.10.1│  ether1-WAN
└─────────────┘
      │
      ▼
   INTERNET
```

Os computadores da LAN possuem endereços privados, por exemplo:

```text
PC → 192.168.10.10
```

Esses endereços não são utilizados diretamente para comunicação com a Internet.

O roteador realiza a tradução:

```text
192.168.10.10
      │
      ▼
[NAT MikroTik]
      │
      ▼
IP público da WAN
      │
      ▼
  INTERNET
```

---

# 🔄 Masquerade

A regra apresentada é:

```routeros
/ip firewall nat
add action=masquerade \
    chain=srcnat \
    log=yes \
    out-interface=ether1-WAN \
    src-address-list=list-permitidos-1
```

Essa regra realiza **NAT de origem (Source NAT)** utilizando `masquerade`.

## Parâmetros

| Parâmetro                            | Função                                                        |
| ------------------------------------ | ------------------------------------------------------------- |
| `add`                                | Cria uma regra                                                |
| `chain=srcnat`                       | Processa NAT de origem                                        |
| `action=masquerade`                  | Traduz o endereço de origem usando o IP da interface de saída |
| `out-interface=ether1-WAN`           | Aplica a regra quando o tráfego sai pela WAN                  |
| `src-address-list=list-permitidos-1` | Restringe a regra aos endereços presentes nessa lista         |
| `log=yes`                            | Gera registros no log quando a regra é utilizada              |

---

# 🧠 O que é `srcnat`?

`srcnat` significa **Source NAT**.

Ele é utilizado quando queremos modificar o endereço/porta de **origem** de uma conexão.

Exemplo:

```text
Antes do NAT:

192.168.10.10:51520
       │
       ▼
   8.8.8.8:443
```

Depois do NAT:

```text
IP público:40001
       │
       ▼
   8.8.8.8:443
```

O servidor da Internet passa a enxergar o endereço traduzido.

O MikroTik mantém o estado dessa tradução para conseguir devolver a resposta ao computador correto.

---

# 🔥 Masquerade

`masquerade` é uma forma de **Source NAT** especialmente conveniente quando o endereço da interface de saída pode mudar, como em conexões DHCP ou PPPoE.

Exemplo:

```routeros
/ip firewall nat
add chain=srcnat \
    action=masquerade \
    out-interface=ether1-WAN
```

Nesse caso, o MikroTik utiliza o endereço IP atualmente atribuído à `ether1-WAN`.

### Fluxo

```text
PC
192.168.10.10
     │
     ▼
MikroTik
     │
     │ Masquerade
     ▼
IP da ether1-WAN
     │
     ▼
Internet
```

---

# 🆚 Masquerade vs. src-nat

Ambos realizam **NAT de origem**, mas possuem aplicações diferentes.

## Masquerade

```routeros
/ip firewall nat
add chain=srcnat \
    action=masquerade \
    out-interface=ether1-WAN
```

É indicado principalmente quando o IP da WAN é **dinâmico**.

O endereço utilizado é obtido da própria interface de saída.

---

## `src-nat`

Com `src-nat`, especificamos explicitamente o endereço que será utilizado:

```routeros
/ip firewall nat
add chain=srcnat \
    action=src-nat \
    to-addresses=200.100.50.10 \
    out-interface=ether1-WAN
```

Nesse caso:

```text
IP privado
192.168.10.10
     │
     ▼
   src-nat
     │
     ▼
200.100.50.10
```

É mais apropriado quando temos um endereço de origem conhecido e estável.

---

# 📊 Comparação

| Característica               | `masquerade`        | `src-nat`             |
| ---------------------------- | ------------------- | --------------------- |
| Tipo                         | Source NAT          | Source NAT            |
| IP definido manualmente      | Não necessariamente | Sim                   |
| Utiliza IP da interface      | Sim                 | Não necessariamente   |
| Bom para IP dinâmico         | ✅                   | ⚠️                    |
| Bom para IP público estático | Pode funcionar      | ✅                     |
| `to-addresses`               | Não necessário      | Normalmente utilizado |

---

# 📋 Address List

A regra utiliza:

```routeros
src-address-list=list-permitidos-1
```

Isso significa que **somente os endereços presentes nessa address-list** serão considerados pela regra.

Podemos visualizar as listas com:

```routeros
/ip firewall address-list print
```

Exemplo:

```routeros
/ip firewall address-list
add list=list-permitidos-1 address=192.168.10.0/24
```

Agora a rede:

```text
192.168.10.0/24
```

está autorizada a passar por essa regra de NAT.

---

# 📝 Logging

A regra também possui:

```routeros
log=yes
```

Isso habilita o registro de correspondências da regra no log.

Podemos consultar:

```routeros
/log print
```

⚠️ Em um ambiente com muito tráfego, utilizar `log=yes` permanentemente pode gerar uma quantidade muito grande de logs. É melhor utilizar o logging de forma controlada durante testes ou troubleshooting.

---

# 🔀 Fluxo completo

Considere:

```text
PC
192.168.10.10
    │
    │
    ▼
MikroTik
192.168.10.1
    │
    │ ether1-WAN
    ▼
200.100.50.10
    │
    ▼
Internet
```

O pacote originalmente possui:

```text
SRC = 192.168.10.10
DST = 8.8.8.8
```

Ao passar pelo `srcnat`:

```text
SRC = 200.100.50.10
DST = 8.8.8.8
```

A resposta retorna:

```text
8.8.8.8
   │
   ▼
200.100.50.10
   │
   ▼
MikroTik
   │
   ▼
192.168.10.10
```

O MikroTik utiliza o estado da conexão/NAT para realizar a tradução reversa.

---

# 🔍 Verificando as regras

Para visualizar as regras de NAT:

```routeros
/ip firewall nat print
```

Para visualizar com detalhes:

```routeros
/ip firewall nat print detail
```

Durante troubleshooting, os contadores também são úteis:

```routeros
/ip firewall nat print stats
```

Eles ajudam a verificar se os pacotes estão realmente correspondendo à regra.

---

# ⚠️ NAT não é Firewall Filter

É importante separar os conceitos:

```text
FILTER
   │
   └── Decide o que fazer com o tráfego
       ACCEPT / DROP / REJECT

NAT
   │
   └── Modifica endereços/portas
       MASQUERADE / SRC-NAT / DST-NAT
```

Uma regra de `masquerade` **não significa que o tráfego foi permitido pelo firewall filter**.

São mecanismos diferentes.

---

# 🧠 Resumo

```text
/ip/firewall/nat
```

é o menu utilizado para NAT.

### `srcnat`

Trabalha principalmente com o **endereço de origem**.

### `masquerade`

Realiza Source NAT utilizando o endereço da interface de saída, sendo especialmente útil para WAN com IP dinâmico.

### `src-nat`

Permite definir explicitamente o endereço utilizado na tradução.

### Regra do exemplo

```routeros
/ip firewall nat
add action=masquerade \
    chain=srcnat \
    log=yes \
    out-interface=ether1-WAN \
    src-address-list=list-permitidos-1
```

Pode ser interpretada como:

> **“Quando um dispositivo pertencente à `list-permitidos-1` sair pela `ether1-WAN`, faça NAT de origem utilizando o endereço da WAN e registre a correspondência no log.”**

---

## 🧩 Para memorizar

```text
srcnat      → altera a origem
dstnat      → altera o destino

masquerade  → NAT de origem usando o IP da interface
src-nat     → NAT de origem com endereço definido
```
