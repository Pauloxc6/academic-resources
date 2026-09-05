# Topologia

```
                              INTERNET
                                  │
                          WAN: 192.168.122.2
                                  │
                    ┌────────────────────────┐
                    │      MikroTik R1       │
                    │────────────────────────│
                    │ WireGuard Server (wg2) │
                    │ LAN: 10.1.0.1/16       │
                    │ WG : 10.10.105.1/24    │
                    └───────────┬────────────┘
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
        WireGuard Tunnel              WireGuard Tunnel
                 │                             │
        10.10.105.2/32                172.10.5.2/24
                 │                             │
        ┌────────────────┐            ┌────────────────┐
        │ Windows Client │            │  Linux Client  │
        │ WireGuard      │            │ WireGuard      │
        └────────────────┘            └────────────────┘
```

---

## Mk1
WAN: 192.168.122.2/24
LAN: 10.1.0.1/16

```
interface wireguard add

ip address add address=10.10.105.1/24 interface=wg2

interface wireguard peers add interface=wg2 public-key=windows allowed-address=10.10.105.2/24

interface wireguard peers add interface=wg2 public-key=linux allowed-address=0.0.0.0/0 client-address=172.10.5.2 client-listen-port=50501 client-endpoint=172.10.5.1
```

---

Windows
```
wireguard
	add
	   name: link1
	   Pub key: -
	   Save

	edit
	   [Interface]
	   Private Key: -
           Address = 10.10.105.2/32
	   DNS = 1.1.1.1

           [PEER]
	   Publickey = u9CmHFc5RBCRhGRzdNKU7t8j7t1nC60kCBMQlssikhg=
           AllowedIPs = 0.0.0.0/0
           Endpoint = 192.168.122.2:24776
           PersistentKeepLive = 10
```

## Linux

```bash
sudo ip link add dev wg0 type wireguard
sudo ip addr add 172.10.5.2/24 dev wg0

sudo wg genkey | tee wireguard/private.key | sudo wg pubkey > wireguard/public.key

sudo wg set wg0 listen-port 50501 private-key wireguard/key peer qnmyprpIUql1VSPLHv1GAVS16CGG9SqH40eni0wsJyo= allowed-ips 0.0.0.0/0 endpoint 192.168.122.254:51679	
```






