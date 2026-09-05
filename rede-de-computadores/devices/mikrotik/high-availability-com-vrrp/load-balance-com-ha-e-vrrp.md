# load-balance-com-ha-e-vrrp

# 🔄 VRRP com Master/Backup invertidos

Neste cenário temos **dois grupos VRRP** na mesma interface física:

* **VRID 49** → R1 é Master e R2 é Backup
* **VRID 77** → R2 é Master e R1 é Backup

Isso permite distribuir a função de Master entre os dois roteadores.

```text id="n5gq6u"
                    ether1
              ┌────────┴────────┐
              │                 │
             R1                R2
              │                 │
        ┌─────┴─────┐     ┌─────┴─────┐
        │           │     │           │
      VRID 49     VRID 77
      MASTER      BACKUP
      150         100

      VRID 49     VRID 77
      BACKUP      MASTER
      100         150
        │           │
        ▼           ▼
  192.168.0.254  192.168.0.253
```

---

# 🖥️ R1

## VRID 49 — Master

```bash id="7k0d7n"
/interface vrrp
add name=vrrp1 \
    interface=ether1 \
    vrid=49 \
    priority=150 \
    authentication=none \
    preemption-mode=yes \
    interval=1s \
    comment="VRRP - Master"
```

O R1 possui prioridade:

```text id="p0eq9a"
150
```

enquanto o R2 possui:

```text id="8y6j9w"
100
```

Portanto:

```text id="7v4r6n"
VRID 49

R1 → 150 → MASTER
R2 → 100 → BACKUP
```

O IP virtual associado é:

```text id="g3s1yn"
192.168.0.254
```

---

## VRID 77 — Backup

No segundo grupo:

```bash id="cb5evw"
/interface vrrp
add name=vrrp2 \
    interface=ether1 \
    vrid=77 \
    priority=100 \
    interval=1s \
    preemption-mode=yes \
    authentication=none \
    comment="VRRP - Backup"
```

O R1 agora possui prioridade menor:

```text id="f6b5fq"
100
```

O IP virtual é:

```text id="ynm5eh"
192.168.0.253
```

Portanto:

```text id="3q4g2p"
VRID 77

R1 → 100 → BACKUP
R2 → 150 → MASTER
```

---

# 🖥️ R2

## VRID 49 — Backup

```bash id="ry3p9q"
/interface vrrp
add name=vrrp1 \
    interface=ether1 \
    vrid=49 \
    priority=100 \
    authentication=none \
    preemption-mode=yes \
    interval=1s \
    comment="VRRP - Backup"
```

O R2 possui prioridade menor que o R1:

```text id="3v6s1c"
R2 → 100
R1 → 150
```

Logo:

```text id="h3j8sy"
VRID 49
R1 → MASTER
R2 → BACKUP
```

---

## VRID 77 — Master

```bash id="iw5p0p"
/interface vrrp
add name=vrrp2 \
    interface=ether1 \
    vrid=77 \
    priority=150 \
    interval=1s \
    preemption-mode=yes \
    authentication=none \
    comment="VRRP - Master"
```

Agora o R2 possui prioridade maior:

```text id="w4e7ns"
150
```

contra:

```text id="b8m1ce"
R1 → 100
```

Logo:

```text id="k6j5sz"
VRID 77
R2 → MASTER
R1 → BACKUP
```

---

# 🌐 IPs virtuais

Temos dois IPs virtuais:

| VRID | IP Virtual      | R1     | R2     |
| ---: | --------------- | ------ | ------ |
|   49 | `192.168.0.254` | Master | Backup |
|   77 | `192.168.0.253` | Backup | Master |

Assim, podemos ter diferentes dispositivos ou redes utilizando diferentes gateways:

```text id="yr6t7m"
Gateway 192.168.0.254
        │
        ▼
       R1
     MASTER
```

e:

```text id="7qz1sd"
Gateway 192.168.0.253
        │
        ▼
       R2
     MASTER
```

---

# ⚖️ Distribuindo a função de Master

Essa é a principal vantagem dessa configuração.

Em vez de deixar:

```text id="n7k4h3"
R1 → MASTER de tudo
R2 → BACKUP de tudo
```

temos:

```text id="y7x0k2"
             R1              R2
              │               │
       ┌──────┴──────┐ ┌──────┴──────┐
       │             │ │             │
    VRID 49       VRID 77
     MASTER        BACKUP
       150           100

    VRID 49       VRID 77
     BACKUP        MASTER
       100           150
       │               │
       ▼               ▼
  .0.254            .0.253
```

Isso pode ajudar a **distribuir o tráfego entre os roteadores**, desde que os clientes sejam configurados para utilizar os respectivos gateways.

> ⚠️ VRRP continua sendo um mecanismo de **redundância**, não um balanceamento automático de uma mesma rede. Aqui estamos distribuindo a função de Master entre **dois grupos VRRP distintos**.

---

# 🔄 Falha do R1

Inicialmente:

```text id="k5v3b9"
VRID 49
R1 → MASTER
R2 → BACKUP

VRID 77
R1 → BACKUP
R2 → MASTER
```

Se o R1 falhar:

```text id="5yd0pq"
VRID 49
R1 → DOWN
R2 → MASTER

VRID 77
R1 → DOWN
R2 → MASTER
```

O R2 passa a ser Master dos dois grupos.

Quando o R1 retornar, devido a:

```text id="1j9z3f"
preemption-mode=yes
```

ele poderá reassumir o VRID 49, pois possui prioridade maior:

```text id="iq6d5r"
VRID 49

R1 → 150 → MASTER
R2 → 100 → BACKUP
```

No VRID 77, o R2 continuará como Master:

```text id="z1j5f0"
VRID 77

R1 → 100 → BACKUP
R2 → 150 → MASTER
```

---

# 🧠 Como memorizar

A regra é simples:

```text id="y0o4yh"
MAIOR PRIORIDADE
       ↓
    MASTER
```

### VRID 49

```text id="x9t4u1"
R1 = 150
R2 = 100

150 > 100

R1 → MASTER
R2 → BACKUP
```

### VRID 77

```text id="a8s6x0"
R1 = 100
R2 = 150

150 > 100

R2 → MASTER
R1 → BACKUP
```

---

# 📋 Configuração resumida

## R1

```bash id="5qf8vc"
/interface vrrp
add name=vrrp1 interface=ether1 vrid=49 priority=150 \
    authentication=none preemption-mode=yes interval=1s \
    comment="VRRP - Master"

add name=vrrp2 interface=ether1 vrid=77 priority=100 \
    authentication=none preemption-mode=yes interval=1s \
    comment="VRRP - Backup"

/ip address
add address=192.168.0.254/24 interface=vrrp1 \
    comment="VRRP Network 1"

add address=192.168.0.253/24 interface=vrrp2 \
    comment="VRRP Network 2"
```

## R2

```bash id="p3m7kj"
/interface vrrp
add name=vrrp1 interface=ether1 vrid=49 priority=100 \
    authentication=none preemption-mode=yes interval=1s \
    comment="VRRP - Backup"

add name=vrrp2 interface=ether1 vrid=77 priority=150 \
    authentication=none preemption-mode=yes interval=1s \
    comment="VRRP - Master"

/ip address
add address=192.168.0.254/24 interface=vrrp1 \
    comment="VRRP Network 1"

add address=192.168.0.253/24 interface=vrrp2 \
    comment="VRRP Network 2"
```

> **Correção importante na sua configuração original:** no R1, o primeiro IP virtual foi colocado diretamente em `ether1`:
> `interface=ether1`
>
> Para manter a configuração coerente com o segundo grupo e com o funcionamento do VRRP, o IP virtual deve ser associado à **interface VRRP correspondente (`vrrp1`)**, não diretamente à interface física. O mesmo vale para o R2.

---

# 🧠 Resumo final

```text id="2y4q1b"
                    VRRP
                     │
          ┌──────────┴──────────┐
          │                     │
       VRID 49               VRID 77
          │                     │
          ▼                     ▼
   192.168.0.254          192.168.0.253
          │                     │
          ▼                     ▼
       R1 MASTER             R2 MASTER
       priority 150          priority 150
          │                     │
       R2 BACKUP             R1 BACKUP
       priority 100          priority 100
```

**Ideia principal:** dois grupos VRRP independentes, cada um com seu próprio **VRID, IP virtual e eleição de Master**. Isso permite que R1 seja preferencial para um gateway e R2 para outro.
