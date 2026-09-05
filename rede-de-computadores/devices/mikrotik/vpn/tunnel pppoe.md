# Topologia

```text
                               CLIENTE
                                   │
                          Interface: ether1
                                   │
                    Sessão PPPoE (CHAP/MSCHAP)
                                   │
                         Endereço via Pool
                             100.64.0.0/10
                                   │
══════════════════════════════════════════════════════════════════════
                                   │
                          Interface: ether3
                     IP: 100.64.0.1/10 (Servidor)
                                   │
                     ┌──────────────────────────┐
                     │        MikroTik          │
                     │      PPPoE Server        │
                     │──────────────────────────│
                     │ Service : PPPoE-Server1 │
                     │ Profile : profile-pppoe │
                     │ Pool    : pool1-pppoe   │
                     │ Auth    : CHAP/MSCHAP   │
                     └──────────────────────────┘
                                   │
                              Rede Interna
```

---

### IP ADDRESS

```
ip add add comment="PPPoE-Server" address=100.64.0.1/10 interface=ether3 network=100.64.0.0
```

### IP POOL

```
ip pool add name=pool1-pppoe ranges=100.64.0.0/10 comment="PPPoE" 
```

### PROFILE

```
ppp profile add name=profile-pppoe local-address=100.64.0.1 remote-address=pool1-pppoe  dns-server=1.1.1.1,1.0.0.1 rate-limit=500MB/500MB only-one=yes
```

### SECRETS

```
ppp secret add name=user1 password=12345678 service=pppoe profile=profile-pppoe
```

### SERVER

```
interface pppoe-server server add service-name=PPPoE-Server1 max-mtu=1480 max-mru=1480 interface=ether3 authentication=chap,mschap1,mschap2 default-profile=profile-pppoe  comment="Servidor PPPoE 1"
```

----
### CLIENT

```
interface pppoe-client add name=ppp1 interface=ether1 user=user1 password=12345678 allow=chap,mschap1,mschap2
```
