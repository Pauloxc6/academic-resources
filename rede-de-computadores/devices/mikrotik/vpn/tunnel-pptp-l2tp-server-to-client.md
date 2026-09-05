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
          │     Matriz      │     PPTP Tunnel    │      Filial     │
          │                 │    10.0.0.0/30     │                 │
          │ PPTP Server     │                    │ PPTP Client     │
          │ VPN: 10.0.0.1   │                    │ VPN: 10.0.0.2   │
          └────────┬────────┘                    └────────┬────────┘
                   │                                      │
            LAN: 10.1.0.0/24                      LAN: 10.1.2.0/24
                   │                                      │
      ┌────────────┴────────────┐            ┌────────────┴────────────┐
      │        Rede Local       │            │        Rede Local       │
      │ PCs, Servidores, NAS... │            │ PCs, Servidores, NAS... │
      └─────────────────────────┘            └─────────────────────────┘
```

---

## Matriz

WAN: 192.168.122.2
LAN: 10.1.0.1
VPN: 10.0.0.1

### Server:

```
interface pptp-server server set enabled=yes max-mtu=1500 max-mru=1500 authentication=mschap1,mschap2
```

### Secret:

```
ppp secret add name=teste local-address=10.0.0.1 remote-address=10.0.0.2 service=pptp routes="192.168.122.0/24 10.0.0.1"
```

---

## Filial
### Client

```
interface pptp-client add name=pptp-out1 allow=mschap1,mschap2 max-mtu=1500 max-mru=1500 connect-to=192.168.122.2 user=test password=123456
```


