# Servidor DNS com BIND9 (Master/Slave)

Este guia apresenta a instalação e configuração de um servidor DNS utilizando o **BIND9**, com um servidor **Master** e um **Slave**.

## Topologia

```text
                INTERNET
                    │
             1.1.1.1 / 1.0.0.1
                    │
          +----------------------+
          |      Gateway         |
          |   192.168.122.1      |
          +----------+-----------+
                     │
        ┌────────────┴────────────┐
        │                         │
+---------------+         +---------------+
| DNS Master    |         | DNS Slave     |
| ns1           |         | ns2           |
|192.168.122.108|         |192.168.122.109|
+---------------+         +---------------+
```

## Ambiente

| Equipamento | IP |
|------------|----------------|
| Gateway | 192.168.122.1 |
| DNS Master (ns1) | 192.168.122.108 |
| DNS Slave (ns2) | 192.168.122.109 |
| DNS Forwarder | 1.1.1.1 / 1.0.0.1 |
| Domínio | dominio.com.br |

---

# 1. Instalação

Atualize o sistema:

```bash
sudo apt update
```

Instale o BIND9:

```bash
sudo apt install bind9 bind9utils bind9-doc dnsutils -y
```

---

# 2. Configuração da Rede

Arquivo:

```
/etc/network/interfaces
```

```conf
iface enp1s0 inet static
    address 192.168.122.108
    netmask 255.255.255.0
    broadcast 192.168.122.255
    gateway 192.168.122.1
    network 192.168.122.0
    dns-nameserver 1.1.1.1
```

Reinicie a rede:

```bash
sudo systemctl restart networking
```

ou

```bash
sudo reboot
```

---

# 3. Configurando o Hosts

Arquivo:

```
/etc/hosts
```

```text
127.0.0.1    ns1
```

---

# 4. Configurando o Resolver

Arquivo:

```
/etc/resolv.conf
```

```text
nameserver 1.1.1.1
```

---

# 5. Configuração do BIND

Arquivo:

```
/etc/bind/named.conf.options
```

```conf
acl "trusted" {
    192.168.122.108;
    192.168.122.109;
    192.168.122.1;
};

options {

    recursion yes;

    allow-recursion {
        trusted;
    };

    listen-on {
        192.168.122.108;
    };

    allow-transfer {
        none;
    };

    forwarders {
        1.1.1.1;
        1.0.0.1;
    };

};
```

---

# 6. Configuração da Zona Master

Arquivo:

```
/etc/bind/named.conf.local
```

```conf
zone "dominio.com.br" {
    type master;
    file "/etc/bind/db.dominio.com.br";
    allow-transfer { 192.168.122.109; };
};

zone "122.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.122";
    allow-transfer { 192.168.122.109; };
};
```

---

# 7. Configuração da Zona Slave

No servidor Slave (`192.168.122.109`)

Arquivo:

```
/etc/bind/named.conf.local
```

```conf
zone "dominio.com.br" {
    type slave;
    file "db.dominio.com.br";
    masters { 192.168.122.108; };
};

zone "122.168.192.in-addr.arpa" {
    type slave;
    file "db.192.168.122";
    masters { 192.168.122.108; };
};
```

---

# 8. Zona Direta

Arquivo:

```
/etc/bind/db.dominio.com.br
```

```dns
$TTL 3600

@ IN SOA ns1.dominio.com.br. root.dominio.com.br. (
        3
        1200
        3600
        1814400
        604800
)

;
; Name Servers
;

        IN NS ns1.dominio.com.br.
        IN NS ns2.dominio.com.br.

;
; Registros A
;

ns1     IN A    192.168.122.108
ns2     IN A    192.168.122.109

gw      IN A    192.168.122.1
```

---

# 9. Zona Reversa

Arquivo:

```
/etc/bind/db.192.168.122
```

```dns
$TTL 3600

@ IN SOA dominio.com.br. root.dominio.com.br. (
        3
        1200
        3600
        1814400
        604800
)

;
; Name Servers
;

        IN NS ns1.dominio.com.br.
        IN NS ns2.dominio.com.br.

;
; Reverse DNS
;

108 IN PTR ns1.dominio.com.br.
109 IN PTR ns2.dominio.com.br.
1   IN PTR gw.dominio.com.br.
```

---

# 10. Validando a Configuração

Verificar sintaxe:

```bash
sudo named-checkconf
```

Validar a zona direta:

```bash
sudo named-checkzone dominio.com.br /etc/bind/db.dominio.com.br
```

Validar a zona reversa:

```bash
sudo named-checkzone 122.168.192.in-addr.arpa /etc/bind/db.192.168.122
```

---

# 11. Reiniciar o Serviço

```bash
sudo systemctl restart bind9
```

Verificar o status:

```bash
sudo systemctl status bind9
```

---

# 12. Firewall

Caso utilize UFW:

```bash
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
```

---

# 13. Testes

Consultar o domínio:

```bash
dig @192.168.122.108 dominio.com.br
```

Consultar um host:

```bash
dig @192.168.122.108 gw.dominio.com.br
```

Consulta reversa:

```bash
dig -x 192.168.122.108 @192.168.122.108
```

Utilizando o nslookup:

```bash
nslookup gw.dominio.com.br 192.168.122.108
```

---

# Estrutura dos Arquivos

```text
/etc/hosts
/etc/resolv.conf
/etc/network/interfaces
/etc/bind/named.conf.options
/etc/bind/named.conf.local
/etc/bind/db.dominio.com.br
/etc/bind/db.192.168.122
```

---

# Observações

- O domínio deve ser declarado como **dominio.com.br** e não www.dominio.com.br
- O servidor Master é responsável pelas zonas.
- O servidor Slave recebe automaticamente as atualizações através de Zone Transfer.
- Sempre que alterar uma zona, aumente o valor do **Serial** antes de reiniciar o serviço.
- Utilize `named-checkconf` e `named-checkzone` antes de reiniciar o BIND para evitar erros de configuração.