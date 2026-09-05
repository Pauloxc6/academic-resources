# Topologia

```
                                   INTERNET
                                       │
                   ┌───────────────────┴───────────────────┐
                   │                                       │
             WAN: 192.168.122.2                     WAN: 192.168.122.3
                   │                                       │
          ┌─────────────────┐                    ┌─────────────────┐
          │   MikroTik R1   │◄══════════════════►│   MikroTik R2   │
          │     Matriz      │     IPsec Tunnel   │      Filial     │
          │                 │   ESP / Tunnel Mode│                 │
          │ Peer: peer1     │                    │ Peer: peer1     │
          └────────┬────────┘                    └────────┬────────┘
                   │                                      │
            LAN: 10.1.0.0/16                      LAN: 10.1.2.0/16
                   │                                      │
      ┌────────────┴────────────┐            ┌────────────┴────────────┐
      │        Rede Local       │            │        Rede Local       │
      │ PCs, Servidores, NAS... │            │ PCs, Servidores, NAS... │
      └─────────────────────────┘            └─────────────────────────┘
```

---

## Mk1

WAN: 192.168.122.2/24
LAN: 10.1.0.1/16

### Peer:

```
/ip ipsec peer add address=192.168.122.3/32 comment="Boise Peer" name=peer1
```
### Policy:

```
ip ipsec policy add comment="Boise Traffic" dst-address=10.1.2.1 sa-dst-address=192.168.122.3 sa-src-address=10.1.0.1 src-address=192.168.122.2 tunnel=yes
```

### Firewall

```
ip firewall nat add chain=srcnat comment="Boise NAT bypass" dst-address=10.1.2.1/24 src-address=10.1.0.1/24
```

## Mk2

WAN: 192.168.122.3/24
LAN: 10.1.2.1/16

### Peer:

```
/ip ipsec peer add address=192.168.122.2/32 comment="Seattle Peer" name=peer1
```

### Policy:

```
ip ipsec policy add comment="Seattle Traffic" dst-address=10.1.0.1 sa-dst-address=192.168.122.2 sa-src-address=10.1.2.1 src-address=192.168.122.3 tunnel=yes
```

### Firewall:

```
ip firewall nat add chain=srcnat comment="Boise NAT bypass" dst-address=10.1.0.1/24 src-address=10.1.2.1/24
```

