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
          │     Matriz      │   PPTP/L2TP Tunnel │      Filial     │
          │                 │    10.0.0.0/30     │                 │
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
### Matriz

WAN: 192.168.122.2
LAN: 10.1.0.1
VPN: 10.0.0.1

Server:
interface pptp-server server set enabled=yes max-mtu=1500 max-mru=1500 authentication=mschap1,mschap2

Secret:
ppp secret add name=teste local-address=10.0.0.1 remote-address=10.0.0.2 service=pptp

Route:
ip route add dst-address=192.168.122.0/24 gateway=10.0.0.2

---
### Filial

WAN: 192.168.122.3
LAN: 10.1.2.1
VPN: 10.0.0.2

Client:
interface pptp-client add name=pptp-out1 max-mtu=1500 max-mru=1500 connect-to=192.168.0.2 user=teste password=123456 allow=mschap1,mschap2

