# 🌐 Enviando rotas com o protocolo BGP

O **BGP** pode anunciar para seus vizinhos rotas que estão presentes na tabela de roteamento.

Neste exemplo, vamos utilizar:

```text
output.redistribute=connected
```

para permitir que a conexão BGP anuncie **redes diretamente conectadas**.

---

# 🖥️ R1

```bash id="qv5n2m"
/routing bgp connection set numbers=0 output.redistribute=connected
```

Com essa configuração, a conexão BGP de número `0` passa a redistribuir rotas do tipo **connected** para o vizinho BGP, respeitando também as políticas de saída configuradas.

Por exemplo, se o R1 possui:

```text id="x8q2hm"
100.100.100.1/32
192.168.122.2/24
100.0.0.1/24
10.1.0.1/24
```

essas redes podem ser candidatas à redistribuição pelo BGP por serem diretamente conectadas.

---

# 🖥️ R2

No R2 fazemos a mesma configuração:

```bash id="z6k4pv"
/routing bgp connection set numbers=0 output.redistribute=connected
```

Assim, o R2 também passa a poder anunciar suas redes diretamente conectadas através da sessão BGP.

Por exemplo:

```text id="h8w4fd"
110.110.110.1/32
192.168.122.5/24
10.2.0.1/24
```

---

# 🔄 Fluxo do anúncio

Podemos representar o funcionamento da seguinte forma:

```text id="0qf6a8"
                  eBGP
        ┌──────────────────────┐
        │                      │
        ▼                      ▼
   ┌─────────┐            ┌─────────┐
   │   R1    │            │   R2    │
   │ AS 200  │            │ AS 201  │
   └────┬────┘            └────┬────┘
        │                      │
        │ Connected            │ Connected
        │ routes               │ routes
        │                      │
        └──────────┬───────────┘
                   │
             Troca de rotas
```

Por exemplo:

```text id="4y1v9j"
R1 → anuncia → 10.1.0.0/24
                 ↓
                R2

R2 → anuncia → 10.2.0.0/24
                 ↓
                R1
```

Dessa maneira, cada AS pode aprender através do BGP redes que originalmente estavam conectadas ao outro roteador.

---

# 📌 O que significa `redistribute=connected`?

A estrutura:

```text id="v2uj3x"
output.redistribute=connected
```

pode ser entendida como:

```text
rotas connected
      ↓
processo BGP
      ↓
política de saída
      ↓
vizinho BGP
```

**Connected** representa rotas referentes a redes diretamente conectadas às interfaces do roteador.

---

# ⚠️ Cuidado com `redistribute=connected`

Esse comando pode ser bastante amplo.

Se o roteador possuir várias interfaces:

```text
LAN
WAN
Loopback
Gerenciamento
VPN
Laboratório
```

todas as rotas `connected` elegíveis podem se tornar candidatas à redistribuição.

Por isso, em ambientes reais, é comum controlar os anúncios usando:

* filtros de saída;
* listas de prefixos;
* `network`/originação específica, conforme a plataforma;
* políticas de roteamento.

No seu laboratório, porém, `redistribute=connected` é uma maneira prática de demonstrar o conceito.

---

# 🔐 Relação com os filtros BGP

Anteriormente configuramos:

```text id="8t4m2z"
input.filter=bgp1-in
output.filter-chain=bgp1-out
```

Portanto, o fluxo completo pode ser representado como:

```text id="m2h7k1"
                  R1
                   │
                   │
          Rotas connected
                   │
                   ▼
        output.redistribute
                   │
                   ▼
            bgp1-out
                   │
                   ▼
                 eBGP
                   │
                   ▼
              bgp1-in
                   │
                   ▼
                  R2
```

Isso é importante:

> `output.redistribute=connected` torna as rotas connected candidatas ao anúncio BGP, enquanto o filtro de saída pode determinar quais delas efetivamente serão anunciadas.

---

# 🔎 Verificando as rotas

Para verificar as rotas diretamente conectadas:

```bash id="r8k2vc"
/ip route print where protocol=connected
```

Para verificar as rotas aprendidas via BGP:

```bash id="9n4x7s"
/ip route print where protocol=bgp
```

E para verificar a sessão:

```bash id="x2v7ma"
/routing bgp connection print
```

---

# 🧠 Para memorizar

```text id="k2v8s1"
connected
    ↓
Rotas diretamente conectadas

redistribute=connected
    ↓
Torna essas rotas candidatas à redistribuição pelo BGP

output
    ↓
Rotas que saem pelo vizinho BGP

input
    ↓
Rotas recebidas do vizinho BGP
```

### Configuração

## R1

```bash id="m9c5va"
/routing bgp connection set numbers=0 output.redistribute=connected
```

## R2

```bash id="w5k1pz"
/routing bgp connection set numbers=0 output.redistribute=connected
```

### Resumo visual

```text id="r1k7mx"
R1 — AS 200
│
├── Connected Routes
│
└──► BGP ─────────────► R2 — AS 201
                              │
                              └──► aprende rotas do R1


R2 — AS 201
│
├── Connected Routes
│
└──► BGP ─────────────► R1 — AS 200
                              │
                              └──► aprende rotas do R2
```
