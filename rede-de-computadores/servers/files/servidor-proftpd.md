# Servidor ProFTPD com TLS (FTPS)

Este guia apresenta a instalação e configuração do **ProFTPD** com suporte a **TLS (FTPS)**, permitindo conexões FTP criptografadas utilizando certificados SSL/TLS.

> **Observação:** FTPS (FTP sobre TLS) é diferente de SFTP (SSH File Transfer Protocol). Este guia utiliza **ProFTPD + TLS (FTPS)**.

---

# Topologia

```text
                 Clientes FTPS
                       │
                Porta TCP 21
                (TLS/SSL)
                       │
              +------------------+
              |  ProFTPD Server  |
              | 192.168.x.x      |
              +------------------+
```

---

# Instalação

Atualize o sistema:

```bash
sudo apt update
sudo apt upgrade -y
```

Instale o ProFTPD e os módulos TLS:

```bash
sudo apt install openssl proftpd proftpd-mod-crypto -y
```

Verifique o serviço:

```bash
sudo systemctl status proftpd
```

---

# Gerando o Certificado TLS

## Gerar a chave privada

```bash
sudo openssl genrsa -out /etc/proftpd/proftpd.key 2048
```

---

## Criar o certificado autoassinado

```bash
sudo openssl req -x509 \
-key /etc/proftpd/proftpd.key \
-out /etc/proftpd/proftpd.crt \
-days 365
```

Durante a criação serão solicitadas informações como:

- Country
- State
- Organization
- Common Name (hostname)

---

## Ajustar permissões

```bash
sudo chmod 600 /etc/proftpd/proftpd.key
sudo chmod 600 /etc/proftpd/proftpd.crt
```

---

# Configuração do ProFTPD

Os arquivos de configuração encontram-se em:

```text
/etc/proftpd/
```

---

## Arquivo principal

Edite:

```bash
sudo nano /etc/proftpd/proftpd.conf
```

Adicione ou altere:

```conf
UseIPv6             on
ServerName          "FTP Server"
Port                21
AuthOrder mod_auth_pam.c* mod_auth_unix.c
Include /etc/proftpd/tls.conf
```

---

## Configuração TLS

Edite:

```bash
sudo nano /etc/proftpd/tls.conf
```

Conteúdo:

```conf
<IfModule mod_tls.c>

    TLSEngine On
    
    TLSRSACertificateFile /etc/proftpd/proftpd.crt
    TLSRSACertificateKeyFile /etc/proftpd/proftpd.key
    TLSLog /var/log/proftpd/tls.log

    TLSProtocol SSLv23

    TLSRequired On

</IfModule>
```

---

## Habilitando o módulo TLS

Edite:

```bash
sudo nano /etc/proftpd/modules.conf
```

Certifique-se de que a linha abaixo esteja habilitada:

```conf
LoadModule mod_tls.c
```

---

# Reiniciando o Serviço

Habilite o serviço:

```bash
sudo systemctl enable --now proftpd.service
```

Reinicie:

```bash
sudo systemctl restart proftpd.service
```

Verifique o status:

```bash
sudo systemctl status proftpd.service
```

---

# Criando um Usuário FTP (Opcional)

Criar o grupo:

```bash
sudo addgroup ftpusers
```

Criar o diretório principal:

```bash
sudo mkdir -p /srv/ftp
```

Criar o usuário:

```bash
sudo useradd \
-M \
-d /srv/ftp \
-s /usr/sbin/nologin \
-G ftpusers \
user
```

Definir senha:

```bash
sudo passwd user
```

Criar o diretório pessoal:

```bash
sudo mkdir /srv/ftp/user
```

Definir permissões:

```bash
sudo chown -R user:ftpusers /srv/ftp/user
sudo chmod -R 700 /srv/ftp/user
```

---

# Firewall

Caso utilize UFW:

```bash
sudo ufw allow 21/tcp
```

Caso utilize modo passivo, libere também a faixa de portas configurada.

Exemplo:

```bash
sudo ufw allow 50000:51000/tcp
```

---

# Testes

Conectando com o cliente FTP:

```bash
lftp -u user ftp://IP_DO_SERVIDOR
```

Ou utilizando o FileZilla:

- Host: `ftps://IP_DO_SERVIDOR`
- Porta: `21`
- Criptografia: **Require explicit FTP over TLS**
- Usuário
- Senha

Verifique se o certificado é apresentado durante a conexão.

---

# Logs

Logs gerais:

```bash
sudo journalctl -u proftpd
```

Logs TLS:

```bash
sudo cat /var/log/proftpd/tls.log
```

Monitoramento em tempo real:

```bash
sudo tail -f /var/log/proftpd/tls.log
```

---

# Comandos Úteis

Iniciar:

```bash
sudo systemctl start proftpd
```

Parar:

```bash
sudo systemctl stop proftpd
```

Reiniciar:

```bash
sudo systemctl restart proftpd
```

Status:

```bash
sudo systemctl status proftpd
```

Habilitar inicialização automática:

```bash
sudo systemctl enable proftpd
```

---

# Arquivos Importantes

```text
/etc/proftpd/proftpd.conf
/etc/proftpd/tls.conf
/etc/proftpd/modules.conf

/etc/proftpd/proftpd.crt
/etc/proftpd/proftpd.key

/var/log/proftpd/tls.log
```

---

# Observações

- O certificado criado neste guia é **autoassinado**, sendo adequado para testes e laboratórios. Em produção, utilize um certificado emitido por uma Autoridade Certificadora (CA), como o Let's Encrypt.
- O protocolo `SSLv23` na configuração do ProFTPD permite negociar versões mais recentes do TLS. Em ambientes modernos, considere restringir a protocolos TLS seguros, desabilitando versões antigas.
- O usuário FTP foi configurado com `/usr/sbin/nologin`, impedindo acesso ao shell do sistema.
- Para conexões em modo passivo (PASV), configure uma faixa de portas no `proftpd.conf` e libere essas portas no firewall.
- O FileZilla e outros clientes FTPS podem exibir um aviso sobre o certificado autoassinado na primeira conexão; isso é esperado em ambientes de teste.