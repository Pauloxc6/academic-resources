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
          │     Matriz      │     IPIP Tunnel    │      Filial     │
          │                 │    1.1.1.0/24      │                 │
          │ VPN: 1.1.1.1    │                    │ VPN: 1.1.1.2    │
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
VPN: 1.1.1.1/24

```
interface ipip add local-address=192.168.122.2 remote-address=192.168.122.3
ip address add address=1.1.1.1/24 interface=ipip-tunnel
```

### Mk2
WAN: 192.168.122.3/24
LAN: 10.1.2.1/16
VPN: 1.1.1.2/24

```
interface ipip add local-address=192.168.122.3 remote-address=192.168.122.3
ip address add address=1.1.1.2/24 interface=ipip-tunnel
```


