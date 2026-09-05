# Aplicando os Filtros no OSPF

Depois de configurar o OSPF, podemos utilizar os **Routing Filters** do MikroTik para controlar quais rotas serão aceitas ou anunciadas pelo protocolo.

Neste exemplo, será criada uma cadeia chamada:

```text
ospf
```

A regra permitirá rotas cujo destino esteja dentro de:

```text
192.168.0.0/16
```

---

# Estrutura do filtro

A regra utilizada é:

```bash
if (dst == 192.168.0.0/16) { accept }
```

Ela pode ser interpretada como:

```text
Se o destino da rota for 192.168.0.0/16
        ↓
     ACCEPT
```

> `dst` representa o **prefixo de destino da rota**.

---

# R1

Criar a cadeia e adicionar a regra:

```bash
/routing/filter/rule
add chain=ospf rule=accept

set ospf rule="if (dst == 192.168.0.0/16) { accept }"
```

Aplicar a cadeia ao OSPF:

```bash
/routing/ospf/instance
set instance-0 \
    in-filter-chain=ospf \
    out-filter-chain=ospf
```

---

# R2

```bash
/routing/filter/rule
add chain=ospf rule=accept

set ospf rule="if (dst == 192.168.0.0/16) { accept }"

/routing/ospf/instance
set instance-0 \
    in-filter-chain=ospf \
    out-filter-chain=ospf
```

---

# R3

```bash
/routing/filter/rule
add chain=ospf rule=accept

set ospf rule="if (dst == 192.168.0.0/16) { accept }"

/routing/ospf/instance
set instance-0 \
    in-filter-chain=ospf \
    out-filter-chain=ospf
```

---

# R4

```bash
/routing/filter/rule
add chain=ospf rule=accept

set ospf rule="if (dst == 192.168.0.0/16) { accept }"

/routing/ospf/instance
set instance-0 \
    in-filter-chain=ospf \
    out-filter-chain=ospf
```

---

# Como o filtro funciona

Cada roteador possui:

```text
             OSPF
               │
       ┌───────┴────────┐
       │                │
       ↓                ↓
   IN FILTER         OUT FILTER
       │                │
       ↓                ↓
Rotas recebidas    Rotas anunciadas
```

Neste laboratório, a mesma cadeia foi configurada nos dois sentidos:

```text
in-filter-chain=ospf
out-filter-chain=ospf
```

Portanto:

```text
Entrada
   ↓
chain=ospf
   ↓
dst == 192.168.0.0/16
   ↓
ACCEPT
```

e:

```text
Saída
   ↓
chain=ospf
   ↓
dst == 192.168.0.0/16
   ↓
ACCEPT
```

---

# ⚠️ Atenção ao `ACCEPT`

Um ponto importante é que:

```bash
if (dst == 192.168.0.0/16) { accept }
```

não significa simplesmente:

> "Aceite qualquer rota que esteja dentro do `/16`."

O operador:

```text
==
```

faz uma **comparação exata do prefixo**.

Ou seja:

```text
192.168.0.0/16    → corresponde
192.168.100.0/24  → não é igual
192.168.100.251/32 → não é igual
```

Se a intenção for verificar se um prefixo está **contido dentro de `192.168.0.0/16`**, deve-se utilizar uma condição apropriada de pertencimento/supernet conforme a sintaxe de filtros da versão do RouterOS.

---

# `in-filter-chain`

```text
in-filter-chain
```

É utilizado para aplicar uma cadeia de filtros às **rotas recebidas** pelo processo de roteamento.

Conceitualmente:

```text
Vizinho OSPF
     │
     ↓
   Rotas
     │
     ↓
IN FILTER
     │
     ├── ACCEPT → continua
     │
     └── REJECT → descarta
```

---

# `out-filter-chain`

```text
out-filter-chain
```

É utilizado para aplicar uma cadeia de filtros às **rotas que serão anunciadas**.

Conceitualmente:

```text
Tabela de rotas
      │
      ↓
 OUT FILTER
      │
      ├── ACCEPT → anuncia
      │
      └── REJECT → não anuncia
```

---

# ⚠️ Filtro somente com `accept`

O exemplo possui apenas uma condição de `accept`:

```bash
if (dst == 192.168.0.0/16) { accept }
```

Para construir políticas de filtragem mais restritivas, normalmente é necessário definir explicitamente o comportamento das rotas que não correspondem à condição.

Por exemplo, conceitualmente:

```text
192.168.0.0/16 → ACCEPT
demais rotas    → REJECT
```

Isso é importante porque uma cadeia de filtros pode ter várias regras e um comportamento final que determina o que acontece quando nenhuma regra anterior corresponde.

---

# Exemplo de política

Imagine que R1 possua:

```text
192.168.0.0/16
10.10.10.0/24
172.16.0.0/16
```

Uma política poderia ser:

```text
              R1
               │
          Routing Filter
               │
       ┌───────┼────────┐
       ↓       ↓        ↓
192.168/16  10.10/24  172.16/16
   │          │          │
 ACCEPT      REJECT     REJECT
```

Assim, somente a rota desejada seria permitida.

---

# Verificação

Depois de aplicar os filtros, podemos verificar a configuração do OSPF:

```bash
/routing/ospf/instance/print detail
```

Ver as regras:

```bash
/routing/filter/rule/print
```

Ver as rotas:

```bash
/ip/route/print
```

E verificar as vizinhanças:

```bash
/routing/ospf/neighbor/print
```

---

# 🧠 Para memorizar

```text
in-filter-chain
       ↓
     ENTRA
       ↓
"Essa rota recebida pode passar?"

out-filter-chain
       ↓
      SAI
       ↓
"Essa rota pode ser anunciada?"
```

E:

```text
dst
 ↓
Prefixo de destino

accept
 ↓
Permite

reject
 ↓
Bloqueia
```

### Fluxo geral

```text
                 OSPF
                  │
          ┌───────┴────────┐
          ↓                ↓
      IN FILTER         OUT FILTER
          │                │
          ↓                ↓
       ACCEPT?          ACCEPT?
          │                │
          ↓                ↓
     Rota entra       Rota é anunciada
     no processo       para vizinhos
```

> **Resumo:** Routing Filters permitem implementar políticas de controle sobre rotas no MikroTik. No OSPF, `in-filter-chain` e `out-filter-chain` permitem aplicar essas políticas respectivamente às rotas recebidas e às rotas anunciadas.
