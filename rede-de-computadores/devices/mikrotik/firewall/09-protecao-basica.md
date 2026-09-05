# 09 — Proteção Básica

Nesta etapa vamos montar uma proteção básica para o MikroTik utilizando o **Firewall Filter**, combinando:

* `input`, `forward` e `output`;
* `connection-state`;
* Address Lists;
* proteção de Winbox;
* proteção de SSH;
* ICMP;
* HTTP/HTTPS;
* bloqueio de conexões inválidas;
* política de `drop` final.

> ⚠️ Esta configuração é voltada para **laboratório/estudo**. Em produção, as regras devem ser adaptadas à topologia e aos serviços realmente necessários.

---

# 🧱 Estrutura do Firewall

O firewall possui três chains principais:

```text
INPUT
Internet/LAN ─────► MikroTik


FORWARD
LAN ─────► MikroTik ─────► Internet
                 │
                 └────► Outra rede


OUTPUT
MikroTik ─────► Internet/LAN
```

| Chain     | Função                                  |
| --------- | --------------------------------------- |
| `input`   | Tráfego destinado ao próprio MikroTik   |
| `forward` | Tráfego que atravessa o MikroTik        |
| `output`  | Tráfego originado pelo próprio MikroTik |

---

# 1. Permitir acesso utilizando Address List

```routeros id="x8f3k1"
/ip/firewall/filter
add action=accept \
    chain=input \
    comment="Permite o acesso com address list" \
    in-interface=ether1-WAN \
    log=yes \
    src-address-list=list-permitidos-1
```

Permite acesso ao próprio MikroTik quando:

```text
interface de entrada = ether1-WAN
```

e o endereço de origem estiver em:

```text
list-permitidos-1
```

Fluxo:

```text
IP autorizado
     │
     ▼
ether1-WAN
     │
     ▼
   INPUT
     │
     ▼
  ACCEPT
```

---

# 2. Permitir a rede WAN

```routeros id="m5q7v2"
add action=accept \
    chain=input \
    comment="Permite a rede WAN" \
    src-address=192.168.122.0/24
```

Permite tráfego destinado ao próprio MikroTik proveniente da rede:

```text
192.168.122.0/24
```

> ⚠️ O nome "WAN" depende da topologia. `192.168.122.0/24` é apenas uma rede IP; ela não é automaticamente "WAN" por ser uma determinada faixa.

---

# 3. Permitir a rede sem depender da interface WAN

```routeros id="r4c9p6"
add action=accept \
    chain=input \
    in-interface=!ether1-WAN \
    src-address=192.168.122.0/24
```

O:

```text
in-interface=!ether1-WAN
```

significa:

> A interface de entrada **não pode ser** `ether1-WAN`.

Assim, essa regra aceita pacotes da rede `192.168.122.0/24` que cheguem por outras interfaces.

---

# 4. Bloquear conexões inválidas

```routeros id="t2w8n4"
add action=drop \
    chain=input \
    comment="Bloqueia conexões inválidas" \
    connection-state=invalid
```

Essa é uma proteção comum.

O Connection Tracking pode classificar determinados pacotes como:

```text
connection-state=invalid
```

A regra simplesmente descarta esses pacotes.

Também é comum aplicar essa proteção à chain `forward`:

```routeros id="p7d3m9"
add action=drop \
    chain=forward \
    connection-state=invalid \
    comment="Descarta conexões inválidas"
```

---

# 5. Permitir conexões estabelecidas

A configuração possui:

```routeros id="k6v1s8"
add action=accept \
    chain=forward \
    comment="Permite conexões estabelecidas" \
    connection-state=established \
    dst-address-list=list-permitidos-1
```

Ela permite tráfego `established` cujo destino esteja na Address List.

Porém, para uma política geral de firewall stateful, normalmente é mais útil:

```routeros id="c3x9h5"
add action=accept \
    chain=forward \
    connection-state=established,related \
    comment="Permite conexões estabelecidas e relacionadas"
```

Assim, o firewall permite o retorno de conexões já existentes e conexões relacionadas.

---

# 6. Permitir Winbox

O Winbox normalmente utiliza:

```text
TCP/8291
```

A regra:

```routeros id="n8q2w6"
add action=accept \
    chain=input \
    comment="Permite login no Winbox" \
    dst-port=8291 \
    log=yes \
    protocol=tcp \
    src-address-list=list-permitidos-1
```

permite acesso ao Winbox somente quando o IP de origem pertence à:

```text
list-permitidos-1
```

Fluxo:

```text
Administrador
      │
      │ TCP/8291
      ▼
  MikroTik
      │
      ▼
    INPUT
      │
      ▼
   ACCEPT
```

Isso é preferível a expor o Winbox para qualquer endereço da Internet.

---

# 7. Permitir saída TCP/80

A regra:

```routeros id="b4j7m1"
add action=accept \
    chain=output \
    comment="Permite saída TCP/80" \
    dst-port=80 \
    log=yes \
    protocol=tcp
```

permite conexões HTTP **originadas pelo próprio MikroTik**.

```text
MikroTik
    │
    │ TCP/80
    ▼
Internet
```

Isso não significa:

```text
LAN → Internet TCP/80
```

Para isso, normalmente estamos falando de `forward`.

---

# 8. Permitir ICMP

A primeira regra:

```routeros id="q1v6z3"
add action=accept \
    chain=forward \
    comment="Permite ICMP com origem na address-list" \
    icmp-options=8:0 \
    protocol=icmp \
    src-address-list=list-permitidos-1
```

permite:

```text
ICMP Type 8 / Code 0
```

que corresponde ao:

```text
Echo Request
```

ou seja, uma requisição de `ping`.

A origem precisa estar na Address List.

---

## ICMP destinado à Address List

```routeros id="w5c8n2"
add action=accept \
    chain=forward \
    comment="Permite ICMP com destino na address-list" \
    dst-address-list=list-permitidos-1 \
    icmp-options=8:0 \
    protocol=icmp
```

Aqui a condição é invertida:

```text
src-address-list
       ↓
origem está na lista


dst-address-list
       ↓
destino está na lista
```

---

# 9. HTTP e HTTPS

A configuração permite HTTP:

```routeros id="j3p8x6"
add action=accept \
    chain=forward \
    comment="Permite TCP/80" \
    dst-port=80 \
    protocol=tcp \
    src-address-list=list-permitidos-1
```

E também:

```routeros id="f7m2q9"
add action=accept \
    chain=forward \
    dst-address-list=list-permitidos-1 \
    dst-port=80 \
    protocol=tcp
```

Para HTTPS:

```routeros id="c5v9k1"
add action=accept \
    chain=forward \
    dst-port=443 \
    protocol=tcp \
    src-address-list=list-permitidos-1
```

E:

```routeros id="z8d4r2"
add action=accept \
    chain=forward \
    dst-address-list=list-permitidos-1 \
    dst-port=443 \
    protocol=tcp
```

---

# ⚠️ Atenção ao significado dessas regras

As regras acima não significam simplesmente:

> "Permitir Internet."

Elas permitem conexões `forward` que correspondam às condições especificadas.

Além disso, HTTP/HTTPS podem envolver:

```text
HTTP/1.1 → TCP/80
HTTPS    → TCP/443
HTTP/3   → UDP/443
```

Portanto, bloquear/liberar somente TCP/443 não representa necessariamente todo tráfego HTTP moderno.

---

# 10. Permitir SSH

A regra:

```routeros id="h6q3m8"
add action=accept \
    chain=forward \
    comment="Permite conexões SSH" \
    dst-port=22 \
    protocol=tcp \
    src-address-list=list-permitidos-1
```

permite SSH:

```text
TCP/22
```

para destinos acessíveis através do roteador, desde que a origem esteja na Address List.

> Se o objetivo for permitir **SSH no próprio MikroTik**, a chain correta é `input`, não `forward`.

---

# 11. Blacklist do Winbox

A configuração possui:

```routeros id="v4n8c2"
add action=drop \
    chain=input \
    comment="Bloqueia ataques de brute force no Winbox" \
    dst-port=8291 \
    protocol=tcp \
    src-address-list=winbox-blacklist
```

A lógica é:

```text
IP
 │
 ▼
winbox-blacklist
 │
 ▼
TCP/8291
 │
 ▼
DROP
```

Essa parte faz sentido: endereços colocados na blacklist são impedidos de acessar o Winbox.

---

# 12. Detecção baseada em `login incorrect`

O material utiliza:

```routeros id="p1w6s9"
add action=accept \
    chain=output \
    content="login incorrect" \
    dst-limit=1/1m,9,dst-address/1m \
    protocol=tcp
```

e:

```routeros id="y7c3m5"
add action=add-dst-to-address-list \
    address-list=winbox-blacklist \
    address-list-timeout=3h \
    chain=output \
    content="login incorrect" \
    protocol=tcp
```

A ideia é detectar a mensagem:

```text
login incorrect
```

e colocar um endereço na:

```text
winbox-blacklist
```

durante:

```text
3 horas
```

### ⚠️ Porém, há uma questão importante

A chain `output` representa tráfego **gerado pelo próprio MikroTik**.

Portanto, essa lógica depende de como o RouterOS está expondo/gerando o conteúdo que essas regras procuram. Não é uma técnica universal para detectar brute force de Winbox.

Além disso, `content=` procura conteúdo visível nos pacotes e não deve ser tratado como um mecanismo robusto de detecção de autenticação.

---

# 13. Blacklist do SSH

A configuração apresenta:

```routeros id="k2r7v4"
add action=drop \
    chain=input \
    comment="Bloqueia ataques de brute force no SSH" \
    dst-port=22 \
    log=yes \
    protocol=tcp \
    src-address-list=list-permitidos-1
```

Aqui existe um problema conceitual.

Se:

```text
list-permitidos-1
```

representa IPs permitidos, então essa regra está dizendo:

```text
IP permitido
      │
      ▼
TCP/22
      │
      ▼
DROP
```

Ou seja, ela pode bloquear justamente os endereços que deveriam estar permitidos.

Para uma blacklist SSH, seria mais coerente:

```routeros id="x9m5q3"
src-address-list=ssh-blacklist
```

ficando:

```routeros id="p6d2k8"
add action=drop \
    chain=input \
    protocol=tcp \
    dst-port=22 \
    src-address-list=ssh-blacklist \
    comment="Bloqueia IPs na blacklist SSH"
```

---

# 14. Regras `output` para SSH

O material apresenta:

```routeros id="r8v3n6"
add action=accept \
    chain=output \
    log=yes \
    protocol=tcp
```

seguido por:

```routeros id="m4q9c7"
add action=add-dst-to-address-list \
    address-list=ssh-blacklist \
    address-list-timeout=10d \
    chain=output \
    log=yes
```

Essas regras são extremamente amplas.

A primeira:

```text
chain=output
protocol=tcp
action=accept
```

permite **qualquer TCP originado pelo próprio MikroTik**.

A segunda pode adicionar destinos TCP à blacklist sem uma condição suficientemente específica.

Isso não é uma forma segura de detectar brute force SSH.

---

# 🛑 Drop final

A última regra é:

```routeros id="w2c6p8"
add action=drop \
    chain=forward \
    comment="Drop Geral"
```

Essa regra funciona como um:

```text
DEFAULT DENY
```

Ou seja:

```text
Se nenhuma regra anterior permitiu:
        ↓
      DROP
```

Fluxo:

```text
                  PACOTE
                    │
                    ▼
             ┌─────────────┐
             │   Firewall  │
             └──────┬──────┘
                    │
          ┌─────────┴─────────┐
          │                   │
       permitido           não permitido
          │                   │
          ▼                   ▼
       ACCEPT                DROP
```

---

# ⚠️ Um detalhe importante: `input` também precisa de política final

O material possui:

```text
DROP final
chain=forward
```

mas não apresenta um `drop` final equivalente para `input`.

Se a intenção é construir uma política **default deny** para acesso ao próprio MikroTik, normalmente teríamos algo como:

```routeros id="n7x3m5"
add chain=input \
    action=drop \
    comment="Drop geral de INPUT"
```

Depois de todas as exceções necessárias.

Porém, isso precisa ser feito com cuidado para não bloquear o próprio acesso administrativo.

---

# 🔐 Estrutura mais organizada

Uma estrutura didática mais coerente seria:

```text
INPUT
│
├── DROP invalid
├── ACCEPT established,related
├── ACCEPT administração autorizada
├── ACCEPT serviços necessários
├── DROP blacklist
└── DROP restante


FORWARD
│
├── DROP invalid
├── ACCEPT established,related
├── ACCEPT tráfego necessário
├── ACCEPT serviços publicados
├── regras específicas
└── DROP restante


OUTPUT
│
├── regras específicas, se necessárias
└── política definida
```

---

# 🧠 Resumo

Esta etapa combina vários mecanismos:

```text
Firewall Filter
      │
      ├── input
      ├── forward
      └── output
            │
            ├── connection-state
            ├── address-list
            ├── ICMP
            ├── SSH
            ├── Winbox
            ├── HTTP/HTTPS
            └── DROP
```

### Principais conceitos

| Conceito           | Função                                    |
| ------------------ | ----------------------------------------- |
| `input`            | Protege o próprio MikroTik                |
| `forward`          | Controla tráfego que atravessa o MikroTik |
| `output`           | Controla tráfego gerado pelo MikroTik     |
| `connection-state` | Identifica o estado da conexão            |
| `address-list`     | Agrupa endereços para reutilização        |
| `accept`           | Permite                                   |
| `drop`             | Descarta                                  |
| `dst-port`         | Porta de destino                          |
| `src-address-list` | Lista baseada na origem                   |
| `dst-address-list` | Lista baseada no destino                  |

---

# 🧩 Para memorizar

```text
              FIREWALL
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
      INPUT    FORWARD    OUTPUT
        │         │         │
        ▼         ▼         ▼
    ROTEADOR    TRÂNSITO   ROTEADOR
```

### Regra fundamental

```text
input
  ↓
"Alguém está tentando acessar o MikroTik?"

forward
  ↓
"Alguém está atravessando o MikroTik?"

output
  ↓
"O próprio MikroTik está iniciando a comunicação?"
```

### E a política final:

```text
ALLOWLIST
    ↓
Regras específicas
    ↓
DROP
```

> **Um firewall seguro normalmente começa com uma política clara de "o que é permitido" e termina bloqueando aquilo que não foi explicitamente autorizado.**
