# 08 — Prevenindo ataque de Brute Force

Um ataque de **Brute Force** consiste em realizar várias tentativas de autenticação até encontrar uma combinação válida de credenciais.

No caso do SSH, um atacante pode tentar repetidamente:

```text
usuario + senha
usuario + senha
usuario + senha
usuario + senha
...
```

Por isso, podemos utilizar o **Firewall + Address Lists + Connection Tracking** para dificultar esse tipo de ataque.

---

# 🔐 SSH

O SSH normalmente utiliza:

```text
TCP/22
```

Quando o serviço SSH do próprio MikroTik está exposto à rede, as conexões destinadas ao roteador passam pela chain:

```text
input
```

Exemplo:

```text
Internet
    │
    │ TCP/22
    ▼
┌──────────┐
│ MikroTik │
│   SSH    │
└──────────┘
    ▲
    │
  INPUT
```

---

# 🚫 Bloqueando SSH

A regra apresentada é:

```routeros
/ip/firewall/filter
add chain=input \
    action=drop \
    protocol=tcp \
    src-address-list=list-permitidos-1 \
    dst-port=22 \
    log=yes \
    log-prefix="" \
    comment="Bloqueia ataques de brute force no SSH"
```

Ela descarta conexões TCP destinadas à porta `22` quando a **origem pertence à `list-permitidos-1`**.

### ⚠️ Atenção

O nome:

```text
list-permitidos-1
```

sugere uma lista de endereços permitidos.

Se a intenção é armazenar **atacantes bloqueados**, seria mais claro utilizar:

```text
ssh-blacklist
```

Por exemplo:

```routeros
src-address-list=ssh-blacklist
```

Assim a regra pode ser interpretada como:

> "Se o IP de origem estiver na lista de bloqueio do SSH, descarte o acesso à porta 22."

---

# 📋 Address List

Uma Address List permite armazenar endereços IP para reutilização em regras do firewall.

Exemplo:

```routeros
/ip/firewall/address-list
add list=ssh-blacklist \
    address=203.0.113.50 \
    timeout=1d
```

Agora:

```text
203.0.113.50
       │
       ▼
ssh-blacklist
       │
       ▼
Firewall
       │
       X
      DROP
```

O endereço permanecerá na lista durante:

```text
1 dia
```

---

# ⏱️ `address-list-timeout`

No exemplo:

```routeros
address-list-timeout=1d
```

define durante quanto tempo o endereço permanecerá na lista.

Exemplos:

```text
1m   → 1 minuto
10m  → 10 minutos
1h   → 1 hora
1d   → 1 dia
```

Isso permite criar bloqueios temporários.

---

# 🧠 Como detectar Brute Force?

A ideia não é simplesmente bloquear qualquer conexão SSH.

Precisamos identificar **várias tentativas originadas pelo mesmo endereço**.

Uma técnica comum é utilizar:

```text
connection-state=new
```

junto com:

```text
connection-limit
```

ou, dependendo da estratégia:

```text
connection-state=new
connection-rate
address-list
```

O objetivo é:

```text
             Tentativas SSH
                    │
                    ▼
             ┌────────────┐
             │  Firewall  │
             └─────┬──────┘
                   │
          muitas tentativas?
                   │
              ┌────┴────┐
              │         │
             NÃO       SIM
              │         │
              ▼         ▼
           permite    blacklist
                        │
                        ▼
                       DROP
```

---

# 🔥 Exemplo utilizando Address List

Uma estratégia didática é colocar IPs que apresentarem comportamento suspeito em uma lista:

```routeros
/ip/firewall/filter
add chain=input \
    protocol=tcp \
    dst-port=22 \
    connection-state=new \
    src-address-list=ssh-stage1 \
    action=add-src-to-address-list \
    address-list=ssh-blacklist \
    address-list-timeout=1d \
    comment="Coloca IP suspeito na blacklist SSH"
```

Depois:

```routeros
/ip/firewall/filter
add chain=input \
    protocol=tcp \
    dst-port=22 \
    src-address-list=ssh-blacklist \
    action=drop \
    comment="Bloqueia IPs da blacklist SSH"
```

A lógica fica:

```text
IP suspeito
    │
    ▼
ssh-stage1
    │
    ▼
ssh-blacklist
    │
    ▼
    DROP
```

> ⚠️ Uma regra `action=add-src-to-address-list` não deve ser usada indiscriminadamente em toda conexão SSH nova, pois isso poderia colocar **qualquer usuário legítimo** na blacklist. É necessário construir uma sequência de regras/condições que realmente represente tentativas excessivas.

---

# 🔄 Regras `output` do exemplo

O material também apresenta:

```routeros
/ip/firewall/filter
add chain=output \
    action=accept \
    protocol=tcp \
    log=yes \
    log-prefix=""
```

e:

```routeros
/ip/firewall/filter
add chain=output \
    action=add-dst-to-address-list \
    address-list=ssh-blacklist \
    address-list-timeout=1d \
    log=yes \
    log-prefix=""
```

Aqui existe um ponto importante.

A chain:

```text
output
```

analisa tráfego **gerado pelo próprio MikroTik**.

```text
┌──────────┐
│ MikroTik │
└────┬─────┘
     │
     │ OUTPUT
     ▼
  Internet
```

Portanto, essas regras **não representam diretamente tentativas de conexão SSH recebidas pelo MikroTik**.

Para proteger o SSH do próprio roteador, normalmente estamos interessados em:

```text
chain=input
```

porque o atacante está tentando acessar **o próprio roteador**.

---

# 📌 `add-dst-to-address-list`

A ação:

```routeros
action=add-dst-to-address-list
```

adiciona o endereço de **destino** à Address List.

Enquanto:

```routeros
action=add-src-to-address-list
```

adiciona o endereço de **origem**.

Exemplo:

```text
add-src-to-address-list
        │
        ▼
IP de quem enviou o pacote
```

Já:

```text
add-dst-to-address-list
        │
        ▼
IP para quem o pacote está indo
```

Para identificar um atacante tentando acessar o SSH, normalmente queremos o:

```text
src-address
```

do atacante.

Por isso, `add-src-to-address-list` costuma fazer mais sentido nesse cenário.

---

# 🛡️ Melhor prática: não expor SSH desnecessariamente

Uma das melhores formas de reduzir brute force é **não deixar o SSH aberto para toda a Internet**.

Por exemplo, podemos permitir somente uma rede administrativa:

```routeros
/ip/firewall/filter
add chain=input \
    protocol=tcp \
    dst-port=22 \
    src-address=192.168.100.0/24 \
    connection-state=new \
    action=accept \
    comment="Permite SSH somente da rede administrativa"
```

E bloquear o restante:

```routeros
/ip/firewall/filter
add chain=input \
    protocol=tcp \
    dst-port=22 \
    connection-state=new \
    action=drop \
    comment="Bloqueia SSH externo"
```

Fluxo:

```text
Rede administrativa
192.168.100.0/24
        │
        │ SSH
        ▼
     ACCEPT


Internet
    │
    │ SSH
    ▼
   DROP
```

Essa abordagem é geralmente muito melhor do que simplesmente tentar reagir a milhares de tentativas de brute force.

---

# 🔑 Outras medidas

Além do firewall, podemos reduzir o risco utilizando:

* autenticação por chave SSH;
* desativação de login por senha quando possível;
* usuários individuais;
* senhas fortes;
* restrição por IP;
* VPN para acesso administrativo;
* desativação de serviços administrativos não utilizados;
* monitoramento dos logs.

---

# 🔍 Verificando os bloqueios

Para visualizar a Address List:

```routeros
/ip/firewall/address-list/print
```

Para visualizar somente a blacklist SSH:

```routeros
/ip/firewall/address-list/print where list=ssh-blacklist
```

Para verificar as regras:

```routeros
/ip/firewall/filter/print
```

E os logs:

```routeros
/log/print
```

---

# 🧠 Resumo

### Brute Force

```text
Muitas tentativas
      │
      ▼
Autenticação SSH
      │
      ▼
Possibilidade de descobrir credenciais
```

### Address List

```text
IP suspeito
     │
     ▼
ssh-blacklist
     │
     ▼
DROP TCP/22
```

### Chains

| Chain     | Função                                  |
| --------- | --------------------------------------- |
| `input`   | Tráfego destinado ao próprio MikroTik   |
| `forward` | Tráfego atravessando o MikroTik         |
| `output`  | Tráfego originado pelo próprio MikroTik |

### Address List

```text
add-src-to-address-list
        ↓
adiciona o IP de origem

add-dst-to-address-list
        ↓
adiciona o IP de destino
```

---

## 🧩 Para memorizar

Para proteger o **SSH do próprio MikroTik**:

```text
INTERNET
   │
   │ TCP/22
   ▼
INPUT
   │
   ├── IP autorizado → ACCEPT
   │
   ├── IP blacklist → DROP
   │
   └── IP suspeito → processo de detecção
```

E lembre:

```text
Brute Force
    ≠
qualquer conexão SSH

Brute Force
    =
múltiplas tentativas de autenticação
```

> **Firewall + Address List** pode ajudar a mitigar brute force, mas a proteção mais eficaz começa por **reduzir a exposição do SSH** e utilizar mecanismos de autenticação fortes.
