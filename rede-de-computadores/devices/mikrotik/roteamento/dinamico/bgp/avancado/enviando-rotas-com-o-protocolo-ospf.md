# 🌐 Enviando rotas entre OSPF e BGP

Nesta etapa vamos trabalhar com **redistribuição de rotas entre protocolos de roteamento**.

O objetivo é permitir que:

```text
OSPF ───────► BGP
  ▲             │
  │             ▼
  └─────────────┘
```

Ou seja:

* o **BGP** pode anunciar rotas aprendidas pelo **OSPF**;
* o **OSPF** pode redistribuir rotas aprendidas pelo **BGP**.

Isso permite a comunicação entre diferentes domínios de roteamento.

---

# 🖥️ R1

## Redistribuindo rotas Connected no BGP

```bash
/routing bgp connection set numbers=0 output.redistribute=connected
```

Essa configuração permite que o BGP anuncie rotas diretamente conectadas que sejam elegíveis para redistribuição.

---

## Redistribuindo rotas OSPF no BGP

```bash
/routing bgp connection set numbers=0 output.redistribute=ospf
```

Agora o BGP também pode anunciar rotas aprendidas através do **OSPF**.

O fluxo fica:

```text
Rota OSPF
    ↓
Tabela de roteamento
    ↓
BGP
    ↓
eBGP
    ↓
Outro AS
```

---

## Redistribuindo BGP no OSPF

```bash
/routing ospf instance set numbers=0 redistribute=bgp
```

Agora o processo OSPF pode redistribuir rotas aprendidas pelo BGP.

O fluxo inverso:

```text
Rota BGP
    ↓
Tabela de roteamento
    ↓
OSPF
    ↓
Outros roteadores OSPF
```

---

# 🖥️ R2

No R2 fazemos a mesma configuração.

### Connected → BGP

```bash
/routing bgp connection set numbers=0 output.redistribute=connected
```

### OSPF → BGP

```bash
/routing bgp connection set numbers=0 output.redistribute=ospf
```

### BGP → OSPF

```bash
/routing ospf instance set numbers=0 redistribute=bgp
```

---

# 🔄 Fluxo completo

Considerando R1 e R2 conectados através de BGP:

```text
                  eBGP
        ┌─────────────────────┐
        │                     │
        ▼                     ▼
   ┌─────────┐           ┌─────────┐
   │   R1    │           │   R2    │
   │ AS 200  │           │ AS 201  │
   └────┬────┘           └────┬────┘
        │                     │
       OSPF                  OSPF
        │                     │
        ▼                     ▼
   Redes internas        Redes internas
```

Podemos ter, por exemplo:

```text
R1
├── 10.1.0.0/24    ← Connected
├── 10.10.0.0/24   ← OSPF
└── BGP

R2
├── 10.2.0.0/24    ← Connected
├── 10.20.0.0/24   ← OSPF
└── BGP
```

O R1 pode anunciar pelo BGP uma rede que aprendeu através do OSPF:

```text
10.10.0.0/24
     ↓
   OSPF
     ↓
    R1
     ↓
    BGP
     ↓
    R2
```

E o R2 pode fazer o processo inverso:

```text
10.20.0.0/24
     ↓
   OSPF
     ↓
    R2
     ↓
    BGP
     ↓
    R1
```

---

# ⚠️ Cuidado com redistribuição bidirecional

Redistribuir rotas nos dois sentidos pode causar problemas se não houver políticas adequadas.

Temos:

```text
OSPF ──► BGP
 ▲         │
 │         ▼
 └─────────┘
```

Se uma rota sair do OSPF, entrar no BGP e depois voltar para o OSPF, podemos criar situações de:

* loops de roteamento;
* rotas duplicadas;
* seleção de caminhos inesperados;
* dificuldade de troubleshooting;
* propagação excessiva de prefixos.

Por isso, em ambientes reais, a redistribuição deve ser acompanhada de **filtros e políticas de roteamento**.

---

# 🔐 Utilizando filtros

No BGP já temos:

```text
input.filter=bgp1-in
output.filter-chain=bgp1-out
```

Esses filtros podem controlar quais rotas serão aceitas ou anunciadas.

O conceito pode ser representado assim:

```text
              OSPF
                │
                ▼
        Rotas aprendidas
                │
                ▼
        Redistribuição
                │
                ▼
              BGP
                │
                ▼
          Filtro de saída
                │
                ▼
              eBGP
```

No sentido contrário:

```text
              eBGP
                │
                ▼
          Filtro de entrada
                │
                ▼
              BGP
                │
                ▼
        Redistribuição
                │
                ▼
              OSPF
```

---

# 📌 Os quatro fluxos

Nesta configuração estamos trabalhando com quatro possibilidades:

| Origem    | Destino   | Configuração                    |
| --------- | --------- | ------------------------------- |
| Connected | BGP       | `output.redistribute=connected` |
| OSPF      | BGP       | `output.redistribute=ospf`      |
| BGP       | OSPF      | `redistribute=bgp`              |
| BGP       | Outros AS | eBGP                            |

Visualmente:

```text
                 ┌──────────────┐
                 │    Connected │
                 └──────┬───────┘
                        │
                        ▼
                     ┌─────┐
                     │ BGP │
                     └──┬──┘
                        │
             eBGP ──────┤
                        │
                        ▼
                     ┌─────┐
                     │OSPF │
                     └─────┘
```

---

# 🔎 Verificando as rotas

Para verificar rotas OSPF:

```bash
/routing ospf route print
```

Rotas BGP:

```bash
/ip route print where protocol=bgp
```

Rotas conectadas:

```bash
/ip route print where protocol=connected
```

Tabela geral:

```bash
/ip route print
```

Sessões BGP:

```bash
/routing bgp connection print
```

Vizinhos OSPF:

```bash
/routing ospf neighbor print
```

---

# 🧠 Para memorizar

```text
OSPF → BGP
output.redistribute=ospf
```

```text
BGP → OSPF
redistribute=bgp
```

```text
Connected → BGP
output.redistribute=connected
```

### Conceito principal

```text
IGP
 │
 │ redistribuição
 ▼
BGP
 │
 │ eBGP
 ▼
Outro AS
```

E no sentido contrário:

```text
Outro AS
   │
  BGP
   │
   ▼
Redistribuição
   │
  OSPF
   │
   ▼
Rede interna
```

> **Importante:** redistribuir uma rota não significa simplesmente "copiar a rota" de um protocolo para outro. Cada protocolo possui suas próprias métricas, atributos e regras de seleção. Por isso, redistribuição deve ser feita com políticas cuidadosamente definidas.

---

# 📋 Configuração completa

## R1

```bash
/routing bgp connection set numbers=0 output.redistribute=connected
/routing bgp connection set numbers=0 output.redistribute=ospf

/routing ospf instance set numbers=0 redistribute=bgp
```

## R2

```bash
/routing bgp connection set numbers=0 output.redistribute=connected
/routing bgp connection set numbers=0 output.redistribute=ospf

/routing ospf instance set numbers=0 redistribute=bgp
```
