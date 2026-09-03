# Servidor RADIUS (FreeRADIUS)

Este guia apresenta a instalação e configuração básica de um **Servidor RADIUS** utilizando o **FreeRADIUS**, amplamente utilizado para autenticação centralizada em redes Wi-Fi, VPNs, switches, roteadores e dispositivos de rede.

> **Observação:** O protocolo **RADIUS (Remote Authentication Dial-In User Service)** fornece serviços de **Autenticação (Authentication)**, **Autorização (Authorization)** e **Contabilização (Accounting)**, conhecidos como **AAA**.

---

# Topologia

```text
                     Clientes
                         │
                  Wi-Fi / VPN / Switch
                         │
                  NAS (Network Access Server)
                         │
                  UDP 1812 / 1813
                         │
        +--------------------------------+
        |       FreeRADIUS Server        |
        |      192.168.122.100           |
        +--------------------------------+
```

---

# Funcionamento

```text
Cliente
    │
    │ Login
    ▼
Access Point / Switch / VPN
    │
    │ Access-Request
    ▼
FreeRADIUS
    │
    ├── Verifica usuário
    ├── Verifica senha
    └── Retorna resposta
            │
            ├── Access-Accept
            ├── Access-Reject
            └── Access-Challenge
```

---

# Instalação

## Debian / Ubuntu

Atualize o sistema:

```bash
sudo apt update
```

Instale o FreeRADIUS:

```bash
sudo apt install freeradius freeradius-utils -y
```

---

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install freeradius freeradius-utils -y
```

---

# Verificando o Serviço

Inicie o serviço:

```bash
sudo systemctl enable --now freeradius
```

Em algumas distribuições:

```bash
sudo systemctl enable --now radiusd
```

Verifique:

```bash
sudo systemctl status freeradius
```

---

# Arquivos de Configuração

```text
/etc/freeradius/3.0/
```

Os principais arquivos são:

```text
clients.conf
mods-config/files/authorize
radiusd.conf
sites-enabled/default
```

---

# Configurando um Cliente RADIUS

Edite:

```bash
sudo nano /etc/freeradius/3.0/clients.conf
```

Adicione:

```conf
client switch01 {
    ipaddr = 192.168.122.10
    secret = senhaSegura123
    shortname = switch01
}
```

Onde:

- **ipaddr** → IP do equipamento que utilizará o RADIUS.
- **secret** → Chave compartilhada.
- **shortname** → Nome do cliente.

---

# Criando um Usuário

Edite:

```bash
sudo nano /etc/freeradius/3.0/mods-config/files/authorize
```

Adicione:

```text
paulo Cleartext-Password := "123456"

    Reply-Message := "Bem-vindo!"
```

---

# Reiniciando o Serviço

```bash
sudo systemctl restart freeradius
```

---

# Testando Localmente

Utilize o utilitário `radtest`:

```bash
radtest paulo 123456 localhost 1812 testing123
```

Exemplo de resposta:

```text
Received Access-Accept
```

---

# Executando em Modo Debug

Muito útil durante a configuração.

Pare o serviço:

```bash
sudo systemctl stop freeradius
```

Execute:

```bash
sudo freeradius -X
```

ou

```bash
sudo radiusd -X
```

Todo o processo de autenticação será exibido em tempo real.

---

# Firewall

### UFW

```bash
sudo ufw allow 1812/udp
sudo ufw allow 1813/udp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-port=1812/udp
sudo firewall-cmd --permanent --add-port=1813/udp
sudo firewall-cmd --reload
```

---

# Portas Utilizadas

| Porta | Protocolo | Serviço |
|--------|-----------|----------|
| 1812 | UDP | Autenticação |
| 1813 | UDP | Accounting |
| 3799 | UDP | CoA (Change of Authorization) *(opcional)* |

---

# Estrutura de Arquivos

```text
/etc/freeradius/

├── clients.conf
├── radiusd.conf
├── mods-enabled/
├── mods-config/
│   └── files/
│       └── authorize
├── sites-enabled/
└── certs/
```

---

# Comandos Úteis

Verificar configuração:

```bash
sudo freeradius -CX
```

Executar em debug:

```bash
sudo freeradius -X
```

Reiniciar:

```bash
sudo systemctl restart freeradius
```

Status:

```bash
sudo systemctl status freeradius
```

Logs:

```bash
sudo journalctl -u freeradius
```

---

# Integração com LDAP (Opcional)

O FreeRADIUS pode autenticar usuários diretamente em um servidor LDAP.

Instale o módulo LDAP:

```bash
sudo apt install freeradius-ldap
```

Configure:

```text
/etc/freeradius/3.0/mods-available/ldap
```

Depois habilite:

```bash
sudo ln -s \
/etc/freeradius/3.0/mods-available/ldap \
/etc/freeradius/3.0/mods-enabled/
```

---

# Integração com MariaDB/MySQL (Opcional)

Instale:

```bash
sudo apt install freeradius-mysql
```

Configure:

```text
/etc/freeradius/3.0/mods-available/sql
```

Habilite:

```bash
sudo ln -s \
/etc/freeradius/3.0/mods-available/sql \
/etc/freeradius/3.0/mods-enabled/
```

---

# Casos de Uso

- Autenticação Wi-Fi (WPA2/WPA3 Enterprise)
- VPN (OpenVPN, IPsec, WireGuard via plugins)
- Switches gerenciáveis
- Controladoras Wi-Fi
- Hotspots
- PPPoE
- Redes corporativas
- Integração com Active Directory e LDAP

---

# Observações

- O FreeRADIUS é uma das implementações RADIUS mais utilizadas no mundo e suporta autenticação local, LDAP, Active Directory, bancos de dados SQL e diversos outros backends.
- Para ambientes de produção, utilize senhas fortes para os clientes RADIUS (`secret`) e restrinja o acesso apenas aos dispositivos autorizados.
- O modo de depuração (`freeradius -X`) é a principal ferramenta para diagnosticar problemas de autenticação.
- Caso utilize autenticação 802.1X (WPA2/WPA3 Enterprise), será necessário configurar certificados digitais para métodos EAP como PEAP ou EAP-TLS.
- Recomenda-se manter sincronização de horário via NTP em todos os dispositivos que utilizam RADIUS para evitar problemas com certificados e registros de autenticação.