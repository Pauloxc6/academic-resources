# Servidor SFTP (OpenSSH)

Este guia apresenta a instalação e configuração de um **Servidor SFTP** utilizando o **OpenSSH**, permitindo a transferência segura de arquivos através do protocolo SSH.

> **Observação:** O **SFTP (SSH File Transfer Protocol)** é diferente do FTP e do FTPS. O SFTP utiliza o protocolo SSH (porta 22) e toda a comunicação é criptografada.

---

# Topologia

```text
              Clientes SFTP
                    │
                Porta TCP 22
                    │
         +-------------------------+
         |      OpenSSH Server     |
         |     192.168.122.100     |
         +-------------------------+
                    │
             /srv/sftp/usuario
```

---

# Instalação

## Debian / Ubuntu

```bash
sudo apt update
sudo apt install openssh-server -y
```

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install openssh-server -y
```

---

# Verificando o Serviço

Inicie e habilite o serviço:

```bash
sudo systemctl enable --now ssh
```

Em algumas distribuições o serviço chama-se:

```bash
sudo systemctl enable --now sshd
```

Verifique o status:

```bash
sudo systemctl status ssh
```

ou

```bash
sudo systemctl status sshd
```

---

# Criando um Grupo SFTP

```bash
sudo groupadd sftpusers
```

---

# Criando um Usuário

```bash
sudo useradd \
-g sftpusers \
-d /upload \
-s /usr/sbin/nologin \
usuario
```

Defina uma senha:

```bash
sudo passwd usuario
```

---

# Criando os Diretórios

Crie o diretório principal:

```bash
sudo mkdir -p /srv/sftp/usuario/upload
```

---

# Ajustando as Permissões

O diretório raiz do usuário deve pertencer ao **root**.

```bash
sudo chown root:root /srv/sftp/usuario
sudo chmod 755 /srv/sftp/usuario
```

O diretório de upload pertence ao usuário:

```bash
sudo chown usuario:sftpusers /srv/sftp/usuario/upload
sudo chmod 755 /srv/sftp/usuario/upload
```

Estrutura final:

```text
/srv/sftp/
└── usuario/
    └── upload/
```

---

# Configurando o OpenSSH

Edite:

```bash
sudo nano /etc/ssh/sshd_config
```

Adicione ao final do arquivo:

```conf
Subsystem sftp internal-sftp

Match Group sftpusers

    ChrootDirectory /srv/sftp/%u

    ForceCommand internal-sftp

    X11Forwarding no

    AllowTcpForwarding no
```

---

# Reiniciando o Serviço

```bash
sudo systemctl restart ssh
```

ou

```bash
sudo systemctl restart sshd
```

---

# Firewall

### UFW

```bash
sudo ufw allow 22/tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

---

# Testando a Conexão

Utilizando o cliente OpenSSH:

```bash
sftp usuario@192.168.122.100
```

Exemplo:

```text
Connected to 192.168.122.100
sftp>
```

Enviar arquivo:

```text
put arquivo.txt
```

Listar arquivos:

```text
ls
```

Baixar arquivo:

```text
get arquivo.txt
```

Sair:

```text
exit
```

---

# Utilizando o FileZilla

Configure:

| Campo | Valor |
|--------|--------|
| Protocolo | SFTP |
| Host | 192.168.122.100 |
| Porta | 22 |
| Usuário | usuario |
| Senha | ******** |

---

# Comandos Úteis

Verificar conexões:

```bash
ss -tlnp | grep :22
```

Logs:

```bash
sudo journalctl -u ssh
```

ou

```bash
sudo journalctl -u sshd
```

Monitorar logs:

```bash
sudo tail -f /var/log/auth.log
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start ssh
```

Parar:

```bash
sudo systemctl stop ssh
```

Reiniciar:

```bash
sudo systemctl restart ssh
```

Status:

```bash
sudo systemctl status ssh
```

Habilitar na inicialização:

```bash
sudo systemctl enable ssh
```

---

# Arquivos Importantes

```text
/etc/ssh/sshd_config

/srv/sftp/

/var/log/auth.log
```

---

# Observações

- O **SFTP** utiliza o protocolo SSH e não requer um servidor FTP dedicado.
- O diretório definido em `ChrootDirectory` **deve pertencer ao usuário root** e não pode ser gravável pelo usuário SFTP; caso contrário, a autenticação falhará.
- Os usuários podem gravar arquivos apenas no subdiretório (`upload` neste exemplo).
- Para maior segurança, recomenda-se utilizar autenticação por chave pública (SSH Keys) em vez de senhas.
- O parâmetro `ForceCommand internal-sftp` impede que o usuário obtenha acesso ao shell do sistema, restringindo-o apenas ao serviço SFTP.