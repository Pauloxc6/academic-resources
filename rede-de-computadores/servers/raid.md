# Configuração de RAID com mdadm

Este guia apresenta a criação de um **RAID por software** utilizando o **mdadm** em sistemas Linux, incluindo a criação do sistema de arquivos, montagem e configuração para montagem automática.

> **Observação:** Os exemplos utilizam **RAID 0 (Striping)** apenas para fins didáticos. Em ambientes de produção, escolha o nível de RAID de acordo com a necessidade de desempenho, redundância e capacidade.

---

# Topologia

```text
           +-------------+
           |   /dev/sdb  |
           +-------------+
                  │
                  │
                  ├──────────────┐
                  │              │
           +-------------+       │
           |   /dev/sdc  |       │
           +-------------+       │
                  │              │
                  └──────┬───────┘
                         │
                  RAID 0 (mdadm)
                         │
                    /dev/md0
                         │
                  Sistema Btrfs
                         │
                    /mnt/md0
```

---

# Pré-requisitos

Verifique os discos disponíveis:

```bash
lsblk
```

ou

```bash
sudo fdisk -l
```

> **Importante:** Todos os dados existentes nos discos utilizados serão apagados.

---

# 1. Instalação

Atualize os repositórios:

```bash
sudo apt update && sudo apt upgrade -y
```

Instale o `mdadm`:

```bash
sudo apt install mdadm -y
```

Verifique a versão:

```bash
mdadm --version
```

---

# 2. Criando o RAID

Crie o array RAID 0 utilizando dois discos.

```bash
sudo mdadm --create \
--verbose \
/dev/md0 \
--level=0 \
--raid-devices=2 \
/dev/sdb /dev/sdc
```

Acompanhe a criação:

```bash
cat /proc/mdstat
```

Detalhes do array:

```bash
sudo mdadm --detail /dev/md0
```

---

# 3. Criando o Sistema de Arquivos

Neste exemplo será utilizado **Btrfs**.

```bash
sudo mkfs.btrfs /dev/md0
```

Também é possível utilizar outros sistemas de arquivos, como:

```bash
sudo mkfs.ext4 /dev/md0
```

ou

```bash
sudo mkfs.xfs /dev/md0
```

---

# 4. Criando o Ponto de Montagem

```bash
sudo mkdir -p /mnt/md0
```

Monte o RAID:

```bash
sudo mount /dev/md0 /mnt/md0
```

Verifique:

```bash
df -h
```

---

# 5. Salvando a Configuração do mdadm

Gere automaticamente a configuração do RAID:

```bash
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
```

Visualize o arquivo:

```bash
cat /etc/mdadm/mdadm.conf
```

---

# 6. Atualizando o initramfs

Atualize o initramfs para que o RAID seja montado durante a inicialização:

```bash
sudo update-initramfs -u
```

---

# 7. Configurando a Montagem Automática

Edite:

```text
/etc/fstab
```

Adicione:

```fstab
/dev/md0    /mnt/md0    btrfs    defaults,nofail,discard    0 0
```

Teste a configuração:

```bash
sudo mount -a
```

---

# Verificando o RAID

Status:

```bash
cat /proc/mdstat
```

Detalhes:

```bash
sudo mdadm --detail /dev/md0
```

Verificar montagem:

```bash
mount | grep md0
```

Espaço disponível:

```bash
df -h
```

---

# Comandos Úteis

Listar arrays:

```bash
cat /proc/mdstat
```

Detalhes do RAID:

```bash
sudo mdadm --detail /dev/md0
```

Parar o RAID:

```bash
sudo mdadm --stop /dev/md0
```

Remover o RAID:

```bash
sudo mdadm --remove /dev/md0
```

Zerar superblocos dos discos:

```bash
sudo mdadm --zero-superblock /dev/sdb
sudo mdadm --zero-superblock /dev/sdc
```

---

# Níveis de RAID

| Nível | Descrição | Redundância | Desempenho |
|--------|-----------|-------------|-------------|
| RAID 0 | Striping | ❌ Não | ⭐⭐⭐⭐⭐ |
| RAID 1 | Espelhamento | ✅ Sim | ⭐⭐⭐ |
| RAID 5 | Paridade Distribuída | ✅ Sim | ⭐⭐⭐⭐ |
| RAID 6 | Dupla Paridade | ✅ Sim | ⭐⭐⭐ |
| RAID 10 | Espelhamento + Striping | ✅ Sim | ⭐⭐⭐⭐⭐ |

---

# Estrutura dos Arquivos

```text
/etc/mdadm/mdadm.conf
/etc/fstab
```

---

# Observações

- **RAID 0** oferece ganho de desempenho, mas **não possui redundância**. A falha de qualquer disco resulta na perda de todos os dados do array.
- Antes de criar o RAID, certifique-se de que os discos não contenham partições ou dados importantes.
- Utilize `cat /proc/mdstat` para acompanhar a sincronização e o estado do array.
- Sempre atualize o `initramfs` após criar ou modificar um array RAID para garantir que ele seja reconhecido durante a inicialização.
- Para maior confiabilidade em ambientes de produção, considere utilizar **RAID 1**, **RAID 5**, **RAID 6** ou **RAID 10**, conforme os requisitos de disponibilidade e desempenho.