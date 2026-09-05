
# Topologia

```text
                                   INTERNET
                                       │
                   ┌───────────────────┴───────────────────┐
                   │                                       │
          WAN: 192.168.122.2                     WAN: 192.168.122.3
                   │                                       │
          ┌─────────────────┐                    ┌─────────────────┐
          │   MikroTik R1   │◄══════════════════►│   MikroTik R2   │
          │     Matriz      │     EoIP Tunnel    │      Filial     │
          │                 │    Tunnel ID: 0    │                 │
          │ eoip-tunnel1    │                    │ eoip-tunnel1    │
          └────────┬────────┘                    └────────┬────────┘
                   │                                      │
             Bridge bridge1                        Bridge bridge1
                   │                                      │
              ether4                               ether4
                   │                                      │
      ┌────────────┴────────────┐            ┌────────────┴────────────┐
      │      Rede Local         │            │      Rede Local         │
      │      10.1.0.0/26        │            │      10.1.2.0/26        │
      │ Gateway: 10.1.0.1       │            │ Gateway: 10.1.2.1       │
      └─────────────────────────┘            └─────────────────────────┘
```


---

## Matriz

WAN: 192.168.122.2/24
LAN: 10.1.0.1/26

### Interface EoIP:

```
/interface eoip add mtu=1500 name=eoip-tunnel1 local-address=192.168.122.2 remote-address=192.168.122.3 tunnel-id=0
```

### Bridge

```
/interface bridge add mtu=1500 name=bridge1
/interface bridge port add bridge=bridge1 interface=eoip-tunnel1
/interface bridge port add bridge=bridge1 interface=ether4
```

---

## Filial

WAN: 192.168.122.3/24
LAN: 10.1.2.1/26

### Interface EoIP:

```
/interface eoip add mtu=1500 name=eoip-tunnel1 local-address=192.168.122.3 remote-address=192.168.122.2 tunnel-id=0
```

### Bridge

```
/interface bridge add mtu=1500 name=bridge1
/interface bridge port add bridge=bridge1 interface=eoip-tunnel1
/interface bridge port add bridge=bridge1 interface=ether4
```