
# Servidor FTP com VSFTPD

Este guia apresenta a instalação e configuração de um servidor **FTP** utilizando o **VSFTPD**, criando um ambiente de testes com usuários locais e acesso restrito ao diretório pessoal (chroot).

---

# Topologia

```text
            Clientes FTP
          192.168.4.0/24
                 │
                 │
          Portas 20, 21
                 │
      +-----------------------+
      |    Servidor VSFTPD    |
      |    192.168.4.106      |
      +-----------------------+
```

---

# Ambiente

| Equipamento | Endereço |
|-------------|----------|
| Servidor FTP | 192.168.4.106 |
| Rede | 192.168.4.0/24 |
| Usuário FTP | ftpuser |
| Grupo | ftpusers |

---

# 1. Instalação

Atualize os repositórios:

```bash
sudo apt update
```

Instale o VSFTPD:

```bash
sudo apt install vsftpd -y
```

Habilite o serviço:

```bash
sudo systemctl enable vsftpd
```

Inicie o serviço:

```bash
sudo systemctl start vsftpd
```

Verifique o status:

```bash
sudo systemctl status vsftpd
```

---

# 2. Criando o Ambiente de Teste

Crie um grupo para usuários FTP:

```bash
sudo groupadd ftpusers
```

Crie o usuário:

```bash
sudo useradd -g ftpusers ftpuser
```

Defina a senha:

```bash
sudo passwd ftpuser
```

---

# 3. Criando o Diretório do Usuário

Acesse o diretório `/home`:

```bash
cd /home
```

Crie a pasta do usuário:

```bash
sudo mkdir ftpuser
```

Defina o proprietário:

```bash
sudo chown ftpuser:ftpusers ftpuser
```

Remova permissão de escrita da raiz do diretório (necessário para o chroot do VSFTPD):

```bash
sudo chmod a-w ftpuser
```

Crie a pasta onde o usuário poderá gravar arquivos:

```bash
sudo mkdir /home/ftpuser/ftp
```

Defina as permissões:

```bash
sudo chown ftpuser:ftpusers /home/ftpuser/ftp
```

---

# 4. Configuração do VSFTPD

Edite o arquivo:

```text
/etc/vsftpd.conf
```

```bash
sudo nano /etc/vsftpd.conf
```

Adicione ou altere as seguintes opções:

```conf
anonymous_enable=NO
local_enable=YES
chroot_local_user=YES
pasv_enable=YES
user_sub_token=$USER
local_root=/home/$USER/ftp
```

### Explicação

| Diretiva | Função |
|----------|--------|
| anonymous_enable=NO | Desabilita login anônimo |
| local_enable=YES | Permite login de usuários locais |
| chroot_local_user=YES | Restringe o usuário ao próprio diretório |
| pasv_enable=YES | Habilita modo passivo |
| user_sub_token | Utiliza o nome do usuário automaticamente |
| local_root | Diretório inicial após login |

---

# 5. Reiniciando o Serviço

```bash
sudo systemctl restart vsftpd
```

Verifique o status:

```bash
sudo systemctl status vsftpd
```

---

# 6. Configurando o Firewall

Permita acesso FTP apenas para a rede local.

Porta de dados:

```bash
sudo ufw allow proto tcp from 192.168.4.0/24 to 192.168.4.106 port 20
```

Porta de controle:

```bash
sudo ufw allow proto tcp from 192.168.4.0/24 to 192.168.4.106 port 21
```

SSH (opcional):

```bash
sudo ufw allow proto tcp from 192.168.4.0/24 to 192.168.4.106 port 22
```

Recarregue o firewall:

```bash
sudo ufw reload
```

---

# 7. Testando

Conecte utilizando o cliente FTP:

```bash
ftp 192.168.4.106
```

Ou utilizando o lftp:

```bash
lftp ftpuser@192.168.4.106
```

Exemplo:

```text
Username: ftpuser
Password: ********
```

---

# Comandos Úteis

Iniciar:

```bash
sudo systemctl start vsftpd
```

Parar:

```bash
sudo systemctl stop vsftpd
```

Reiniciar:

```bash
sudo systemctl restart vsftpd
```

Status:

```bash
sudo systemctl status vsftpd
```

Habilitar na inicialização:

```bash
sudo systemctl enable vsftpd
```

Logs:

```bash
sudo journalctl -u vsftpd
```

Monitorar logs:

```bash
sudo journalctl -fu vsftpd
```

---

# Estrutura dos Arquivos

```text
/etc/vsftpd.conf
/home/ftpuser/
/home/ftpuser/ftp/
```

---

# Observações

- O diretório `/home/ftpuser` **não deve possuir permissão de escrita** quando `chroot_local_user=YES` estiver habilitado, caso contrário o VSFTPD recusará o login.
- Crie um subdiretório (como `/home/ftpuser/ftp`) para que o usuário possa enviar e remover arquivos.
- Em ambientes com NAT, configure também as portas do modo passivo (`pasv_min_port` e `pasv_max_port`) no `vsftpd.conf`.
- Para maior segurança, permita acesso apenas à rede interna e mantenha o firewall habilitado.
- Em produção, considere utilizar **FTPS (FTP sobre TLS)** para proteger a autenticação e a transferência de arquivos.