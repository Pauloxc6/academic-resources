# Servidor DHCP (ISC DHCP Server)

Este guia apresenta a instalação e configuração de um servidor DHCP utilizando o **ISC DHCP Server** em distribuições Debian/Ubuntu.

---

# Topologia

```text
                    INTERNET
                        │
                 192.168.0.1 (Gateway)
                        │
                +-----------------+
                |   DHCP Server   |
                | 192.168.0.2     |
                +--------+--------+
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   Cliente 1        Cliente 2       Cliente N
192.168.0.10    192.168.0.11    192.168.0.30
```

---

# Ambiente

| Equipamento | Endereço |
|-------------|----------|
| Gateway | 192.168.0.1 |
| Servidor DHCP | 192.168.0.2 |
| Rede | 192.168.0.0/24 |
| Faixa DHCP | 192.168.0.10 - 192.168.0.30 |
| DNS | 8.8.8.8 / 1.1.1.1 |

---

# 1. Instalação

Atualize os repositórios:

```bash
sudo apt update
```

Instale o servidor DHCP:

```bash
sudo apt install isc-dhcp-server -y
```

---

# 2. Definir Interface

Edite:

```text
/etc/default/isc-dhcp-server
```

Localize:

```bash
INTERFACESv4=""
```

Altere para:

```bash
INTERFACESv4="enp1s0"
```

> Substitua `enp1s0` pela interface da sua máquina.

---

# 3. Configuração do DHCP

Edite:

```text
/etc/dhcp/dhcpd.conf
```

Exemplo:

```conf
# option domain-name "example.org";

option domain-name-servers 8.8.8.8, 1.1.1.1;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

subnet 192.168.0.0 netmask 255.255.255.0 {
    range 192.168.0.10 192.168.0.30
    option broadcast-address 192.168.0.255;
    option routers 192.168.0.1;
}
```

---

# 4. Reiniciar o Serviço

```bash
sudo systemctl restart isc-dhcp-server
```

Verifique o status:

```bash
sudo systemctl status isc-dhcp-server
```

---

# 5. Firewall

Caso utilize UFW:

```bash
sudo ufw allow 67/udp
sudo ufw reload
```

---

# 6. Verificando Logs

```bash
sudo journalctl -u isc-dhcp-server
```

ou

```bash
sudo tail -f /var/log/syslog
```

---

# 7. Testando

Renove o endereço IP do cliente.

Linux:

```bash
sudo dhclient -r
sudo dhclient
```

Windows:

```cmd
ipconfig /release
ipconfig /renew
```

Verifique o endereço obtido:

Linux:

```bash
ip addr
```

Windows:

```cmd
ipconfig
```

---

# Estrutura do Arquivo

```text
/etc/default/isc-dhcp-server
/etc/dhcp/dhcpd.conf
```

---

# Explicação da Configuração

| Diretiva | Função |
|----------|--------|
| option domain-name-servers | Servidores DNS entregues aos clientes |
| default-lease-time | Tempo padrão da concessão (segundos) |
| max-lease-time | Tempo máximo da concessão |
| ddns-update-style none | Desabilita atualização dinâmica do DNS |
| subnet | Rede atendida pelo DHCP |
| range | Intervalo de IPs distribuídos |
| option broadcast-address | Endereço de broadcast da rede |
| option routers | Gateway padrão entregue aos clientes |

---

# Comandos Úteis

Verificar sintaxe:

```bash
sudo dhcpd -t
```

Iniciar:

```bash
sudo systemctl start isc-dhcp-server
```

Parar:

```bash
sudo systemctl stop isc-dhcp-server
```

Reiniciar:

```bash
sudo systemctl restart isc-dhcp-server
```

Status:

```bash
sudo systemctl status isc-dhcp-server
```

Habilitar na inicialização:

```bash
sudo systemctl enable isc-dhcp-server
```

---

# Observações

- O servidor DHCP deve possuir um **IP estático**.
- Certifique-se de que não exista outro servidor DHCP ativo na mesma rede.
- O gateway informado em `option routers` deve ser válido e acessível pelos clientes.
- Caso utilize um servidor DNS interno, substitua os endereços públicos (`8.8.8.8` e `1.1.1.1`) pelo IP do seu servidor DNS.
- Sempre valide a configuração com `dhcpd -t` antes de reiniciar o serviço.
