# 🌐 Configurações iniciais do BGP no MikroTik

O **BGP (Border Gateway Protocol)** é um protocolo de roteamento utilizado principalmente para trocar informações de rotas entre diferentes **Sistemas Autônomos (AS)**.

Nesta configuração, teremos uma sessão **eBGP (External BGP)** entre dois MikroTik:

```text
┌─────────────────────┐                  ┌─────────────────────┐
│        MK1          │                  │        MK3          │
│                     │                  │                     │
│       AS 200        │                  │       AS 201        │
│                     │                  │                     │
│ 192.168.122.2       │◄────── BGP ─────►│ 192.168.122.4       │
│                     │                  │                     │
└─────────────────────┘                  └─────────────────────┘
```

---

## 🔹 MK1 — AS 200

Primeiro configuramos o **template BGP**:

```bash
/routing bgp template set 0 as=200 router-id=192.168.122.2
```

### Parâmetros

| Parâmetro                 | Função                                            |
| ------------------------- | ------------------------------------------------- |
| `as=200`                  | Define o **AS local** do MK1                      |
| `router-id=192.168.122.2` | Define o identificador BGP do roteador            |
| `0`                       | Identifica o template existente que será alterado |

---

### Criando a conexão BGP

```bash
/routing bgp connection add \
    name=bgp1-as201 \
    templates=default \
    remote.address=192.168.122.4 \
    remote.as=201 \
    local.role=ebgp \
    input.filter=as201-in \
    output.filter-chain=as201-out
```

Essa configuração cria uma sessão BGP com o **MK3**, que pertence ao **AS 201**.

### Principais parâmetros

| Parâmetro                       | Função                              |
| ------------------------------- | ----------------------------------- |
| `name=bgp1-as201`               | Nome da sessão                      |
| `templates=default`             | Utiliza o template BGP `default`    |
| `remote.address=192.168.122.4`  | Endereço IP do vizinho              |
| `remote.as=201`                 | AS remoto                           |
| `local.role=ebgp`               | Define a sessão como eBGP           |
| `input.filter=as201-in`         | Filtro aplicado às rotas recebidas  |
| `output.filter-chain=as201-out` | Filtro aplicado às rotas anunciadas |

---

# 🔹 MK3 — AS 201

No MK3 configuramos o AS e o Router ID:

```bash
/routing bgp template set 0 as=201 router-id=192.168.122.4
```

Nesse caso:

```text
AS local  = 201
Router ID = 192.168.122.4
```

---

### Criando a conexão com o MK1

```bash
/routing bgp connection add \
    name=bgp1-as200 \
    templates=default \
    remote.address=192.168.122.2 \
    remote.as=200 \
    local.role=ebgp \
    input.filter=as200-in \
    output.filter-chain=as200-out
```

Agora o MK3 estabelece uma sessão eBGP com o **AS 200**.

```text
MK1                                      MK3
AS 200                                   AS 201
192.168.122.2                            192.168.122.4
     │                                        │
     └────────────── eBGP ───────────────────┘
```

---

# 🔄 Relação entre as configurações

As configurações dos dois lados precisam ser compatíveis:

| MK1                       | MK3                       |
| ------------------------- | ------------------------- |
| AS `200`                  | AS `201`                  |
| Router ID `192.168.122.2` | Router ID `192.168.122.4` |
| Remote IP `192.168.122.4` | Remote IP `192.168.122.2` |
| Remote AS `201`           | Remote AS `200`           |
| `local.role=ebgp`         | `local.role=ebgp`         |

Observe a relação:

```text
MK1                                  MK3
AS 200                              AS 201
   │                                  │
   │  remote.as=201    remote.as=200 │
   │                                  │
   └──────────── eBGP ────────────────┘
```

---

# 🔐 Filtros BGP

Na configuração foram definidos filtros:

### MK1

```text
input.filter=as201-in
output.filter-chain=as201-out
```

### MK3

```text
input.filter=as200-in
output.filter-chain=as200-out
```

Eles permitem controlar **quais rotas podem ser recebidas ou anunciadas**.

```text
                  MK1
             ┌───────────┐
             │   AS 200  │
             └─────┬─────┘
                   │
             output.filter
                   │
                   ▼
                eBGP
                   │
                   ▼
             input.filter
             ┌─────┴─────┐
             │   AS 201  │
             └───────────┘
                  MK3
```

> ⚠️ Os filtros precisam existir e estar configurados corretamente. Apenas referenciar `as201-in`, `as201-out`, `as200-in` e `as200-out` não cria as regras de filtragem.

---

# 🧠 Conceitos importantes

### AS

Um **Sistema Autônomo (AS)** é uma rede ou conjunto de redes administradas por uma mesma entidade e identificadas por um número de AS.

```text
MK1 → AS 200
MK3 → AS 201
```

Como os AS são diferentes, a sessão é **eBGP**.

---

### eBGP

**eBGP (External BGP)** é utilizado para estabelecer sessões BGP entre roteadores pertencentes a **AS diferentes**.

```text
AS 200 ───────── eBGP ───────── AS 201
```

Já o **iBGP** é utilizado entre roteadores pertencentes ao mesmo AS:

```text
AS 200

MK1 ───────── iBGP ───────── MK2
```

---

### Router ID

O `router-id` identifica o roteador dentro do processo BGP.

Neste exemplo:

```text
MK1 → 192.168.122.2
MK3 → 192.168.122.4
```

O Router ID deve ser **único dentro do domínio BGP relevante**.

---

# 🔎 Verificando a sessão

Depois da configuração, podemos verificar o estado da sessão BGP:

```bash
/routing bgp connection print
```

Para visualizar informações mais detalhadas:

```bash
/routing bgp connection print detail
```

Também é importante verificar as rotas BGP:

```bash
/ip route print where protocol=bgp
```

E, dependendo da versão do RouterOS 7, consultar as rotas recebidas/anunciadas pela sessão através dos menus de BGP disponíveis em:

```bash
/routing bgp
```

---

# 📌 Fluxo da configuração

```text
1. Definir AS local
        ↓
2. Definir Router ID
        ↓
3. Criar conexão BGP
        ↓
4. Informar IP do vizinho
        ↓
5. Informar AS remoto
        ↓
6. Definir eBGP
        ↓
7. Aplicar filtros de entrada/saída
        ↓
8. Estabelecer sessão TCP/179
        ↓
9. Trocar informações de roteamento
```

---

# 🧠 Para memorizar

```text
AS             → identifica o Sistema Autônomo
router-id      → identifica o roteador no BGP
remote.address → IP do vizinho
remote.as      → AS do vizinho
ebgp           → BGP entre AS diferentes
input.filter   → controla rotas recebidas
output.filter  → controla rotas anunciadas
```

### Neste laboratório

```text
MK1
AS: 200
IP: 192.168.122.2
       │
       │ eBGP
       │
       ▼
MK3
AS: 201
IP: 192.168.122.4
```

**Objetivo:** estabelecer uma sessão eBGP entre o **AS 200** e o **AS 201**, preparando o ambiente para posteriormente realizar a troca e o controle de rotas.
