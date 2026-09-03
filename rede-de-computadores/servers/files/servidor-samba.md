# Homelab - openSUSE Leap + Samba + Nextcloud + ZFS

## Objetivo

Montar um servidor doméstico silencioso, estável e eficiente para:

- Compartilhamento de arquivos
- Acesso remoto via Tailscale
- Nextcloud
- Docker
- Armazenamento centralizado
- Backups e snapshots
- Ambiente de estudos de infraestrutura Linux

---

# Hardware Planejado

## Notebook servidor

### Configuração base

- CPU: Intel Core i3-1115G4
- RAM: 16GB DDR4
- Storage principal: SSD/NVMe
- Rede: Ethernet preferencial
- Sistema operacional: openSUSE Leap

---

# Motivos da Escolha

## Vantagens do notebook

- Silencioso
- Baixo consumo elétrico
- Bateria funciona como mini nobreak
- Pouco calor
- Hardware moderno
- Excelente desempenho por watt

---

# Sistema Operacional

## openSUSE Leap

### Motivos

- Estabilidade
- Btrfs integrado
- Snapper
- Firewalld integrado
- YaST
- Excelente suporte a Samba
- Excelente suporte a Docker

---

# Arquitetura de Storage

## Separação do sistema e dados

```text
Sistema       -> Btrfs
Armazenamento -> ZFS
```

---

# Layout de Disco

## SSD/NVMe

Usado para:

- Sistema operacional
- Docker
- PostgreSQL
- Redis
- Containers
- Cache

---

## ZFS

Usado para:

- Arquivos Samba
- Dados do Nextcloud
- Backups
- Snapshots
- Compartilhamento de arquivos

---

# Estrutura de Diretórios

```text
/tank
├── clientes/
│   ├── maria/
│   ├── joao/
│   └── public/
├── nextcloud/
├── backups/
└── media/
```

---

# ZFS

## Criar pool

```bash
sudo zpool create tank /dev/sdb
```

---

## Ativar compressão

```bash
sudo zfs set compression=lz4 tank
```

---

## Criar datasets

```bash
sudo zfs create tank/clientes
sudo zfs create tank/public
sudo zfs create tank/nextcloud
sudo zfs create tank/backups
```

---

# Quotas por Usuário

## Exemplo

```bash
sudo zfs create tank/clientes/maria
sudo zfs set quota=20G tank/clientes/maria
```

```bash
sudo zfs create tank/clientes/joao
sudo zfs set quota=50G tank/clientes/joao
```

---

# Snapshots ZFS

## Criar snapshot

```bash
sudo zfs snapshot tank/clientes/maria@backup-2026
```

---

## Listar snapshots

```bash
sudo zfs list -t snapshot
```

---

# Usuários e Grupos

## Criar grupo Samba

```shell
sudo groupadd clientes
```

---

## Criar usuários Linux

### Exemplo

```shell
sudo useradd -M -s /sbin/nologin -G clientes maria
sudo useradd -M -s /sbin/nologin -G clientes joao
```

---

## Definir senha Linux

```shell
sudo passwd maria
sudo passwd joao
```

---

## Adicionar usuários no Samba

```
sudo smbpasswd -a maria
sudo smbpasswd -a joao
```

---

## Ativar usuários Samba

```shell
sudo smbpasswd -e maria
sudo smbpasswd -e joao
```

---

## Criar diretórios dos usuários

```shell
sudo mkdir -p /tank/clientes/maria
sudo mkdir -p /tank/clientes/joao
```

---

## Ownership

```shell
sudo chown maria:clientes /tank/clientes/maria
sudo chown joao:clientes /tank/clientes/joao
```

---

## Permissões

```shell
sudo chmod 770 /tank/clientes/maria
sudo chmod 770 /tank/clientes/joao
```

---

## Verificar usuários Samba

```shell
sudo pdbedit -L
```

---

## Verificar grupos

```shell
groups maria
```

---

# Samba

## Objetivo

- Compartilhamento SMB
- Compartilhamento LAN
- Compartilhamento via Tailscale
- Integração futura com Nextcloud

---
# Samba

## Objetivo

- Compartilhamento SMB
- Compartilhamento LAN
- Compartilhamento via Tailscale
- Integração futura com Nextcloud

---

# Configuração Global Samba

```ini
[global]
    workgroup = HOMELAB
    server string = Servidor de Arquivos
    netbios name = s1

    security = user
    map to guest = Bad User

    passdb backend = tdbsam

    server min protocol = SMB3
    smb encrypt = required

    smb3 unix extensions = yes

    usershare allow guests = yes
```

---

# Share Público

```ini
[public]
    comment = Diretorio Publico
    path = /tank/public

    browseable = yes
    read only = no

    guest ok = yes
    guest only = yes

    force user = nobody
    force group = nobody

    hosts allow = 192.168.0.0/16 100.64.0.0/10

    create mask = 0666
    directory mask = 1777

    veto files = /*.exe/

    smb encrypt = required
```

---

# Share Privado

```ini
[clientes]
    comment = Diretorio Clientes
    path = /tank/clientes

    browseable = yes
    read only = no

    guest ok = no

    valid users = @clientes
    force group = clientes

    inherit acls = yes

    create mask = 0660
    directory mask = 0770

    veto files = *.exe

    smb encrypt = required
```

---

# Permissões Linux

## Exemplo

```bash
sudo chown maria:clientes /tank/clientes/maria
sudo chmod 770 /tank/clientes/maria
```

---

# Firewall

## Liberar Samba

```bash
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload
```

---

# Verificações Samba

## Ver conexões

```bash
sudo smbstatus
```

---

## Ver portas

```bash
sudo ss -tupan | grep 445
```

---

## Validar configuração

```bash
testparm
```

---

# rpcclient

## Informações do servidor

```bash
rpcclient -U maria localhost -c "srvinfo"
```

---

## Ver shares

```bash
rpcclient -U maria localhost -c "netshareenum"
```

---

# Tailscale

## Objetivo

- Acesso remoto seguro
- Evitar exposição pública
- Evitar port forwarding
- WireGuard integrado

---

# Instalação Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

---

## Login

```bash
sudo tailscale up
```

---

# Rede Tailscale

## Range

```text
100.64.0.0/10
```

---

# Nextcloud

## Objetivo

- Interface web
- Sincronização
- Acesso remoto
- Compartilhamento de arquivos

---

# Arquitetura

```text
Usuário
   │
   ▼
Tailscale
   │
   ▼
Nextcloud
   │ SMB
   ▼
Samba
   │
   ▼
ZFS
```

---

# Docker

## Containers planejados

- Nextcloud
- PostgreSQL
- Redis
- Nginx Proxy Manager
- Jellyfin
- Vaultwarden

---

# Docker Compose Base

```yaml
services:
  nextcloud:
    image: nextcloud
    restart: unless-stopped

  postgres:
    image: postgres
    restart: unless-stopped

  redis:
    image: redis
    restart: unless-stopped
```

---

# Redis

## Função

- File locking
- Cache
- Sessões

---

# PostgreSQL

## Motivo

Melhor escalabilidade e estabilidade para Nextcloud.

---

# SELinux

## Verificar status

```bash
getenforce
```

---

## Ver status completo

```bash
sestatus
```

---

## Contextos Samba

Verificar contexto:

```bash
ls -Zd /tank/clientes
```

Contexto esperado:

```text
samba_share_t
```

---

## Configurar contexto permanente

```bash
sudo semanage fcontext -a -t samba_share_t "/tank/clientes(/.*)?"
sudo restorecon -Rv /tank/clientes
```

---

## Compartilhamento leitura/escrita

```bash
sudo setsebool -P samba_export_all_rw on
```

---

## Compartilhamento home

```bash
sudo setsebool -P samba_enable_home_dirs on
```

---

## Ver booleans Samba

```bash
getsebool -a | grep samba
```

---

## Logs SELinux

```bash
sudo ausearch -m AVC -ts recent
```

---

## Recomendação

Manter SELinux em:

```text
Enforcing
```

Evitar desabilitar SELinux sem necessidade.

---

# Segurança

## SMB

- SMB3 obrigatório
- Criptografia obrigatória
- Signing ativo

---

## Rede

- Tailscale
- Sem SMB exposto na internet
- Sem portas públicas SMB

---

## Firewall

Liberar apenas:

- Samba
- SSH
- Tailscale

---

# Snapper

## Listar snapshots

```bash
snapper list
```

---

## Restaurar snapshot

```bash
sudo snapper rollback
```

---

# Recomendações

## Fazer

- Usar Ethernet
- Fazer backups externos
- Monitorar temperatura
- Limitar carga da bateria
- Usar snapshots
- Atualizar sistema regularmente

---

## Evitar

- SMB exposto diretamente na internet
- Servidores rack 1U no quarto
- Docker rodando tudo como root
- SQLite para muitos usuários
- Wi-Fi como rede principal do servidor


---

# Expansões Futuras

## Possíveis melhorias

- RAID/ZFS mirror
- SSD dedicado para banco
- UPS real
- Reverse proxy
- SSO
- LDAP
- Grafana
- Prometheus
- Immich
- AdGuard Home

---

# Stack Final Planejada

```text
openSUSE Leap
├── Btrfs
├── Snapper
├── Docker
├── Samba
├── Tailscale
├── ZFS
├── Nextcloud
├── PostgreSQL
├── Redis
└── Backups
```

---

# Objetivo Final

Criar uma infraestrutura doméstica:

- silenciosa
- eficiente
- segura
- estável
- modular
- escalável
- ideal para estudos e uso pessoal