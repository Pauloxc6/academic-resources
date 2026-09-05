# 12 — Bloqueando ataques de SYN Flood e Ping of Death

Nesta etapa vamos utilizar o Firewall Filter do MikroTik para implementar proteções básicas contra alguns tipos de tráfego abusivo:

* **SYN Flood**
* **Ping of Death**
* `jump`
* `limit`
* chains personalizadas

> ⚠️ As regras apresentadas são uma proteção básica para laboratório. Elas não substituem mecanismos completos de mitigação de DDoS/DoS.

---

# 🧠 1. `jump` no Firewall

O `jump` permite encaminhar um pacote para outra chain criada pelo administrador.

Exemplo:

```routeros
add action=jump \
    chain=forward \
    jump-target=Protect-SYN
```

A ideia é organizar as regras:

```text
FORWARD
   │
   ├── tráfego normal
   │
   └── TCP SYN
          │
          ▼
      Protect-SYN
          │
          ├── permite quantidade normal
          │
          └── bloqueia excesso
```

Isso facilita a organização de firewalls mais complexos.

---

# 🛡️ 2. Proteção contra SYN Flood

## O que é SYN Flood?

O **SYN Flood** é um ataque de negação de serviço que explora o processo de estabelecimento de uma conexão TCP.

O handshake normal é:

```text
Cliente                    Servidor

   SYN ─────────────────────►
   
       ◄──────────────── SYN + ACK

   ACK ─────────────────────►
   
          CONEXÃO ESTABELECIDA
```

No ataque, o atacante envia uma grande quantidade de:

```text
SYN
```

sem completar adequadamente o handshake.

```text
Atacante
   │
   ├── SYN ─────►
   ├── SYN ─────►
   ├── SYN ─────►
   ├── SYN ─────►
   ├── SYN ─────►
   ├── SYN ─────►
   └── SYN ─────►
                  │
                  ▼
               Servidor
```

Isso pode consumir recursos relacionados às conexões pendentes.

---

# 3. Enviando SYN para uma chain específica

A primeira regra é:

```routeros
add action=jump \
    chain=forward \
    comment="Proteção contra SYN Flood" \
    connection-state=new \
    jump-target=Protect-SYN \
    log=yes \
    protocol=tcp \
    tcp-flags=syn
```

Vamos analisar:

| Parâmetro                 | Função                                   |
| ------------------------- | ---------------------------------------- |
| `chain=forward`           | Analisa tráfego que atravessa o roteador |
| `action=jump`             | Desvia o processamento para outra chain  |
| `jump-target=Protect-SYN` | Chain de destino                         |
| `protocol=tcp`            | Considera somente TCP                    |
| `tcp-flags=syn`           | Procura pacotes SYN                      |
| `connection-state=new`    | Considera novas conexões                 |
| `log=yes`                 | Registra correspondências                |

Portanto:

```text
TCP
 │
 └── SYN
      │
      └── NEW
           │
           ▼
       Protect-SYN
```

---

# 4. Limitando SYNs

Na chain `Protect-SYN` temos:

```routeros
add chain=Protect-SYN \
    connection-state=new \
    limit=400,5:packet \
    protocol=tcp \
    tcp-flags=syn
```

O parâmetro:

```text
limit=400,5:packet
```

define uma limitação de correspondências.

De forma simplificada:

```text
400 pacotes
+
burst de 5
```

A sintaxe exata do `limit` deve ser interpretada de acordo com o mecanismo de token bucket do RouterOS.

O objetivo é permitir uma quantidade considerada aceitável de SYNs e evitar que todo o tráfego seja tratado como ataque.

---

# 5. Bloqueando o excesso

A próxima regra é:

```routeros
add action=drop \
    chain=Protect-SYN \
    connection-state=new \
    protocol=tcp \
    tcp-flags=syn
```

A lógica da chain fica:

```text
Protect-SYN
     │
     ▼
SYN + NEW
     │
     ▼
┌────────────────────┐
│ Dentro do limite?  │
└─────────┬──────────┘
          │
     ┌────┴────┐
     │         │
    SIM       NÃO
     │         │
     ▼         ▼
  ACCEPT      DROP
```

A primeira regra permite a quantidade de tráfego que estiver dentro do `limit`.

Quando ela deixa de corresponder devido ao limite, o pacote continua para a próxima regra:

```text
action=drop
```

e é descartado.

---

# ⚠️ Um detalhe importante

Essa proteção é baseada na **taxa de SYNs observada**, não em uma identificação sofisticada de "atacante".

Portanto, uma rede com muitos clientes legítimos abrindo conexões simultaneamente pode atingir o limite.

Por exemplo:

```text
Servidor web
    │
    ├── 100 clientes
    ├── 200 clientes
    ├── 300 clientes
    └── 400 clientes
```

Dependendo do ambiente, um limite muito baixo pode causar falsos positivos.

Os valores devem ser ajustados de acordo com o tráfego normal da rede.

---

# 💀 6. Ping of Death

Agora temos outra chain:

```routeros
add action=jump \
    chain=forward \
    comment="Proteção contra Ping of Death" \
    jump-target=PINGOFDEATH \
    protocol=icmp
```

Essa regra pega tráfego:

```text
ICMP
```

e envia para:

```text
PINGOFDEATH
```

Fluxo:

```text
ICMP
 │
 ▼
FORWARD
 │
 ▼
PINGOFDEATH
```

---

# 7. O que é Ping of Death?

O **Ping of Death** é uma técnica histórica de DoS baseada no envio de pacotes ICMP malformados ou excessivamente grandes, explorando vulnerabilidades de implementação.

Sistemas modernos normalmente possuem proteção contra esse problema específico.

Portanto, atualmente o termo também aparece em contextos de **ICMP flood/abuso de ICMP**, embora tecnicamente não sejam exatamente a mesma coisa.

---

# 8. Limitando ICMP Echo Request

A regra utilizada é:

```routeros
add action=drop \
    chain=PINGOFDEATH \
    icmp-options=8:0 \
    in-interface=ether1-WAN \
    limit=1,5:packet \
    protocol=icmp
```

Ela procura:

```text
ICMP
Type 8
Code 0
```

Ou seja:

```text
ICMP Echo Request
```

que é o pacote utilizado pelo `ping`.

Além disso:

```text
in-interface=ether1-WAN
```

limita a regra aos pacotes que entram pela interface WAN.

---

# ⚠️ Atenção ao funcionamento dessa regra

Existe uma particularidade importante.

A regra é:

```routeros
action=drop
limit=1,5:packet
```

Portanto, **ela não significa simplesmente "permita somente 1 ping"**.

O `limit` controla quando a própria regra corresponde.

Assim, a lógica é diferente de:

```text
permitir 1
bloquear todo o restante
```

Para implementar um rate-limit de ICMP de maneira mais explícita, normalmente usamos uma regra `accept` limitada seguida por uma regra `drop`.

Por exemplo:

```routeros
/ip/firewall/filter

add chain=forward \
    action=accept \
    protocol=icmp \
    icmp-options=8:0 \
    in-interface=ether1-WAN \
    limit=1,5:packet \
    comment="Permite ICMP dentro do limite"

add chain=forward \
    action=drop \
    protocol=icmp \
    icmp-options=8:0 \
    in-interface=ether1-WAN \
    comment="Bloqueia ICMP acima do limite"
```

A lógica fica muito mais clara:

```text
             ICMP Echo Request
                     │
                     ▼
              ┌─────────────┐
              │ Dentro do   │
              │   limite?   │
              └──────┬──────┘
                     │
              ┌──────┴──────┐
              │             │
             SIM           NÃO
              │             │
              ▼             ▼
           ACCEPT          DROP
```

---

# 🔄 `jump` x `chain`

O `jump` não cria a chain.

A chain precisa existir ou ser utilizada como destino conforme o mecanismo do RouterOS.

Conceitualmente:

```text
FORWARD
   │
   │ jump
   ▼
Protect-SYN
```

e:

```text
FORWARD
   │
   │ jump
   ▼
PINGOFDEATH
```

Isso permite separar a lógica:

```text
Firewall
│
├── regras gerais
│
├── Protect-SYN
│    └── proteção SYN
│
└── PINGOFDEATH
     └── proteção ICMP
```

---

# 🧩 SYN Flood x Ping of Death

| Ataque        | Protocolo | Característica                             |
| ------------- | --------- | ------------------------------------------ |
| SYN Flood     | TCP       | Grande quantidade de SYNs                  |
| Ping Flood    | ICMP      | Grande quantidade de Echo Requests         |
| Ping of Death | ICMP/IP   | Pacotes malformados/excessivamente grandes |
| UDP Flood     | UDP       | Grande volume de datagramas                |

Não devemos tratar todos esses ataques como se fossem exatamente a mesma coisa.

---

# 🛡️ Proteções adicionais

Para um firewall real, outras técnicas podem ser utilizadas.

## Connection Tracking

```routeros
connection-state=new
```

permite trabalhar especificamente com novas conexões.

## Address Lists

Podem ser utilizadas para identificar e bloquear endereços suspeitos.

```routeros
src-address-list=blacklist
```

## Rate Limiting

O:

```text
limit=
```

permite controlar a quantidade de pacotes que uma regra pode aceitar/processar como correspondência.

## Logging

```routeros
log=yes
```

pode ajudar na análise:

```text
ataque
   ↓
firewall
   ↓
log
   ↓
análise
```

> ⚠️ Não é recomendável habilitar `log=yes` indiscriminadamente em regras que recebem volumes enormes de tráfego, pois o próprio logging pode gerar carga adicional.

---

# 🔍 Comandos para verificar

Visualizar as regras:

```routeros
/ip/firewall/filter/print
```

Ver estatísticas:

```routeros
/ip/firewall/filter/print stats
```

Ver logs:

```routeros
/log/print
```

---

# 🧠 Resumo

Nesta configuração aprendemos:

```text
                Firewall
                   │
             ┌─────┴─────┐
             │           │
           TCP          ICMP
             │           │
            SYN         Echo
             │           │
             ▼           ▼
        Protect-SYN   PINGOFDEATH
             │           │
             ▼           ▼
           LIMIT       LIMIT
             │           │
             ▼           ▼
           DROP        DROP
```

### `jump`

```text
jump
 ↓
desvia o processamento
 ↓
chain especializada
```

### `limit`

```text
limit
 ↓
controla a taxa de correspondência
```

### `tcp-flags=syn`

```text
identifica SYN
```

### `icmp-options=8:0`

```text
ICMP Type 8 / Code 0
 ↓
Echo Request
 ↓
Ping
```

---

# 🎯 Para memorizar

```text
SYN Flood
    ↓
TCP
    ↓
SYN
    ↓
connection-state=new
    ↓
Protect-SYN
    ↓
limit
    ↓
excesso → DROP
```

```text
ICMP Flood
    ↓
ICMP
    ↓
Echo Request (8:0)
    ↓
PINGOFDEATH
    ↓
limit
    ↓
excesso → DROP
```

> **Observação:** o título `12-bloqueando-ataques-bf` não corresponde exatamente ao conteúdo. Essas regras tratam principalmente de **DoS/SYN Flood e ICMP**, e não de *brute force*. Um título mais preciso seria `12-protecao-contra-syn-flood-e-icmp`.
