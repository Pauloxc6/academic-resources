# Servidor NTP (Network Time Protocol)

Este guia apresenta a instalação e configuração de um **Servidor NTP** utilizando o **Chrony**, recomendado para sincronização de horário em sistemas Linux.

> **Observação:** O **Chrony** é atualmente a implementação padrão de NTP na maioria das distribuições Linux modernas, substituindo o `ntpd` em muitos casos.

---

# Topologia

```text
                    Internet
                         │
                Servidores NTP Públicos
                         │
                +--------------------+
                |   Servidor Chrony  |
                | 192.168.122.100    |
                +----------+---------+
                           │
             UDP Porta 123 │
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
+--------------+   +--------------+   +--------------+
| Cliente Linux|   | Cliente Win  |   | Servidor     |
+--------------+   +--------------+   +--------------+
```

---

# Instalação

## Debian / Ubuntu

```bash
sudo apt update
sudo apt install chrony -y
```

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install chrony -y
```

---

# Verificando o Serviço

Inicie e habilite o serviço:

```bash
sudo systemctl enable --now chrony
```

Em algumas distribuições:

```bash
sudo systemctl enable --now chronyd
```

Verifique o status:

```bash
sudo systemctl status chrony
```

ou

```bash
sudo systemctl status chronyd
```

---

# Configuração do Servidor

Edite:

```bash
sudo nano /etc/chrony/chrony.conf
```

Em sistemas Red Hat:

```bash
sudo nano /etc/chrony.conf
```

---

## Servidores Públicos

Exemplo:

```conf
pool pool.ntp.org iburst
pool time.google.com iburst
pool time.cloudflare.com iburst
```

---

## Permitindo Clientes da Rede

```conf
allow 192.168.122.0/24
```

Permitir toda a rede:

```conf
allow
```

---

## Arquivo de Drift

```conf
driftfile /var/lib/chrony/drift
```

---

## Registrar Logs

```conf
logdir /var/log/chrony
```

---

# Reiniciando o Serviço

```bash
sudo systemctl restart chrony
```

ou

```bash
sudo systemctl restart chronyd
```

---

# Firewall

### UFW

```bash
sudo ufw allow 123/udp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

---

# Configurando um Cliente Linux

Instale o Chrony:

```bash
sudo apt install chrony -y
```

Edite:

```bash
sudo nano /etc/chrony/chrony.conf
```

Comente os pools públicos:

```conf
#pool pool.ntp.org iburst
```

Adicione o servidor local:

```conf
server 192.168.122.100 iburst
```

Reinicie:

```bash
sudo systemctl restart chrony
```

---

# Verificando a Sincronização

Mostrar as fontes:

```bash
chronyc sources
```

Mostrar estatísticas:

```bash
chronyc tracking
```

Verificar servidores:

```bash
chronyc sourcestats
```

---

# Testando o Servidor

No servidor:

```bash
chronyc tracking
```

No cliente:

```bash
chronyc sources
```

Verifique se o servidor aparece como origem do horário.

---

# Configuração para Windows

Abra um Prompt de Comando como administrador:

```cmd
w32tm /config /manualpeerlist:192.168.122.100 /syncfromflags:manual /update
```

Reinicie o serviço:

```cmd
net stop w32time
net start w32time
```

Forçar sincronização:

```cmd
w32tm /resync
```

---

# Comandos Úteis

Mostrar fontes:

```bash
chronyc sources
```

Mostrar rastreamento:

```bash
chronyc tracking
```

Mostrar estatísticas:

```bash
chronyc sourcestats
```

Forçar sincronização:

```bash
sudo chronyc makestep
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start chrony
```

Parar:

```bash
sudo systemctl stop chrony
```

Reiniciar:

```bash
sudo systemctl restart chrony
```

Status:

```bash
sudo systemctl status chrony
```

Habilitar na inicialização:

```bash
sudo systemctl enable chrony
```

---

# Logs

Visualizar logs:

```bash
sudo journalctl -u chrony
```

Monitorar em tempo real:

```bash
sudo journalctl -fu chrony
```

---

# Arquivos Importantes

```text
Debian/Ubuntu:
/etc/chrony/chrony.conf

Rocky/Fedora:
/etc/chrony.conf
/var/lib/chrony/
/var/log/chrony/
```

---

# Observações

- O protocolo **NTP** utiliza a **porta UDP 123**.
- O Chrony é mais eficiente que o `ntpd` em ambientes com máquinas virtuais, notebooks e sistemas que nem sempre permanecem conectados.
- Em ambientes corporativos, recomenda-se que apenas um servidor sincronize com servidores NTP públicos, enquanto os demais clientes utilizem esse servidor interno como referência.
- Mantenha o fuso horário configurado corretamente utilizando `timedatectl`, pois o NTP sincroniza apenas a data e a hora (UTC), não o fuso horário.
- Para verificar o estado geral do relógio do sistema, utilize:

```bash
timedatectl status
```