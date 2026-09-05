# 🌐 Trabalhando com EGP

## 📚 O que é EGP?

**EGP (Exterior Gateway Protocol)** é uma categoria de protocolos utilizada para realizar roteamento **entre diferentes Sistemas Autônomos (AS)**.

Enquanto os **IGPs** são utilizados dentro de um AS:

```text
AS 200
R1 ─── OSPF ─── R2
```

os protocolos de roteamento externo permitem a comunicação entre AS diferentes:

```text
AS 200                    AS 201
   │                        │
   │        BGP/eBGP        │
   └──────────┬─────────────┘
              │
```

O principal protocolo utilizado atualmente para essa função é o **BGP (Border Gateway Protocol)**.

> ⚠️ Tecnicamente, **EGP é uma categoria**, enquanto **BGP é o protocolo utilizado neste laboratório**. O antigo protocolo chamado EGP (Exterior Gateway Protocol, RFC 904) é obsoleto.

---

# 🧪 Topologia do laboratório

Neste cenário temos dois roteadores pertencentes a AS diferentes:

```text
             AS 200                         AS 201
        ┌─────────────┐                ┌─────────────┐
        │     R1      │                │     R2      │
        │             │                │             │
        │ Loopback    │                │ Loopback    │
        │100.100.100.1│                │110.110.110.1│
        └──────┬──────┘                └──────┬──────┘
               │                              │
               └──────────── eBGP ────────────┘
```

A sessão BGP utiliza as **loopbacks** como endereços dos vizinhos:

```text
R1 → remote.address=110.110.110.1
R2 → remote.address=100.100.100.1
```

---

# 🖥️ R1 — AS 200

## Default Route

```bash id="n6p0r2"
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1
```

Essa rota define o caminho padrão utilizado pelo R1 para destinos que não possuam uma rota mais específica.

```text
0.0.0.0/0
    ↓
192.168.122.1
```

---

## Configurando a sessão BGP

```bash id="q8w4sm"
/routing bgp connection add \
    name=bgp1 \
    disabled=no \
    remote.address=110.110.110.1 \
    remote.as=201 \
    templates=default \
    input.filter=bgp1-in \
    output.filter-chain=bgp1-out \
    multihop=yes \
    vrf=main \
    local.role=ebgp
```

### Principais parâmetros

| Parâmetro                      | Função                                              |
| ------------------------------ | --------------------------------------------------- |
| `name=bgp1`                    | Nome da conexão                                     |
| `remote.address=110.110.110.1` | Endereço do vizinho BGP                             |
| `remote.as=201`                | AS remoto                                           |
| `templates=default`            | Utiliza o template BGP `default`                    |
| `local.role=ebgp`              | Define a sessão como eBGP                           |
| `input.filter=bgp1-in`         | Filtro das rotas recebidas                          |
| `output.filter-chain=bgp1-out` | Filtro das rotas anunciadas                         |
| `multihop=yes`                 | Permite estabelecer a sessão além de um único salto |
| `vrf=main`                     | Utiliza a VRF principal                             |

O R1 está no:

```text
AS = 200
```

e estabelece uma sessão com:

```text
AS remoto = 201
```

Como os AS são diferentes:

```text
200 ≠ 201
```

a sessão é:

```text
eBGP
```

---

# 🖥️ R2 — AS 201

## Default Route

```bash id="d2x4kq"
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.2
```

O R2 possui como próximo salto:

```text
0.0.0.0/0
    ↓
192.168.122.2
```

---

## Configurando a sessão BGP

```bash id="k0p3aa"
/routing bgp connection add \
    name=bgp1 \
    disabled=no \
    remote.address=100.100.100.1 \
    remote.as=200 \
    templates=default \
    input.filter=bgp1-in \
    output.filter-chain=bgp1-out \
    multihop=yes \
    vrf=main \
    local.role=ebgp
```

O R2 está no:

```text
AS = 201
```

e seu vizinho pertence ao:

```text
AS = 200
```

---

# 🔗 Por que utilizar `multihop=yes`?

Neste laboratório, a sessão BGP não utiliza diretamente os endereços do enlace entre os roteadores.

Em vez disso:

```text
R1 → 100.100.100.1
R2 → 110.110.110.1
```

são utilizadas as **loopbacks**.

Por isso, dependendo da topologia, o vizinho BGP pode estar a mais de um salto IP de distância.

```text
R1
│
│ 192.168.122.0/24
│
R2
```

Mesmo que fisicamente exista apenas um enlace entre R1 e R2, o endereço usado como `remote.address` pode exigir um caminho roteado até a loopback.

O:

```text
multihop=yes
```

permite que a sessão eBGP utilize múltiplos saltos IP em vez de exigir que o vizinho esteja diretamente conectado no endereço configurado para a sessão.

---

# 🔄 Relação entre R1 e R2

A configuração dos dois lados deve corresponder:

| R1                        | R2                        |
| ------------------------- | ------------------------- |
| AS `200`                  | AS `201`                  |
| Remote AS `201`           | Remote AS `200`           |
| Remote IP `110.110.110.1` | Remote IP `100.100.100.1` |
| `local.role=ebgp`         | `local.role=ebgp`         |
| `multihop=yes`            | `multihop=yes`            |

Visualmente:

```text
                 eBGP
        ┌────────────────────┐
        │                    │
        ▼                    ▼
   ┌─────────┐          ┌─────────┐
   │   R1    │          │   R2    │
   │ AS 200  │◄────────►│ AS 201  │
   │         │          │         │
   │100.100. │          │110.110. │
   │100.1    │          │110.1    │
   └─────────┘          └─────────┘
```

---

# 🧠 IGP x EGP

É importante diferenciar os dois conceitos.

## IGP

Utilizado **dentro de um AS**:

```text
                 AS 200
        ┌────────────────────┐
        │                    │
        │ R1 ── OSPF ── R2   │
        │                    │
        └────────────────────┘
```

Exemplos:

* OSPF
* RIP
* EIGRP
* IS-IS

---

## EGP

Utilizado para comunicação de roteamento **entre AS**.

```text
AS 200                         AS 201
┌──────────┐                  ┌──────────┐
│          │                  │          │
│    R1 ───┼────── BGP ──────┼─── R2    │
│          │                  │          │
└──────────┘                  └──────────┘
```

Neste laboratório:

```text
IGP → OSPF
EGP → BGP/eBGP
```

---

# 🔐 Filtros BGP

A sessão utiliza filtros de entrada e saída:

```text
input.filter=bgp1-in
output.filter-chain=bgp1-out
```

O fluxo pode ser representado assim:

```text
             Rotas recebidas
                    │
                    ▼
              bgp1-in
                    │
                    ▼
                   R1
                    │
                 eBGP
                    │
                    ▼
              bgp1-out
                    │
                    ▼
             Rotas anunciadas
```

Os filtros permitem controlar quais prefixos podem entrar ou sair da sessão BGP.

> ⚠️ Os filtros `bgp1-in` e `bgp1-out` precisam existir e conter regras válidas. Apenas referenciá-los na conexão não cria as políticas de filtragem.

---

# 🔎 Verificando o BGP

Podemos verificar as conexões:

```bash id="j5p8vf"
/routing bgp connection print
```

Com detalhes:

```bash id="q6t1ad"
/routing bgp connection print detail
```

Verificar as rotas BGP:

```bash id="e4z7kp"
/ip route print where protocol=bgp
```

E verificar a tabela geral:

```bash id="m8s2cx"
/ip route print
```

---

# 🔄 Fluxo completo

```text
R1
AS 200
 │
 │ 1. Alcança a loopback do R2
 ▼
110.110.110.1
 │
 │ 2. Estabelece sessão TCP
 ▼
TCP/179
 │
 │ 3. Negociação BGP
 ▼
eBGP
 │
 │ 4. Troca de rotas
 ▼
AS 201
 │
 ▼
R2
```

---

# 🧠 Para memorizar

```text
IGP
└── roteamento dentro do AS

EGP
└── roteamento entre AS

BGP
└── principal protocolo utilizado para roteamento entre AS

eBGP
└── BGP entre AS diferentes

iBGP
└── BGP dentro do mesmo AS

remote.address
└── endereço do vizinho

remote.as
└── AS do vizinho

local.role=ebgp
└── define a sessão como eBGP

multihop=yes
└── permite sessão BGP utilizando múltiplos saltos IP

TCP/179
└── transporte utilizado pelo BGP
```

---

# 📋 Configuração final

## R1 — AS 200

```bash id="u7r4za"
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1

/routing bgp connection add \
    name=bgp1 \
    disabled=no \
    remote.address=110.110.110.1 \
    remote.as=201 \
    templates=default \
    input.filter=bgp1-in \
    output.filter-chain=bgp1-out \
    multihop=yes \
    vrf=main \
    local.role=ebgp
```

## R2 — AS 201

```bash id="w3c9ke"
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.2

/routing bgp connection add \
    name=bgp1 \
    disabled=no \
    remote.address=100.100.100.1 \
    remote.as=200 \
    templates=default \
    input.filter=bgp1-in \
    output.filter-chain=bgp1-out \
    multihop=yes \
    vrf=main \
    local.role=ebgp
```

> **Ponto fundamental:** antes de esperar que a sessão BGP fique estabelecida, as loopbacks `100.100.100.1` e `110.110.110.1` precisam ser **roteáveis entre si**. O `multihop=yes` não cria essa conectividade; ele apenas permite que a sessão BGP utilize múltiplos saltos.
