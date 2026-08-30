# Rede Básica com DMZ

## 1. Objetivo

Configurar uma rede básica utilizando um servidor Linux como **Gateway**, realizando roteamento, NAT e encaminhamento de conexões para um servidor Web localizado em uma **DMZ**.

### Componentes

* **Gateway**

  * Linux: Debian / Ubuntu / OpenSUSE
  * `net-tools`
  * `iptables`
  * `netfilter-persistent`

* **WebServer**

  * Linux: Debian / Ubuntu / OpenSUSE
  * `net-tools`
  * `iptables`
  * Apache2 ou Nginx

---

# 2. Topologia

```text
                       INTERNET
                           |
                        Gateway
                           |
                    +------+------+
                    |             |
                   MZ            DMZ
                    |             |
                 Cliente       WebServer
```

Detalhando:

```text
                         INTERNET
                            |
                         enp3s0
                            |
                     +------+------+
                     |   Gateway   |
                     |    Linux   |
                     +------+------+
                            |
                 +----------+----------+
                 |                     |
              enp9s0                enp8s0
                 |                     |
             MZ 10.2.2.0/24       DMZ 10.1.1.0/24
                 |                     |
             Cliente               WebServer
```

---

# 3. Endereçamento

## Gateway

| Interface | Função    | Configuração          |
| --------- | --------- | --------------------- |
| `enp3s0`  | Board/WAN | DHCP, PPPoE ou Static |
| `enp8s0`  | DMZ       | `10.1.1.1/24`         |
| `enp9s0`  | MZ        | `10.2.2.1/24`         |

## WebServer

| Interface | Função | Configuração  |
| --------- | ------ | ------------- |
| `enp8s0`  | DMZ    | `10.1.1.4/24` |

## Redes

```text
DMZ: 10.1.1.0/24

MZ:  10.2.2.0/24
```

---

# 4. Configuração de Rede — Gateway

Editar:

```bash
nano /etc/network/interfaces
```

## Board/WAN

Exemplo utilizando DHCP:

```ini
allow-hotplug enp3s0
iface enp3s0 inet dhcp
```

> Caso a conexão utilize PPPoE ou IP estático, a configuração deve ser adaptada ao ambiente.

## DMZ

```ini
auto enp8s0
iface enp8s0 inet static
    address 10.1.1.1/24
```

## MZ

```ini
auto enp9s0
iface enp9s0 inet static
    address 10.2.2.1/24
```

### Configuração completa

```ini
# Board
allow-hotplug enp3s0
iface enp3s0 inet dhcp

# DMZ
auto enp8s0
iface enp8s0 inet static
    address 10.1.1.1/24

# MZ
auto enp9s0
iface enp9s0 inet static
    address 10.2.2.1/24
```

### Ativar as interfaces

```bash
ifdown enp3s0
ifdown enp8s0
ifdown enp9s0

ifup enp3s0
ifup enp8s0
ifup enp9s0
```

Verificar:

```bash
ip addr
```

E:

```bash
ip route
```

---

# 5. Ativar o encaminhamento IPv4

O Gateway precisa encaminhar pacotes entre as interfaces.

Editar:

```bash
nano /etc/sysctl.conf
```

Adicionar:

```ini
net.ipv4.ip_forward=1
```

Aplicar:

```bash
sysctl -p
```

Verificar:

```bash
sysctl net.ipv4.ip_forward
```

Resultado esperado:

```text
net.ipv4.ip_forward = 1
```

---

# 6. Configuração do Firewall — Gateway

## Instalação

```bash
apt update
apt upgrade -y
apt install iptables netfilter-persistent -y
```

---

## 6.1 NAT

A regra abaixo realiza o **MASQUERADE** dos dispositivos das redes internas quando acessam a Internet através da interface `enp3s0`.

```bash
iptables -t nat -A POSTROUTING -o enp3s0 -j MASQUERADE
```

---

## 6.2 Permitir DMZ → Internet

```bash
iptables -A FORWARD -i enp8s0 -o enp3s0 -j ACCEPT
```

Essa regra permite que o tráfego originado na DMZ seja encaminhado para a Internet.

---

## 6.3 Permitir MZ → Internet

```bash
iptables -A FORWARD -i enp9s0 -o enp3s0 -j ACCEPT
```

Essa regra permite que os clientes da MZ acessem a Internet através do Gateway.

---

## 6.4 Permitir conexões relacionadas — DMZ

```bash
iptables -A FORWARD \
    -i enp3s0 \
    -o enp8s0 \
    -m state \
    --state RELATED,ESTABLISHED \
    -j ACCEPT
```

Essa regra permite o tráfego de retorno relacionado às conexões encaminhadas para a DMZ.

---

## 6.5 Permitir conexões relacionadas — MZ

```bash
iptables -A FORWARD \
    -i enp3s0 \
    -o enp9s0 \
    -m state \
    --state RELATED,ESTABLISHED \
    -j ACCEPT
```

Essa regra permite o tráfego de retorno relacionado às conexões encaminhadas para a MZ.

> **Observação:** `ESTABLISHED` significa que a conexão já está estabelecida, enquanto `RELATED` permite conexões relacionadas a uma conexão existente.

---

# 7. Redirecionamento HTTP para o WebServer

O WebServer está localizado na DMZ:

```text
10.1.1.4
```

Para encaminhar requisições HTTP recebidas na porta `80` do Gateway para o WebServer:

```bash
iptables -t nat -A PREROUTING \
    -p tcp \
    --dport 80 \
    -j DNAT \
    --to-destination 10.1.1.4:80
```

Fluxo:

```text
Internet
    |
    | TCP/80
    v
Gateway
    |
    | DNAT
    v
10.1.1.4:80
    |
    v
WebServer
```

---

# 8. Permitir HTTP para o WebServer

```bash
iptables -A FORWARD \
    -p tcp \
    -d 10.1.1.4 \
    --dport 80 \
    -j ACCEPT
```

Essa regra permite que o tráfego HTTP seja encaminhado para o WebServer.

---

# 9. Conferir as regras

Listar regras:

```bash
iptables -L -n -v
```

Listar regras da tabela NAT:

```bash
iptables -t nat -L -n -v
```

Mostrar as regras numeradas:

```bash
iptables -L -n -v --line-numbers
```

---

# 10. Salvar o Firewall

Depois de configurar as regras:

```bash
netfilter-persistent save
```

Também é possível salvar diretamente:

```bash
iptables-save > /etc/iptables/rules.v4
```

---

# 11. Apagar o Firewall

Para limpar as regras:

```bash
iptables -F
iptables -t nat -F
```

> Esses comandos removem as regras atuais das tabelas `filter` e `nat`.

---

# 12. Restaurar o Firewall

```bash
iptables-restore < /etc/iptables/rules.v4
```

Depois de restaurar, verifique:

```bash
iptables -L -n -v
```

---

# 13. Configuração do WebServer

## Configuração de rede

Editar:

```bash
nano /etc/network/interfaces
```

Configuração:

```ini
# DMZ
auto enp8s0
iface enp8s0 inet static
    address 10.1.1.4/24
    gateway 10.1.1.1
```

Neste caso, o Gateway da DMZ é:

```text
10.1.1.1
```

### Ativar a interface

```bash
ifdown enp8s0
ifup enp8s0
```

Verificar:

```bash
ip addr
```

E:

```bash
ip route
```

Testar comunicação com o Gateway:

```bash
ping 10.1.1.1
```

---

# 14. Instalação do Apache2

Atualizar o sistema:

```bash
apt update
apt upgrade -y
```

Instalar Apache:

```bash
apt install apache2 -y
```

Verificar o serviço:

```bash
systemctl status apache2
```

Caso necessário:

```bash
systemctl enable apache2
systemctl start apache2
```

Testar:

```bash
curl http://127.0.0.1
```

Ou:

```bash
curl http://10.1.1.4
```

---

# 15. Hardening básico do Apache2

## 15.1 Remover Directory Listing

Editar:

```bash
nano /etc/apache2/apache2.conf
```

Localizar:

```apache
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

Alterar para:

```apache
<Directory /var/www/>
    Options FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

A remoção de:

```text
Indexes
```

impede que o Apache apresente automaticamente a listagem dos arquivos de um diretório quando não existe uma página `index`.

---

# 16. Ocultar informações da versão do Apache

Editar:

```bash
nano /etc/apache2/conf-available/security.conf
```

Adicionar ou alterar:

```apache
ServerTokens Prod
ServerSignature Off
```

### ServerTokens

```apache
ServerTokens Prod
```

Reduz as informações da versão do servidor apresentadas nos headers HTTP.

### ServerSignature

```apache
ServerSignature Off
```

Remove informações do servidor das páginas de erro geradas pelo Apache.

---

# 17. Proteção do `.htaccess`

Editar:

```bash
nano /etc/apache2/apache2.conf
```

Configurar:

```apache
AccessFileName .htaccess

<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>
```

Essa configuração impede que arquivos como:

```text
.htaccess
.htpasswd
```

sejam acessados diretamente através do navegador.

---

# 18. Configuração do `.htaccess`

Criar/editar:

```bash
nano /var/www/html/.htaccess
```

Antes de utilizar regras de reescrita, habilitar o módulo:

```bash
a2enmod rewrite
```

Configuração:

```apache
RewriteEngine On

# Verifica se a requisição utiliza GET
RewriteCond %{REQUEST_METHOD} ^GET$

# Verifica se o arquivo não existe
RewriteCond %{REQUEST_FILENAME} !-f

# Verifica se o diretório não existe
RewriteCond %{REQUEST_FILENAME} !-d

# Redireciona para uma página específica
# RewriteRule ^ /erro.html [R=301,L]

RewriteRule ^ /erro.html

# Bloqueio por User-Agent
SetEnvIfNoCase User-Agent "Wfuzz" bad_user_agent
SetEnvIfNoCase User-Agent "gobuster" bad_user_agent
SetEnvIfNoCase User-Agent "DirBuster" bad_user_agent
SetEnvIfNoCase User-Agent "curl" bad_user_agent

<RequireAll>
    Require all granted
    Require not env bad_user_agent
</RequireAll>
```

---

# 19. Funcionamento do `.htaccess`

## RewriteEngine

```apache
RewriteEngine On
```

Ativa o mecanismo de reescrita do Apache.

## Verificar método HTTP

```apache
RewriteCond %{REQUEST_METHOD} ^GET$
```

Verifica se a requisição utiliza o método `GET`.

Também seria possível verificar múltiplos métodos:

```apache
RewriteCond %{REQUEST_METHOD} ^(GET|POST|HEAD)$
```

## Verificar arquivo

```apache
RewriteCond %{REQUEST_FILENAME} !-f
```

Verifica se o recurso solicitado **não é um arquivo existente**.

## Verificar diretório

```apache
RewriteCond %{REQUEST_FILENAME} !-d
```

Verifica se o recurso solicitado **não é um diretório existente**.

## Redirecionamento

```apache
RewriteRule ^ /erro.html
```

Redireciona a requisição para:

```text
/erro.html
```

Caso queira realizar um redirecionamento HTTP permanente:

```apache
RewriteRule ^ /erro.html [R=301,L]
```

---

# 20. Bloqueio por User-Agent

Podemos identificar determinados User-Agents:

```apache
SetEnvIfNoCase User-Agent "Wfuzz" bad_user_agent
SetEnvIfNoCase User-Agent "gobuster" bad_user_agent
SetEnvIfNoCase User-Agent "DirBuster" bad_user_agent
SetEnvIfNoCase User-Agent "curl" bad_user_agent
```

Depois:

```apache
<RequireAll>
    Require all granted
    Require not env bad_user_agent
</RequireAll>
```

O Apache permite as requisições normalmente, exceto aquelas que possuem a variável:

```text
bad_user_agent
```

---

# 21. Reiniciar o Apache

Após modificar as configurações:

```bash
apache2ctl configtest
```

O resultado esperado é:

```text
Syntax OK
```

Depois:

```bash
systemctl restart apache2
```

Verificar:

```bash
systemctl status apache2
```

---

# 22. Testes

## Testar o WebServer

No próprio WebServer:

```bash
curl http://10.1.1.4
```

No cliente da MZ:

```bash
curl http://10.1.1.4
```

---

## Testar o acesso externo

A partir de uma máquina externa à rede:

```bash
curl http://IP_PUBLICO
```

O fluxo esperado é:

```text
Cliente externo
      |
      | TCP/80
      v
   Gateway
      |
     DNAT
      |
      v
10.1.1.4:80
      |
      v
 Apache2
```

---

# 23. Verificação do Firewall

Visualizar regras:

```bash
iptables -L -n -v
```

Visualizar NAT:

```bash
iptables -t nat -L -n -v
```

Visualizar regras com números:

```bash
iptables -L -n -v --line-numbers
```

---

# 24. Monitoramento com tcpdump

Para observar o tráfego da DMZ:

```bash
tcpdump -i enp8s0
```

Para observar o tráfego da MZ:

```bash
tcpdump -i enp9s0
```

Para observar o tráfego da WAN:

```bash
tcpdump -i enp3s0
```

Para observar somente HTTP:

```bash
tcpdump -i enp3s0 tcp port 80
```

---

# 25. Resumo das regras do Firewall

As regras utilizadas no laboratório são:

```bash
# NAT
iptables -t nat -A POSTROUTING -o enp3s0 -j MASQUERADE

# DMZ -> Internet
iptables -A FORWARD -i enp8s0 -o enp3s0 -j ACCEPT

# MZ -> Internet
iptables -A FORWARD -i enp9s0 -o enp3s0 -j ACCEPT

# Internet -> DMZ - conexões relacionadas
iptables -A FORWARD \
    -i enp3s0 \
    -o enp8s0 \
    -m state \
    --state RELATED,ESTABLISHED \
    -j ACCEPT

# Internet -> MZ - conexões relacionadas
iptables -A FORWARD \
    -i enp3s0 \
    -o enp9s0 \
    -m state \
    --state RELATED,ESTABLISHED \
    -j ACCEPT

# DNAT HTTP
iptables -t nat -A PREROUTING \
    -p tcp \
    --dport 80 \
    -j DNAT \
    --to-destination 10.1.1.4:80

# Permitir HTTP para o WebServer
iptables -A FORWARD \
    -p tcp \
    -d 10.1.1.4 \
    --dport 80 \
    -j ACCEPT
```

---

# 26. Fluxo da rede

```text
                         INTERNET
                            |
                            |
                       +----+----+
                       | Gateway |
                       |  Linux  |
                       +----+----+
                            |
              +-------------+-------------+
              |                           |
             DMZ                         MZ
        10.1.1.0/24                 10.2.2.0/24
              |                           |
       10.1.1.4                         Cliente
              |
         WebServer
              |
           Apache2
              |
             :80
```

### Fluxos principais

```text
MZ
 |
 +------> Gateway ------> Internet
```

```text
DMZ
 |
 +------> Gateway ------> Internet
```

```text
Internet
 |
 +------> Gateway:80
              |
             DNAT
              |
              v
        WebServer:80
```

---

# 27. Conceitos abordados

* Redes IPv4
* Interfaces de rede Linux
* Gateway
* Roteamento
* DMZ
* MZ
* NAT
* DNAT
* `iptables`
* `netfilter-persistent`
* Apache2
* `.htaccess`
* `mod_rewrite`
* Headers HTTP
* User-Agent
* Hardening básico
* Monitoramento com `tcpdump`
* Testes utilizando `curl`
