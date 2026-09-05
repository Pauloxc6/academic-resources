# 05 — Trabalhando com MPLS Traffic Engineering

O **MPLS Traffic Engineering (MPLS-TE)** permite controlar de forma mais precisa o caminho que determinado tráfego MPLS deverá utilizar.

Enquanto o OSPF normalmente escolhe o caminho de **menor custo**, o MPLS-TE permite definir caminhos explícitos levando em consideração fatores como:

* largura de banda disponível;
* caminho desejado;
* prioridade;
* restrições;
* reserva de recursos;
* caminho primário e secundário.

---

# 🧠 Conceito

No cenário anterior tínhamos:

```text
                P1
               /  \
             /      \
           PE1       P2
             \      /
              \    /
               ─────
```

Com MPLS-TE podemos dizer:

> "Quero que o túnel entre PE1 e P2 passe especificamente por determinados enlaces."

Por exemplo:

```text
PE1 → P1 → P2
```

em vez de simplesmente deixar o IGP determinar o caminho.

---

# 🔄 OSPF + MPLS-TE

O OSPF continua sendo utilizado como **IGP**, mas passa a carregar informações adicionais relacionadas ao Traffic Engineering.

```text
             OSPF
              │
              ├── Rotas IP
              │
              └── Informações de TE
                       │
                       ▼
                  MPLS-TE
                       │
                       ▼
                 Túnel TE
```

O OSPF fornece informações sobre a topologia e os recursos disponíveis.

O MPLS-TE utiliza essas informações para estabelecer túneis de engenharia de tráfego.

---

# 1. Configurando MPLS-TE no PE1

## Habilitando MPLS-TE no OSPF

```routeros
/routing ospf instance set numbers=0 \
    mpls-te-area=0.0.0.0 \
    mpls-te-address=172.0.1.1
```

### Parâmetros

| Parâmetro                   | Função                                           |
| --------------------------- | ------------------------------------------------ |
| `numbers=0`                 | Seleciona a instância OSPF de índice `0`         |
| `mpls-te-area=0.0.0.0`      | Define a área OSPF utilizada para MPLS-TE        |
| `mpls-te-address=172.0.1.1` | Endereço utilizado para identificação do MPLS-TE |

Nesse cenário:

```text
PE1
LSR-ID / TE Address
172.0.1.1
```

---

# 🛣️ Criando o caminho TE

```routeros
/mpls traffic-eng path add \
    name=PE1-P1-P2 \
    setup-priority=0 \
    holding-priority=0 \
    use-cspf=no \
    record-route=yes \
    hops=192.100.200.2:/strict,192.168.220.2:/strict,172.0.0.2:/strict \
    disabled=no
```

Esse objeto define um **caminho explícito** para o túnel.

## `name`

```text
name=PE1-P1-P2
```

Nome dado ao caminho.

---

## `setup-priority`

```text
setup-priority=0
```

Define a prioridade utilizada durante a tentativa de estabelecimento do túnel.

Em geral, valores menores representam maior prioridade.

---

## `holding-priority`

```text
holding-priority=0
```

Define a prioridade utilizada para manter os recursos já reservados pelo túnel.

---

## `use-cspf`

```text
use-cspf=no
```

Desabilita o **CSPF (Constrained Shortest Path First)** para esse caminho.

O CSPF é uma extensão do cálculo de caminho que considera restrições, como:

* largura de banda;
* atributos dos enlaces;
* afinidades;
* outras restrições de TE.

Como o laboratório está utilizando um caminho explícito, o CSPF não é utilizado nesse objeto.

---

## `record-route`

```text
record-route=yes
```

Solicita o registro do caminho percorrido pelo túnel.

Isso pode ser útil para:

* diagnóstico;
* visualização do caminho;
* troubleshooting;
* confirmação do caminho utilizado.

---

# 📍 Hops

```text
hops=192.100.200.2:/strict,192.168.220.2:/strict,172.0.0.2:/strict
```

Aqui está sendo definido o caminho desejado.

A ideia é indicar os endereços que deverão fazer parte do caminho do túnel.

O termo:

```text
/strict
```

indica uma exigência mais rígida sobre o próximo salto especificado.

Conceitualmente:

```text
PE1
 │
 │ 192.100.200.2
 ▼
 P1
 │
 │ 192.168.220.2
 ▼
 P2
 │
 ▼
172.0.0.2
```

> ⚠️ Os endereços precisam corresponder exatamente à topologia e à forma como o RouterOS espera os hops no `path`. Em caso de dúvida, utilize `?` no CLI para conferir a sintaxe da versão instalada.

---

# 🚇 Criando o túnel MPLS-TE

```routeros
/mpls traffic-eng tunnel add \
    name=tunnel1 \
    to-address=172.0.0.2 \
    bandwidth=100k \
    primary-path=PE1-P1-P2 \
    setup-priority=0 \
    holding-priority=0
```

Agora o caminho definido anteriormente é associado a um **túnel MPLS-TE**.

---

## `name`

```text
name=tunnel1
```

Nome do túnel.

---

## `to-address`

```text
to-address=172.0.0.2
```

Define o endereço do destino do túnel.

Nesse cenário:

```text
PE1 → P2
```

com P2 identificado por:

```text
172.0.0.2
```

---

## `bandwidth`

```text
bandwidth=100k
```

Define a largura de banda solicitada pelo túnel.

Neste exemplo:

```text
100 kbit/s
```

Essa informação pode ser utilizada pelo mecanismo de TE para verificar disponibilidade de recursos.

---

## `primary-path`

```text
primary-path=PE1-P1-P2
```

Define:

```text
PE1-P1-P2
```

como o caminho primário do túnel.

Assim:

```text
tunnel1
   │
   ▼
PE1-P1-P2
   │
   ▼
PE1 → P1 → P2
```

---

# 🔌 Interfaces MPLS-TE no PE1

```routeros
/mpls traffic-eng interface add \
    interface=ether2 \
    bandwidth=200k \
    use-udp=yes

/mpls traffic-eng interface add \
    interface=ether3 \
    bandwidth=200k \
    use-udp=yes
```

As interfaces possuem:

```text
ether2 → PE1 ↔ P1
ether3 → PE1 ↔ P2
```

Cada enlace foi configurado com:

```text
bandwidth=200k
```

Portanto, para o laboratório:

```text
PE1 → P1 = 200 kbit/s
PE1 → P2 = 200 kbit/s
```

---

# 2. Configurando MPLS-TE no P1

Primeiro configuramos a identificação MPLS-TE:

```routeros
/routing ospf instance set numbers=0 \
    mpls-te-area=0.0.0.0 \
    mpls-te-address=172.0.0.1
```

O P1 utiliza:

```text
172.0.0.1
```

como endereço MPLS-TE.

---

## Interfaces

```routeros
/mpls traffic-eng interface add \
    interface=ether1 \
    bandwidth=200k \
    use-udp=yes

/mpls traffic-eng interface add \
    interface=ether2 \
    bandwidth=200k \
    use-udp=yes
```

### Topologia

```text
ether1 → P1 ↔ PE1
ether2 → P1 ↔ P2
```

> ⚠️ **Correção:** no material original, `ether2` aparecia duas vezes. O correto, considerando a topologia anterior, é utilizar `ether1` e `ether2`.

---

# 3. Configurando MPLS-TE no P2

## OSPF MPLS-TE

```routeros
/routing ospf instance set numbers=0 \
    mpls-te-area=0.0.0.0 \
    mpls-te-address=172.0.0.2
```

P2 utiliza:

```text
172.0.0.2
```

como endereço MPLS-TE.

---

## Interfaces

```routeros
/mpls traffic-eng interface add \
    interface=ether1 \
    bandwidth=200k \
    use-udp=yes

/mpls traffic-eng interface add \
    interface=ether2 \
    bandwidth=200k \
    use-udp=yes
```

No cenário:

```text
ether1 → P2 ↔ PE1
ether2 → P2 ↔ P1
```

---

# 4. Configurando MPLS-TE no P3

O P3 não aparece no túnel `PE1-P1-P2`, mas está sendo preparado para participar do domínio MPLS-TE.

## OSPF

```routeros
/routing ospf instance set numbers=0 \
    mpls-te-area=0.0.0.0 \
    mpls-te-address=172.0.0.3
```

---

## Interfaces

```routeros
/mpls traffic-eng interface add \
    interface=ether1 \
    bandwidth=200k \
    use-udp=yes

/mpls traffic-eng interface add \
    interface=ether2 \
    bandwidth=200k \
    use-udp=yes
```

P3 utiliza:

```text
172.0.0.3
```

como endereço MPLS-TE.

---

# 📊 Resumo da configuração

| Router | TE Address  | Interfaces TE  | Capacidade |
| ------ | ----------- | -------------- | ---------- |
| PE1    | `172.0.1.1` | ether2, ether3 | 200k cada  |
| P1     | `172.0.0.1` | ether1, ether2 | 200k cada  |
| P2     | `172.0.0.2` | ether1, ether2 | 200k cada  |
| P3     | `172.0.0.3` | ether1, ether2 | 200k cada  |

Túnel:

```text
tunnel1
   │
   ├── Destino: 172.0.0.2
   ├── Banda: 100k
   └── Caminho: PE1-P1-P2
```

---

# 🧭 Caminho explícito x caminho calculado

Existem duas ideias importantes aqui.

### Caminho explícito

Você determina o caminho:

```text
PE1 → P1 → P2
```

Isso é o que o laboratório está fazendo com:

```text
hops=...
```

### CSPF

O CSPF pode calcular um caminho considerando restrições:

```text
                  ┌─ 200k ─┐
                  │        │
PE1 ───────────── P1 ───── P2
 │
 └──────── 50k ────────────┘
```

Se o túnel precisa de:

```text
100k
```

o CSPF pode considerar a capacidade disponível dos enlaces e escolher um caminho que satisfaça essa restrição.

---

# 📦 Reserva de banda

Neste laboratório:

```text
Interface:
200k

Túnel:
100k
```

Conceitualmente:

```text
200k disponíveis
│
├── 100k → tunnel1
│
└── 100k → restante
```

Isso permite que o Traffic Engineering considere a disponibilidade de recursos ao estabelecer túneis.

---

# 🔍 Verificação

Depois da configuração, é importante verificar:

### OSPF

```routeros
/routing ospf instance print detail
```

### Interfaces MPLS-TE

```routeros
/mpls traffic-eng interface print
```

### Caminhos

```routeros
/mpls traffic-eng path print
```

### Túneis

```routeros
/mpls traffic-eng tunnel print
```

---

# 🧠 Fluxo completo

O funcionamento pode ser resumido assim:

```text
             OSPF
              │
              ▼
     Descobre a topologia
              │
              ▼
       MPLS-TE / CSPF
              │
              ▼
      Define o caminho
              │
              ▼
        Cria o túnel
              │
              ▼
       MPLS Label Path
              │
              ▼
      Encaminhamento
```

No nosso exemplo:

```text
PE1
 │
 │  tunnel1
 │
 ▼
 P1
 │
 ▼
 P2
```

O túnel foi configurado para utilizar:

```text
PE1 → P1 → P2
```

mesmo que exista outro caminho possível na topologia.

---

# ⚠️ Pontos importantes

### 1. MPLS-TE não substitui o IGP

O OSPF continua sendo importante para fornecer a visão da topologia.

### 2. O túnel não é simplesmente uma rota estática

Um túnel TE possui mecanismos próprios para estabelecimento, recursos, prioridades e caminhos.

### 3. `bandwidth` não é simplesmente a velocidade física

Neste contexto, representa o recurso de banda considerado pelo Traffic Engineering.

### 4. P3 não participa do caminho definido

O caminho:

```text
PE1-P1-P2
```

não utiliza P3.

P3 apenas está sendo preparado para participar do domínio MPLS-TE.

---

# 🧠 Para memorizar

```text
IGP
 ↓
Conhece a topologia

MPLS-TE
 ↓
Manipula o caminho

CSPF
 ↓
Calcula caminho considerando restrições

Tunnel
 ↓
Representa o caminho TE

MPLS
 ↓
Encaminha o tráfego utilizando labels
```

**Ideia principal:**

> **MPLS-TE permite controlar o caminho do tráfego MPLS em vez de depender exclusivamente do caminho de menor custo calculado pelo IGP.**
