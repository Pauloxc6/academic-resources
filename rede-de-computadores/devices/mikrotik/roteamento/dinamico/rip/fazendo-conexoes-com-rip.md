# Fazendo Conexões com RIP

O **RIP (Routing Information Protocol)** é um protocolo de roteamento dinâmico do tipo **IGP**, utilizado para trocar informações de rotas entre roteadores dentro de um mesmo domínio de roteamento.

Nesta etapa vamos configurar o RIP em dois MikroTik:

```text
MK1 ───────── MK2
       RIP
```

---

# MK1

## Criando a instância RIP

```bash id="p7x3kd"
/routing rip instance
add disabled=no \
    name=rip-instance-1 \
    vrf=main
```

A instância:

```text id="1hy5r6"
rip-instance-1
```

representa o processo RIP que será utilizado pelo roteador.

O parâmetro:

```text id="d8g2jq"
vrf=main
```

indica que o RIP está associado à **VRF `main`**, ou seja, à tabela/instância de roteamento principal.

---

## Configurando o Interface Template

```bash id="8xq2mv"
/routing rip interface-template
add disabled=no \
    instance=rip-instance-1 \
    interfaces=all
```

Esse template associa as interfaces correspondentes à instância RIP.

Como foi utilizado:

```text id="8t5jqp"
interfaces=all
```

o template poderá abranger todas as interfaces elegíveis do roteador.

---

# MK2

## Criando a instância RIP

```bash id="z4c8nw"
/routing rip instance
add disabled=no \
    name=rip-instance-1 \
    vrf=main
```

## Configurando o Interface Template

```bash id="f3v9ka"
/routing rip interface-template
add disabled=no \
    instance=rip-instance-1 \
    interfaces=all
```

Assim como no MK1, o RIP ficará habilitado e associado à VRF `main`.

---

# Estrutura da configuração

Em ambos os roteadores temos:

```text id="x4q7va"
                 RIP
                  │
                  ↓
          rip-instance-1
                  │
                  ↓
          interface-template
                  │
                  ↓
            interfaces=all
```

O fluxo pode ser representado como:

```text id="z7v3hy"
MK1
 │
 │ RIP
 │
 ▼
MK2
```

O RIP utiliza as interfaces participantes para trocar informações de roteamento com os vizinhos.

---

# O que é RIP?

O RIP é um protocolo de roteamento baseado em **vetor de distância (Distance Vector)**.

Seu principal critério de seleção de rotas é a quantidade de **saltos (hops)**.

Por exemplo:

```text id="m2x8zq"
MK1 ─── R2 ─── R3 ─── MK2
```

A rota até MK2 teria:

```text id="q7c5kw"
3 saltos
```

Cada roteador representa um salto no caminho.

---

# Métrica

A métrica utilizada pelo RIP é:

```text id="v6x1sn"
Número de saltos
```

Existe um limite importante:

```text id="d9h3pz"
1 → destino diretamente conectado
2 → um roteador intermediário
...
15 → máximo utilizável
16 → infinito / destino inalcançável
```

Portanto:

```text
1–15 → alcançável
16   → inalcançável
```

Isso limita o uso do RIP em redes grandes.

---

# Versões do RIP

Existem principalmente:

```text id="1s5v0h"
RIPv1
RIPv2
RIPng
```

### RIPv1

É a versão mais antiga e possui limitações, como:

* classful;
* não transporta máscara de sub-rede nas atualizações;
* utiliza broadcast.

### RIPv2

Introduziu suporte a:

* CIDR;
* VLSM;
* autenticação;
* informações de máscara nas atualizações.

### RIPng

É utilizado para:

```text
IPv6
```

Enquanto:

```text
RIPv1 / RIPv2 → IPv4
RIPng         → IPv6
```

---

# RIP × OSPF

É importante diferenciar os dois protocolos:

| Característica   | RIP                            | OSPF                   |
| ---------------- | ------------------------------ | ---------------------- |
| Tipo             | Distance Vector                | Link State             |
| Métrica          | Hops                           | Custo                  |
| Máximo de saltos | 15                             | Não possui esse limite |
| Convergência     | Mais lenta                     | Mais rápida            |
| Escalabilidade   | Baixa                          | Alta                   |
| Algoritmo        | Bellman-Ford / Distance Vector | SPF (Dijkstra)         |
| Uso comum        | Redes pequenas/laboratórios    | Redes médias/grandes   |

---

# ⚠️ `interfaces=all`

Neste laboratório foi utilizado:

```bash id="7y4m2c"
interfaces=all
```

Isso é conveniente para testes, mas **não é necessariamente a melhor prática em produção**.

Imagine que o roteador possua:

```text
ether1 → WAN
ether2 → LAN
ether3 → gerenciamento
```

Com:

```text
interfaces=all
```

você pode acabar habilitando o RIP em interfaces que não deveriam participar do protocolo.

Uma abordagem mais controlada é especificar somente a interface desejada.

Por exemplo:

```bash id="n8s3kw"
/routing rip interface-template
add instance=rip-instance-1 interfaces=ether2
```

Assim, o RIP ficará restrito à interface especificada.

---

# Como o RIP aprende as rotas?

Imagine:

```text id="f6w4j1"
        192.168.10.0/24
              │
             MK1
              │
              │ RIP
              │
             MK2
              │
        192.168.20.0/24
```

MK1 anuncia:

```text
192.168.10.0/24
```

MK2 aprende essa rede.

MK2 anuncia:

```text
192.168.20.0/24
```

MK1 aprende essa rede.

Resultado:

```text id="x8p2dc"
MK1
 │
 ├── 192.168.10.0/24 → diretamente conectado
 └── 192.168.20.0/24 → aprendida via RIP

MK2
 │
 ├── 192.168.20.0/24 → diretamente conectado
 └── 192.168.10.0/24 → aprendida via RIP
```

---

# Verificação

Depois de configurar o RIP, podemos verificar a instância:

```bash id="s5n8vy"
/routing rip instance print
```

Ver os templates:

```bash id="r7x3mf"
/routing rip interface-template print
```

Ver as rotas aprendidas:

```bash id="m4q9tz"
/ip route print
```

Também podemos filtrar as rotas relacionadas ao RIP:

```bash id="a2v6kp"
/ip route print where protocol=rip
```

---

# 🧠 Para memorizar

```text id="7v3m9k"
RIP
 │
 ├── IGP
 ├── Distance Vector
 ├── Métrica = hops
 ├── 15 hops = máximo
 └── 16 = inalcançável
```

Configuração:

```text id="c8x4wn"
RIP Instance
      ↓
Interface Template
      ↓
Interfaces
      ↓
Vizinhos
      ↓
Troca de rotas
      ↓
Tabela de roteamento
```

> **Resumo:** a configuração cria uma instância RIP em cada MikroTik e associa as interfaces à instância por meio de um `interface-template`. A partir daí, o RIP pode ser utilizado para trocar informações de roteamento entre os roteadores. Para um ambiente real, é recomendável restringir o RIP às interfaces que realmente devem participar do protocolo, em vez de utilizar `interfaces=all`.
