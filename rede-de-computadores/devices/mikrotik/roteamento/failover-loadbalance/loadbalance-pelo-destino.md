# Load Balance pelo Destino

O **load balance pelo destino** consiste em direcionar determinados destinos ou tipos de tráfego para um link específico.

No MikroTik, isso pode ser feito utilizando:

* `address-list` para identificar destinos;
* `mangle` para marcar o roteamento;
* tabelas de roteamento específicas para cada link.

---

# 1. Marcando destinos específicos

Podemos criar uma lista de endereços:

```bash
/ip firewall address-list
add list=WAN-DST address=8.8.8.8
add list=WAN-DST address=1.1.1.1
```

Depois, podemos marcar o tráfego destinado a esses endereços:

```bash
/ip firewall mangle
add chain=prerouting \
    dst-address-list=WAN-DST \
    action=mark-routing \
    new-routing-mark=Rota-WAN2
```

Fluxo:

```text
Cliente
   │
   ↓
Destino pertence à WAN-DST?
   │
   ├── NÃO → roteamento normal
   │
   └── SIM
        ↓
    Rota-WAN2
        ↓
      WAN 2
```

---

# 2. Direcionando portas específicas

Também podemos selecionar tráfego com base na porta de destino.

Exemplo:

```bash
/ip firewall mangle
add chain=prerouting \
    protocol=tcp \
    dst-port=80,443 \
    action=mark-routing \
    new-routing-mark=WAN-2PORTAS
```

Nesse caso:

```text
TCP/80  → HTTP
TCP/443 → HTTPS
```

serão marcados para o roteamento associado a:

```text
WAN-2PORTAS
```

> Isso não significa necessariamente que todo acesso à Internet será balanceado. Significa que o tráfego que corresponde a esses critérios será **direcionado para uma rota/tabela específica**.

---

# 3. Rota para o tráfego marcado

No RouterOS 7, o ideal é utilizar uma **routing table**.

Criando a tabela:

```bash
/routing table
add fib name=Rota-WAN2
```

Depois:

```bash
/ip route
add \
    dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    distance=2 \
    routing-table=Rota-WAN2
```

Assim:

```text
Mangle
  │
  ↓
routing-mark=Rota-WAN2
  │
  ↓
Tabela Rota-WAN2
  │
  ↓
0.0.0.0/0
  │
  ↓
ether4-WAN2
```

---

# ⚠️ RouterOS 6 × RouterOS 7

Em configurações antigas é comum encontrar:

```bash
routing-mark=Rota-WAN2
```

diretamente na rota.

No **RouterOS 7**, o conceito foi reorganizado em torno das **routing tables**.

Por isso, atualmente é comum utilizar:

```bash
/routing table
add fib name=Rota-WAN2
```

e:

```bash
/ip route
add dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    routing-table=Rota-WAN2
```

O `new-routing-mark` do `mangle` deve corresponder ao nome da tabela de roteamento utilizada.

---

# Exemplo completo

```bash
# Criar tabela
/routing table
add fib name=Rota-WAN2

# Criar lista de destinos
/ip firewall address-list
add list=WAN-DST address=8.8.8.8
add list=WAN-DST address=1.1.1.1

# Marcar destinos
/ip firewall mangle
add chain=prerouting \
    dst-address-list=WAN-DST \
    action=mark-routing \
    new-routing-mark=Rota-WAN2

# Rota da tabela
/ip route
add \
    dst-address=0.0.0.0/0 \
    gateway=ether4-WAN2 \
    routing-table=Rota-WAN2
```

---

# Fluxo do tráfego

```text
                     Cliente
                        │
                        ↓
                   PREROUTING
                        │
                        ↓
              ┌──────────────────┐
              │   Mangle         │
              │                  │
              │ destino pertence │
              │ à WAN-DST?       │
              └────────┬─────────┘
                       │
                      SIM
                       ↓
                Rota-WAN2
                       │
                       ↓
                 ether4-WAN2
                       │
                       ↓
                   INTERNET
```

---

# 🧠 Para memorizar

```text
dst-address-list
       ↓
identifica DESTINO
       ↓
mangle
       ↓
mark-routing
       ↓
routing-table
       ↓
gateway
       ↓
LINK
```

### Diferenças

```text
LOAD BALANCE POR ORIGEM
        ↓
src-address
        ↓
"Quem está acessando?"

LOAD BALANCE POR DESTINO
        ↓
dst-address / dst-address-list
        ↓
"Para onde está indo?"

LOAD BALANCE POR PORTA
        ↓
dst-port
        ↓
"Qual serviço está sendo acessado?"
```

> **Importante:** tecnicamente, o exemplo acima é melhor descrito como **roteamento baseado no destino/serviço**. Para existir balanceamento de carga de verdade, você precisa distribuir diferentes destinos/fluxos entre os links, em vez de simplesmente mandar todos os destinos selecionados para a WAN 2.
