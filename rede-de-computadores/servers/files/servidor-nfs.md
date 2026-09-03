# Servidor NFS (Network File System)

Este guia apresenta a instalação e configuração de um servidor **NFS**, permitindo o compartilhamento de diretórios entre sistemas Linux.

---

# Topologia

```text
                Rede 192.168.122.0/24

        +-----------------------------+
        |         NFS Server          |
        |      192.168.122.198        |
        |        /mnt/nfs             |
        +-------------+---------------+
                      │
      ┌───────────────┼────────────────┐
      │               │                │
+-------------+ +-------------+ +-------------+
| Cliente 01  | | Cliente 02  | | Cliente 03  |
+-------------+ +-------------+ +-------------+
```

---

# Ambiente

| Equipamento | Endereço |
|-------------|----------|
| Servidor NFS | 192.168.122.198 |
| Rede | 192.168.122.0/24 |
| Compartilhamento | /mnt/nfs |

---

# Servidor

## 1. Instalação

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install nfs-kernel-server -y
```

### Fedora / Rocky / AlmaLinux / CentOS

```bash
sudo dnf install nfs-utils -y
```

---

## 2. Habilitando o Serviço

```bash
sudo systemctl enable --now nfs-server.service
```

Verifique o status:

```bash
sudo systemctl status nfs-server.service
```

---

## 3. Criando o Diretório Compartilhado

```bash
sudo mkdir -p /mnt/nfs
```

Defina as permissões conforme necessário:

```bash
sudo chmod 755 /mnt/nfs
```

---

## 4. Configurando os Compartilhamentos

Edite:

```text
/etc/exports
```

```bash
sudo nano /etc/exports
```

Adicione:

```text
/mnt/nfs    192.168.122.0/24(rw,sync,no_subtree_check)
```

### Explicação das Opções

| Opção | Descrição |
|--------|-----------|
| rw | Permite leitura e escrita |
| ro | Somente leitura |
| sync | Grava os dados antes de responder ao cliente |
| async | Responde antes da gravação (mais rápido, porém menos seguro) |
| no_subtree_check | Desabilita verificação de subdiretórios |
| subtree_check | Habilita verificação de subdiretórios |

---

## 5. Aplicando a Configuração

```bash
sudo exportfs -avr
```

Visualizar compartilhamentos:

```bash
sudo exportfs -v
```

---

# Cliente

## 1. Instalação

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install nfs-common -y
```

### Fedora / Rocky / AlmaLinux / CentOS

```bash
sudo dnf install nfs-utils -y
```

---

## 2. Criando o Ponto de Montagem

```bash
sudo mkdir -p /mnt/nfs
```

---

## 3. Montando o Compartilhamento

```bash
sudo mount -t nfs 192.168.122.198:/mnt/nfs /mnt/nfs
```

Verifique:

```bash
df -h
```

ou

```bash
mount | grep nfs
```

---

## 4. Desmontando

```bash
sudo umount /mnt/nfs
```

---

# Montagem Automática (fstab)

Edite:

```text
/etc/fstab
```

Adicione:

```fstab
192.168.122.198:/mnt/nfs    /mnt/nfs    nfs    defaults,user,exec    0 0
```

Teste sem reiniciar:

```bash
sudo mount -a
```

---

# Testes

No servidor:

```bash
touch /mnt/nfs/teste.txt
```

No cliente:

```bash
ls -l /mnt/nfs
```

Criando um arquivo:

```bash
touch /mnt/nfs/arquivo_cliente.txt
```

---

# Comandos Úteis

Listar compartilhamentos do servidor:

```bash
showmount -e 192.168.122.198
```

Listar compartilhamentos locais:

```bash
sudo exportfs -v
```

Recarregar exportações:

```bash
sudo exportfs -avr
```

Montar:

```bash
sudo mount -t nfs 192.168.122.198:/mnt/nfs /mnt/nfs
```

Desmontar:

```bash
sudo umount /mnt/nfs
```

Verificar montagens:

```bash
mount | grep nfs
```

---

# Firewall

### Ubuntu (UFW)

```bash
sudo ufw allow from 192.168.122.0/24 to any port 2049 proto tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --reload
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start nfs-server.service
```

Parar:

```bash
sudo systemctl stop nfs-server.service
```

Reiniciar:

```bash
sudo systemctl restart nfs-server.service
```

Status:

```bash
sudo systemctl status nfs-server.service
```

---

# Arquivos Importantes

```text
/etc/exports
/etc/fstab
```

---

# Observações

- O servidor e os clientes devem possuir conectividade de rede entre si.
- Utilize `exportfs -avr` sempre que alterar o arquivo `/etc/exports`.
- Para ambientes de produção, restrinja os compartilhamentos apenas às redes ou hosts autorizados.
- Caso utilize firewall, certifique-se de liberar a porta **2049/TCP**, utilizada pelo NFS.
- Para aumentar a segurança, considere utilizar autenticação baseada em Kerberos (NFSv4 + Kerberos) em ambientes corporativos.