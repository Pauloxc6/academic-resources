# Servidor TFTP (Trivial File Transfer Protocol)

Este guia apresenta a instalação e configuração de um **Servidor TFTP** utilizando o **tftpd-hpa**, muito utilizado para **boot PXE**, transferência de arquivos de configuração para equipamentos de rede, switches, roteadores e dispositivos embarcados.

> **Observação:** O TFTP **não possui autenticação nem criptografia**. Utilize-o apenas em redes internas e ambientes controlados.

---

# Topologia

```text
                  Rede Local

        +-----------------------------+
        |       TFTP Server           |
        |    192.168.122.100          |
        |      /srv/tftp              |
        +--------------+--------------+
                       │
                  UDP Porta 69
                       │
      ┌────────────────┼────────────────┐
      │                │                │
+-------------+ +-------------+ +--------------+
| Computador  | | Roteador    | | PXE Client   |
+-------------+ +-------------+ +--------------+
```

---

# Instalação

## Debian / Ubuntu

```bash
sudo apt update
sudo apt install tftpd-hpa -y
```

## Fedora / Rocky / AlmaLinux

```bash
sudo dnf install tftp-server tftp -y
```

---

# Criando o Diretório de Compartilhamento

```bash
sudo mkdir -p /srv/tftp
```

Defina as permissões:

```bash
sudo chown -R nobody:nogroup /srv/tftp
sudo chmod -R 755 /srv/tftp
```

---

# Configurando o Servidor

Edite o arquivo:

```bash
sudo nano /etc/default/tftpd-hpa
```

Configure:

```conf
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```

### Explicação

| Opção | Descrição |
|--------|-----------|
| TFTP_USERNAME | Usuário que executará o serviço |
| TFTP_DIRECTORY | Diretório compartilhado |
| TFTP_ADDRESS | Endereço e porta do serviço |
| --secure | Restringe o acesso ao diretório configurado |

---

# Reiniciando o Serviço

```bash
sudo systemctl restart tftpd-hpa
```

Habilite na inicialização:

```bash
sudo systemctl enable tftpd-hpa
```

Verifique o status:

```bash
sudo systemctl status tftpd-hpa
```

---

# Firewall

### UFW

```bash
sudo ufw allow 69/udp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-port=69/udp
sudo firewall-cmd --reload
```

---

# Testando o Servidor

Crie um arquivo:

```bash
echo "Servidor TFTP" | sudo tee /srv/tftp/teste.txt
```

Instale o cliente:

```bash
sudo apt install tftp -y
```

Conecte-se:

```bash
tftp 192.168.122.100
```

No prompt do TFTP:

```text
tftp> get teste.txt
tftp> put arquivo.txt
tftp> quit
```

---

# Permitir Upload (Opcional)

Por padrão, o upload é desabilitado.

Edite:

```bash
sudo nano /etc/default/tftpd-hpa
```

Altere:

```conf
TFTP_OPTIONS="--secure --create"
```

Reinicie:

```bash
sudo systemctl restart tftpd-hpa
```

---

# Verificando a Porta

```bash
ss -lun | grep 69
```

---

# Estrutura do Diretório

```text
/srv/tftp
├── teste.txt
├── pxelinux.0
├── boot/
└── images/
```

---

# Comandos Úteis

Iniciar:

```bash
sudo systemctl start tftpd-hpa
```

Parar:

```bash
sudo systemctl stop tftpd-hpa
```

Reiniciar:

```bash
sudo systemctl restart tftpd-hpa
```

Status:

```bash
sudo systemctl status tftpd-hpa
```

Habilitar na inicialização:

```bash
sudo systemctl enable tftpd-hpa
```

---

# Logs

Visualizar logs:

```bash
sudo journalctl -u tftpd-hpa
```

Monitorar em tempo real:

servidor-tftp```bash
sudo journalctl -fu tftpd-hpa
```

---

# Arquivos Importantes

```text
/etc/default/tftpd-hpa
/srv/tftp/
```

---

# Observações

- O TFTP utiliza **UDP porta 69** e não oferece autenticação ou criptografia.
- É amplamente utilizado para **boot PXE**, atualização de firmware e backup/restauração de configurações de roteadores, switches e outros equipamentos de rede.
- Utilize o parâmetro `--secure` para restringir o acesso apenas ao diretório configurado.
- Caso seja necessário permitir uploads, utilize a opção `--create` e ajuste cuidadosamente as permissões do diretório.
- Evite expor um servidor TFTP diretamente à Internet; utilize-o apenas em redes confiáveis ou isoladas.