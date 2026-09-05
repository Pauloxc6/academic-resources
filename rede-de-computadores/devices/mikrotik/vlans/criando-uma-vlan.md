# 🏷️ Criando uma VLAN

Neste cenário, os roteadores **R1** e **R2** possuem as VLANs **30** e **40** trafegando pela interface `ether1`.

```text
             VLAN 30
      192.168.30.1/24
            R1
             │
             │ ether1
             │ VLAN 30 e VLAN 40
             │
            R2
      192.168.30.2/24
             │
             │
      192.168.40.2/24
```

---

# R1

## Criando a VLAN 30

```bash
/interface vlan add name=vlan30 vlan-id=30 interface=ether1
/ip address add address=192.168.30.1/24 interface=vlan30
```

A interface lógica `vlan30` será criada sobre a `ether1`.

```text
ether1
  │
  └── VLAN 30
        │
        └── 192.168.30.1/24
```

---

## Criando a VLAN 40

```bash
/interface vlan add name=vlan40 vlan-id=40 interface=ether1
/ip address add address=192.168.40.1/24 interface=vlan40
```

```text
ether1
  │
  ├── VLAN 30 → 192.168.30.1/24
  │
  └── VLAN 40 → 192.168.40.1/24
```

---

# R2

## Criando a VLAN 30

```bash
/interface vlan add name=vlan30 vlan-id=30 interface=ether1
/ip address add address=192.168.30.2/24 interface=vlan30
```

---

## Criando a VLAN 40

```bash
/interface vlan add name=vlan40 vlan-id=40 interface=ether1
/ip address add address=192.168.40.2/24 interface=vlan40
```

O resultado será:

```text
                    ether1
                      │
        ┌─────────────┴─────────────┐
        │                           │
      VLAN 30                     VLAN 40
        │                           │
        ▼                           ▼

R1                              R1
192.168.30.1/24                 192.168.40.1/24
        │                           │
════════════════════════════════════════════════
        │                           │
R2                              R2
192.168.30.2/24                 192.168.40.2/24
```

---

# 🧪 Testando a conectividade

No **R1**:

```bash
/ping 192.168.30.2
/ping 192.168.40.2
```

No **R2**:

```bash
/ping 192.168.30.1
/ping 192.168.40.1
```

---

# ⚠️ Sobre `use-service-tag=yes`

Você colocou:

```bash
use-service-tag=yes
```

Esse parâmetro faz a interface utilizar **802.1ad (Q-in-Q)**, conhecido como **Service VLAN**.

Ou seja, em vez do encapsulamento VLAN tradicional **802.1Q**, ele utiliza o EtherType associado ao **802.1ad**.

Para uma VLAN comum, normalmente seria:

```bash
/interface vlan add name=vlan30 vlan-id=30 interface=ether1
```

e:

```bash
/interface vlan add name=vlan40 vlan-id=40 interface=ether1
```

Use `use-service-tag=yes` principalmente quando estiver trabalhando com **Q-in-Q** ou **Service Provider VLANs**.

---

# 🌉 Sobre a Bridge no R1

Na configuração original:

```bash
/interface bridge add name=bridge30
/interface bridge port add interface=ether1 bridge=bridge30
/interface bridge port add interface=vlan30 bridge=bridge30
```

⚠️ **Essa configuração precisa de atenção.**

Você está colocando:

```text
ether1
  +
vlan30
```

na mesma bridge, enquanto a `vlan30` já é uma interface criada **sobre a própria `ether1`**.

Em geral, para um cenário simples de comunicação entre R1 e R2 utilizando VLANs roteadas, **essa bridge não é necessária**.

A configuração mais simples seria:

```text
R1                                  R2

ether1 ───── VLAN 30 ──────────── ether1
  │                                  │
vlan30                             vlan30
192.168.30.1                      192.168.30.2


ether1 ───── VLAN 40 ──────────── ether1
  │                                  │
vlan40                             vlan40
192.168.40.1                      192.168.40.2
```

Portanto, para esse laboratório, a configuração pode ficar apenas:

## R1

```bash
/interface vlan
add name=vlan30 vlan-id=30 interface=ether1
add name=vlan40 vlan-id=40 interface=ether1

/ip address
add address=192.168.30.1/24 interface=vlan30
add address=192.168.40.1/24 interface=vlan40
```

## R2

```bash
/interface vlan
add name=vlan30 vlan-id=30 interface=ether1
add name=vlan40 vlan-id=40 interface=ether1

/ip address
add address=192.168.30.2/24 interface=vlan30
add address=192.168.40.2/24 interface=vlan40
```

---

# 🧠 Resumo

| Interface | R1                | R2                |
| --------- | ----------------- | ----------------- |
| `vlan30`  | `192.168.30.1/24` | `192.168.30.2/24` |
| `vlan40`  | `192.168.40.1/24` | `192.168.40.2/24` |

```text
                 TRUNK
       ┌─────────────────────┐
       │ VLAN 30 │ VLAN 40   │
       └─────────────────────┘
               ether1
        R1 ─────────── R2
```

A `ether1` transporta as duas VLANs, e cada VLAN possui sua própria interface lógica e rede IP.
