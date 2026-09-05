# Openvpn Site-To-Site
# Topologia

```text
```text
                                   INTERNET
                                       │
                   ┌───────────────────┴───────────────────┐
                   │                                       │
          WAN: 192.168.100.2                     WAN: 192.168.100.3
                   │                                       │
          ┌─────────────────┐                    ┌─────────────────┐
          │   MikroTik R1   │◄══════════════════►│   MikroTik R2   │
          │ OpenVPN Server  │   OpenVPN Tunnel   │ OpenVPN Client  │
          │                 │    10.0.0.0/30     │                 │
          │ VPN 10.0.0.1    │                    │ VPN 10.0.0.2    │
          └────────┬────────┘                    └────────┬────────┘
                   │                                      │
           10.1.1.0/24                           192.168.4.0/24
                   │                                      │
      ┌────────────┴────────────┐            ┌────────────┴────────────┐
      │        Rede Local       │            │        Rede Local       │
      │ PCs, Servidores, NAS... │            │ PCs, Servidores, NAS... │
      └─────────────────────────┘            └─────────────────────────┘
```

---

## R1

### Certificado

```
cerfiticate add name=ca-template common-name=CA_R1 key-usage=key-cert-sign,crl-sign
cerfiticate add name=server-template common-name=SERVER
cerfiticate add name=client-R2-template common-name=client-R2
```

### Assinar

```
certificate sign ca-template ca-crl-host=192.168.100.2 name=CA_R1
certificate sign server-template ca=CA_R1 name=SERVER
certificate sign client-R2-template ca=CA_R1 name=client-R2
```

### Autorizar/Validar

```
certificate set CA_R1 trusted=yes
certificate set SERVER trusted=yes
```

### Export

```
certificate export-certificate CA_R1
certificate export-certificate client-R2 export-passphrase=SENHA123!
```

### Perfil

```
ppp profile add name=openvpn local-address=10.0.0.1 remote-address=10.0.0.2 change-tcp-mss=yes use-compression=no use-encryption=required
ppp secret add name=VPN-SECRET password=SENHA123!mk! profile=openvpn service=ovpn
```

### Servidor

```
interface ovpn-server server set certificate=SERVER cipher=blowfish128,aes128-cbc,aes256-cbc default-profile=openvpn enabled=yes require-client-certificate=yes
```

### Rotas

```
ip route add dst-address=192.168.4.0/24 gateway=10.0.0.1
```

### Firewall

```
ip firewall filter add chain=input dst-port=1194 protocol=tcp
ip firewall nat add chain=srcnat src-address=10.1.1.0/24 dst-address=192.168.4.0/24
```

---

## R2

### Import

```
certificate import file-name=cert_export_CA_R1.crt passphrase=""
certificate import file-name=cert_export_client-R2.crt passphrase="SENHA123!"
certificate import file-name=cert_export_client-R2.key passphrase="SENHA123!"
```

### Rotas

```
ip route add dst-address=10.1.1.0/24 gateway=10.0.0.2
```

### Servidor

```
interface ovpn-client add certificate=cert_export_client-R2.crt_0 cipher=aes256-cbc connect-to=192.168.100.2 name=ovpn-R2 password=SENHA123!mk! user=VPN-SECRET profile=default-encryption
```

### Firewall

```
ip firewall filter add chain=input dst-port=1194 protocol=tcp
ip firewall nat add chain=srcnat src-address=192.168.4.0/24 dst-address=10.1.1.0/24
```