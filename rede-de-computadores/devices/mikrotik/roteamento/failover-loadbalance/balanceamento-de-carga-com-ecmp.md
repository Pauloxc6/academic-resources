# Balanceamento de carga com ECMP

**ECMP (Equal-Cost Multi-Path)** permite utilizar múltiplos caminhos com o **mesmo custo administrativo** para alcançar um destino.

No MikroTik, podemos utilizar duas rotas padrão com a mesma `distance`:

```text
WAN 1 → 192.168.100.1
WAN 2 → 172.16.0.1
```

Como ambas possuem o mesmo custo, o RouterOS pode utilizar os dois caminhos.

---

# Topologia

```text
                    INTERNET
                 ┌──────┴──────┐
                 │             │
              WAN 1          WAN 2
           192.168.100.1    172.16.0.1
                 │             │
                 └──────┬──────┘
                        │
                   ┌────▼────┐
                   │ MikroTik│
                   └────┬────┘
                        │
                       LAN
```

---

# Rotas

Para utilizar ECMP, as rotas devem possuir o mesmo destino e o mesmo custo.

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.100.1 distance=1
add dst-address=0.0.0.0/0 gateway=172.16.0.1 distance=1
```

Observe:

```text
WAN 1 → distance=1
WAN 2 → distance=1
```

Diferente de:

```text
WAN 1 → distance=1
WAN 2 → distance=2
```

Nesse segundo caso, a WAN 2 normalmente funciona como **rota de backup**, e não como ECMP ativo.

---

# Como o ECMP funciona

```text
                    Rota padrão
                        │
                 ┌──────┴──────┐
                 │             │
             WAN 1           WAN 2
             custo 1         custo 1
                 │             │
                 └──────┬──────┘
                        │
                     Internet
```

O RouterOS pode distribuir diferentes fluxos entre os caminhos disponíveis.

Exemplo:

```text
Conexão 1 → WAN 1
Conexão 2 → WAN 2
Conexão 3 → WAN 1
Conexão 4 → WAN 2
```

> **Importante:** ECMP não significa que uma única conexão será dividida simultaneamente entre os dois links.

---

# Mark Connections

Em determinados cenários, podemos precisar identificar por qual WAN uma conexão entrou.

```bash
/ip firewall mangle
add action=mark-connection \
    chain=input \
    in-interface=ether1 \
    connection-mark=no-mark \
    new-connection-mark=Con-WAN1 \
    passthrough=yes

add action=mark-connection \
    chain=input \
    in-interface=ether2 \
    connection-mark=no-mark \
    new-connection-mark=Con-WAN2 \
    passthrough=yes
```

Considerando:

```text
ether1 → WAN 1
ether2 → WAN 2
```

Temos:

```text
WAN 1 → Con-WAN1
WAN 2 → Con-WAN2
```

Isso permite identificar a origem das conexões recebidas pelo roteador.

---

# Mark Routing

Se quisermos utilizar marcas de roteamento para garantir que determinadas conexões retornem pela mesma WAN, devemos utilizar `new-routing-mark`.

```bash
/ip firewall mangle
add chain=output \
    connection-mark=Con-WAN1 \
    action=mark-routing \
    new-routing-mark=to-WAN1 \
    passthrough=no

add chain=output \
    connection-mark=Con-WAN2 \
    action=mark-routing \
    new-routing-mark=to-WAN2 \
    passthrough=no
```

### Atenção

No exemplo original estava:

```text
new-connection-mark=to-WAN1
```

Isso está incorreto porque `mark-routing` deve utilizar:

```text
new-routing-mark=
```

e não:

```text
new-connection-mark=
```

---

# Routing Tables

No RouterOS 7, quando utilizamos marcas de roteamento, devemos criar as tabelas correspondentes.

```bash
/routing/table
add fib name=to-WAN1

add fib name=to-WAN2
```

Depois podemos criar as rotas:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=192.168.100.1 \
    routing-table=to-WAN1

add dst-address=0.0.0.0/0 \
    gateway=172.16.0.1 \
    routing-table=to-WAN2
```

---

# ECMP x PCC

Os dois mecanismos podem fazer balanceamento, mas funcionam de maneiras diferentes.

| Característica       | ECMP                                  | PCC                               |
| -------------------- | ------------------------------------- | --------------------------------- |
| Local principal      | Routing                               | Firewall Mangle                   |
| Classificação        | Roteamento                            | Conexões                          |
| Divisão              | Caminhos de mesmo custo               | Grupos definidos pelo PCC         |
| Links diferentes     | Não é ideal para proporção específica | Permite distribuição proporcional |
| Configuração         | Mais simples                          | Mais detalhada                    |
| Controle por conexão | Pelo mecanismo de ECMP                | Explícito                         |
| Uso de `mangle`      | Opcional                              | Normalmente necessário            |

### Exemplo

ECMP:

```text
WAN 1 ─┐
       ├──→ mesmo custo → distribuição ECMP
WAN 2 ─┘
```

PCC:

```text
                PCC
                 │
        ┌────────┴────────┐
        ↓                 ↓
     Grupo 0           Grupo 1
        │                 │
      WAN 1             WAN 2
```

---

# ECMP com links iguais

Exemplo:

```text
WAN 1 → 100 Mbps
WAN 2 → 100 Mbps
```

Rotas:

```bash
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.100.1 distance=1
add dst-address=0.0.0.0/0 gateway=172.16.0.1 distance=1
```

Resultado conceitual:

```text
              ECMP
                │
       ┌────────┴────────┐
       ↓                 ↓
     WAN 1             WAN 2
      50%                50%
```

> O balanceamento real não deve ser interpretado como uma divisão perfeitamente matemática de 50/50 em todos os momentos. A distribuição depende dos fluxos e do mecanismo de seleção utilizado pelo RouterOS.

---

# 🧠 Para memorizar

```text
ECMP
 │
 ├── múltiplas rotas
 │
 ├── mesmo destino
 │
 ├── mesmo custo
 │
 └── múltiplos caminhos ativos
```

### Regra principal

```text
distance=1
distance=1
   ↓
ECMP
```

Enquanto:

```text
distance=1
distance=2
   ↓
Principal + Backup
```

### PCC

```text
PCC → Mangle → Connection Mark → Routing Mark → Routing Table
```

### ECMP

```text
ECMP → Routing Table → múltiplos caminhos de mesmo custo
```
